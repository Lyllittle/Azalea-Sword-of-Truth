extends Node

# __________ VARIABLES AND CONSTANTS __________

var base_attacks = {
	"slash": {
		"damage": 25,
		"traits": ["melee", "quick","blade_projectile"],
		"difficulty_pattern": {
			"pattern": "add", "value": 0
		},
		"mana_cost": 0,
		"name": "Slash",
		"description": "A quick, sharp strike that deals moderate damage to enemies in close proximity."
	},
	"pierce": {
		"damage": 30,
		"traits": ["sharp_projectile","melee", "piercing", "high_velocity"],
		"difficulty_pattern": {
			"pattern": "add", "value": 1
		},
		"mana_cost": 0,
		"name": "Pierce",
		"description": "A thrusting attack that pierces through enemies, dealing damage in a straight line."
	},
	"spike_shot": {
		"damage": 50,
		"traits": ["high_velocity", "sharp_projectile"],
		"difficulty_pattern": {
			"pattern": "add", "value": 0
		},
		"mana_cost": 0,
		"name": "Spike Shot",
		"description": "A spiked projectile shot in a straight line that deals damage and can pierce through enemies."
	},
	"hammer_strike": {
		"damage": 40,
		"traits": ["melee", "stun", "area_of_effect", "slow"],
		"difficulty_pattern": {
			"pattern": "add", "value": 2
		},
		"mana_cost": 0,
		"name": "Hammer Strike",
		"description": "A powerful smash that deals high damage to enemies in a small area and slows them down."
	},
	"axe_swing": {
		"damage": 35,
		"traits": ["melee", "stun", "wide_melee", "area_of_effect"],
		"difficulty_pattern": {
			"pattern": "multiply", "value": 1.1
		},
		"mana_cost": 0,
		"name": "Axe Swing",
		"description": "A wide swing of an axe that damages all enemies within range."
	},
	"kick": {
		"damage": 15,
		"traits": ["melee", "stun", "knockback", "high_velocity", "hand_projectile"],
		"difficulty_pattern": {
			"pattern": "add", "value": 0
		},
		"mana_cost": 0,
		"name": "Kick",
		"description": "A strong kick that pushes enemies away and deals moderate damage."
	},
	"charge": {
		"damage": 45,
		"traits": ["melee", "slower_attack", "knockback", "hand_projectile", "solid_projectile"],
		"difficulty_pattern": {
			"pattern": "set", "value": 5
		},
		"mana_cost": 0,
		"name": "Charge",
		"description": "A charging attack that deals significant damage and knocks back enemies in its path."
	},
	"throw": {
		"damage": 45,
		"traits": ["sharp_projectile", "slow_velocity", "slow", "solid_projectile"],
		"difficulty_pattern": {
			"pattern": "add", "value": -2
		},
		"mana_cost": 0,
		"name": "Throw",
		"description": "Throw a heavy object at enemies, dealing moderate damage and slowing them down."
	},
	"whip_strike": {
		"damage": 20,
		"traits": ["melee", "sharp_projectile", "whip_melee"],
		"difficulty_pattern": {
			"pattern": "add", "value": 0
		},
		"mana_cost": 0,
		"name": "Whip Strike",
		"description": "A fast whip strike that extends to hit enemies at a distance, dealing moderate damage."
	},
	"spin_attack": {
		"damage": 30,
		"traits": ["melee", "sharp_projectile", "area_of_effect", "quick"],
		"difficulty_pattern": {
			"pattern": "multiply", "value": 1.2
		},
		"mana_cost": 0,
		"name": "Spin Attack",
		"description": "A spinning attack."
	},
	"punch": {
		"damage": 10,
		"traits": ["melee", "hand_projectile", "fast"],
		"difficulty_pattern": {
			"pattern": "add", "value": 0
		},
		"mana_cost": 0,
		"name": "Punch",
		"description": "A quick punch that deals light damage in close combat."
	},
	"throwing_dagger": {
		"damage": 15,
		"traits": ["sharp", "sharp_projectile", "piercing"],
		"difficulty_pattern": {
			"pattern": "add", "value": 1
		},
		"mana_cost": 0,
		"name": "Throwing Dagger",
		"description": "A thrown dagger that pierces through enemies, dealing damage in a straight line."
	},
	"lunge": {
		"damage": 35,
		"traits": ["melee", "sharp_projectile"],
		"difficulty_pattern": {
			"pattern": "set", "value": 3
		},
		"mana_cost": 0,
		"name": "Lunge",
		"description": "A quick lunge that covers a short distance and deals high damage to enemies in the way."
	},
	"roundhouse_kick": {
		"damage": 40,
		"traits": ["melee", "stun", "wide_melee", "knockback"],
		"difficulty_pattern": {
			"pattern": "add", "value": 2
		},
		"mana_cost": 0,
		"name": "Roundhouse Kick",
		"description": "A powerful roundhouse kick that hits all enemies within range and knocks them back."
	}
}


var base_spells = {
	"fireball": {
		"damage": 30,
		"traits": ["fire", "explosion", "area_of_effect"],
		"difficulty_pattern": {
			"pattern": "add", "value": -2
		},
		"mana_cost": 5,
		"name": "Fireball",
		"description": "A burst of fire magic that explodes on impact, burning enemies within range."
	},
	"ice_blast": {
		"damage": 18,
		"traits": ["ice_projectile", "slow", "area_of_effect", "solid_projectile"],
		"difficulty_pattern": {
			"pattern": "add", "value": 2
		},
		"mana_cost": 4,
		"name": "Ice Blast",
		"description": "A freezing blast of ice that slows enemies within a small area and deals moderate damage."
	},
	"lightning_strike": {
		"damage": 35,
		"traits": ["lightning_projectile", "stun", "area_of_effect", "ethereal_projectile", "auto_aim"],
		"difficulty_pattern": {
			"pattern": "set", "value": 6
		},
		"mana_cost": 8,
		"name": "Lightning Strike",
		"description": "A powerful strike of lightning that stuns and deals high damage to all enemies within range."
	},
	"earthquake": {
		"damage": 50,
		"traits": ["earth_projectile", "area_of_effect", "stun", "vibration"],
		"difficulty_pattern": {
			"pattern": "multiply", "value": 1.2
		},
		"mana_cost": 10,
		"name": "Earthquake",
		"description": "A powerful tremor that shakes the ground, dealing significant damage and stunning enemies in a large area."
	},
	"wind_cutter": {
		"damage": 25,
		"traits": ["wind_projectile", "solid_projectile", "blade_projectile"],
		"difficulty_pattern": {
			"pattern": "add", "value": 1
		},
		"mana_cost": 3,
		"name": "Wind Cutter",
		"description": "A slicing gust of wind that cuts through enemies in a straight line, dealing moderate damage."
	},
	"arcane_blast": {
		"damage": 40,
		"traits": ["arcane_projectile", "explosive", "ethereal_projectile"],
		"difficulty_pattern": {
			"pattern": "set", "value": 4
		},
		"mana_cost": 7,
		"name": "Arcane Blast",
		"description": "An arcane burst that explodes on impact, penetrating through enemies and causing massive damage."
	},
	"heal": {
		"damage": -20,
		"traits": ["arcane_projectile", "healing", "ethereal_projectile"],
		"difficulty_pattern": {
			"pattern": "multiply", "value": 0.8
		},
		"mana_cost": 4,
		"name": "Heal",
		"description": "Heals the target, restoring a significant amount of health."
	},
	"mana_burst": {
		"damage": 10,
		"traits": ["arcane_projectile", "damage_drain"],
		"difficulty_pattern": {
			"pattern": "add", "value": 4
		},
		"mana_cost": 5,
		"name": "Mana Burst",
		"description": "Drains mana from the target, reducing their mana and dealing moderate damage."
	},
	"shadow_strike": {
		"damage": 30,
		"traits": ["shadow_projectile", "poison"],
		"difficulty_pattern": {
			"pattern": "multiply", "value": 1.5
		},
		"mana_cost": 6,
		"name": "Shadow Strike",
		"description": "A quick strike of shadow energy that poisons the target and deals high damage over time."
	},
	"light_shield": {
		"damage": 10,
		"traits": ["light_projectile", "defensive_buff"],
		"difficulty_pattern": {
			"pattern": "add", "value": 2
		},
		"mana_cost": 3,
		"name": "Light Shield",
		"description": "Creates a protective light barrier that shields the target from incoming damage."
	},
	"blizzard": {
		"damage": 20,
		"traits": ["ice_projectile", "area_of_effect", "slow", "damage_over_time"],
		"difficulty_pattern": {
			"pattern": "add", "value": 4
		},
		"mana_cost": 6,
		"name": "Blizzard",
		"description": "A frigid storm of ice and snow that slows enemies in its radius and deals continuous damage."
	},
	"dark_pulse": {
		"damage": 60,
		"traits": ["shadow_projectile", "explosive", "area_of_effect", "life_steal"],
		"difficulty_pattern": {
			"pattern": "multiply", "value": 1.3
		},
		"mana_cost": 10,
		"name": "Dark Pulse",
		"description": "A devastating pulse of dark energy that heals the caster while damaging enemies in the area."
	},
	"vortex": {
		"damage": 15,
		"traits": ["wind_projectile", "pull", "area_of_effect", "slow"],
		"difficulty_pattern": {
			"pattern": "multiply", "value": 1.2
		},
		"mana_cost": 4,
		"name": "Vortex",
		"description": "Summons a vortex that pulls enemies toward its center, dealing damage and displacing them."
	},
	"flame_wave": {
		"damage": 25,
		"traits": ["fire", "blade_projectile", "area_of_effect"],
		"difficulty_pattern": {
			"pattern": "set", "value": 3
		},
		"mana_cost": 6,
		"name": "Flame Wave",
		"description": "A rolling wave of flame that scorches all enemies in its path, dealing moderate damage."
	},
	"arcane_shield": {
		"damage": 10,
		"traits": ["arcane_projectile", "defensive_buff"],
		"difficulty_pattern": {
			"pattern": "multiply", "value": 0.9
		},
		"mana_cost": 5,
		"name": "Arcane Shield",
		"description": "An arcane barrier that reduces damage taken by the target for a short duration."
	},
	"mirror_image": {
		"damage": 10,
		"traits": ["wind_projectile", "buff_summon_clones"],
		"difficulty_pattern": {
			"pattern": "add", "value": 1
		},
		"mana_cost": 4,
		"name": "Mirror Image",
		"description": "Creates illusory copies of the caster, confusing enemies and drawing their attention."
	}
}

signal hid_menu()
signal start_game()
signal bribe()
signal hide_menu()
signal mana_updated()
signal show_stat()
signal hide_stat()
signal start_combat(attack_dict,scene)
signal health_updated()
signal player_died()
signal stats_updated()
signal enemy_killed()

var current_save

var difficulty = 5

var minion

var combat_ongoing = false

var player : Node

var game_data = {}

var current_attack_damage

const save_file_paths = [
	"res://Saves/save1.json",
	"res://Saves/save2.json",
	"res://Saves/save3.json" 
]

const default_data = {
	"stats": {
		"strength": 0,
		"dexterity": 0,
		"wisdom": 0,
		"intelligence": 0,
		"charisma": 0,
		"attack": 3,
		"defense": 0,
		"health": 500,
		"max_health": 500,
		"mana": 20,
		"max_mana": 40,
		"bottles_multiplier": 8,
		"projectile_speed": 20,
		"projectile_damage": 10
	},
	"attacks": ["punch", "slash","pierce"],
	"spells": ["heal", "fireball"]
}

# __________ FUNCTIONS __________

func show_menu():
	emit_signal("hide_menu")

func set_game_data(section, value):
	var game_data_copy = game_data.duplicate()
	game_data_copy[section] = value
	game_data = game_data_copy

func set_stat(stat, value):
	var game_data_copy = game_data.duplicate()
	var game_data_stats_copy = game_data_copy["stats"].duplicate()
	game_data_stats_copy[stat] = value
	game_data_copy["stats"] = game_data_stats_copy
	if stat in ["mana","max_mana","bottles_multiplier"]:
		game_data = game_data_copy
		emit_signal("mana_updated")
		emit_signal("stats_updated")
	elif stat in ["health","max_health"]:
		game_data = game_data_copy
		emit_signal("health_updated")
		emit_signal("stats_updated")
	else:
		game_data = game_data_copy
		emit_signal("stats_updated")


func load_data_into_global(save_id):
	game_data = get_game_variables(save_id)
	emit_signal("mana_updated")

func save_game(save_id: int, game_data: Dictionary) -> bool:
	if save_id < 0 or save_id >= save_file_paths.size():
		print("Invalid save ID.")
		return false
	
	var json_data = JSON.stringify(game_data)
	
	var file_path = save_file_paths[save_id]
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_string(json_data)
		file.close()
		print("Game saved to " + file_path)
		return true
	else:
		print("Failed to save game.")
		return false

func load_game(save_id: int) -> Dictionary:
	if save_id < 0 or save_id >= save_file_paths.size():
		print("Invalid save ID.")
		return {}
	
	var file_path = save_file_paths[save_id]
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if FileAccess.file_exists(file_path):
		if FileAccess.get_open_error() == OK:
			var file_content = file.get_as_text()
			file.close()
			
			var game_data = JSON.parse_string(file_content)
			
			if game_data is Dictionary:
				print("Game loaded from " + file_path)
				return game_data
			else:
				print("Error: Corrupted save file!")
				return {}
		else:
			print("Failed to open file: " + file_path)
			return {}
	else:
		print("Save file does not exist: " + file_path)
		return default_data

func verify_save_integrity(save_id: int) -> bool:
	var game_data = load_game(save_id)
	var is_stat_good = game_data["stats"].keys().all(func(key): return key in default_data["stats"]) if game_data.has("stats") else false
	var is_attack_good = game_data["attacks"].all(func(key): return key in base_attacks.keys()) if game_data.has("attacks") else false
	var is_spell_good = game_data["spells"].all(func(key): return key in base_spells.keys()) if game_data.has("spells") else false
	return is_attack_good and is_spell_good and is_stat_good
	#var required_keys = ["strength", "dexterity", "wisdom", "intelligence", "charisma", "attack", "defense", "health", "max_health", "mana", "max_mana", "bottles_multiplier", "projectile_speed", "projectile_damage"]
	#
	#if game_data.has("stats") and game_data.has("attacks") and game_data.has("spells"):
		#var stats = game_data["stats"]
		#if required_keys.all(func(key): return stats.has(key)):
			#print("Save integrity verified!")
			#return true
		#else:
			#print("Error: Missing or invalid stats fields.")
			#return false
	#else:
		#print("Error: Missing main fields.")
		#return false

func get_game_variables(save_id: int) -> Dictionary:
	if verify_save_integrity(save_id):
		return load_game(save_id)
	else:
		print("Load default data due to corrupted save.")
		return default_data

func heal_player():
	set_stat("health",game_data["stats"]["max_health"])

func can_cast_spell(cost):
	return cost <= game_data["stats"]["mana"]

func update_ui_on_launch():
	emit_signal("health_updated")
	emit_signal("stats_updated")
	emit_signal("mana_updated")

# __________ MAIN FUNCTIONS __________

func _ready() -> void:
	player_died.connect(heal_player)
	print("I'm here !")
	call_deferred("update_ui_on_launch")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Show Statistic Screen"):
		emit_signal("show_stat")
	if Input.is_action_just_released("Show Statistic Screen"):
		emit_signal("hide_stat")
	if Input.is_action_just_pressed("Show Menu"):
		emit_signal("hide_menu")
