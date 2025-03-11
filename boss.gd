extends VBoxContainer

var health := 200
var wave := []
var active_enemies := []
var rng = RandomNumberGenerator.new()
signal enemies_created
var minion_scene = preload("res://enemy.tscn")
var minion_traits_to_display = {"shooting_patterns":"","moving_pattern":"","warp_level":0,"enemies_number":0}

@onready var screen_size = get_viewport_rect().size

func _ready():
	rng.randomize()
	setup_health_bar()
	generate_wave()

func generate_wave():
	var minion = minion_scene.instantiate()
	minion.local_difficulty = get_difficulty()
	minion.initialize_enemy(minion.local_difficulty)
	minion_traits_to_display["shooting_patterns"] = minion.traits["shooting_patterns"]
	minion_traits_to_display["shooting_patterns"] = minion.traits["moving_pattern"]
	var size_of_wave = calculate_wave_size()
	minion_traits_to_display["enemies_number"] = size_of_wave
	minion.died.connect(_on_enemy_died.bind(minion))
	var spawn_positions = generate_spawn_positions(size_of_wave)
	for i in size_of_wave:
		var duplicate = minion.duplicate()
		duplicate.traits = minion.traits
		wave.append({"enemy":add_modifications(duplicate),"spawn_position":spawn_positions[i]})
	GlobalData.enemies = wave

func add_modifications(minion):
	return minion

func get_difficulty():
	return max(0, GlobalData.difficulty + rng.randi_range(-2, 2))

func setup_health_bar():
	$TextureProgressBar.max_value = health
	$TextureProgressBar.value = health
	$TextureProgressBar.texture_progress_offset = Vector2(
		float(-$TextureProgressBar.size.x) * (1 - $TextureProgressBar.value/$TextureProgressBar.max_value), 
		0
	)

func calculate_wave_size() -> int:
	return rng.randi_range(1, 4)  # 1-4 enemies per wave

func generate_spawn_positions(amount: int) -> Array:
	var positions = []
	var base_x = screen_size.x * 0.75
	var base_y = screen_size.y / 2
	for i in amount:
		positions.append(Vector2(base_x, base_y + (i * 20 - float(amount) / 2 * 20)))
	return positions

func generate_traits_for_display():
	return minion_traits_to_display

func _on_enemy_died(damage_to_boss, minion):
	minion.died.disconnect(_on_enemy_died)
	active_enemies.erase(minion)
	if active_enemies.is_empty():
		update_boss_health(damage_to_boss)
		GlobalData.enemy_killed.emit()

func update_boss_health(damage: int):
	health -= damage
	$TextureProgressBar.value = health
	$TextureProgressBar.texture_progress_offset = Vector2(
		float(-$TextureProgressBar.size.x) * (1 - $TextureProgressBar.value/$TextureProgressBar.max_value), 
		0
	)
	print("Boss health: ", health)
	
	if health <= 0:
		destroy_boss()

func destroy_boss():
	for enemy in active_enemies:
		enemy.queue_free()
	queue_free()
