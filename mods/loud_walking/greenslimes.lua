--  **CODE**
--  --------
--  See Mobs.Redo license
--  
--  
--  **MODELS/TEXTURES**
--  -------------------
--  WTFPL
--  Author/origin: Tomas J. Luis
--  
--  Jeija_glue texture by: Jeija
--  
--  **SOUNDS**
--  ----------
--  Original sound for slime damage by RandomationPictures under licence CC0 1.0.
--  http://www.freesound.org/people/RandomationPictures/sounds/138481/
--  
--  Original sounds for slime jump, land and death by Dr. Minky under licence CC BY 3.0.
--  http://www.freesound.org/people/DrMinky/sounds/

local ENABLE_SPAWN_NODE = true

-- sounds
local green_sounds = {
	damage = "slimes_damage",
	death = "slimes_death",
	jump = "slimes_jump",
	attack = "slimes_attack"
}

-- textures
local green_textures = {"green_slime_sides.png", "green_slime_sides.png", "green_slime_sides.png",
	"green_slime_sides.png", "green_slime_front.png", "green_slime_sides.png"}

-- small
mobs:register_mob("loud_walking:green_small", {
	type = "monster",
	visual = "cube",
	textures = { green_textures },
	visual_size = {x = 0.5, y = 0.5},
	collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	sounds = green_sounds,
	hp_min = 2,
	hp_max = 4,
	armor = 100,
	knock_back = 3,
	blood_amount = 3,
	blood_texture = "green_slime_blood.png",
	lava_damage = 3,
	fall_damage = 0,
	damage = 1,
	reach = 1,
	attack_type = "dogfight",
	attacks_monsters = true,
	view_range = 10,
	walk_chance = 0,
	walk_velocity = 2,
	stepheight = 0.6,
	jump_chance = 60,
	drops = {
		{name = "loud_walking:green_slimeball", chance = 2, min = 1, max = 2},
	}
})

-- medium
mobs:register_mob("loud_walking:green_medium", {
	type = "monster",
	visual = "cube",
	textures = { green_textures },
	visual_size = {x = 1, y = 1},
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	sounds = green_sounds,
	hp_min = 4,
	hp_max = 8,
	armor = 100,
	knock_back = 2,
	blood_amount = 4,
	blood_texture = "green_slime_blood.png",
	lava_damage = 7,
	fall_damage = 0,
	damage = 2,
	reach = 2,
	attack_type = "dogfight",
	attacks_monsters = true,
	view_range = 10,
	walk_chance = 0,
	walk_velocity = 2,
	stepheight = 1.1,
	jump_chance = 60,
	on_die = function(self, pos)
		local num = math.random(2, 4)
		for i=1,num do
			minetest.add_entity({x=pos.x + math.random(-2, 2), y=pos.y + 1, z=pos.z + (math.random(-2, 2))}, "loud_walking:green_small")
		end
	end
})

-- big
mobs:register_mob("loud_walking:green_big", {
	type = "monster",
	visual = "cube",
	textures = { green_textures },
	visual_size = {x = 2, y = 2},
	collisionbox = {-1, -1, -1, 1, 1, 1},
	sounds = green_sounds,
	hp_min = 6,
	hp_max = 12,
	armor = 100,
	knock_back = 1,
	blood_amount = 5,
	blood_texture = "green_slime_blood.png",
	lava_damage = 11,
	fall_damage = 0,
	damage = 3,
	reach = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	view_range = 10,
	walk_chance = 0,
	walk_velocity = 2,
	stepheight = 1.1,
	jump_chance = 60,
	on_die = function(self, pos)
		local num = math.random(1, 2)
		for i=1,num do
			minetest.add_entity({x=pos.x + math.random(-2, 2), y=pos.y + 1, z=pos.z + (math.random(-2, 2))}, "loud_walking:green_medium")
		end
	end
})

--name, nodes, neighbors, min_light, max_light, interval, chance, active_object_count, min_height, max_height
mobs:spawn_specific("loud_walking:green_big",
	{"default:dirt_with_grass", "default:junglegrass", "default:mossycobble"},
	{"air"},
	-1, 20, 30, 30000, 1, -31000, 31000
)
mobs:spawn_specific("loud_walking:green_medium",
	{"default:dirt_with_grass", "default:junglegrass", "default:mossycobble"},
	{"air"},
	-1, 20, 30, 30000, 2, -31000, 31000
)
mobs:spawn_specific("loud_walking:green_small",
	{"default:dirt_with_grass", "default:junglegrass", "default:mossycobble"},
	{"air"},
	-1, 20, 30, 30000, 3, -31000, 31000
)

mobs:register_egg("loud_walking:green_small", "Small Green Slime", "green_slime_front.png", 0)
mobs:register_egg("loud_walking:green_medium", "Medium Green Slime", "green_slime_front.png", 0)
mobs:register_egg("loud_walking:green_big", "Big Green Slime", "green_slime_front.png", 0)

-- crafts
minetest.register_craftitem("loud_walking:green_slimeball", {
	image = "jeija_glue.png",
	description="Green Slime Ball",
})
