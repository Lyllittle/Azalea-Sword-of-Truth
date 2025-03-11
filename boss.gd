extends VBoxContainer

var health := 200
var wave_queue := []  # Array of wave dictionaries
var active_enemies := []  # Currently active enemies in the wave
var rng = RandomNumberGenerator.new()
signal enemies_created
var minion_scene = preload("res://enemy.tscn")

@onready var screen_size = get_viewport_rect().size

func _ready():
	rng.randomize()
	setup_health_bar()
	generate_wave_queue()
	spawn_next_wave()

func setup_health_bar():
	$TextureProgressBar.max_value = health
	$TextureProgressBar.value = health
	$TextureProgressBar.texture_progress_offset = Vector2(
		float(-$TextureProgressBar.size.x) * (1 - $TextureProgressBar.value/$TextureProgressBar.max_value), 
		0
	)

func generate_wave_queue():
	# Generate 3 waves for demonstration
	for wave_num in 3:
		var wave = {
			"enemies": generate_wave_enemies(calculate_wave_size()),
			"spawn_positions": generate_spawn_positions()
		}
		wave_queue.append(wave)

func calculate_wave_size() -> int:
	return rng.randi_range(1, 4)  # 1-4 enemies per wave

func generate_wave_enemies(amount: int) -> Array:
	var enemies = []
	for i in amount:
		enemies.append({
			"scene": minion_scene,
			"difficulty": max(0, GlobalData.difficulty + rng.randi_range(-2, 2))
		})
	return enemies

func generate_spawn_positions() -> Array:
	var positions = []
	var base_x = screen_size.x * 0.75
	var base_y = screen_size.y / 2
	for i in calculate_wave_size():
		positions.append(Vector2(base_x + (i * 100), base_y))
	return positions

func spawn_next_wave():
	if wave_queue.is_empty():
		destroy_boss()
		return
	
	var wave = wave_queue.pop_front()
	for i in wave["enemies"].size():
		var enemy_data = wave["enemies"][i]
		var spawn_pos = wave["spawn_positions"][i]
		
		var minion = enemy_data["scene"].instantiate()
		minion.position = spawn_pos
		minion.local_difficulty = enemy_data["difficulty"]
		minion.initialize_enemy(minion.local_difficulty)
		minion.died.connect(_on_enemy_died.bind(minion))
		
		add_child(minion)
		active_enemies.append(minion)
	
	enemies_created.emit()

func _on_enemy_died(damage_to_boss, minion):
	minion.died.disconnect(_on_enemy_died)
	active_enemies.erase(minion)
	
	update_boss_health(damage_to_boss)
	
	if active_enemies.is_empty():
		if wave_queue.is_empty():
			destroy_boss()
		else:
			spawn_next_wave()

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
