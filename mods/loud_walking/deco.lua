local low_size = 138
local road_level = 1
local dirt_depth = 5
local water_diff = 8
local water_level = road_level - water_diff

loud_walking.schematics = {}

local math_floor = math.floor
local math_ceil = math.ceil
local math_abs = math.abs
local math_random = math.random

local csize

local heat_noise = {offset = 50, scale = 50, seed = 5349, spread = {x = 750, y = 750, z = 750}, octaves = 3, persist = 0.5, lacunarity = 2}
local heat_blend_noise = {offset = 0, scale = 1.5, seed = 13, spread = {x = 8, y = 8, z = 8}, octaves = 2, persist = 1.0, lacunarity = 2}
local humidity_noise = {offset = 50, scale = 50, seed = 842, spread = {x = 750, y = 750, z = 750}, octaves = 3, persist = 0.5, lacunarity = 2}
local humidity_blend_noise = {offset = 0, scale = 1.5, seed = 90003, spread = {x = 8, y = 8, z = 8}, octaves = 2, persist = 1.0, lacunarity = 2}


do
	local biome_mod = {
		coniferous_forest_dunes = { heat_point = 35, humidity_point = 60, },
		coniferous_forest = { heat_point = 35, humidity_point = 60, },
		coniferous_forest_ocean = { heat_point = 35, humidity_point = 60, },
		deciduous_forest = { heat_point = 60, humidity_point = 60, },
		deciduous_forest_ocean = { heat_point = 60, humidity_point = 60, },
		deciduous_forest_swamp = { heat_point = 60, humidity_point = 60, },
		desert = { heat_point = 80, humidity_point = 10, },
		desert_ocean = { heat_point = 80, humidity_point = 10, },
		glacier = {},
		glacier_ocean = {},
		rainforest = { heat_point = 85, humidity_point = 70, },
		rainforest_ocean = { heat_point = 85, humidity_point = 70, },
		rainforest_swamp = { heat_point = 85, humidity_point = 70, },
		sandstone_grassland_dunes = { heat_point = 55, humidity_point = 40, },
		sandstone_grassland = { heat_point = 55, humidity_point = 40, },
		sandstone_grassland_ocean = { heat_point = 55, humidity_point = 40, },
		savanna = { heat_point = 80, humidity_point = 25, },
		savanna_ocean = { heat_point = 80, humidity_point = 25, },
		savanna_swamp = { heat_point = 80, humidity_point = 25, },
		stone_grassland_dunes = { heat_point = 35, humidity_point = 40, },
		stone_grassland = { heat_point = 35, humidity_point = 40, },
		stone_grassland_ocean = { heat_point = 35, humidity_point = 40, },
		taiga = {},
		taiga_ocean = {},
		tundra = { node_river_water = "loud_walking:thin_ice", },
		tundra_beach = { node_river_water = "loud_walking:thin_ice", },
		tundra_ocean = {},
	}
	local rereg = {}

	for n, bi in pairs(biome_mod) do
		for i, rbi in pairs(minetest.registered_biomes) do
			if rbi.name == n then
				rereg[#rereg+1] = table.copy(rbi)
				for j, prop in pairs(bi) do
					rereg[#rereg][j] = prop
				end
			end
		end
	end

	minetest.clear_registered_biomes()

	for _, bi in pairs(rereg) do
		minetest.register_biome(bi)
	end

	rereg = {}
	for _, dec in pairs(minetest.registered_decorations) do
		rereg[#rereg+1] = dec
	end
	minetest.clear_registered_decorations()
	for _, dec in pairs(rereg) do
		minetest.register_decoration(dec)
	end
	rereg = nil


	minetest.register_biome({
		name = "desertstone_grassland",
		--node_dust = "",
		node_top = "default:dirt_with_grass",
		depth_top = 1,
		node_filler = "default:dirt",
		depth_filler = 1,
		node_stone = "default:desert_stone",
		node_riverbed = "default:sand",
		depth_riverbed = 2,
		--node_water_top = "",
		--depth_water_top = ,
		--node_water = "",
		--node_river_water = "",
		y_min = 6,
		y_max = 31000,
		heat_point = 80,
		humidity_point = 55,
	})


	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:dirt_with_grass"},
		sidelen = 80,
		fill_ratio = 0.1,
		biomes = {"desertstone_grassland", },
		y_min = 1,
		y_max = 31000,
		decoration = "default:junglegrass",
	})
end


flowers.register_decorations()


loud_walking.decorations = {}
local bad_deco = {}
for _, i in pairs({"apple_tree", "pine_tree", "jungle_tree", "acacia_tree", "aspen_tree", }) do
	bad_deco[i] = true
end

do
	for _, odeco in pairs(minetest.registered_decorations) do
		if not odeco.schematic then
			local deco = {}
			if odeco.biomes then
				deco.biomes = {}
				for _, b in pairs(odeco.biomes) do
					deco.biomes[b] = true
				end
			end

			deco.deco_type = odeco.deco_type
			deco.decoration = odeco.decoration
			deco.schematic = odeco.schematic
			deco.fill_ratio = odeco.fill_ratio

			if odeco.noise_params then
				deco.fill_ratio = math.max(0.001, (odeco.noise_params.scale + odeco.noise_params.offset) / 4)
			end

			local nod = minetest.registered_nodes[deco.decoration]
			if nod and nod.groups and nod.groups.flower then
				deco.flower = true
			end

			loud_walking.decorations[#loud_walking.decorations+1] = deco
		end
	end
end

minetest.clear_registered_decorations()


local function register_flower(name, desc, biomes, chance)
	local groups = {}
	groups.snappy = 3
	groups.flammable = 2
	groups.flower = 1
	groups.flora = 1
	groups.attached_node = 1

	minetest.register_node("loud_walking:" .. name, {
		description = desc,
		drawtype = "plantlike",
		waving = 1,
		tiles = {"loud_walking_" .. name .. ".png"},
		inventory_image = "loud_walking_" .. name .. ".png",
		wield_image = "flowers_" .. name .. ".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		stack_max = 99,
		groups = groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		}
	})

	local bi = {}
	if biomes then
		bi = {}
		for _, b in pairs(biomes) do
			bi[b] = true
		end
	end

	loud_walking.decorations[#loud_walking.decorations+1] = {
		deco_type = "simple",
		place_on = {"default:dirt_with_grass"},
		biomes = bi,
		fill_ratio = chance,
		flower = true,
		decoration = "loud_walking:"..name,
	}
end

register_flower("orchid", "Orchid", {"rainforest", "rainforest_swamp"}, 0.025)
register_flower("bird_of_paradise", "Bird of Paradise", {"rainforest", "desertstone_grassland"}, 0.025)
register_flower("gerbera", "Gerbera", {"savanna", "rainforest", "desertstone_grassland"}, 0.005)


local function register_decoration(deco, place_on, biomes, chance)
	local bi = {}
	if biomes then
		bi = {}
		for _, b in pairs(biomes) do
			bi[b] = true
		end
	end

	loud_walking.decorations[#loud_walking.decorations+1] = {
		deco_type = "simple",
		place_on = place_on,
		biomes = bi,
		fill_ratio = chance,
		decoration = deco,
	}
end


loud_walking.biomes = {}
local biomes = loud_walking.biomes
local biome_names = {}
do
	--local biome_terrain_scale = {}
	--biome_terrain_scale["coniferous_forest"] = 0.75
	--biome_terrain_scale["rainforest"] = 0.33
	--biome_terrain_scale["underground"] = 1.5

	local tree_biomes = {}
	tree_biomes["deciduous_forest"] = {"apple_tree", 'aspen_tree'}
	tree_biomes["coniferous_forest"] = {"pine_tree"}
	tree_biomes["taiga"] = {"pine_tree"}
	tree_biomes["rainforest"] = {"jungle_tree"}
	tree_biomes["rainforest_swamp"] = {"jungle_tree"}
	tree_biomes["coniferous_forest"] = {"pine_tree"}
	tree_biomes["savanna"] = {"acacia_tree"}

	for i, obiome in pairs(minetest.registered_biomes) do
		local biome = table.copy(obiome)
		biome.special_tree_prob = 2 * 25
		if string.match(biome.name, "^rainforest") then
			biome.special_tree_prob = 0.8 * 25
		end
		if biome.name == "savanna" then
			biome.special_tree_prob = 30 * 25
		end
		--biome.terrain_scale = biome_terrain_scale[biome] or 0.5
		--if string.find(biome.name, "ocean") then
		--	biome.terrain_scale = 1
		--end
		--if string.find(biome.name, "swamp") then
		--	biome.terrain_scale = 0.25
		--end
		--if string.find(biome.name, "beach") then
		--	biome.terrain_scale = 0.25
		--end
		--if string.find(biome.name, "^underground$") then
		--	biome.node_top = "default:stone"
		--end
		biome.special_trees = tree_biomes[biome.name]
		biomes[biome.name] = biome
		biome_names[#biome_names+1] = biome.name
	end
end


local function get_decoration(biome_name)
	for i, deco in pairs(loud_walking.decorations) do
		if not deco.biomes or deco.biomes[biome_name] then
			local range = 1000
			if deco.deco_type == "simple" then
				if deco.fill_ratio and math.random(range) - 1 < deco.fill_ratio * 1000 then
					return deco.decoration
				end
			else
				-- nop
			end
		end
	end
end


-- Create and initialize a table for a schematic.
function loud_walking.schematic_array(width, height, depth)
	-- Dimensions of data array.
	local s = {size={x=width, y=height, z=depth}}
	s.data = {}

	for z = 0,depth-1 do
		for y = 0,height-1 do
			for x = 0,width-1 do
				local i = z*width*height + y*width + x + 1
				s.data[i] = {}
				s.data[i].name = "air"
				s.data[i].param1 = 000
			end
		end
	end

	s.yslice_prob = {}

	return s
end


dofile(loud_walking.path.."/deco_trees.lua")
