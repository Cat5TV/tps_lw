-- This tables looks up nodes that aren't already stored.
local node = setmetatable({}, {
	__index = function(t, k)
		if not (t and k and type(t) == 'table') then
			return
		end

		t[k] = minetest.get_content_id(k)
		return t[k]
	end
})

loud_walking.node = node

local math_abs = math.abs
local math_floor = math.floor

local cloud_i = 0.5
local glass = {"loud_walking:sky_scrith", "loud_walking:cloud_scrith", "loud_walking:transparent_scrith"}


local data = {}
local p2data = {}  -- vm rotation data buffer
local vm, emin, emax, a, csize, heightmap, biomemap
local div_sz_x, div_sz_z, minp, maxp, terrain, cave
local cloud

local terrain_noise = {offset = 0,
scale = 20, seed = 8829, spread = {x = 40, y = 40, z = 40},
octaves = 6, persist = 0.4, lacunarity = 2}

local cave_noise = {offset = 0, scale = 1,
seed = -3977, spread = {x = 30, y = 30, z = 30}, octaves = 3,
persist = 0.8, lacunarity = 2}

local cloud_noise = {offset = 0, scale = 1,
seed = -7874, spread = {x = 30, y = 30, z = 30}, octaves = 3,
persist = 0.8, lacunarity = 2}

loud_walking.biomes = {}
local biomes = loud_walking.biomes
local biome_names = {}
biome_names["common"] = {}
biome_names["uncommon"] = {}
do
	local biome_terrain_scale = {}
	biome_terrain_scale["coniferous_forest"] = 0.75
	biome_terrain_scale["rainforest"] = 0.33
	biome_terrain_scale["underground"] = 1.5

	local tree_biomes = {}
	tree_biomes["deciduous_forest"] = {"deciduous_trees"}
	tree_biomes["coniferous_forest"] = {"conifer_trees"}
	tree_biomes["taiga"] = {"conifer_trees"}
	tree_biomes["rainforest"] = {"jungle_trees"}
	tree_biomes["rainforest_swamp"] = {"jungle_trees"}
	tree_biomes["coniferous_forest"] = {"conifer_trees"}
	tree_biomes["savanna"] = {"acacia_trees"}

	for i, obiome in pairs(minetest.registered_biomes) do
		local biome = table.copy(obiome)
		biome.special_tree_prob = 5
		if biome.name == "rainforest" or biome.name == 'rainforest_swamp' then
			biome.special_tree_prob = 2
		end
		if biome.name == "savanna" then
			biome.special_tree_prob = 30
		end
		local rarity = "common"
		biome.terrain_scale = biome_terrain_scale[biome] or 0.5
		if string.find(biome.name, "ocean") then
			biome.terrain_scale = 1
			rarity = "uncommon"
		end
		if string.find(biome.name, "swamp") then
			biome.terrain_scale = 0.25
			rarity = "uncommon"
		end
		if string.find(biome.name, "beach") then
			biome.terrain_scale = 0.25
			rarity = "uncommon"
		end
		if string.find(biome.name, "^underground$") then
			biome.node_top = "default:stone"
			rarity = "uncommon"
		end
		biome.special_trees = tree_biomes[biome.name]
		biomes[biome.name] = biome
		biome_names[rarity][#biome_names[rarity]+1] = biome.name
	end
end
biomes["control"] = {}

local cave_stones = {
	"loud_walking:stone_with_moss",
	"loud_walking:stone_with_lichen",
	"loud_walking:stone_with_algae",
	"loud_walking:stone_with_salt",
}
local mushroom_stones = {}
mushroom_stones[node["default:stone"]] = true
mushroom_stones[node["loud_walking:stone_with_algae"]] = true
mushroom_stones[node["loud_walking:stone_with_lichen"]] = true

local function connection(x, y, z)
	local min_x = math_floor((x + 32) / csize.x)
	local min_y = math_floor((y + 32) / csize.y)
	local min_z = math_floor((z + 32) / csize.z)

	--local seed_noise = minetest.get_perlin({offset = 0, scale = 32768,
	--seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2,
	--persist = 0.4, lacunarity = 2})
	--math.randomseed(seed_noise:get2d({x=minp.x, y=minp.z}))

	local ct = min_x % 2 + min_y % 2 + min_z % 2
	local r = min_x % 2 + 2 * (min_y % 2) + 4 * (min_z % 2)
	if ct == 1 then
		return r
	end

	return nil
end

local function get_decoration(biome)
	if not loud_walking.decorations then
		return
	end

	for i, deco in pairs(loud_walking.decorations) do
		if not deco.biomes or deco.biomes[biome] then
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


local pod_size = {x=loud_walking.pod_size_x, y=loud_walking.pod_size_y, z=loud_walking.pod_size_z}
local half_pod = {x=math_floor(pod_size.x / 2), y=math_floor(pod_size.y / 2), z=math_floor(pod_size.z / 2)}
local bridge_size = loud_walking.bridge_size
local vert_sep = loud_walking.vertical_sep
local fcsize = {x=pod_size.x + bridge_size, y=pod_size.y + vert_sep, z=pod_size.z + bridge_size}
local bevel = half_pod.y
local room_size = 20
local control_off = math_floor(room_size / 4)
local biome_look = {}
local cave_look = {}
local ore_look = {}
local tree_space = 3

loud_walking.fcsize = table.copy(fcsize)
loud_walking.pod_size = table.copy(pod_size)


local function place_schematic(pos, schem, center)
	local rot = math.random(4) - 1
	local yslice = {}
	if schem.yslice_prob then
		for _, ys in pairs(schem.yslice_prob) do
			yslice[ys.ypos] = ys.prob
		end
	end

	if center then
		pos.x = pos.x - math_floor(schem.size.x / 2)
		pos.z = pos.z - math_floor(schem.size.z / 2)
	end

	for z1 = 0, schem.size.z - 1 do
		for x1 = 0, schem.size.x - 1 do
			local x, z
			if rot == 0 then
				x, z = x1, z1
			elseif rot == 1 then
				x, z = schem.size.z - z1 - 1, x1
			elseif rot == 2 then
				x, z = schem.size.x - x1 - 1, schem.size.z - z1 - 1
			elseif rot == 3 then
				x, z = z1, schem.size.x - x1 - 1
			end
			local fdz = (pos.z + z) % fcsize.z
			local fdx = (pos.x + x) % fcsize.x
			if fdz < pod_size.z - 1 and fdz > 0 and fdx < pod_size.x - 1 and fdx > 0 then
				local ivm = a:index(pos.x + x, pos.y, pos.z + z)
				local isch = z1 * schem.size.y * schem.size.x + x1 + 1
				for y = 0, schem.size.y - 1 do
					if pos.y + y < maxp.y + 16 and pos.y + y > minp.y - 16 then
						local fdy = (pos.y + y) % fcsize.y
						if math.min(fdx, pod_size.x - fdx) + math.min(fdy, pod_size.y - fdy) + math.min(fdz, pod_size.z - fdz) > bevel then
							if yslice[y] or 255 >= math.random(255) then
								local prob = schem.data[isch].prob or schem.data[isch].param1 or 255
								if prob >= math.random(255) and schem.data[isch].name ~= "air" then
									data[ivm] = node[schem.data[isch].name]
								end
								local param2 = schem.data[isch].param2 or 0
								p2data[ivm] = param2
							end
						end
					end

					ivm = ivm + a.ystride
					isch = isch + schem.size.x
				end
			end
		end
	end
end


local function get_biome(x, y, z)
	local px = math_floor(x / fcsize.x)
	local py = math_floor(y / fcsize.y)
	local pz = math_floor(z / fcsize.z)

	if px % 10 == 6 and pz % 10 == 6 then
		return "control"
	else
		local hash = px * 1000000 + py * 1000 + pz
		if not biome_look[hash] then
			-- use the same seed (based on perlin noise).
			local seed_noise = minetest.get_perlin({offset = 0, scale = 32768, seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2, persist = 0.4, lacunarity = 2})
			math.randomseed(seed_noise:get3d({x=px, y=py, z=pz}))

			local rarity = "common"
			if math.random(5) == 1 then
				rarity = "uncommon"
			end
			biome_look[hash] = biome_names[rarity][math.random(#biome_names[rarity])]

			local cave_lining
			if math.random(3) ~= 1 then
				cave_lining = cave_stones[math.random(#cave_stones)]
			end
			cave_look[hash] = cave_lining

			local sr = math.random(100)
			if sr == 1 then
				ore_look[hash] = 'default:stone_with_mese'
			elseif sr <= 3 then
				ore_look[hash] = 'default:stone_with_diamond'
			elseif sr <= 7 then
				ore_look[hash] = 'default:stone_with_gold'
			elseif sr <= 15 then
				ore_look[hash] = 'default:stone_with_copper'
			elseif sr <= 31 then
				ore_look[hash] = 'default:stone_with_iron'
			elseif sr <= 63 then
				ore_look[hash] = 'default:stone_with_coal'
			else
				ore_look[hash] = 'default:stone'
			end
		end

		--return 'rainforest', cave_look[hash]
		return biome_look[hash], cave_look[hash], ore_look[hash]
	end
end


local function get_height(fdx, fdz, y, index, heights, terrain_scale, ocean)
	local py = math_floor(y / fcsize.y)

	if not terrain_scale then
		return
	end

	if not heights[py] then
		heights[py] = minetest.get_perlin_map(terrain_noise, csize):get2dMap_flat({x=minp.x, y=minp.z})
	end

	local terr = math_floor(heights[py][index] * terrain_scale + 0.5)

	local d = - math_abs(math_abs(fdx - (half_pod.x - 0.5)) - math_abs(fdz - (half_pod.z - 0.5)))
	if math_abs(fdx - half_pod.x) > math_abs(fdz - half_pod.z) then
		d = d + half_pod.x - 2
	else
		d = d + half_pod.z - 2
	end

	if math_abs(terr) > d then
		if terr > 0 then
			terr = math_floor(d + 0.5)
		elseif not ocean then
			terr = math_floor(0.5 - d)
		end
	end

	return terr
end


local function generate(p_minp, p_maxp, seed)
	--local ta0, ta1, ta2 = 0, 0, 0
	local t0 = os.clock()
	minp, maxp = p_minp, p_maxp
	vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	--p2data = vm:get_param2_data()
	a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	csize = vector.add(vector.subtract(maxp, minp), 1)

	local ground = half_pod.y
	local heights = {}
	cloud = minetest.get_perlin_map(cloud_noise, csize):get2dMap_flat(minp)
	cave = minetest.get_perlin_map(cave_noise, csize):get3dMap_flat(minp)
	local goblin_spawner
	if minetest.registered_nodes['loud_walking:goblin_spawner'] then
		goblin_spawner = node['loud_walking:goblin_spawner']
	end

	local t1 = os.clock()

	local index = 0
	local index3d = 0
	local last_biome, last_px, last_py, last_pz, node_top, node_filler, node_water_top, node_water, depth_top, depth_water_top, depth_filler, node_stone, ocean, swamp, beach, dunes, height
	local biome, cave_lining, room_type, room_type_below, ore_type

	for z = minp.z, maxp.z do
		local dz = z - minp.z
		local fdz = z % fcsize.z
		local pz = math_floor(z / fcsize.z)
		for x = minp.x, maxp.x do
			index = index + 1
			local dx = x - minp.x
			local fdx = x % fcsize.x
			local px = math_floor(x / fcsize.x)
			local in_cave = false
			index3d = dz * csize.y * csize.x + dx + 1
			local ivm = a:index(x, minp.y, z)
			local cave_height = 0
			last_py = nil

			for y = minp.y, maxp.y do
				local dy = y - minp.y
				local fdy = y % fcsize.y
				local py = math_floor(y / fcsize.y)

				if biome == 'control' then
					local room_px = math_floor((math_abs(fdx - half_pod.x) - 3) / room_size)
					local room_py = math_floor(fdy / 5)
					local room_pz = math_floor((math_abs(fdz - half_pod.z) - 3) / room_size)
					room_type = math_floor((math_abs(room_pz * 1000000 + room_py * 1000 + room_px) % 17) / 3)
					room_type_below = math_floor((math_abs(room_pz * 1000000 + (room_py - 1) * 1000 + room_px) % 17) / 3)
					if room_type_below == 1 and room_type == 3 then
						room_type = 0
					end
				end

				if py ~= last_py or px ~= last_px or pz ~= last_pz then
					biome, cave_lining, ore_type = get_biome(x, y, z)
				end
				if biome ~= last_biome then
					node_top = biomes[biome].node_top or "default:dirt_with_grass"
					node_filler = biomes[biome].node_filler or "default:dirt"
					node_water_top = biomes[biome].node_water_top or "default:water_source"
					node_water = biomes[biome].node_water or "default:water_source"
					depth_top = biomes[biome].depth_top or 1
					depth_water_top = biomes[biome].node_water_top or 1
					depth_filler = biomes[biome].depth_filler or 1
					node_stone = biomes[biome].node_stone or "default:stone"
					ocean = string.find(biome, "ocean") and true or false
					swamp = string.find(biome, "swamp") and true or false
					beach = string.find(biome, "beach") and true or false
					dunes = string.find(biome, "dunes") and true or false
				end

				if py ~= last_py then
					height = half_pod.y - 5
					if not (biome == "underground" or biome == 'control') then
						height = get_height(fdx, fdz, y, index, heights, biomes[biome].terrain_scale, ocean)
					end
				end

				if not (data[ivm] == node['air'] or data[ivm] == node['ignore']) then
					-- nop
				elseif biome == "control" and math_abs(fdx - half_pod.x) < 3 and math_abs(fdz - half_pod.z) < 3 then
					data[ivm] = node["loud_walking:air_ladder"]
				elseif fdz >= pod_size.z or fdx >= pod_size.x or fdy >= pod_size.y then
					if (fdy == half_pod.y and fdx == half_pod.x) or (fdy == half_pod.y and fdz == half_pod.z) then
						data[ivm] = node['loud_walking:scrith']
					else
						--data[ivm] = node['air']
					end
				elseif math.min(fdx, pod_size.x - fdx) + math.min(fdy, pod_size.y - fdy) + math.min(fdz, pod_size.z - fdz) < bevel then
					--data[ivm] = node['air']
					in_cave = false
				elseif (fdx == 0 or fdx == pod_size.x - 1) or (fdz == 0 or fdz == pod_size.z - 1) or (fdy == 0 or fdy == pod_size.y - 1) or math.min(fdx, pod_size.x - fdx) + math.min(fdy, pod_size.y - fdy) + math.min(fdz, pod_size.z - fdz) < bevel + 1 then
					if math_abs(fdy - half_pod.y - 2) < 2 and (fdz == half_pod.z or fdx == half_pod.x) then
						--data[ivm] = node["air"]
					else
						if biome == "control" then
							data[ivm] = node[glass[3]]
						elseif fdy < half_pod.y then
							data[ivm] = node["loud_walking:scrith"]
						elseif biome == "underground" then
							data[ivm] = node["loud_walking:scrith"]
						elseif fdy == pod_size.y - 1 then
							data[ivm] = node[glass[cloud[index] < cloud_i and 1 or 2]]
						else
							data[ivm] = node[glass[1]]
						end
					end
				elseif fdz == 0 and fdz == pod_size.z - 1 or fdx == 0 and fdx == pod_size.x - 1 or fdy == 0 and fdy == pod_size.y - 1 then
					data[ivm] = node['loud_walking:scrith']
				elseif biome == "control" and fdy < pod_size.y then
					if (math_abs(fdx - half_pod.x) < 3 or math_abs(fdz - half_pod.z) < 3) then
						-- corridor
						if fdy % 5 == 0 then
							data[ivm] = node["loud_walking:control_floor"]
						end
					elseif ((math_abs(fdx - half_pod.x) % room_size == 3) or (math_abs(fdz - half_pod.z) % room_size == 3)) then
						if fdy % 5 == 0 then
							data[ivm] = node["loud_walking:control_floor"]
						elseif ((math_abs(fdx - half_pod.x) % room_size == 3 and (math_abs(fdz - half_pod.z) - (math_floor(room_size / 2) + 2)) % room_size > 3) or (math_abs(fdz - half_pod.z) % room_size == 3 and (math_abs(fdx - half_pod.x) - (math_floor(room_size / 2) + 2)) % room_size > 3)) then
							data[ivm] = node["loud_walking:control_wall"]
						end
					elseif fdy % 5 == 0 then
						if room_type == 1 then
							if room_type_below == 1 then
								data[ivm] = node["loud_walking:control_floor_alert_both"]
							else
								data[ivm] = node["loud_walking:control_floor_alert_up"]
							end
						elseif room_type_below == 1 then
							data[ivm] = node["loud_walking:control_floor_alert_down"]
						elseif room_type == 3 then
							data[ivm] = node["loud_walking:control_floor_growth"]
						else
							data[ivm] = node["loud_walking:control_floor"]
						end
					elseif room_type == 2 and fdy < pod_size.y then
						if math_abs(fdx - half_pod.x) % 4 < 3 and math_abs(fdz - half_pod.z) % 4 < 3 then
							data[ivm] = node["loud_walking:air_ladder"]
						end
					elseif room_type == 3 then
						if fdy % 5 == 1 then
							local sr2 = math.random(20)
							if sr2 == 1 then
								data[ivm] = node["loud_walking:control_plant_1"]
							elseif sr2 == 2 then
								data[ivm] = node["loud_walking:control_plant_2"]
							end
						end
					elseif room_type == 4 then
						if fdy % 5 == 4 and (((math_abs(fdx - half_pod.x) % room_size == 4 or math_abs(fdx - half_pod.x) % room_size == 2) and (math_abs(fdz - half_pod.z) - (math_floor(room_size / 2) + 2)) % room_size > 3) or ((math_abs(fdz - half_pod.z) % room_size == 4 or math_abs(fdz - half_pod.z) % room_size == 2) and (math_abs(fdx - half_pod.x) - (math_floor(room_size / 2) + 2)) % room_size > 3)) then
							data[ivm] = node["loud_walking:controls"]
						end
					else
						-- nop
					end
				elseif (((fdx == (half_pod.x - control_off) or fdx == (half_pod.x + control_off)) and fdz >= (half_pod.z - control_off) and fdz <= (half_pod.z + control_off)) or ((fdz == (half_pod.z - control_off) or fdz == (half_pod.z + control_off)) and fdx >= (half_pod.x - control_off) and fdx <= (half_pod.x + control_off))) and fdx ~= half_pod.x and fdz ~= half_pod.z and fdy == pod_size.y - 2 then
					data[ivm] = node["loud_walking:controls"]
				elseif (((fdx == (half_pod.x - control_off) or fdx == (half_pod.x + control_off)) and fdz >= (half_pod.z - control_off) and fdz <= (half_pod.z + control_off)) or ((fdz == (half_pod.z - control_off) or fdz == (half_pod.z + control_off)) and fdx >= (half_pod.x - control_off) and fdx <= (half_pod.x + control_off))) and fdx ~= half_pod.x and fdz ~= half_pod.z and fdy > pod_size.y - control_off then
					data[ivm] = node[glass[3]]
				elseif fdz >= (half_pod.z - control_off) and fdz <= (half_pod.z + control_off) and fdx >= (half_pod.x - control_off) and fdx <= (half_pod.x + control_off) and fdy == pod_size.y - control_off then
					data[ivm] = node[glass[3]]
				elseif not in_cave and  (ocean or swamp or beach) and fdy > height + ground and fdy <= half_pod.y and fdy == height + ground + 1 then
					-- ** water decorations **
					--local deco = get_decoration(biome)
					--if deco then
					--	data[ivm] = node[deco]
					--end
				elseif not in_cave and fdy == height + ground + 1 then
					local deco = get_decoration(biome)
					if deco then
						data[ivm] = node[deco]
					end
				elseif (ocean or swamp or beach) and fdy > height + ground and fdy <= half_pod.y and fdy >= half_pod.y - depth_water_top then
					data[ivm] = node[node_water_top]
					in_cave = false
				elseif (ocean or swamp or beach) and fdy > height + ground and fdy <= half_pod.y then
					data[ivm] = node[node_water]
					in_cave = false
				elseif fdy > height + ground then
					--data[ivm] = node["air"]
					in_cave = false
				elseif cave[index3d] ^ 2 > (biome == "underground" and 0.5 or 1.3 - math.sin(fdy / (half_pod.y * 0.2))) then
					cave_height = cave_height + 1
					if height + ground >= fdy and not in_cave and fdy > height + ground - 10 then
						data[ivm] = node[node_top]
					elseif fdy == 1 then
						if not cave_lining and not ocean and not swamp and not beach and biome ~= "glacier" and math.random(6) == 1 then
							data[ivm] = node["default:lava_source"]
						elseif ocean or swamp or beach then
							data[ivm] = node[node_filler]
						end
					elseif (ocean or swamp or beach) and not in_cave and node_stone == "default:stone" and fdy < half_pod.y and math.random(20) == 1 then
						data[ivm] = node["loud_walking:glowing_fungal_stone"]
					elseif (ocean or swamp or beach) and fdy < half_pod.y then
						data[ivm] = node[node_water]
					elseif cave_height == 3 and node_filler == "default:dirt" and mushroom_stones[data[ivm - 3 * a.ystride]] and math.random(40) == 1 then
						data[ivm] = node["loud_walking:giant_mushroom_cap"]
						data[ivm - a.ystride] = node["loud_walking:giant_mushroom_stem"]
						data[ivm - 2 * a.ystride] = node["loud_walking:giant_mushroom_stem"]
						data[ivm - 3 * a.ystride] = node[node_filler]
					elseif cave_height == 2 and node_filler == "default:dirt" and mushroom_stones[data[ivm - 2 * a.ystride]] and math.random(20) == 1 then
						data[ivm] = node["loud_walking:huge_mushroom_cap"]
						data[ivm - a.ystride] = node["loud_walking:giant_mushroom_stem"]
						data[ivm - 2 * a.ystride] = node[node_filler]
					elseif not in_cave and node_stone == "default:stone" and not cave_lining and math.random(10) == 1 then
						data[ivm] = node["loud_walking:stalagmite"]
					elseif not in_cave and node_stone == "default:ice" and math.random(10) == 1 then
						data[ivm] = node["loud_walking:icicle_up"]
					elseif not in_cave and goblin_spawner and loud_walking.goblin_rarity < 11 and math.random(loud_walking.goblin_rarity * 1000) == 1 then
						data[ivm] = goblin_spawner
					else
						--data[ivm] = node["air"]
					end
					in_cave = true
				elseif cave_lining and cave[index3d] ^ 2 > (biome == "underground" and 0.4 or 1.2 - math.sin(fdy / (half_pod.y * 0.2))) then
					data[ivm] = node[cave_lining]
				elseif fdy > height + ground - depth_top then
					data[ivm] = node[node_top]
					in_cave = false
				elseif fdy > height + ground - depth_filler - depth_top then
					data[ivm] = node[node_filler]
					in_cave = false
				else
					data[ivm] = node[node_stone]
					if math.random(100) == 1 then
						data[ivm] = node[ore_type]
					end

					if in_cave and node_stone == "default:stone" and math.random(20) == 1 then
						data[ivm] = node["loud_walking:glowing_fungal_stone"]
					elseif in_cave and not (ocean or swamp or beach) and node_stone == "default:stone" and not cave_lining and math.random(10) == 1 then
						data[ivm - a.ystride] = node["loud_walking:stalactite"]
					elseif in_cave and not (ocean or swamp or beach) and node_stone == "default:ice" and math.random(10) == 1 then
						data[ivm - a.ystride] = node["loud_walking:icicle_down"]
					end
					in_cave = false
				end

				if not in_cave then
					cave_height = 0
				end

				last_biome = biome
				last_py = py

				ivm = ivm + a.ystride
				index3d = index3d + csize.x
			end
			last_px = px
		end
		last_pz = pz
	end

	local t2 = os.clock()

	local index = 0
	for z = minp.z, maxp.z do
		local fdz = z % fcsize.z
		local pz = math_floor(z / fcsize.z)
		for x = minp.x, maxp.x do
			local fdx = x % fcsize.x
			local px = math_floor(x / fcsize.x)
			index = index + 1
			last_py = nil
			for y = minp.y, maxp.y do
				if fdz % tree_space == 0 and fdx % tree_space == 0 then
					local fdy = y % fcsize.y
					local py = math_floor(y / fcsize.y)
					local pod = fdz < pod_size.z and fdx < pod_size.x and fdy < pod_size.y
					if py ~= last_py or px ~= last_px or pz ~= last_pz then
						biome, cave_lining = get_biome(x, y, z)
						ocean = string.find(biome, "ocean") and true or false
						swamp = string.find(biome, "swamp") and true or false
						node_top = biomes[biome].node_top or "default:dirt_with_grass"
					end
					if py ~= last_py then
						height = get_height(fdx, fdz, y, index, heights, biomes[biome].terrain_scale, ocean)
					end

					if biome ~= 'control' and pod and fdy == height + ground and biomes[biome].special_tree_prob and math.random(biomes[biome].special_tree_prob) == 1 then
						local rx = x + math.random(tree_space) - 1
						local rz = z + math.random(tree_space) - 1

						local ivm = a:index(rx, y, rz)
						if (swamp or data[ivm + a.ystride] ~= node["default:water_source"]) and (data[ivm] == node[node_top]) then
							if biomes[biome].special_trees then
								local tree_type = biomes[biome].special_trees[math.random(#biomes[biome].special_trees)]
								if tree_type and loud_walking.schematics then
									local schem = loud_walking.schematics[tree_type][math.random(#loud_walking.schematics[tree_type])]
									local pos = {x=rx, y=y, z=rz}
									-- The minetest schematic functions don't seem very accurate.
									place_schematic(pos, schem, true)
								end
							else
								-- regular schematics?
							end
						end
					end
				end
			end
		end
	end

	local t3 = os.clock()

	local t4 = os.clock()

	vm:set_data(data)
	--minetest.generate_ores(vm, minp, maxp)
	--vm:set_param2_data(p2data)
	vm:set_lighting({day = 0, night = 0}, minp, maxp)
	vm:update_liquids()
	vm:calc_lighting(minp, maxp, false)
	vm:write_to_map()

	local t5 = os.clock()
	--print(' times: '..(t1 - t0)..', '..(t2 - t1)..', '..(t3 - t2)..', '..(t5 - t4)..' = '..(t5 - t0))
	--print(' also: '..ta1..', '..ta2)
end


local function pgenerate(...)
	--local status, err = pcall(generate, ...)
	local status, err = true
	generate(...)
	if not status then
		print('Loud Walking: Could not generate terrain:')
		print(dump(err))
		collectgarbage("collect")
	end
end


-- Inserting helps to ensure that squaresville operates first.
table.insert(minetest.registered_on_generateds, 1, pgenerate)


function loud_walking.respawn(player)
	local player_name = player:get_player_name()
	if not player_name then
		return
	end

	if beds and beds.spawn and beds.spawn[player_name] then
		return
	end

	while true do
		local px = math.random(-10, 10) * 2 - 1
		local pz = math.random(-10, 10) * 2
		local x = fcsize.x * px + math.random(half_pod.x) + math_floor(half_pod.x / 2)
		local z = fcsize.z * pz + math.random(half_pod.z) + math_floor(half_pod.z / 2)
		local y = half_pod.y + 5
		local biome = get_biome(x,y,z)
		if biome then
			local terrain_scale = biomes[biome].terrain_scale

			local noise = minetest.get_perlin(terrain_noise)
			if not noise then
				return
			end

			local height = noise:get2d({x=x, y=z}) * terrain_scale
			local y = height + half_pod.y + 5
			local pos = {x=x,y=y,z=z}
			local node = minetest.get_node_or_nil(pos)
			if not node or node.name == 'air' then
				player:setpos(pos)
				return true
			end
		end
	end
end

minetest.register_on_newplayer(loud_walking.respawn)
minetest.register_on_respawnplayer(loud_walking.respawn)
