-- This was taken more or less intact from loud_walking by D00Med

mobs:register_mob("loud_walking:fox", {
	type = "animal",
	attacks_monsters = true,
	reach = 1,
	damage = 1,
	attack_type = "dogfight",
	hp_min = 4,
	hp_max = 8,
	armor = 100,
	collisionbox = {-0.4, -0.6, -0.4, 0.3, 0.3, 0.3},
	runaway = true,
	pathfinding = true,
	visual = "mesh",
	mesh = "fox.b3d",
	textures = {
		{"dmobs_fox.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=1.5, y=1.5},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 2.5,
	jump = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	replace_rate = 10,
	replace_what = {"farming:wheat_5", "default:fence_wood", "default:grass_5", "default:dirt_with_grass"},
	replace_with = "air",
	follow = {"mobs:meat_raw"},
	view_range = 14,
	animation = {
		speed_normal = 6,
		speed_run = 15,
		walk_start = 25,
		walk_end = 35,
		stand_start = 51,
		stand_end = 60,
		run_start = 1,
		run_end = 16,
		punch_start = 36,
		punch_end = 51,
	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})

mobs:register_spawn("loud_walking:fox", {"default:dirt_with_grass","default:dirt"}, 20, 10, 15000, 2, 31000)

mobs:register_egg("loud_walking:fox", "Fox", "wool_orange.png", 1)


mobs:register_mob("loud_walking:hedgehog", {
	type = "animal",
	passive = true,
	hp_min = 1,
	hp_max = 2,
	armor = 100,
	collisionbox = {-0.1, -0.1, -0.2, 0.2, 0.2, 0.2},
	visual = "mesh",
	mesh = "hedgehog.b3d",
	textures = {
		{"dmobs_hedgehog.png"},
	},
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=2, y=2},
	makes_footstep_sound = true,
	walk_velocity = 0.5,
	run_velocity = 1,
	jump = true,
	water_damage = 2,
	lava_damage = 2,
	light_damage = 0,
	view_range = 14,
	follow = {"farming:bread"},
	animation = {
		speed_normal = 5,
		speed_run = 10,
		walk_start = 1,
		walk_end = 10,
		stand_start = 1,
		stand_end = 10,
		run_start = 1,
		run_end = 10,

	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})

mobs:register_spawn("loud_walking:hedgehog", {"default:dirt_with_grass","default:pine_needles"}, 20, 10, 15000, 2, 31000)

mobs:register_egg("loud_walking:hedgehog", "Hedgehog", "wool_brown.png", 1)


mobs:register_mob("loud_walking:elephant", {
	type = "monster",
	passive = false,
	reach = 3,
	damage = 5,
	attack_type = "dogfight",
	hp_min = 24,
	hp_max = 40,
	armor = 75,
	collisionbox = {-0.9, -1.2, -0.9, 0.9, 0.9, 0.9},
	visual = "mesh",
	mesh = "elephant.b3d",
	textures = {
		{"dmobs_elephant.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=2.5, y=2.5},
	makes_footstep_sound = true,
	walk_velocity = 0.5,
	run_velocity = 1,
	jump = false,
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	replace_rate = 10,
	replace_what = {"default:grass_3", "default:grass_4", "default:grass_5", "ethereal:bamboo"},
	replace_with = "air",
	follow = {"farming:wheat"},
	view_range = 14,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 9},
	},
	animation = {
		speed_normal = 5,
		speed_run = 10,
		walk_start = 3,
		walk_end = 19,
		stand_start = 20,
		stand_end = 30,
		run_start = 3,
		run_end = 19,

	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})

mobs:register_spawn("loud_walking:elephant", {"default:dirt_with_dry_grass","default:desert_sand"}, 20, 10, 15000, 2, 31000)

mobs:register_egg("loud_walking:elephant", "Elephant", "default_dry_grass.png", 1)


mobs:register_mob("loud_walking:whale", {
	type = "animal",
	passive = false,
	reach = 2,
	damage = 5,
	attack_type = "dogfight",
	hp_min = 52,
	hp_max = 82,
	armor = 100,
	collisionbox = {-0.9, -1.2, -0.9, 0.9, 0.9, 0.9},
	visual = "mesh",
	mesh = "whale.b3d",
	rotate = 180,
	textures = {
		{"dmobs_whale.png"},
	},
	sounds = {
		random = "whale_1",
		death = "whale_1",
		distance = 128,
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=2.5, y=2.5},
	makes_footstep_sound = true,
	walk_velocity = 0.5,
	run_velocity = 1,
	jump = false,	
	stepheight = 1.5,
	fall_damage = 0,
	fall_speed = -6,
	fly = true,
	fly_in = "default:water_source",
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"fishing:fish_cooked"},
	view_range = 14,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	animation = {
		speed_normal = 5,
		speed_run = 10,
		walk_start = 2,
		walk_end = 39,
		stand_start = 2,
		stand_end = 39,
		run_start = 2,
		run_end = 39,

	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})

mobs:register_spawn("loud_walking:whale", {"default:water_source"}, 20, 1, 15000, -20, 31000)

mobs:register_egg("loud_walking:whale", "Whale", "default_water_source.png", 1)


mobs:register_mob("loud_walking:orc", {
	type = "monster",
	passive = false,
	reach = 2,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 12,
	hp_max = 22,
	armor = 100,
	collisionbox = {-0.4, -1.3, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "orc.b3d",
	textures = {
		{"dmobs_orc.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 4},
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 20,
		walk_start = 2,
		walk_end = 18,
		stand_start = 30,
		stand_end = 40,
		run_start = 2,
		run_end = 18,
		punch_start = 20,
		punch_end = 30,

	},
})

mobs:register_spawn("loud_walking:orc", {'group:stone', "default:snow","default:snow_block", "default:desert_sand"}, 20, -1, 11000, 2, 31000)

mobs:register_egg("loud_walking:orc", "Orc", "default_desert_sand.png", 1)


mobs:register_mob("loud_walking:ogre", {
	type = "monster",
	passive = false,
	reach = 3,
	damage = 3,
	attack_type = "dogfight",
	hp_min = 15,
	hp_max = 26,
	armor = 70,
	collisionbox = {-0.6, -1.3, -0.6, 0.6, 1.5, 0.6},
	visual = "mesh",
	mesh = "ogre.b3d",
	textures = {
		{"dmobs_ogre.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=3.5, y=3.5},
	makes_footstep_sound = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 9},
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	rotate = 180,
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 20,
		walk_start = 3,
		walk_end = 38,
		stand_start = 40,
		stand_end = 70,
		run_start = 3,
		run_end = 38,
		punch_start = 70,
		punch_end = 100,

	},
})

mobs:register_spawn("loud_walking:ogre", {"default:snow","default:dirt_with_dry_grass", "default:desert_sand"}, 20, 10, 15000, 2, 31000)

mobs:register_egg("loud_walking:ogre", "Ogre", "default_desert_sand.png", 1)


mobs:register_mob("loud_walking:badger", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 6,
	hp_max = 12,
	armor = 100,
	collisionbox = {-0.3, -0.15, -0.3, 0.3, 0.4, 0.3},
	visual = "mesh",
	mesh = "badger.b3d",
	textures = {
		{"dmobs_badger.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=2, y=2},
	makes_footstep_sound = true,
	walk_velocity = 0.7,
	run_velocity = 1,
	jump = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 2},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"mobs:meat_raw"},
	view_range = 14,
	animation = {
		speed_normal = 12,
		speed_run = 18,
		walk_start = 34,
		walk_end = 58,
		stand_start = 1,
		stand_end = 30,
		run_start = 34,
		run_end = 58,
		punch_start = 60,
		punch_end = 80,

	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})

mobs:register_spawn("loud_walking:badger", {"default:dirt_with_grass","default:dirt"}, 20, 10, 15000, 2, 31000)

mobs:register_egg("loud_walking:badger", "Badger", "default_obsidian.png", 1)


--dragon

mobs:register_mob("loud_walking:dragon", {
   type = "monster",
   passive = false,
   attacks_monsters = true,
   damage = 6,
   reach = 3,
   attack_type = "dogshoot",
   shoot_interval = 2.5,
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max =5,
   arrow = "loud_walking:fireball",
   shoot_offset = 1,
   hp_min = 30,
   hp_max = 40,
   armor = 50,
	collisionbox = {-0.6, -1.2, -0.6, 0.6, 0.6, 0.6},
   visual = "mesh",
   mesh = "dragon.b3d",
   textures = {
      {"dmobs_dragon.png"},
      {"dmobs_dragon2.png"},
      {"dmobs_dragon3.png"},
      {"dmobs_dragon4.png"},
   },
   blood_texture = "mobs_blood.png",
   visual_size = {x=2, y=2},
   makes_footstep_sound = true,
	runaway = false,
	jump_chance = 30,
	walk_chance = 80,
	fall_speed = 0,
	pathfinding = true,
	fall_damage = 0,
   sounds = {
      shoot_attack = "mobs_fireball",
   },
   walk_velocity = 3,
   run_velocity = 5,
   jump = true,
   fly = true,
   drops = {
      {name = "mobs:lava_orb", chance = 1, min = 1, max = 1},
      {name = "mobs:meat_raw", chance = 1, min = 1, max = 9},
   },
   fall_speed = 0,
   stepheight = 10,
   water_damage = 2,
   lava_damage = 0,
   light_damage = 0,
   view_range = 20,
   animation = {
      speed_normal = 10,
      speed_run = 20,
      walk_start = 1,
      walk_end = 22,
      stand_start = 1,
      stand_end = 22,
      run_start = 1,
      run_end = 22,
      punch_start = 22,
      punch_end = 47,
   },
	knock_back = 2,
})

--Thanks to Tenplus1
mobs:register_arrow("loud_walking:fireball", {
   visual = "sprite",
   visual_size = {x = 0.5, y = 0.5},
   textures = {"dmobs_fire.png"},
   velocity = 8,
   tail = 1, -- enable tail
   tail_texture = "fire_basic_flame.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 8},
      }, nil)
   end,
   
   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 8},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      mobs:explosion(pos, 2, 1, 1)
   end,
})


mobs:spawn_specific("loud_walking:dragon", {"air"}, {"default:stone"}, 20, 10, 300, 15000, 2, -31000, 31000)
   
mobs:register_egg("loud_walking:dragon", "Dragon", "default_apple.png", 1)

if minetest.registered_entities["mobs_yeti:yeti"] then
	local m = table.copy(minetest.registered_entities["loud_walking:dragon"])
	m.name = 'loud_walking:snow_dragon'
	m.lava_damage = 4
	m.textures = { {"squaresville_snow_dragon.png"}, }
	m.base_texture = m.textures[1]
	m.arrow = "loud_walking:snow_blast"
	m.attack_type = 'dogshoot'
	m.shoot_interval = .7
	m.shoot_offset = 2
	m.drops = {
		{name = "default:ice", chance = 1, min = 1, max = 3},
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 9},
	}

	minetest.registered_entities["loud_walking:snow_dragon"] = m
	mobs.spawning_mobs["loud_walking:snow_dragon"] = true

	local m = table.copy(minetest.registered_entities["mobs_yeti:snowball"])
	m.hit_player = function(self, player)
		if not (self and player) then
			return
		end

		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end

	m.hit_mob = function(self, player)
		if not (self and player) then
			return
		end

		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end

	minetest.registered_entities["loud_walking:snow_blast"] = m

	mobs:spawn_specific("loud_walking:snow_dragon", {"air"}, {'default:snow', 'default:ice', 'default:snow_block'}, -1, 20, 300, 15000, 2, -31000, 31000)
end
