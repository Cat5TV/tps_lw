---------------------------------------------------------------
-- GOBLINS
---------------------------------------------------------------

local spawn_frequency = 3000  -- 350
local dig_freq = 5  -- 5
local trap_freq = 25  -- 25
local torch_freq = 2  -- 2

local diggable = {
	'default:dirt',
	'default:dirt_with_grass',
	'default:dirt_with_dry_grass',
	'default:dirt_with_snow',
	'default:sand',
	'default:stone',
	'default:sandstone',
	'default:desert_stone',
	'default:stone_with_coal',
	'default:stone_with_copper',
	'default:stone_with_diamond',
	'default:stone_with_gold',
	'default:stone_with_iron',
	'default:stone_with_mese',
	'loud_walking:stone_with_coal_trap',
	'loud_walking:stone_with_copper_trap',
	'loud_walking:stone_with_diamond_trap',
	'loud_walking:stone_with_gold_trap',
	'loud_walking:stone_with_iron_trap',
	'loud_walking:stone_with_salt',
	'loud_walking:stone_with_algae',
	'loud_walking:stone_with_lichen',
	'loud_walking:stone_with_moss',
	'loud_walking:giant_mushroom_cap',
	'loud_walking:huge_mushroom_cap',
	'loud_walking:giant_mushroom_stem',
	'loud_walking:stalactite',
	'loud_walking:stalagmite',
	'loud_walking:stalactite_slimy',
	'loud_walking:stalagmite_slimy',
	'loud_walking:stalactite_mossy',
	'loud_walking:stalagmite_mossy',
	'flowers:mushroom_red',
	'flowers:mushroom_brown'
}


local traps = {
	'loud_walking:mossycobble_trap',
	'loud_walking:stone_with_coal_trap',
	'loud_walking:stone_with_copper_trap',
	'loud_walking:stone_with_diamond_trap',
	'loud_walking:stone_with_gold_trap',
	'loud_walking:stone_with_iron_trap',
}


local function goblin_do(self)
	if not (self and loud_walking.custom_ready and loud_walking.search_replace and loud_walking.surface_damage and loud_walking.custom_ready(self)) then
		return
	end

	local cold_natured = false
	local pos = self.object:getpos()
	pos.y = pos.y + 0.5

	-- dig
	if self.name == 'loud_walking:goblin_digger' then
		loud_walking.search_replace(pos, 1, diggable, 'air')
	else
		loud_walking.search_replace(pos, dig_freq, diggable, 'air')
	end

	--loud_walking.search_replace(pos, dig_freq * 3, burnable, 'fire:basic_flame')

	-- steal torches
	loud_walking.search_replace(self.object:getpos(), torch_freq, {"default:torch"}, "air")

	pos.y = pos.y - 0.5

	-- place a mossycobble
	local cobbling = trap_freq
	if self.name == 'loud_walking:goblin_cobbler' then
		cobbling = torch_freq
	end
	loud_walking.search_replace(pos, cobbling, {"group:stone", "default:sandstone"}, "default:mossycobble")

	-- place a trap
	local trap = 'loud_walking:mossycobble_trap'
	if self.name == 'loud_walking:goblin_ice' then
		cold_natured = true
		trap = 'loud_walking:ice_trap'
		loud_walking.search_replace(pos, trap_freq, {"default:ice"}, trap)
	else
		if self.name == 'loud_walking:goblin_coal' then
			trap = 'loud_walking:stone_with_coal_trap'
		elseif self.name == 'loud_walking:goblin_copper' then
			trap = 'loud_walking:stone_with_copper_trap'
		elseif self.name == 'loud_walking:goblin_diamond' then
			trap = 'loud_walking:stone_with_diamond_trap'
		elseif self.name == 'loud_walking:goblin_gold' then
			trap = 'loud_walking:stone_with_gold_trap'
		elseif self.name == 'loud_walking:goblin_iron' then
			trap = 'loud_walking:stone_with_iron_trap'
		elseif self.name == 'loud_walking:goblin_king' then
			trap = traps[math.random(#traps)]
		end
		loud_walking.search_replace(pos, trap_freq, {"group:stone", "default:sandstone"}, trap)
	end

	loud_walking.surface_damage(self, cold_natured)
end


local drops = {
	digger = {
		{name = "default:mossycobble", chance = 1, min = 1, max = 3},
	},
	--cobbler = {
	--	{name = "loud_walking:glowing_fungus", chance = 1, min = 2, max = 5},
	--},
	coal = {
		{name = "default:coal_lump", chance = 1, min = 1, max = 3},
	},
	copper = {
		{name = "default:copper_lump", chance = 1, min = 1, max = 3},
	},
	diamond = {
		{name = "default:diamond", chance = 5, min = 1, max = 3},
	},
	gold = {
		{name = "default:gold_lump", chance = 1, min = 1, max = 3},
	},
	ice = {
		{name = "default:coal_lump", chance = 1, min = 1, max = 3},
	},
	iron = {
		{name = "default:iron_lump", chance = 1, min = 1, max = 3},
	},
	king = {
		{name = "default:mese_crystal", chance = 1, min = 1, max = 3},
	},
}
for name, drop in pairs(drops) do
	if name == 'digger' or name == 'cobbler' or name == 'coal' or name == 'ice' then
		drop[#drop+1] = {name = "default:pick_stone", chance = 3, min = 1, max = 3}
		drop[#drop+1] = {name = "default:sword_stone", chance = 5, min = 1, max = 1}
	elseif name == 'copper' or name == 'iron' then
		drop[#drop+1] = {name = "default:pick_steel", chance = 3, min = 1, max = 3}
		drop[#drop+1] = {name = "default:sword_steel", chance = 5, min = 1, max = 1}
	elseif name == 'diamond' or name == 'gold' then
		drop[#drop+1] = {name = "default:pick_diamond", chance = 3, min = 1, max = 3}
		drop[#drop+1] = {name = "default:sword_diamond", chance = 5, min = 1, max = 1}
	elseif name == 'king' then
		drop[#drop+1] = {name = "default:pick_mese", chance = 3, min = 1, max = 3}
		drop[#drop+1] = {name = "default:sword_mese", chance = 5, min = 1, max = 1}
	end

	drop[#drop+1] = {name = "loud_walking:rotten_flesh", chance = 2, min = 1, max = 2}
	drop[#drop+1] = {name = "default:torch", chance = 3, min = 1, max = 10}
end


mobs:register_mob("loud_walking:goblin_digger", {
	description = "Digger Goblin",
	type = "monster",
	passive = false,
	damage = 1,
	attack_type = "dogfight",
	attacks_monsters = true,
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	fear_height = 4,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
	textures = {
		{"goblins_goblin_digger.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "goblins_goblin_ambient",
		warcry = "goblins_goblin_attack",
		attack = "goblins_goblin_attack",
		damage = "goblins_goblin_damage",
		death = "goblins_goblin_death",
		distance = 15,
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = drops['digger'],
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	lifetimer = 60,
	follow = {"default:diamond"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},
	on_rightclick = nil,
	do_custom = goblin_do,
})

mobs:register_egg("loud_walking:goblin_digger", "Goblin Egg (digger)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["loud_walking:goblin_digger"])
m.name = 'loud_walking:goblin_cobbler'
m.textures = { {"goblins_goblin_cobble1.png"}, {"goblins_goblin_cobble2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['cobbler']
minetest.registered_entities["loud_walking:goblin_cobbler"] = m

mobs:register_egg("loud_walking:goblin_cobbler", "Goblin Egg (cobbler)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["loud_walking:goblin_digger"])
m.name = 'loud_walking:goblin_coal'
m.hp_min = 7
m.hp_max = 15
m.armor = 90
m.textures = { {"goblins_goblin_coal1.png"}, {"goblins_goblin_coal2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['coal']
minetest.registered_entities["loud_walking:goblin_coal"] = m

mobs:register_egg("loud_walking:goblin_coal", "Goblin Egg (coal)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["loud_walking:goblin_digger"])
m.name = 'loud_walking:goblin_copper'
m.damage = 2
m.hp_min = 7
m.hp_max = 15
m.armor = 70
m.textures = { {"goblins_goblin_copper1.png"}, {"goblins_goblin_copper2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['copper']
minetest.registered_entities["loud_walking:goblin_copper"] = m

mobs:register_egg("loud_walking:goblin_copper", "Goblin Egg (copper)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["loud_walking:goblin_digger"])
m.name = 'loud_walking:goblin_diamond'
m.damage = 3
m.hp_min = 7
m.hp_max = 15
m.armor = 50
m.textures = { {"goblins_goblin_diamond1.png"}, {"goblins_goblin_diamond2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['diamond']
minetest.registered_entities["loud_walking:goblin_diamond"] = m

mobs:register_egg("loud_walking:goblin_diamond", "Goblin Egg (diamond)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["loud_walking:goblin_digger"])
m.name = 'loud_walking:goblin_gold'
m.damage = 3
m.hp_min = 7
m.hp_max = 15
m.armor = 60
m.textures = { {"goblins_goblin_gold1.png"}, {"goblins_goblin_gold2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['gold']
minetest.registered_entities["loud_walking:goblin_gold"] = m

mobs:register_egg("loud_walking:goblin_gold", "Goblin Egg (gold)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["loud_walking:goblin_digger"])
m.name = 'loud_walking:goblin_ice'
m.textures = { {"loud_walking_goblin_ice2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['ice']
minetest.registered_entities["loud_walking:goblin_ice"] = m

mobs:register_egg("loud_walking:goblin_ice", "Goblin Egg (ice)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["loud_walking:goblin_digger"])
m.name = 'loud_walking:goblin_iron'
m.damage = 2
m.hp_min = 7
m.hp_max = 15
m.armor = 80
m.textures = { {"goblins_goblin_iron1.png"}, {"goblins_goblin_iron2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['iron']
minetest.registered_entities["loud_walking:goblin_iron"] = m

mobs:register_egg("loud_walking:goblin_iron", "Goblin Egg (iron)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["loud_walking:goblin_digger"])
m.name = 'loud_walking:goblin_king'
m.damage = 3
m.hp_min = 10
m.hp_max = 20
m.armor = 40
m.textures = { {"goblins_goblin_king.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['king']
minetest.registered_entities["loud_walking:goblin_king"] = m

mobs:register_egg("loud_walking:goblin_king", "Goblin Egg (king)", "default_mossycobble.png", 1)


---------------------------------------------------------------
-- Traps
---------------------------------------------------------------

minetest.register_node("loud_walking:mossycobble_trap", {
	description = "Messy Gobblestone",
	tiles = {"default_mossycobble.png"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1, trap = 1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	light_source =  4,
})

minetest.register_craft({
	type = "cooking",
	output = "default:stone",
	recipe = "loud_walking:mossycobble_trap",
})

minetest.register_node("loud_walking:stone_with_coal_trap", {
	description = "Coal Trap",
	tiles = {"default_cobble.png^default_mineral_coal.png"},
	groups = {cracky = 3, trap = 1},
	drop = 'default:coal_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

if minetest.registered_nodes['tnt:tnt_burning'] then
	-- 5... 4... 3... 2... 1...
	loud_walking.diamond_trap = function(pos, player)
		if not (pos and player) then
			return
		end

		minetest.set_node(pos, {name="tnt:tnt_burning"})
		local timer = minetest.get_node_timer(pos)
		if timer then
			timer:start(5)
		end
		minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
	end
else
	-- wimpier trap for non-tnt settings
	loud_walking.diamond_trap = function(pos, player)
		if not (pos and player) then
			return
		end

		minetest.set_node(pos, {name="default:lava_source"})
		local hp = player:get_hp()
		if hp > 0 then
			player:set_hp(hp - 2)
			minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
		end
	end
end

minetest.register_node("loud_walking:stone_with_diamond_trap", {
	description = "Diamond Trap",
	tiles = {"default_cobble.png^(default_mineral_diamond.png^[colorize:#000000:160)"},
	groups = {cracky = 3, trap = 1},
	drop = 'default:diamond',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_dig = function(pos, node, digger)
		if not (pos and digger) then
			return
		end

		if math.random(3) == 1 then
			loud_walking.diamond_trap(pos, digger)
		else
			minetest.node_dig(pos, node, digger)
		end
	end
})


newnode = loud_walking.clone_node("default:lava_source")
newnode.description = "Molten Gold Source"
newnode.wield_image = "goblins_molten_gold.png"
newnode.tiles[1].name = "goblins_molten_gold_source_animated.png"
newnode.special_tiles[1].name = "goblins_molten_gold_source_animated.png"
newnode.liquid_alternative_flowing = "loud_walking:molten_gold_flowing"
newnode.liquid_alternative_source = "loud_walking:molten_gold_source"
newnode.liquid_renewable = false
newnode.post_effect_color = {a=192, r=255, g=64, b=0}
minetest.register_node("loud_walking:molten_gold_source", newnode)

newnode = loud_walking.clone_node("default:lava_flowing")
newnode.description = "Flowing Molten Gold"
newnode.wield_image = "goblins_molten_gold.png"
newnode.tiles = {"goblins_molten_gold.png"}
newnode.special_tiles[1].name = "goblins_molten_gold_flowing_animated.png"
newnode.liquid_alternative_flowing = "loud_walking:molten_gold_flowing"
newnode.liquid_alternative_source = "loud_walking:molten_gold_source"
newnode.liquid_renewable = false
newnode.post_effect_color = {a=192, r=255, g=64, b=0}
minetest.register_node("loud_walking:molten_gold_flowing", newnode)

bucket.register_liquid(
	"loud_walking:molten_gold_source",
	"loud_walking:molten_gold_flowing",
	"loud_walking:bucket_molten_gold",
	"loud_walking_bucket_molten_gold.png",
	"Bucket of Molten Gold",
	{}
)

loud_walking.gold_trap = function(pos, player)
	if not (pos and player) then
		return
	end

	minetest.set_node(pos, {name="loud_walking:molten_gold_source"})
	minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
	local hp = player:get_hp()
	if hp > 0 then
		player:set_hp(hp - 2)
	end
end

minetest.register_node("loud_walking:stone_with_gold_trap", {
	description = "Gold Trap",
	tiles = {"default_cobble.png^(default_mineral_gold.png^[colorize:#000000:160)"},
	groups = {cracky = 3, trap = 1},
	drop = 'default:gold_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_dig = function(pos, node, digger)
		if not (pos and digger) then
			return
		end

		if math.random(3) == 1 then
			loud_walking.gold_trap(pos, digger)
		else
			minetest.node_dig(pos, node, digger)
		end
	end
})


loud_walking.ice_trap = function(pos, player)
		if not (pos and player) then
			return
		end

	local ppos = player:getpos()
	if ppos then
		ppos.y = ppos.y + 1
		local p1 = vector.subtract(ppos, 2)
		local p2 = vector.add(ppos, 2)
		local nodes = minetest.find_nodes_in_area(p1, p2, 'air')
		if not (nodes and type(nodes) == 'table') then
			return
		end

		for _, npos in pairs(nodes) do
			minetest.set_node(npos, {name="default:ice"})
		end

		minetest.set_node(pos, {name="default:ice"})
	end
end

minetest.register_node("loud_walking:ice_trap", {
	description = "Ice Trap",
	tiles = {"default_ice.png^loud_walking_mineral_moonstone.png"},
	groups = {cracky = 3, trap = 1},
	drop = 'default:ice',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_dig = function(pos, node, digger)
		if not (pos and digger) then
			return
		end

		if math.random(3) == 1 then
			loud_walking.ice_trap(pos, digger)
		else
			minetest.node_dig(pos, node, digger)
		end
	end
})


local function lightning_effects(pos, radius)
		if not (pos and radius) then
			return
		end

	minetest.add_particlespawner({
		amount = 30,
		time = 1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x=-10, y=-10, z=-10},
		maxvel = {x=10,  y=10,  z=10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 3,
		minsize = 16,
		maxsize = 32,
		texture = "goblins_lightning.png",
	})
end

loud_walking.copper_trap = function(pos, player)
	if not (pos and player) then
		return
	end

	local hp = player:get_hp()
	if hp > 0 then
		player:set_hp(hp - 1)
		lightning_effects(pos, 3)
		minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
	end
end

minetest.register_node("loud_walking:stone_with_copper_trap", {
	description = "Copper Trap",
	tiles = {"default_cobble.png^(default_mineral_copper.png^[colorize:#000000:160)"},
	groups = {cracky = 3, trap = 1},
	drop = 'default:copper_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_dig = function(pos, node, digger)
		if not (pos and digger) then
			return
		end

		if math.random(3) == 1 then
			loud_walking.copper_trap(pos, digger)
		else
			minetest.node_dig(pos, node, digger)
		end
	end
})


-- summon a metallic goblin?
-- pit of iron razors?
minetest.register_node("loud_walking:stone_with_iron_trap", {
	description = "Iron Trap",
	tiles = {"default_cobble.png^(default_mineral_iron.png^[colorize:#000000:160)"},
	groups = {cracky = 3, trap = 1},
	drop = 'default:iron_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_dig = function(pos, node, digger)
		if not (pos and digger) then
			return
		end

		if math.random(3) == 1 then
			loud_walking.copper_trap(pos, digger)
		else
			minetest.node_dig(pos, node, digger)
		end
	end
})


-- goblin spawner

minetest.register_node("loud_walking:goblin_spawner", {
	--tiles = {"default_obsidian.png^[colorize:#00FF00:10"},
	tiles = {"default_obsidian.png"},
	paramtype = "light",
	description = "Goblin Throne",
	groups = {cracky = 2, falling_node = 1},
	light_source = 4,
	drop = 'default:mossycobble',
	drawtype = "nodebox",
	node_box = { type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.4, 0.25, 0.0, 0.4},  -- seat
			{-0.25, 0.0, -0.25, -0.2, 0.5, 0.25},  -- back
			{-0.25, 0.5, -0.4, -0.2, 1.0, 0.4},  -- back
		} },
})

local goblins = {}
goblins['loud_walking:goblin_king'] = 1
goblins['loud_walking:goblin_diamond'] = 2
goblins['loud_walking:goblin_gold'] = 2
goblins['loud_walking:goblin_copper'] = 4
goblins['loud_walking:goblin_iron'] = 4
goblins['loud_walking:goblin_coal'] = 8
goblins['loud_walking:goblin_digger'] = 8
goblins['loud_walking:goblin_cobbler'] = 8
local goblins_total = 0
for name, rate in pairs(goblins) do
	goblins_total = goblins_total + rate
end

-- spawner abm
minetest.register_abm({
	nodenames = {"loud_walking:goblin_spawner"},
	interval = 4,
	chance = 6,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)
		-- check objects inside 9x9 area around spawner
		local objs = minetest.get_objects_inside_radius(pos, 9)
		local count = 0

		-- count mob objects of same type in area
		for k, obj in pairs(objs) do
			local ent = obj:get_luaentity()

			if ent and string.find(ent.name, 'goblin') then
				count = count + 1
			end
		end

		-- Are there too many of same type?
		if count >= 12 then
			return
		end

		-- find air blocks within 5 nodes of spawner
		local air = minetest.find_nodes_in_area(
			{x = pos.x - 5, y = pos.y, z = pos.z - 5},
			{x = pos.x + 5, y = pos.y, z = pos.z + 5},
			{"air"})

		-- spawn in random air block
		if air and #air > 0 then
			local choose
			local r = math.random(goblins_total)
			for name, rate in pairs(goblins) do
				if r <= rate then
					choose = name
					break
				else
					r = r - rate
				end
			end

			local pos2 = air[math.random(#air)]
			--local lig = minetest.get_node_light(pos2) or 0

			pos2.y = pos2.y + 0.5

			-- only if light levels are within range
			--if lig >= mlig and lig <= xlig then
			minetest.add_entity(pos2, choose)
			--end
		end
	end
})
