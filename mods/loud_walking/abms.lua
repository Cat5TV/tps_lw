-------------------------------------------------------------------
-- Abms
-------------------------------------------------------------------

-- player surface damage and hunger
local dps_delay = 3

local last_dps_check = 0
local cold_delay = 5
local monster_delay = 3
local hunger_delay = 60
local dps_count = hunger_delay

local time_factor = (loud_walking.time_factor or 10)
local light_max = (loud_walking.light_max or 10)


------------------------------------------------------------
-- all the loud_walking globalstep functions
------------------------------------------------------------
local hot_stuff = {"group:surface_hot"}
local traps = {"group:trap"}
local cold_stuff = {"group:surface_cold"}
local poison_stuff = {"group:poison"}


local sparking = {}

minetest.register_globalstep(function(dtime)
	if not (dtime and type(dtime) == 'number') then
		return
	end

	if not (loud_walking.db.status and loud_walking.registered_status) then
		return
	end

	local time = minetest.get_gametime()
	if not (time and type(time) == 'number') then
		return
	end

	-- Trap check
	if last_dps_check and time - last_dps_check < 1 then
		return
	end

	local minetest_find_nodes_in_area = minetest.find_nodes_in_area
	local players = minetest.get_connected_players()
	if not (players and type(players) == 'table') then
		return
	end

	for i = 1, #players do
		local player = players[i]
		local pos = player:getpos()
		pos = vector.round(pos)
		local player_name = player:get_player_name()

		local minp = vector.subtract(pos, 2)
		local maxp = vector.add(pos, 2)
		local counts = minetest_find_nodes_in_area(minp, maxp, traps)
		if counts and type(counts) == 'table' and #counts > 0 then
			for _, tpos in ipairs(counts) do
				local node = minetest.get_node_or_nil(tpos)
				if not node then
					return
				end
				if node.name == 'loud_walking:stone_with_coal_trap' then
					minetest.set_node(tpos, {name="fire:basic_flame"})

					local hp = player:get_hp()
					if hp > 0 then
						player:set_hp(hp - 1)
					end
				elseif node.name == 'loud_walking:stone_with_diamond_trap' then
					loud_walking.diamond_trap(tpos, player)
				elseif node.name == 'loud_walking:stone_with_gold_trap' then
					loud_walking.gold_trap(tpos, player)
				elseif node.name == 'loud_walking:mossycobble_trap' then
					player:set_physics_override({speed = 0.1})
					minetest.after(1, function() -- this effect is temporary
						player:set_physics_override({speed = 1})  -- we'll just set it to 1 and be done.
					end)
				elseif node.name == 'loud_walking:ice_trap' then
					loud_walking.ice_trap(tpos, player)
				elseif node.name == 'loud_walking:stone_with_copper_trap' or node.name == 'loud_walking:stone_with_iron_trap' then
					if not sparking[player_name] then
						sparking[player_name] = true
						loud_walking.copper_trap(tpos, player)

						minetest.after(1, function()
							sparking[player_name] = nil
						end)
					end
				else
					minetest.remove_node(tpos)
				end
			end
		end

		-- Execute only after an interval.
		if last_dps_check and time - last_dps_check >= dps_delay then
			-- environmental damage
			local minp = vector.subtract(pos, 0.5)
			local maxp = vector.add(pos, 0.5)

			-- Remove status effects.
			local status = loud_walking.db.status[player_name]
			for status_name, status_param in pairs(status) do
				local def = loud_walking.registered_status[status_name]
				if not def then
					print('Loud Walking: Error - unregistered status ' .. status_name)
					break
				end

				local remove
				if type(status_param.remove) == 'number' then
					if status_param.remove < time then
						remove = true
					end
				elseif def.remove then
					remove = def.remove(player)
				else
					print('Loud Walking: Error in status remove for ' .. status_name)
				end

				if remove then
					loud_walking.remove_status(player_name, status_name)
				elseif def.during then
					def.during(player)
				end
			end

			if loud_walking.db.status[player_name]['breathe'] then
				player:set_breath(11)
			end

			-- ... from standing on or near hot objects.
			local counts =  minetest_find_nodes_in_area(minp, maxp, hot_stuff)
			if not (counts and type(counts) == 'table') then
				return
			end

			if #counts > 1 then
				player:set_hp(player:get_hp() - 1)
			end

			-- ... from standing on or near poison.
			local counts =  minetest_find_nodes_in_area(minp, maxp, poison_stuff)
			if not (counts and type(counts) == 'table') then
				return
			end

			if #counts > 1 then
				player:set_hp(player:get_hp() - 1)
			end

			-- ... from standing on or near cold objects (less often).
			if dps_count % cold_delay == 0 then
				counts =  minetest_find_nodes_in_area(minp, maxp, cold_stuff)
				if not (counts and type(counts) == 'table') then
					return
				end

				if #counts > 1 then
					player:set_hp(player:get_hp() - 1)
				end
			end

			-- ... from hunger (even less often).
			if dps_count % hunger_delay == 0 and loud_walking.hunger_change then
				loud_walking.hunger_change(player, -1)
			end
		end
	end

	-- Execute only after an interval.
	if last_dps_check and time - last_dps_check < dps_delay then
		return
	end

	local out = io.open(loud_walking.world..'/loud_walking_data.txt','w')	
	if out then
		out:write(minetest.serialize(loud_walking.db))
		out:close()
	end

	-- Promote mobs based on spawn position
	for _, mob in pairs(minetest.luaentities) do
		if not mob.initial_promotion then
			local pos = mob.object:getpos()
			if mob.hp_max and mob.object and mob.health and mob.damage then
				local factor = 1 + (math.max(math.abs(pos.x), math.abs(pos.y), math.abs(pos.z)) / 2000)
				mob.hp_max = math.floor(mob.hp_max * factor)
				mob.damage = math.floor(mob.damage * factor)
				mob.health = math.floor(mob.health * factor)
				mob.object:set_hp(mob.health)
				mob.initial_promotion = true
				check_for_death(mob)

				--local name = mob.object:get_entity_name() or ''
				--print('Promoting '..name..': '..mob.health..' health, '..mob.damage..' damage')
			end
		end
	end

	-- Set this outside of the player loop, to affect everyone.
	if dps_count % hunger_delay == 0 then
		dps_count = hunger_delay
	end

	last_dps_check = minetest.get_gametime()
	if not (last_dps_check and type(last_dps_check) == 'number') then
		last_dps_check = 0
	end
	dps_count = dps_count - 1
end)


------------------------------------------------------------
-- abms
------------------------------------------------------------

minetest.register_abm({
	nodenames = {"loud_walking:flare",},
	interval = 5,
	chance = 10,
	action = function(pos, node)
		if not (pos and node) then
			return
		end

		minetest.remove_node(pos)
	end,
})

minetest.register_abm({
	nodenames = {"fire:basic_flame"},
	interval = 2 * time_factor,
	chance = 50,
	action = function(p0, node, _, _)
		minetest.remove_node(p0)
	end,
})
