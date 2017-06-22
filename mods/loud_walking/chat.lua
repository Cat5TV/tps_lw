--minetest.register_chatcommand("armor", {
--	params = "",
--	description = "Display your armor values",
--	privs = {},
--	func = function(player_name, param)
--		if not (player_name and type(player_name) == 'string' and player_name ~= '' and fun_caves.db.status) then
--			return
--		end
--
--		local player = minetest.get_player_by_name(player_name)
--		if not player then
--			return
--		end
--
--		local armor = player:get_armor_groups()
--		if armor then
--			minetest.chat_send_player(player_name, "Armor:")
--			for group, value in pairs(armor) do
--				minetest.chat_send_player(player_name, "  "..group.." "..value)
--			end
--
--			if fun_caves.db.status[player_name].armor_elixir then
--				local armor_time = fun_caves.db.status[player_name].armor_elixir.remove
--				local game_time = minetest.get_gametime()
--				if not (armor_time and type(armor_time) == 'number' and game_time and type(game_time) == 'number') then
--					return
--				end
--
--				local min = math.floor(math.max(0, armor_time - game_time) / 60)
--				minetest.chat_send_player(player_name, "Your armor elixir will expire in "..min..' minutes.')
--			end
--		end
--	end,
--})


--minetest.register_chatcommand("setspawn", {
--	params = "",
--	description = "change your spawn position",
--	privs = {},
--	func = function(player_name, param)
--		if not (player_name and type(player_name) == 'string' and player_name ~= '') then
--			return
--		end
--
--		local player = minetest.get_player_by_name(player_name)
--		if not player then
--			return
--		end
--
--		local pos = player:getpos()
--		beds.spawn[player_name] = pos
--		minetest.chat_send_player(player_name, 'Your spawn position has been changed.')
--	end,
--})


minetest.register_chatcommand("fixlight", {
	params = "<radius>",
	description = "attempt to fix light bugs",
	privs = {},
	func = function(player_name, param)
		if not (player_name and type(player_name) == 'string' and player_name ~= '') then
			return
		end

		local privs = minetest.check_player_privs(player_name, {server=true})
		if not privs then
			return
		end

		print('Loud Walking: '..player_name..' used the fixlight command')
		local player = minetest.get_player_by_name(player_name)
		if not player then
			return
		end

		local pos = player:getpos()
		if not pos then
			return
		end
		pos = vector.round(pos)

		local radius = tonumber(param) or 50
		radius = math.floor(radius)
		local minp = vector.subtract(pos, radius)
		local maxp = vector.add(pos, radius)

		local vm = minetest.get_voxel_manip(minp, maxp)
		if not vm then
			return
		end

		--vm:set_lighting({day = 0, night = 0}, minp, maxp)
		vm:calc_lighting(minp, maxp, false)
		vm:update_liquids()
		vm:write_to_map()
		vm:update_map()
	end,
})


--minetest.register_chatcommand("sleep", {
--	params = "",
--	description = "Sleep on the ground",
--	privs = {},
--	func = function(player_name, param)
--		local player = minetest.get_player_by_name(player_name)
--		if not (player and beds) then
--			return
--		end
--
--		if (beds.player and beds.player[player_name]) then
--			minetest.chat_send_player(player_name, 'You can\'t sleep.')
--			return
--		end
--
--		local pos = player:getpos()
--		if not pos then
--			return
--		end
--		pos = vector.round(pos)
--
--		local status, err = pcall(beds.on_rightclick, pos, player)
--
--		if status then
--			minetest.after(5, function()
--				local time = minetest.get_timeofday()
--				if not time or time < 0.23 or time > 0.3 then
--					return
--				end
--
--				local hp = player:get_hp()
--				if hp and type(hp) == 'number' then
--					player:set_hp(hp - 1)
--				end
--
--				minetest.chat_send_player(player_name, 'You\'d sleep better in a bed.')
--			end)
--		end
--	end,
--})
