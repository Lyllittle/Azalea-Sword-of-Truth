extends Control

@export var player_scene = preload("res://character.tscn")
var base_scene_enemy = preload("res://enemy.tscn")

@export var player_spawn_position: Vector2
@export var enemy_spawn_position: Vector2

var active_attack = {}

var player = null
var enemy = null

func prepare():
	var screen_size = get_viewport_rect().size
	enemy_spawn_position = Vector2(float(screen_size.x) * 0.75, float(screen_size.y) / 2)
	player_spawn_position = Vector2(float(screen_size.x) * 0.25, float(screen_size.y) / 2)
	GlobalData.combat_ongoing = true
	spawn_player()
	spawn_enemy()
	
func _ready():
	GlobalData.enemy_killed.connect(kill_everything)
	GlobalData.player_died.connect(kill_everything)
	prepare()

func _process(delta: float) -> void:
	pass

func spawn_player():
	if player_scene:
		player = player_scene.instantiate()
		player.position = player_spawn_position
		player.active_attack_traits = active_attack["traits"]
		GlobalData.player = player
		add_child(player)
	else:
		print("Player scene is not set!")

func spawn_enemy():
	if enemy == null:
		enemy = base_scene_enemy.instantiate()
		enemy.position = enemy_spawn_position
		print(str(enemy_spawn_position))
		add_child(enemy)
	else:
		enemy.position = enemy_spawn_position
		print(str(enemy_spawn_position))
		add_child(enemy)



func kill_everything():
	if player and is_instance_valid(player):
		remove_child(player)
		player.queue_free()
	if enemy and is_instance_valid(enemy):
		remove_child(enemy)
		enemy.queue_free()
	for children in get_children():
		children.queue_free()
	queue_free()
