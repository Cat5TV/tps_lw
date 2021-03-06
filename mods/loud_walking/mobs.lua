-- search/replace -- lets mobs change the terrain
-- used for goblin traps and torch thieving
loud_walking.search_replace = function(pos, search_rate, replace_what, replace_with)
	if not (pos and search_rate and replace_what and replace_with and type(search_rate) == 'number' and (type(replace_what) == 'string' or type(replace_what) == 'table') and type(replace_with) == 'string') then
		return
	end

	if math.random(search_rate) == 1 then
		local p1 = vector.subtract(pos, 1)
		local p2 = vector.add(pos, 1)

		--look for nodes
		local nodelist = minetest.find_nodes_in_area(p1, p2, replace_what)
		if not (nodelist and type(nodelist) == 'table') then
			return
		end

		if #nodelist > 0 then
			for _, new_pos in pairs(nodelist) do 
				minetest.set_node(new_pos, {name = replace_with})
				return true  -- only one at a time
			end
		end
	end
end

-- causes mobs to take damage from hot/cold surfaces
loud_walking.surface_damage = function(self, cold_natured)
	if not self then
		return
	end

	local pos = self.object:getpos()
	if not pos then
		return
	end

	local minp = vector.subtract(pos, 1.5)
	local maxp = vector.add(pos, 1.5)
	local counts = 0
	if self.lava_damage > 1 then
		counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_hot"})
		if not (counts and type(counts) == 'table') then
			return
		end

		if #counts > 0 then
			self.health = self.health - math.floor(self.lava_damage / 2)
			effect(pos, 5, "fire_basic_flame.png")
		end
	end

	if not cold_natured then
		counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_cold"})
		if not (counts and type(counts) == 'table') then
			return
		end

		if #counts > 0 then
			self.health = self.health - 1
		end
	end

	check_for_death(self)

end

-- executed in a mob's do_custom() to regulate their actions
-- if false, do nothing
local custom_delay = 2000000
loud_walking.custom_ready = function(self, delay)
	if not self then
		return
	end

	local time = minetest.get_us_time()
	if not (time and type(time) == 'number') then
		return
	end

	if not delay then
		delay = custom_delay
	end

	if not self.custom_time or time - self.custom_time > delay then
		self.custom_time = time
		return true
	else
		return false
	end
end


-- Try to standardize creature stats based on (log of) mass.
local mob_stats = {
	{name = 'kpgmobs:deer', hp = 20, damage = 2, armor = 100, reach = 2},
	{name = 'kpgmobs:horse2', hp = 30, damage = 3, armor = 100, reach = 2},
	{name = 'kpgmobs:horse3', hp = 30, damage = 3, armor = 100, reach = 2},
	{name = 'kpgmobs:horse', hp = 30, damage = 3, armor = 100, reach = 2},
	{name = 'kpgmobs:jeraf', hp = 32, damage = 3, armor = 100, reach = 2},
	{name = 'kpgmobs:medved', hp = 26, damage = 3, armor = 100, reach = 2},
	{name = 'kpgmobs:wolf', hp = 18, damage = 3, armor = 100, reach = 1},
	{name = 'mobs_animal:bee', hp = 1, damage = 1, armor = 200, reach = 1},
	{name = 'mobs_animal:bunny', hp = 2, damage = 1, armor = 100, reach = 1},
	{name = 'mobs_animal:chicken', hp = 8, damage = 1, armor = 150, reach = 1},
	{name = 'mobs_animal:cow', hp = 30, damage = 3, armor = 150, reach = 1},
	{name = 'mobs_animal:kitten', hp = 8, damage = 1, armor = 100, reach = 1},
	{name = 'mobs_animal:pumba', hp = 20, damage = 2, armor = 100, reach = 1},
	{name = 'mobs_animal:rat', hp = 2, damage = 1, armor = 100, reach = 1},
	{name = 'mobs_animal:sheep', hp = 18, damage = 1, armor = 150, reach = 1},
	{name = 'mobs_bat:bat', hp = 2, damage = 1, armor = 150, reach = 1},
	{name = 'mobs_birds:bird_lg', hp = 4, damage = 1, armor = 150, reach = 1},
	{name = 'mobs_birds:bird_sm', hp = 2, damage = 1, armor = 150, reach = 1},
	{name = 'mobs_birds:gull', hp = 4, damage = 1, armor = 150, reach = 1},
	{name = 'mobs_butterfly:butterfly', hp = 1, damage = 0, armor = 200, reach = 1},
	{name = 'mobs_creeper:creeper', hp = 14, damage = 2, armor = 150, reach = 1},
	{name = 'mobs_crocs:crocodile_float', hp = 26, damage = 3, armor = 75, reach = 2},
	{name = 'mobs_crocs:crocodile', hp = 26, damage = 3, armor = 75, reach = 2},
	{name = 'mobs_crocs:crocodile_swim', hp = 26, damage = 3, armor = 75, reach = 2},
	{name = 'mobs_fish:clownfish', hp = 2, damage = 0, armor = 100, reach = 1},
	{name = 'mobs_fish:tropical', hp = 2, damage = 0, armor = 100, reach = 1},
	{name = 'mobs_jellyfish:jellyfish', hp = 2, damage = 2, armor = 200, reach = 1},
	{name = 'mobs_monster:dirt_monster', hp = 20, damage = 2, armor = 100, reach = 2},
	{name = 'mobs_monster:dungeon_master', hp = 30, damage = 5, armor = 50, reach = 2},
	{name = 'mobs_monster:lava_flan', hp = 16, damage = 3, armor = 50, reach = 2},
	{name = 'mobs_monster:mese_monster', hp = 10, damage = 2, armor = 40, reach = 2},
	{name = 'mobs_monster:oerkki', hp = 16, damage = 2, armor = 100, reach = 2},
	{name = 'mobs_monster:sand_monster', hp = 20, damage = 2, armor = 200, reach = 2},
	{name = 'mobs_monster:spider', hp = 22, damage = 2, armor = 100, reach = 2},
	{name = 'mobs_monster:stone_monster', hp = 20, damage = 2, armor = 50, reach = 2},
	{name = 'mobs_monster:tree_monster', hp = 18, damage = 2, armor = 75, reach = 2},
	{name = 'mobs_sandworm:sandworm', hp = 42, damage = 7, armor = 100, reach = 3},
	{name = 'mobs_sharks:shark_lg', hp = 34, damage = 5, armor = 80, reach = 3},
	{name = 'mobs_sharks:shark_md', hp = 25, damage = 3, armor = 80, reach = 2},
	{name = 'mobs_sharks:shark_sm', hp = 16, damage = 2, armor = 80, reach = 1},
	{name = 'mobs_turtles:seaturtle', hp = 18, damage = 2, armor = 75, reach = 1},
	{name = 'mobs_turtles:turtle', hp = 10, damage = 1, armor = 50, reach = 1},
	{name = 'mobs_yeti:yeti', hp = 22, damage = 2, armor = 100, reach = 2},
}
local colors = { 'black', 'blue', 'brown', 'cyan', 'dark_green', 'dark_grey', 'green', 'grey', 'magenta', 'orange', 'pink', 'red', 'violet', 'white', 'yellow',}
for _, color in pairs(colors) do
	mob_stats[#mob_stats+1] = {name = 'mobs_animal:sheep_'..color, hp = 18, damage = 1, armor = 150}
end
for _, mob in pairs(mob_stats) do
	if string.find(mob.name, 'mobs_monster') or string.find(mob.name, 'mobs_animal') then
		local i, j = string.find(mob.name, ':')
		local suff = string.sub(mob.name, i)
		mob_stats[#mob_stats+1] = {name = 'mobs'..suff, hp = mob.hp, damage = mob.damage, armor = mob.armor}
	end
end

for _, mob in pairs(mob_stats) do
	if minetest.registered_entities[mob.name] then
		minetest.registered_entities[mob.name].damage = mob.damage
		minetest.registered_entities[mob.name].hp_min = math.ceil(mob.hp * 0.5)
		minetest.registered_entities[mob.name].hp_max = math.ceil(mob.hp * 1.5)
		minetest.registered_entities[mob.name].armor = mob.armor
		if mob.reach then
			minetest.registered_entities[mob.name].reach = mob.reach
		end
		if mob.meat then
			minetest.registered_entities[mob.name].drops[#minetest.registered_entities[mob.name].drops+1] = {name = "mobs:meat_raw", chance = 1, min = 1, max = mob.damage ^ 2}
		end
	end
end


if minetest.registered_entities["mobs:bee"] then
	mobs:register_spawn("mobs_animal:bee", {"group:flower"}, 20, 10, 300, 1, 31000, true)
end

if minetest.registered_entities["kpgmobs:wolf"] then
	local m = table.copy(minetest.registered_entities["kpgmobs:wolf"])
	m.name = 'loud_walking:white_wolf'
	m.textures = { {"loud_walking_white_wolf.png"}, }
	m.base_texture = m.textures[1]

	minetest.registered_entities["loud_walking:white_wolf"] = m
	mobs.spawning_mobs["loud_walking:white_wolf"] = true

	mobs:register_spawn("loud_walking:white_wolf", {"default:dirt_with_snow"}, 20, -1, 11000, 3, 31000)
	mobs:register_egg("loud_walking:white_wolf", "White Wolf", "wool_white.png", 1)
end

if minetest.registered_entities["kpgmobs:medved"] then
	local m = table.copy(minetest.registered_entities["kpgmobs:medved"])
	m.name = 'loud_walking:moon_bear'
	m.textures = { {"loud_walking_moon_bear.png"}, }
	m.type = 'monster'
	m.base_texture = m.textures[1]

	minetest.registered_entities["loud_walking:moon_bear"] = m
	mobs.spawning_mobs["loud_walking:moon_bear"] = true

	mobs:register_spawn("loud_walking:moon_bear", {"default:dirt_with_snow"}, 20, -1, 11000, 3, 31000, false)
	mobs:register_egg("loud_walking:moon_bear", "Moon Bear", "wool_white.png", 1)
end

if minetest.registered_entities["mobs_monster:spider"] then
	-- Deep spider
	local m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.name = 'loud_walking:spider'
	m.docile_by_day = false
	m.drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		{name = "wool:black", chance = 1, min = 1, max = 3},
	}
	m.water_damage = 0
	m.do_custom = function(self)
		if not (self and loud_walking.custom_ready(self)) then
			return
		end

		loud_walking.surface_damage(self)
	end

	minetest.registered_entities["loud_walking:spider"] = m
	mobs.spawning_mobs["loud_walking:spider"] = true

	mobs:register_spawn("loud_walking:spider", 'group:stone', 5, 0, 2000, 2, 31000)

	mobs:register_egg("loud_walking:spider", "Deep Spider", "mobs_cobweb.png", 1)


	-- ice spider
	m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.name = 'loud_walking:spider_ice'
	m.docile_by_day = false
	m.textures = { {"loud_walking_spider_ice.png"}, }
	m.base_texture = m.textures[1]
	m.drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		{name = "wool:white", chance = 1, min = 1, max = 3},
	}
	m.water_damage = 0
	m.do_custom = function(self)
		if not (self and loud_walking.custom_ready(self)) then
			return
		end

		loud_walking.surface_damage(self, true)
	end

	minetest.registered_entities["loud_walking:spider_ice"] = m
	mobs.spawning_mobs["loud_walking:spider_ice"] = true

	mobs:register_spawn("loud_walking:spider_ice", {"default:ice"}, 14, 0, 1000, 2, 31000)

	mobs:register_egg("loud_walking:spider_ice", "Ice Spider", "mobs_cobweb.png", 1)


	-- dangling spiders
	m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.name = 'loud_walking:dangler'
	m.docile_by_day = false
	m.attacks_monsters = true
	m.damage = 2
	m.hp_min = 9
	m.hp_max = 27
	m.armor = 100
	m.water_damage = 0
	m.fall_damage = 0
	m.collisionbox = {-0.32, -0.0, -0.25, 0.25, 0.25, 0.25}
	m.visual_size = {x = 1.5, y = 1.5}
	m.drops = {
		{name = "mobs:meat_raw", chance = 2, min = 1, max = 4},
		{name = "farming:cotton", chance = 2, min = 1, max = 4},
	}
	m.do_custom = function(self)
		if not (self and loud_walking.custom_ready(self)) then
			return
		end

		loud_walking.climb(self)
		loud_walking.search_replace(self.object:getpos(), 30, {"air"}, "mobs:cobweb")

		loud_walking.surface_damage(self)
	end

	minetest.registered_entities["loud_walking:dangler"] = m
	mobs.spawning_mobs["loud_walking:dangler"] = true

	--mobs:register_spawn("loud_walking:dangler", loud_walking_stones, 14, 0, 1000, 3, 31000)

	mobs:register_egg("loud_walking:dangler", "Dangling Spider", "mobs_cobweb.png", 1)


	-- tarantula
	m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.name = 'loud_walking:tarantula'
	m.type = "animal"
	m.reach = 1
	m.damage = 1
	m.hp_min = 1
	m.hp_max = 2
	m.collisionbox = {-0.15, -0.01, -0.15, 0.15, 0.1, 0.15}
	m.textures = { {"loud_walking_tarantula.png"}, }
	m.base_texture = m.textures[1]
	m.visual_size = {x = 1, y = 1}
	m.sounds = {}
	m.run_velocity = 2
	m.jump = false
	m.drops = { {name = "mobs:meat_raw", chance = 1, min = 1, max = 1}, }
	m.do_custom = function(self)
		if not self then
			return
		end

		if not self.loud_walking_damage_timer then
			self.loud_walking_damage_timer = 0
		end

		loud_walking.surface_damage(self)
	end
	minetest.registered_entities["loud_walking:tarantula"] = m
	mobs.spawning_mobs["loud_walking:tarantula"] = true

	mobs:register_spawn("loud_walking:tarantula", {"default:desert_sand", "default:dirt_with_dry_grass"}, 99, 0, 4000, 2, 31000)

	mobs:register_egg("loud_walking:tarantula", "Tarantula", "mobs_cobweb.png", 1)
end

if minetest.registered_entities["mobs_monster:sand_monster"] then
	local m = table.copy(minetest.registered_entities["mobs_monster:sand_monster"])
	m.name = 'loud_walking:tar_monster'
	m.damage = 2
	m.hp_min = 10
	m.hp_max = 30
	m.armor = 200
	m.textures = { {"loud_walking_tar_monster.png"}, }
	m.base_texture = m.textures[1]
	m.drops = { {name = "default:coal_lump", chance = 1, min = 3, max = 5}, }
	m.water_damage = 1
	m.lava_damage = 2
	m.light_damage = 1

	minetest.registered_entities["loud_walking:tar_monster"] = m
	mobs.spawning_mobs["loud_walking:tar_monster"] = true

	--mobs:register_spawn("loud_walking:tar_monster", {"loud_walking:black_sand"}, 20, 0, 4000, 1, 31000)

	mobs:register_egg("loud_walking:tar_monster", "Tar Monster", "loud_walking_black_sand.png", 1)


	m = table.copy(minetest.registered_entities["mobs_monster:sand_monster"])
	m.name = 'loud_walking:sand_monster'
	m.textures = { {"loud_walking_sand_monster.png"}, }
	m.base_texture = m.textures[1]
	m.drops = { {name = "default:sand", chance = 1, min = 3, max = 5}, }

	minetest.registered_entities["loud_walking:sand_monster"] = m
	mobs.spawning_mobs["loud_walking:sand_monster"] = true

	--mobs:register_spawn("loud_walking:sand_monster", {"default:sand"}, 20, 0, 4000, 3, 31000)

	mobs:register_egg("loud_walking:sand_monster", "Deep Sand Monster", "default_sand.png", 1)

	--mobs:register_spawn("loud_walking:sand_monster", {"loud_walking:pyramid_1"}, 20, 0, 150, 5, 31000)
end

if minetest.registered_entities["mobs_monster:stone_monster"] then
	--mobs:register_spawn("mobs_monster:stone_monster", {"loud_walking:pyramid_1"}, 20, 0, 300, 5, 31000)
	--local stones = table.copy(loud_walking_stones)
	--stones[#stones+1] = 'loud_walking:hot_cobble'
	--stones[#stones+1] = 'loud_walking:salt'
	--mobs:register_spawn("mobs_monster:stone_monster", stones, 7, 0, 7000, 1, 31000)

	m = table.copy(minetest.registered_entities["mobs_monster:stone_monster"])
	m.name = 'loud_walking:radiated_stone_monster'
	m.damage = 4
	m.hp_min = 20
	m.hp_max = 45
	m.armor = 70
	m.textures = { {"loud_walking_radiated_stone_monster.png"}, }
	m.base_texture = m.textures[1]
	m.drops = { {name = "loud_walking:radioactive_ore", chance = 1, min = 3, max = 5}, }

	minetest.registered_entities["loud_walking:radiated_stone_monster"] = m
	mobs.spawning_mobs["loud_walking:radiated_stone_monster"] = true

	--mobs:register_spawn("loud_walking:radiated_stone_monster", {"loud_walking:salt"}, 20, 0, 7000, 3, 31000)

	mobs:register_egg("loud_walking:radiated_stone_monster", "Radiated Stone Monster", "loud_walking_radioactive_ore.png", 1)

end

if minetest.registered_entities["mobs_monster:dungeon_master"] then
	mobs:register_spawn("mobs_monster:dungeon_master", 'group:stone', 7, 0, 7000, 1, 31000)
end

if minetest.registered_entities["mobs_monster:oerkki"] then
	mobs:register_spawn("mobs_monster:oerkki", 'group:stone', 7, 0, 7000, 1, 31000)
end

if minetest.registered_entities["mobs_monster:mese_monster"] then
	mobs:register_spawn("mobs_monster:mese_monster", 'group:stone', 7, 0, 5000, 1, 31000)
end

if minetest.registered_entities["mobs_bat:bat"] then
	mobs:spawn_specific("mobs_bat:bat", {"air"}, 'group:stone', 0, 6, 30, 20000, 2, -31000, 31000)
end

if minetest.registered_entities["mobs_monster:dirt_monster"] then
	-- check this
	mobs:register_spawn("mobs_monster:dirt_monster", {"default:dirt_with_dry_grass"}, 7, 0, 7000, 1, 31000, false)
end

if loud_walking.path then
	dofile(loud_walking.path.."/greenslimes.lua")
	dofile(loud_walking.path.."/dmobs.lua")
	dofile(loud_walking.path.."/goblin.lua")
end
