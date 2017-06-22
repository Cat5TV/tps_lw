loud_walking = {}
loud_walking.version = "1.0"
loud_walking.time_factor = 10  -- affects growth abms
loud_walking.light_max = 8  -- light intensity for mushroom growth
loud_walking.path = minetest.get_modpath(minetest.get_current_modname())
loud_walking.world = minetest.get_worldpath()

loud_walking.pod_size_x = minetest.setting_get('loud_walking_pod_size_x')
if loud_walking.pod_size_x == nil then
	loud_walking.pod_size_x = 100
end

loud_walking.pod_size_y = minetest.setting_get('loud_walking_pod_size_y')
if loud_walking.pod_size_y == nil then
	loud_walking.pod_size_y = 100
end

loud_walking.pod_size_z = minetest.setting_get('loud_walking_pod_size_z')
if loud_walking.pod_size_z == nil then
	loud_walking.pod_size_z = 100
end

loud_walking.bridge_size = minetest.setting_get('loud_walking_bridge_size')
if loud_walking.bridge_size == nil then
	loud_walking.bridge_size = 50
end

loud_walking.vertical_sep = minetest.setting_get('loud_walking_vertical_sep')
if loud_walking.vertical_sep == nil then
	loud_walking.vertical_sep = 300
end

loud_walking.breakable_wood = minetest.setting_getbool('loud_walking_breakable_wood')
if loud_walking.breakable_wood == nil then
	loud_walking.breakable_wood = false
end

local armor_mod = minetest.get_modpath("3d_armor") and armor and armor.set_player_armor

loud_walking.elixir_armor = minetest.setting_getbool('loud_walking_use_armor_elixirs')
if loud_walking.elixir_armor == nil then
	loud_walking.elixir_armor = true
end

loud_walking.expire_elixir_on_death = minetest.setting_getbool('loud_walking_expire_elixir_on_death')
if loud_walking.expire_elixir_on_death == nil then
	loud_walking.expire_elixir_on_death = true
end

loud_walking.breakable_wood = minetest.setting_getbool('loud_walking_breakable_wood')
if loud_walking.breakable_wood == nil then
	loud_walking.breakable_wood = false
end

loud_walking.starting_equipment = minetest.setting_getbool('loud_walking_starting_equipment')
if loud_walking.starting_equipment == nil then
	loud_walking.starting_equipment = false
end

loud_walking.quick_leaf_decay = minetest.setting_getbool('loud_walking_quick_leaf_decay')
if loud_walking.quick_leaf_decay == nil then
	loud_walking.quick_leaf_decay = false
end

loud_walking.goblin_rarity = minetest.setting_get('loud_walking_goblin_rarity')
if loud_walking.goblin_rarity == nil then
	loud_walking.goblin_rarity = 9
end
loud_walking.goblin_rarity = 11 - loud_walking.goblin_rarity
print(loud_walking.goblin_rarity)

loud_walking.DEBUG = false  -- for maintenance only


local inp = io.open(loud_walking.world..'/loud_walking_data.txt','r')
if inp then
	local d = inp:read('*a')
	loud_walking.db = minetest.deserialize(d)
	inp:close()
end
if not loud_walking.db then
	loud_walking.db = {}
end
for _, i in pairs({'teleport_data', 'hunger', 'status', 'translocators'}) do
	if not loud_walking.db[i] then
		loud_walking.db[i] = {}
	end
end


if not minetest.set_mapgen_setting then
	return
end

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode", water_level=-31000, flags="nolight"})
end)


-- Modify a node to add a group
function minetest.add_group(node, groups)
	local def = minetest.registered_items[node]
	if not (node and def and groups and type(groups) == 'table') then
		return false
	end
	local def_groups = def.groups or {}
	for group, value in pairs(groups) do
		if value ~= 0 then
			def_groups[group] = value
		else
			def_groups[group] = nil
		end
	end
	minetest.override_item(node, {groups = def_groups})
	return true
end

function loud_walking.clone_node(name)
	if not (name and type(name) == 'string') then
		return
	end

	local node = minetest.registered_nodes[name]
	local node2 = table.copy(node)
	return node2
end


loud_walking.registered_status = {}
function loud_walking.register_status(def)
	if not (def and loud_walking.registered_status and type(def) == 'table') then
		return
	end

	loud_walking.registered_status[def.name] = {
		remove = def.remove,
		start = def.start,
		during = def.during,
		terminate = def.terminate,
	}
end

function loud_walking.set_status(player_name, status, time, param)
	if not (player_name and type(player_name) == 'string' and status and type(status) == 'string') and loud_walking.db and loud_walking.db.status and loud_walking.db.status[player_name] then
		return
	end

	local player = minetest.get_player_by_name(player_name)
	local def = loud_walking.registered_status[status]
	if not (def and player) then
		return
	end

	if not param then
		param = {}
	end

	if time then
		param.remove = (minetest.get_gametime() or 0) + time
	end

	loud_walking.db.status[player_name][status] = param
	if def.start then
		def.start(player)
	end
end

function loud_walking.remove_status(player_name, status)
	if not (player_name and type(player_name) == 'string' and status and type(status) == 'string') and loud_walking.db and loud_walking.db.status and loud_walking.db.status[player_name] then
		return
	end

	local player = minetest.get_player_by_name(player_name)
	local def = loud_walking.registered_status[status]
	if player and def then
		if def.terminate then
			loud_walking.db.status[player_name][status] = def.terminate(player)
		else
			loud_walking.db.status[player_name][status] = nil
		end
	end
end


--dofile(loud_walking.path .. "/recipe_list.lua")

dofile(loud_walking.path .. "/chat.lua")
dofile(loud_walking.path .. "/nodes.lua")
dofile(loud_walking.path .. "/deco.lua")
dofile(loud_walking.path .. "/deco_caves.lua")
--dofile(loud_walking.path .. "/schematics.lua")
--dofile(loud_walking.path .. "/wallhammer.lua")
dofile(loud_walking.path .. "/mapgen.lua")
dofile(loud_walking.path .. "/wooden_buckets.lua")
dofile(loud_walking.path .. "/tools.lua")
--dofile(loud_walking.path .. "/molotov.lua")
--dofile(loud_walking.path .. "/elixir.lua")
--dofile(loud_walking.path .. "/chat.lua")

if minetest.get_modpath("mobs") and mobs and mobs.mod == "redo" then
	dofile(loud_walking.path .. "/mobs.lua")
end

dofile(loud_walking.path .. "/abms.lua")

--loud_walking.print_recipes()


-- Attempt to save data at shutdown (as well as periodically).
minetest.register_on_shutdown(function()
	local out = io.open(loud_walking.world..'/loud_walking_data.txt','w')	
	if out then
		print('Squaresville: Saving database at shutdown')
		out:write(minetest.serialize(loud_walking.db))
		out:close()
	end
end)


local hunger_mod = minetest.get_modpath("hunger")
loud_walking.hunger_id = {}

function loud_walking.hunger_change(player, change)
	if not (player and change and type(change) == 'number') then
		return
	end

	local player_name = player:get_player_name()
	if hunger_mod then
		if change < 0 and hunger and hunger.update_hunger and hunger.players then
			hunger.update_hunger(player, hunger.players[player_name].lvl + change * 4)
		end
		return
	end

	if not (loud_walking.db.hunger and loud_walking.hunger_id) then
		return
	end

	local hp = player:get_hp()
	if not (hp and type(hp) == 'number') then
		return
	end

	if change < 0 or hp >= 16 then
		loud_walking.db.hunger[player_name] = math.min(20, math.max(0, loud_walking.db.hunger[player_name] + change))
		player:hud_change(loud_walking.hunger_id[player_name], 'number', loud_walking.db.hunger[player_name])
		if loud_walking.db.hunger[player_name] == 0 then
			player:set_hp(hp - 1)
		end
	end
end

local hunger_hud
if not hunger_mod then
	hunger_hud = function(player)
		if not (player and loud_walking.db.hunger and loud_walking.hunger_id) then
			return
		end

		local player_name = player:get_player_name()

		if not loud_walking.db.hunger[player_name] then
			loud_walking.db.hunger[player_name] = 20
		end

		local hunger_bar = {
			hud_elem_type = 'statbar',
			position = {x=0.52, y=1},
			offset = {x = 0, y = -90},
			name = "hunger",
			text = "farming_bread.png",
			number = loud_walking.db.hunger[player_name],
			direction = 0,
			size = { x=24, y=24 },
		}

		loud_walking.hunger_id[player_name] = player:hud_add(hunger_bar)
	end

	minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
		if not (hp_change and type(hp_change) == 'number') then
			return
		end

		if hp_change > 0 then
			loud_walking.hunger_change(user, hp_change)
		end
	end)
end

minetest.register_on_dieplayer(function(player)
	if loud_walking.db.status and not player then
		return
	end

	local player_name = player:get_player_name()
	if not (player_name and type(player_name) == 'string' and player_name ~= '') then
		return
	end

	if loud_walking.db.status[player_name] then
		for status in pairs(loud_walking.db.status[player_name]) do
			local def = loud_walking.registered_status[status]
			if not def.remain_after_death then
				loud_walking.remove_status(player_name, status)
			end
		end
	end

	if loud_walking.db.hunger and loud_walking.hunger_id and not hunger_mod then
		loud_walking.db.hunger[player_name] = 20
		player:hud_change(loud_walking.hunger_id[player_name], 'number', 20)
	end
end)

loud_walking.armor_id = {}
local armor_hud
if not armor_mod then
	armor_hud = function(player)
		if not (player and loud_walking.armor_id) then
			return
		end

		local player_name = player:get_player_name()
		if not player_name then
			return
		end

		local armor_icon = {
			hud_elem_type = 'image',
			name = "armor_icon",
			text = 'loud_walking_shield.png',
			scale = {x=1,y=1},
			position = {x=0.8, y=1},
			offset = {x = -30, y = -80},
		}

		local armor_text = {
			hud_elem_type = 'text',
			name = "armor_text",
			text = '0%',
			number = 0xFFFFFF,
			position = {x=0.8, y=1},
			offset = {x = 0, y = -80},
		}

		loud_walking.armor_id[player_name] = {}
		loud_walking.armor_id[player_name].icon = player:hud_add(armor_icon)
		loud_walking.armor_id[player_name].text = player:hud_add(armor_text)
	end

	loud_walking.display_armor = function(player)
		if not (player and loud_walking.armor_id) then
			return
		end

		local player_name = player:get_player_name()
		local armor = player:get_armor_groups()
		if not (player_name and armor and armor.fleshy) then
			return
		end

		player:hud_change(loud_walking.armor_id[player_name].text, 'text', (100 - armor.fleshy)..'%')
	end
end


if loud_walking.starting_equipment then
	minetest.register_on_newplayer(function(player)
		local inv = player:get_inventory()
		inv:add_item("main", 'default:sword_wood')
		inv:add_item("main", 'default:axe_wood')
		inv:add_item("main", 'default:pick_wood')
		inv:add_item("main", 'default:apple 10')
		inv:add_item("main", 'default:torch 10')
		if minetest.registered_items['unified_inventory:bag_small'] then
			inv:add_item("main", 'unified_inventory:bag_small')
		end
	end)
end


minetest.register_on_joinplayer(function(player)
	if not (player and loud_walking.db.status) then
		return
	end

	local player_name = player:get_player_name()

	if not (player_name and type(player_name) == 'string' and player_name ~= '') then
		return
	end

	if not loud_walking.db.status[player_name] then
		loud_walking.db.status[player_name] = {}
	end

	if armor_hud then
		armor_hud(player)
	end

	if hunger_hud then
		hunger_hud(player)
	end

	-- If there's an armor mod, we wait for it to load armor.
	if loud_walking.load_armor_elixir and not armor_mod then
		loud_walking.load_armor_elixir(player)
	end
end)

-- support for 3d_armor
-- This may or may not work with all versions.
if armor_mod then
	local old_set_player_armor = armor.set_player_armor

	armor.set_player_armor = function(self, player)
		old_set_player_armor(self, player)
		if loud_walking.load_armor_elixir then
			loud_walking.load_armor_elixir(player)
		end
	end
end


----------------------------------------------------------------------


if loud_walking.quick_leaf_decay then
	for name, node in pairs(minetest.registered_nodes) do
		if node.groups.leafdecay then
			node.groups.leafdecay = 0
			node.groups.qfc_leafdecay = 0
		end
	end
end


local breakable = {}
breakable['loud_walking:wood_rotten'] = true
breakable['loud_walking:glowing_fungal_wood'] = true
if not loud_walking.breakable_wood then
	print('* Loud Walking: Wood is NOT breakable by hand.')
	for _, item in pairs(minetest.registered_items) do
		if (item.groups.tree or item.groups.wood) and not breakable[item.name] then
			local groups = table.copy(item.groups)
			groups.oddly_breakable_by_hand = nil
			minetest.override_item(item.name, {groups=groups})
		end
	end
end

minetest.register_on_joinplayer(function(player)
	player:set_sky("#4070FF", "plain", {})
end)
