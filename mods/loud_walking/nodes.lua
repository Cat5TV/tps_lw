local get_node_or_nil = minetest.get_node_or_nil
local get_item_group = minetest.get_item_group
local light_max = 12
local max_depth = 31000


local newnode = loud_walking.clone_node("farming:straw")
newnode.description = 'Bundle of Grass'
newnode.tiles = {'farming_straw.png^[colorize:#00FF00:50'}
minetest.register_node("loud_walking:bundle_of_grass", newnode)

minetest.register_craft({
	output = 'loud_walking:bundle_of_grass',
	recipe = {
		{'default:grass_1', 'default:grass_1', 'default:grass_1'},
		{'default:grass_1', 'default:grass_1', 'default:grass_1'},
		{'default:grass_1', 'default:grass_1', 'default:grass_1'},
	}
})

minetest.register_craft({
	output = 'loud_walking:bundle_of_grass',
	type = 'shapeless',
	recipe = {
		'default:junglegrass', 'default:junglegrass',
		'default:junglegrass', 'default:junglegrass',
	}
})

newnode = loud_walking.clone_node("farming:straw")
newnode.description = "Dry Fiber"
minetest.register_node("loud_walking:dry_fiber", newnode)

minetest.register_craft({
	type = "cooking",
	output = "loud_walking:dry_fiber",
	recipe = 'loud_walking:bundle_of_grass',
	cooktime = 3,
})

local function rope_remove(pos)
	if not pos then
		return
	end

	for i = 1, 100 do
		local newpos = table.copy(pos)
		newpos.y = newpos.y - i
		local node = minetest.get_node_or_nil(newpos)
		if node and node.name and node.name == 'loud_walking:rope_ladder_piece' then
			minetest.set_node(newpos, {name='air'})
		else
			break
		end
	end
end

local good_params = {nil, true, true, true, true}
for length = 10, 50, 10 do
	minetest.register_node("loud_walking:rope_ladder_"..length, {
		description = "Rope Ladder ("..length.." meter)",
		drawtype = "signlike",
		tiles = {"loud_walking_rope_ladder.png"},
		inventory_image = "loud_walking_rope_ladder.png",
		wield_image = "loud_walking_rope_ladder.png",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		climbable = true,
		is_ground_content = false,
		selection_box = {
			type = "wallmounted",
		},
		groups = {snappy = 2, oddly_breakable_by_hand = 3, flammable = 2},
		legacy_wallmounted = true,
		sounds = default.node_sound_leaves_defaults(),
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			if not (pointed_thing and pointed_thing.above) then
				return
			end

			local pos_old = pointed_thing.above
			local orig = minetest.get_node_or_nil(pos_old)
			if orig and orig.name and orig.param2 and good_params[orig.param2] then
				for i = 1, length do
					local newpos = table.copy(pos_old)
					newpos.y = newpos.y - i
					local node = minetest.get_node_or_nil(newpos)
					if node and node.name and node.name == 'air' then
						minetest.set_node(newpos, {name='loud_walking:rope_ladder_piece', param2=orig.param2})
					else
						break
					end
				end
			end
		end,
		on_destruct = rope_remove,
	})

	if length > 10 then
		rec = {}
		for i = 10, length, 10 do
			rec[#rec+1] = 'loud_walking:rope_ladder_10'
		end
		minetest.register_craft({
			output = 'loud_walking:rope_ladder_'..length,
			type = 'shapeless',
			recipe = rec,
		})
	end
end

minetest.register_node("loud_walking:rope_ladder_piece", {
	description = "Rope Ladder",
	drawtype = "signlike",
	tiles = {"loud_walking_rope_ladder.png"},
	inventory_image = "loud_walking_rope_ladder.png",
	wield_image = "loud_walking_rope_ladder.png",
	drop = '',
	paramtype = "light",
	paramtype2 = "wallmounted",
	buildable_to = true,
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	groups = {snappy = 2, oddly_breakable_by_hand = 3, flammable = 2},
	legacy_wallmounted = true,
	sounds = default.node_sound_leaves_defaults(),
	on_destruct = rope_remove,
})

minetest.register_craft({
	output = 'loud_walking:rope_ladder_10',
	recipe = {
		{'loud_walking:dry_fiber', '', 'loud_walking:dry_fiber'},
		{'loud_walking:dry_fiber', 'loud_walking:dry_fiber', 'loud_walking:dry_fiber'},
		{'loud_walking:dry_fiber', '', 'loud_walking:dry_fiber'},
	}
})

minetest.register_craftitem("loud_walking:apple_pie_slice", {
	description = "Apple Pie Slice",
	inventory_image = "loud_walking_apple_pie_slice.png",
	on_use = minetest.item_eat(5),
})

minetest.register_craft({
	output = 'loud_walking:apple_pie_slice 6',
	type = 'shapeless',
	recipe = {
		'loud_walking:apple_pie',
	}
})

minetest.register_node("loud_walking:apple_pie", {
	description = "Apple Pie",
	drawtype = "raillike",
	tiles = {"loud_walking_apple_pie.png"},
	inventory_image  = "loud_walking_apple_pie.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.5, -0.4, 0.4}
	},
	groups = {dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_craftitem("loud_walking:apple_pie_uncooked", {
	description = "Uncooked Apple Pie",
	inventory_image = "loud_walking_apple_pie_uncooked.png",
})

if minetest.registered_items['mobs:bucket_milk'] then
	minetest.register_craft({
		output = 'loud_walking:apple_pie_uncooked',
		type = 'shapeless',
		recipe = {
			'default:apple',
			'default:apple',
			'farming:flour',
			'mobs:bucket_milk',
		},
		replacements = {
			{'mobs:bucket_milk', 'loud_walking:bucket_empty'},
		},
	})
end

if minetest.registered_items['mobs:honey'] then
	minetest.register_craft({
		output = 'loud_walking:apple_pie_uncooked',
		type = 'shapeless',
		recipe = {
			'default:apple',
			'default:apple',
			'farming:flour',
			'mobs:honey',
		},
	})
end

if minetest.registered_items['mobs:meat_raw'] then
	minetest.register_craft({
		output = 'loud_walking:meat_pie_uncooked',
		type = 'shapeless',
		recipe = {
			'loud_walking:barely_edible_meat',
			'loud_walking:barely_edible_meat',
			'loud_walking:onion',
			'loud_walking:onion',
			'farming:flour',
		},
	})

	minetest.register_craftitem("loud_walking:meat_pie_uncooked", {
		description = "Uncooked Meat Pie",
		inventory_image = "loud_walking_meat_pie_uncooked.png",
	})

	minetest.register_craft({
		output = 'loud_walking:meat_pie_uncooked',
		type = 'shapeless',
		recipe = {
			'mobs:meat_raw',
			'mobs:meat_raw',
			'loud_walking:onion',
			'farming:flour',
		},
	})

	minetest.register_craftitem("loud_walking:barely_edible_meat", {
		description = "Barely edible meat",
		inventory_image = "mobs_meat.png^[colorize:#000000:150",
		on_use = minetest.item_eat(1),
	})

	minetest.register_node("loud_walking:meat_pie", {
		description = "Meat Pie",
		drawtype = "raillike",
		tiles = {"loud_walking_meat_pie.png"},
		inventory_image  = "loud_walking_meat_pie.png",
		paramtype = "light",
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-0.4, -0.5, -0.4, 0.5, -0.4, 0.4}
		},
		groups = {dig_immediate = 3, attached_node = 1},
		sounds = default.node_sound_dirt_defaults(),
	})

	minetest.register_craft({
		type = "cooking",
		cooktime = 15,
		output = "loud_walking:meat_pie",
		recipe = "loud_walking:meat_pie_uncooked"
	})

	minetest.register_craftitem("loud_walking:meat_pie_slice", {
		description = "Meat Pie Slice",
		inventory_image = "loud_walking_meat_pie_slice.png",
		on_use = minetest.item_eat(9),
	})

	minetest.register_craft({
		output = 'loud_walking:meat_pie_slice 5',
		type = 'shapeless',
		recipe = {
			'loud_walking:meat_pie',
		}
	})
end

farming.register_plant("loud_walking:onion", {
	description = "Onion",
	inventory_image = "loud_walking_onion.png",
	steps = 3,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"}
})

minetest.registered_items['loud_walking:seed_onion'] = nil
minetest.registered_nodes['loud_walking:seed_onion'] = nil
minetest.registered_craftitems['loud_walking:seed_onion'] = nil
minetest.register_alias('loud_walking:seed_onion', 'loud_walking:onion')
for i = 1, 3 do
	local onion = minetest.registered_items['loud_walking:onion_'..i]
	if onion then
		onion.drop = {
			max_items = i,
			items = {
				{ items = {'loud_walking:onion'}, rarity = 4 - i, },
				{ items = {'loud_walking:onion'}, rarity = (4 - i) * 2, },
				{ items = {'loud_walking:onion'}, rarity = (4 - i) * 4, },
			},
		}
	end
end

minetest.register_node("loud_walking:onion", {
	description = "Onion",
	drawtype = "plantlike",
	visual_scale = 0.75,
	tiles = {"loud_walking_onion.png"},
	inventory_image = "loud_walking_onion.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	fertility = {'grassland'},
	groups = {seed = 1, fleshy = 3, dig_immediate = 3, flammable = 2},
	on_use = minetest.item_eat(2),
	sounds = default.node_sound_leaves_defaults(),
	next_plant = 'loud_walking:onion_1',
	on_timer = farming.grow_plant,
	minlight = 10,
	maxlight = 15,

	on_place = function(itemstack, placer, pointed_thing)
		local stack = farming.place_seed(itemstack, placer, pointed_thing, 'loud_walking:onion')
		if stack then
			return stack
		end

		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "loud_walking:apple_pie",
	recipe = "loud_walking:apple_pie_uncooked"
})


for i = 3, 5 do
	minetest.override_item("default:grass_" .. i, {
		drop = {
			max_items = 2,
			items = {
				{ items = { "default:grass_1"}, },
				{ items = {'farming:seed_wheat'},rarity = 5 },
				{ items = {"loud_walking:onion",}, rarity = 5 },
			},
		},
	})
end

minetest.register_craftitem("loud_walking:wooden_bowl", {
	description = "Wooden Bowl",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"loud_walking_wooden_bowl.png"},
	inventory_image = "loud_walking_wooden_bowl.png",
	groups = {bowl = 1, dig_immediate = 3},
})

minetest.register_craft({
	output = 'loud_walking:wooden_bowl 20',
	recipe = {
		{'group:wood', '', 'group:wood'},
		{'group:wood', '', 'group:wood'},
		{'', 'group:wood', ''},
	},
})

minetest.register_craft({
	output = 'default:diamondblock',
	recipe = {
		{'default:coalblock', 'default:coalblock', 'default:coalblock'},
		{'default:coalblock', 'default:mese_crystal_fragment', 'default:coalblock'},
		{'default:coalblock', 'default:coalblock', 'default:coalblock'},
	}
})

minetest.register_craft({
	output = 'default:mese_crystal 2',
	recipe = {
		{'default:diamond', 'default:diamond', 'default:diamond'},
		{'default:diamond', 'default:mese_crystal', 'default:diamond'},
		{'default:diamond', 'default:diamond', 'default:diamond'},
	}
})


minetest.register_craftitem("loud_walking:charcoal", {
	description = "Charcoal Briquette",
	inventory_image = "default_coal_lump.png",
	groups = {coal = 1}
})

minetest.register_craft({
	type = "fuel",
	recipe = "loud_walking:charcoal",
	burntime = 50,
})

minetest.register_craft({
	type = "cooking",
	output = "loud_walking:charcoal",
	recipe = "group:tree",
})

minetest.register_craft({
	output = 'default:torch 4',
	recipe = {
		{'group:coal'},
		{'group:stick'},
	}
})

minetest.register_craft({
	output = 'default:coalblock',
	recipe = {
		{'group:coal', 'group:coal', 'group:coal'},
		{'group:coal', 'group:coal', 'group:coal'},
		{'group:coal', 'group:coal', 'group:coal'},
	}
})

if minetest.get_modpath('tnt') then
	minetest.register_craft({
		output = "tnt:gunpowder",
		type = "shapeless",
		recipe = {"group:coal", "default:gravel"}
	})
end

minetest.register_craftitem("loud_walking:disgusting_gruel", {
	description = "Disgusting Gruel",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"loud_walking_disgusting_gruel.png"},
	inventory_image = "loud_walking_disgusting_gruel.png",
	on_use = minetest.item_eat(2),
	groups = {dig_immediate = 3},
})

minetest.register_craftitem("loud_walking:disgusting_gruel_raw", {
	description = "Bowl Of Gluey Paste",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"loud_walking_disgusting_gruel_raw.png"},
	inventory_image = "loud_walking_disgusting_gruel_raw.png",
	groups = {dig_immediate = 3},
})

minetest.register_craft({
	type = "cooking",
	output = "loud_walking:disgusting_gruel",
	recipe = 'loud_walking:disgusting_gruel_raw',
	cooktime = 2,
})

minetest.register_craft({
	output = "loud_walking:disgusting_gruel_raw",
	type = 'shapeless',
	recipe = {
		'loud_walking:dry_fiber',
		'group:water_bucket',
		'group:bowl',
	},
	replacements = {
		{'bucket:bucket_water', 'bucket:bucket_water'},
		{'bucket:bucket_river_water', 'bucket:bucket_river_water'},
		{'loud_walking:bucket_wood_water', 'loud_walking:bucket_wood_water'},
		{'loud_walking:bucket_wood_river_water', 'loud_walking:bucket_wood_river_water'},
	},
})

-- Glowing fungal stone provides an eerie light.
minetest.register_node("loud_walking:glowing_fungal_stone", {
	description = "Glowing Fungal Stone",
	tiles = {"default_stone.png^vmg_glowing_fungal.png",},
	is_ground_content = true,
	light_source = light_max - 4,
	groups = {cracky=3, stone=1},
	drop = {items={ {items={"default:cobble"},}, {items={"loud_walking:glowing_fungus",},},},},
	sounds = default.node_sound_stone_defaults(),
})

-- Glowing fungus grows underground.
minetest.register_craftitem("loud_walking:glowing_fungus", {
	description = "Glowing Fungus",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_glowing_fungus.png"},
	inventory_image = "vmg_glowing_fungus.png",
	groups = {dig_immediate = 3},
})

-- moon glass (glows)
newnode = loud_walking.clone_node("default:glass")
newnode.description = "Glowing Glass"
newnode.light_source = default.LIGHT_MAX
minetest.register_node("loud_walking:moon_glass", newnode)

-- Moon juice is extracted from glowing fungus, to make glowing materials.
minetest.register_craftitem("loud_walking:moon_juice", {
	description = "Moon Juice",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_moon_juice.png"},
	inventory_image = "vmg_moon_juice.png",
	--groups = {dig_immediate = 3, attached_node = 1},
	groups = {dig_immediate = 3, vessel = 1},
	sounds = default.node_sound_glass_defaults(),
})

-- moon juice from fungus
minetest.register_craft({
	output = "fun_caves:moon_juice",
	recipe = {
		{"fun_caves:glowing_fungus", "fun_caves:glowing_fungus", "fun_caves:glowing_fungus"},
		{"fun_caves:glowing_fungus", "fun_caves:glowing_fungus", "fun_caves:glowing_fungus"},
		{"fun_caves:glowing_fungus", "vessels:glass_bottle", "fun_caves:glowing_fungus"},
	},
})

minetest.register_craft({
	output = "fun_caves:moon_glass",
	type = "shapeless",
	recipe = {
		"fun_caves:moon_juice",
		"fun_caves:moon_juice",
		"default:glass",
	},
})


minetest.register_node("loud_walking:plate_glass", {
	description = "Plate Glass",
	drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"loud_walking_plate_glass.png"},
	light_source = 8,
	use_texture_alpha = true,
	is_ground_content = false,
	groups = {cracky = 3, level=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("loud_walking:scrith", {
	description = "Scrith",
	paramtype = "light",
	tiles = {"default_obsidian.png"},
	use_texture_alpha = true,
	is_ground_content = false,
	groups = {},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("loud_walking:sky_scrith", {
	description = "Transparent Scrith",
	drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"loud_walking_sky_glass.png"},
	light_source = 1,
	use_texture_alpha = true,
	is_ground_content = false,
	groups = {},
	sounds = default.node_sound_stone_defaults(),
})
local node = loud_walking.clone_node("loud_walking:sky_scrith")
node.tiles = {"loud_walking_cloud_glass.png"}
minetest.register_node("loud_walking:cloud_scrith", node)
node = loud_walking.clone_node("loud_walking:sky_scrith")
node.tiles = {"loud_walking_glass_detail.png"}
minetest.register_node("loud_walking:transparent_scrith", node)

node = loud_walking.clone_node("air")
node.light_source = minetest.LIGHT_MAX
minetest.register_node("loud_walking:light_air", node)

minetest.register_node("loud_walking:control_floor", {
	description = "Floor",
	paramtype = "light",
	tiles = {"loud_walking_control_floor.png"},
	light_source = minetest.LIGHT_MAX,
	use_texture_alpha = true,
	is_ground_content = false,
	groups = {},
	sounds = default.node_sound_stone_defaults(),
})
node = loud_walking.clone_node("loud_walking:control_floor")
node.tiles = { "loud_walking_control_floor.png", "loud_walking_control_floor_alert.png", "loud_walking_control_floor.png"}
minetest.register_node("loud_walking:control_floor_alert_down", node)
node = loud_walking.clone_node("loud_walking:control_floor")
node.tiles = {"loud_walking_control_floor_alert.png", "loud_walking_control_floor.png", "loud_walking_control_floor.png"}
minetest.register_node("loud_walking:control_floor_alert_up", node)
node.tiles = {"loud_walking_control_floor_alert.png", "loud_walking_control_floor_alert.png", "loud_walking_control_floor.png"}
minetest.register_node("loud_walking:control_floor_alert_both", node)
node.tiles = {"loud_walking_strange_growth.png", "loud_walking_control_floor.png", "loud_walking_control_floor.png"}
minetest.register_node("loud_walking:control_floor_growth", node)

minetest.register_node("loud_walking:control_wall", {
	description = "Wall",
	paramtype = "light",
	tiles = {"loud_walking_control_wall.png"},
	use_texture_alpha = true,
	light_source = minetest.LIGHT_MAX,
	is_ground_content = false,
	groups = {},
	sounds = default.node_sound_stone_defaults(),
})

loud_walking.control_fun = function(pos, node, puncher, pointed_thing)
	if not puncher:is_player() then
		return
	end

	local sr = math.random(20)
	if sr < 3 then
		puncher:set_hp(puncher:get_hp() - sr)
	elseif sr < 6 then
		minetest.chat_send_player(puncher:get_player_name(), "Prepare for transport...")
		local pos = {x=50000, y=50000, z=50000}
		while pos.x > 31000 or pos.x < -31000 do
			pos.x = math.random(-100, 100) * loud_walking.fcsize.x + math.floor(loud_walking.pod_size.x / 2)
		end
		while pos.y > 31000 or pos.y < -31000 do
			pos.y = math.random(-100, 100) * loud_walking.fcsize.y + math.floor(loud_walking.pod_size.y - 3)
		end
		while pos.z > 31000 or pos.z < -31000 do
			pos.z = math.random(-100, 100) * loud_walking.fcsize.z + math.floor(loud_walking.pod_size.z / 2)
		end
		puncher:setpos(pos)
	elseif sr == 6 then
		minetest.chat_send_player(puncher:get_player_name(), "Infectious organism detected. Sterilizing area...")
		for z1 = -4, 4 do
			for y1 = -4, 4 do
				for x1 = -4, 4 do
					local p = {x = pos.x + x1, y = pos.y + y1, z = pos.z + z1}
					local node = minetest.get_node(p)
					if node and node.name == "air" then
						minetest.set_node(p, {name="fire:basic_flame"})
					end
				end
			end
		end
	elseif sr == 7 then
		minetest.chat_send_player(puncher:get_player_name(), "Repairing injured animal...")
		puncher:set_hp(20)
	elseif sr == 8 then
		minetest.chat_send_player(puncher:get_player_name(), "Reseting chronometers...")
		minetest.set_timeofday(math.random(100)/100)
	elseif sr == 9 then
		minetest.chat_send_player(puncher:get_player_name(), "Escaped animal detected. Ejecting...")
		local pos = puncher:getpos()
		for z1 = -1, 1 do
			for x1 = -1, 1 do
				minetest.set_node({x = pos.x + x1, y = pos.y - 1, z = pos.z + z1}, {name="air"})
			end
		end
	elseif sr == 10 then
		minetest.set_node(pos, {name="air"})
	else
		minetest.chat_send_player(puncher:get_player_name(), "Please do not press this button again.")
	end
end

minetest.register_node("loud_walking:controls", {
	description = "Alien control system",
	paramtype = "light",
	tiles = {"loud_walking_controls.png"},
	use_texture_alpha = true,
	is_ground_content = false,
	groups = {},
	sounds = default.node_sound_stone_defaults(),
	on_punch = loud_walking.control_fun,
})

minetest.register_node("loud_walking:air_ladder", {
	description = "Air Ladder",
	drawtype = "glasslike",
	tiles = {"loud_walking_air_ladder.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	use_texture_alpha = true,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0},
	},
})

minetest.register_node("loud_walking:control_plant_1", {
	description = "Strange Plant",
	drawtype = "plantlike",
	waving = 1,
	tiles = {"loud_walking_strange_plant_1.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0},
	},
})

minetest.register_node("loud_walking:control_plant_2", {
	description = "Strange Plant",
	drawtype = "plantlike",
	waving = 1,
	tiles = {"loud_walking_strange_plant_2.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0},
	},
})
