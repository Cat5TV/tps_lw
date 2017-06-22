-----------
-- Trees --
-----------

-- Change leafdecay ratings
minetest.add_group("default:leaves", {leafdecay = 4})
minetest.add_group("default:jungleleaves", {leafdecay = 4})
minetest.add_group("default:pine_needles", {leafdecay = 5})


-- tree creation code
dofile(loud_walking.path.."/deco_deciduous.lua")
dofile(loud_walking.path.."/deco_conifer.lua")
dofile(loud_walking.path.."/deco_jungle.lua")


loud_walking.schematics.acacia_trees = {}
local mz = 9
local mx = 9
local my = 7
local s = loud_walking.schematic_array(mx, my, mz)
for i = 1, #s.data do
	s.data[i] = { name = "air", prob = 0 }
end

local y1 = 5
for z1 = 0, 5, 5 do
	for x1 = 0, 5, 5 do
		if x1 ~= z1 then
			for z = 0, 3 do
				for x = 0, 3 do
					local i = (z + z1) * mx * my + y1 * mx + x1 + x + 1
					s.data[i] = { name = "default:acacia_leaves", prob = 240 }
				end
			end
		end
	end
end
y1 = 6
for z1 = 4, 0, -4 do
	for x1 = 0, 4, 4 do
		if x1 == z1 then
			for z = 0, 4 do
				for x = 0, 4 do
					local i = (z + z1) * mx * my + y1 * mx + x1 + x + 1
					s.data[i] = { name = "default:acacia_leaves", prob = 240 }
				end
			end
		end
	end
end
local trunk = {{4,0,4}, {4,1,4}, {4,2,4}, {4,3,4}, {3,4,3}, {5,4,5}, {3,3,5}, {5,3,3}, {2,5,2}, {6,5,6}, {2,4,6}, {6,4,2}}
for _, p in pairs(trunk) do
	local i = p[3] * mx * my + p[2] * mx + p[1] + 1
	s.data[i] = { name = "default:acacia_tree", prob = 255 }
end
loud_walking.schematics.acacia_trees[#loud_walking.schematics.acacia_trees+1] = s
