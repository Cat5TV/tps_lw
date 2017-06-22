local function floor(pos, blocks, node_name, user_name)
	if not (pos and blocks and node_name and user_name and type(blocks) == 'number' and type(node_name) == 'string' and type(user_name) == 'string') then
		return
	end

	local p = {y = pos.y}
	local count = 0
	for r = 1, blocks do
		for z = -r, r do
			p.z = pos.z + z
			for x = -r, r do
				p.x = pos.x + x
				local node = minetest.get_node_or_nil(p)

				if node and (node.name == 'air' or node.name == 'default:water_source') and not minetest.is_protected(p, user_name) then
					minetest.set_node(p, {name = node_name})
					count = count + 1
					if count > blocks then
						return
					end
				end
			end
		end
	end
end


if minetest.get_modpath('tnt') then
	-- Floor bombs
	local nodes = {{'default:sandstone', 'default:sandstone_block'}, {'default:wood', 'loud_walking:wood_block'}, {'default:stone', 'default:stone_block'},}
	for _, node in pairs(nodes) do
		local node_name = node[1]
		local comp = node[2] or node_name
		if not minetest.registered_items[node_name] or (not minetest.registered_items[comp] and not comp:find('^loud_walking')) then
			break
		end

		local node_texture = minetest.registered_items[node_name].tiles
		if type(node_texture) == 'table' then
			node_texture = node_texture[1]
		end
		local _, d_name = node_name:match('(.*:)(.*)')
		local bomb_name = "loud_walking:"..d_name..'_floor_bomb'
		local d_name_u = d_name:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)

		local newnode = loud_walking.clone_node(node_name)
		newnode.description = d_name_u.." Floor Bomb"
		newnode.inventory_image = '[inventorycube{'..node_texture..'{'..node_texture..'{'..node_texture..'^loud_walking_expand.png'
		newnode.drop = bomb_name
		newnode.on_punch = function(pos, node, puncher, pointed_thing)
			if not (pos and puncher) then
				return
			end

			local wield = puncher:get_wielded_item()
			if not wield or wield:get_name() ~= "default:torch" then
				return
			end

			minetest.after(5, function()
				local pos_node = minetest.get_node_or_nil(pos)
				if not (pos_node and pos_node.name == bomb_name) then
					return
				end

				floor(pos, 100, node_name, puncher:get_player_name())
				minetest.set_node(pos, {name = node_name})
			end)
		end
		minetest.register_node(bomb_name, newnode)

		if not minetest.registered_items[comp] then
			newnode = loud_walking.clone_node(node_name)
			newnode.description = newnode.description .. ' Block'
			minetest.register_node(comp, newnode)

			minetest.register_craft({
				output = comp,
				recipe = {
					{node_name, node_name, node_name},
					{node_name, node_name, node_name},
					{node_name, node_name, node_name}
				}
			})
		end

		minetest.register_craft({
			output = "loud_walking:"..d_name..'_floor_bomb',
			recipe = {
				{comp, comp, comp},
				{comp, "tnt:gunpowder", comp},
				{comp, comp, comp}
			}
		})
	end
end

local function power(player, pos, tool_type, max)
	if not (player and pos and tool_type) then
		return
	end

	local player_pos = vector.round(player:getpos())
	local player_name = player:get_player_name()
	local inv = player:get_inventory()
	pos = vector.round(pos)
	local node = minetest.get_node_or_nil(pos)
	if not (node and player_pos and player_name and inv) then
		return
	end

	local maxr, node_type
	if tool_type == 'axe' then
		node_type = 'choppy'
		maxr = {x = 2, y = 20, z = 2}
	elseif tool_type == 'pick' then
		node_type = 'cracky'
		maxr = {x = 2, y = 4, z = 2}
	else
		return
	end

	if minetest.get_item_group(node.name, node_type) == 0 then
		return
	end

	local max_nodes = max or 60
	local minp = vector.subtract(pos, 2)
	local maxp = vector.add(pos, maxr)
	local yloop_a, yloop_b, yloop_c
	if pos.y >= player_pos.y then
		minp.y = player_pos.y
		yloop_a, yloop_b, yloop_c = minp.y, maxp.y, 1
		if node_type == 'cracky' and pos.y - player_pos.y < 3 then
			maxp.y = player_pos.y + 3
		end
	else
		maxp.y = player_pos.y
		yloop_a, yloop_b, yloop_c = maxp.y, minp.y, -1
	end

	local air = minetest.get_content_id('air')
	local vm = minetest.get_voxel_manip()
	if not vm then
		return
	end

	local emin, emax = vm:read_from_map(minp, maxp)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	local drops = {}
	local names = {}
	local diggable = {}
	local tree_like = {}
	local leaf_like = {}
	local stone_like = {}
	local count = 0
	local p = {}
	for y = yloop_a, yloop_b, yloop_c do
		p.y = y
		for z = minp.z, maxp.z do
			p.z = z
			local ivm = area:index(minp.x, y, z)
			for x = minp.x, maxp.x do
				p.x = x
				if not names[data[ivm]] then
					names[data[ivm]] = minetest.get_name_from_content_id(data[ivm])
				end

				if not diggable[data[ivm]] then
					diggable[data[ivm]] = minetest.get_item_group(names[data[ivm]], node_type) or 0
					if node_type == 'choppy' then
						diggable[data[ivm]] = diggable[data[ivm]] + minetest.get_item_group(names[data[ivm]], 'snappy') or 0
						diggable[data[ivm]] = diggable[data[ivm]] + minetest.get_item_group(names[data[ivm]], 'fleshy') or 0
					end

					if names[data[ivm]] and names[data[ivm]]:find('^door') then
						diggable[data[ivm]] = 0
					end
				end

				if count < max_nodes and diggable[data[ivm]] > 0 and not minetest.is_protected(p, player_name) then
					drops[data[ivm]] = (drops[data[ivm]] or 0) + 1
					data[ivm] = air
					count = count + 1
				end
				ivm = ivm + 1
			end
		end
	end
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()

	local tool = player:get_wielded_item()
	for id, number in pairs(drops) do
		for i = 1, number do
			local drops = minetest.get_node_drops(names[id], tool:get_name())
			minetest.handle_node_drops(pos, drops, player)
		end

		local tp = tool:get_tool_capabilities()
		local def = ItemStack({name=names[id]}):get_definition()
		local dp = minetest.get_dig_params(def.groups, tp)
		if not dp then
			return
		end

		tool:add_wear(dp.wear * number)
	end

	return tool
end

minetest.register_tool("loud_walking:chainsaw", {
	description = "Chainsaw",
	inventory_image = "loud_walking_chainsaw.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=80, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	on_use = function(itemstack, user, pointed_thing)
		if not (user and pointed_thing) then
			return
		end

		minetest.sound_play('chainsaw', {
			object = user,
			gain = 0.1,
			max_hear_distance = 30
		})

		return power(user, pointed_thing.under, 'axe')
	end,
})

minetest.register_tool("loud_walking:jackhammer", {
	description = "Jackhammer",
	inventory_image = "loud_walking_jackhammer.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=80, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	on_use = function(itemstack, user, pointed_thing)
		if not (user and pointed_thing) then
			return
		end

		minetest.sound_play('jackhammer', {
			object = user,
			gain = 0.1,
			max_hear_distance = 30
		})

		return power(user, pointed_thing.under, 'pick')
	end,
})

minetest.register_craft({
	output = 'loud_walking:chainsaw',
	recipe = {
		{'', 'default:diamond', ''},
		{'', 'default:steelblock', ''},
		{'default:copper_ingot', 'default:coalblock', ''},
	}
})

minetest.register_craft({
	output = 'loud_walking:chainsaw',
	recipe = {
		{'', '', ''},
		{'', 'loud_walking:chainsaw', ''},
		{'', 'default:steelblock', 'default:coalblock'},
	}
})

minetest.register_craft({
	output = 'loud_walking:jackhammer',
	recipe = {
		{'default:copper_ingot', 'default:coalblock', ''},
		{'', 'default:steelblock', ''},
		{'', 'default:diamond', ''},
	}
})

minetest.register_craft({
	output = 'loud_walking:jackhammer',
	recipe = {
		{'', '', ''},
		{'', 'loud_walking:jackhammer', ''},
		{'', 'default:steelblock', 'default:coalblock'},
	}
})


local function flares(player)
	local dir = player:get_look_dir()
	local pos = player:getpos()
	if not pos then
		return
	end
	pos.x = pos.x + dir.x * 10
	pos.y = pos.y + dir.y * 10
	pos.z = pos.z + dir.z * 10
	pos = vector.round(pos)

	local air = minetest.get_content_id('air')
	local flare = minetest.get_content_id('loud_walking:flare')
	local vm = minetest.get_voxel_manip()
	if not vm then
		return
	end

	local r = 8
	local minp = vector.subtract(pos, r)
	local maxp = vector.add(pos, r)
	local emin, emax = vm:read_from_map(minp, maxp)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	local count = 0
	for i = 1, 50 do
		local x = pos.x + math.random(2 * r + 1) - r - 1
		local y = pos.y + math.random(2 * r + 1) - r - 1
		local z = pos.z + math.random(2 * r + 1) - r - 1
		local ivm = area:index(x, y, z)
		if data[ivm] == air then
			data[ivm] = flare
			count = count + 1
		end
	end
	vm:set_data(data)
	vm:calc_lighting(minp, maxp)
	vm:update_liquids()
	vm:write_to_map()
	vm:update_map()

	return count
end

minetest.register_node("loud_walking:flare", {
	description = "Fungal tree fruit",
	drawtype = "plantlike",
	visual_scale = 0.75,
	tiles = {"loud_walking_flare.png"},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 15,
	walkable = false,
	diggable = false,
	pointable = false,
	is_ground_content = false,
})

minetest.register_tool("loud_walking:flare_gun", {
	description = "Flare Gun",
	inventory_image = "loud_walking_flare_gun.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
	on_use = function(itemstack, user, pointed_thing)
		if not user then
			return
		end

		local count = flares(user)
		itemstack:add_wear(count * 400)
		return itemstack
	end,
})

minetest.register_craft({
	output = 'loud_walking:flare_gun',
	recipe = {
		{'', '', ''},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', 'tnt:gunpowder', 'group:stick'},
	}
})

minetest.register_craft({
	output = 'loud_walking:flare_gun',
	recipe = {
		{'', '', ''},
		{'', 'loud_walking:flare_gun', ''},
		{'', 'tnt:gunpowder', ''},
	}
})
