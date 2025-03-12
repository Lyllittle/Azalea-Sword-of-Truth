extends Control

@export var player_scene = preload("res://character.tscn")
@export var enemies_to_spawn: Array = []  # Array of dictionaries: [{"enemy": EnemyScene, "spawn_position": Vector2}]

@export var player_spawn_position: Vector2

var active_attack = {}
var arena_rect = Rect2(0, 0, 1500, 1500)
var player = null
var enemies = []  # Array to track spawned enemies
var spawn_center

func prepare():
	var screen_size = arena_rect
	spawn_center = Vector2(screen_size.end.x-screen_size.position.x,screen_size.end.y-screen_size.position.y)
	player_spawn_position = Vector2(float(screen_size.end.x-screen_size.position.x) * 0.25, float(screen_size.end.y-screen_size.position.y) / 2)
	GlobalData.combat_ongoing = true
	spawn_player()
	spawn_enemies()
	
func _ready():
	GlobalData.enemy_killed.connect(_on_enemy_died)
	GlobalData.player_died.connect(_on_player_died)
	prepare()

func spawn_player():
	if player_scene:
		player = player_scene.instantiate()
		player.position = player_spawn_position
		player.active_attack_traits = active_attack["traits"]  # Ensure "traits" key exists in active_attack
		GlobalData.player = player
		add_child(player)
	else:
		print("Player scene is not set!")

func spawn_enemies():
	for enemy_data in enemies_to_spawn:
		var enemy_scene = enemy_data.get("enemy")
		var spawn_pos = enemy_data.get("spawn_position")
		if enemy_scene:
			enemy_scene.position = spawn_center + spawn_pos
			add_child(enemy_scene)
			enemies.append(enemy_scene)
		else:
			print("Invalid enemy data in enemies_to_spawn array")

func _on_player_died():
	kill_everything()
	
func _on_enemy_died():
	kill_everything()

func kill_everything():
	GlobalData.combat_ongoing = false
	if player and is_instance_valid(player):
		remove_child(player)
		player.queue_free()
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			remove_child(enemy)
			enemy.queue_free()
	enemies.clear()
	# Clean up any remaining children
	for child in get_children():
		if child.name != "TextureRect":
			child.queue_free()
	queue_free()
