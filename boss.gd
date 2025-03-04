extends VBoxContainer

var health := 200
var minion_queue := []
signal enemies_created
var minion_scene = preload("res://enemy.tscn")

var minion_spawn_position: Vector2

func _ready():
	$TextureProgressBar.max_value = health
	$TextureProgressBar.value = health
	$TextureProgressBar.texture_progress_offset = Vector2(float(-$TextureProgressBar.size.x) * (1-$TextureProgressBar.value/$TextureProgressBar.max_value),0)
	generate_minion_queue()
	spawn_next_minion()

func generate_minion_queue():
	var screen_size = get_viewport_rect().size
	GlobalData.player = preload("res://character.tscn").instantiate()
	GlobalData.player.position = Vector2(float(screen_size.x) * 0.25, float(screen_size.y) / 2)
	for i in range(10):
		#print("i = "+str(i))
		minion_queue.append(minion_scene.instantiate())
		minion_queue[i].local_difficulty = max(0,GlobalData.difficulty + randi_range(-2 , 2))
		minion_queue[i].initialize_enemy(minion_queue[i].local_difficulty)
	GlobalData.minion = minion_queue[0]
	enemies_created.emit()
	
func spawn_next_minion():
	var minion_scene_local = minion_queue.pop_front()
	minion_scene_local.died.connect(_on_minion_died)
	GlobalData.minion = minion_queue[0]
	GlobalData.minion.died.connect(_on_minion_died)
	var new_minion = minion_scene.instantiate()
	new_minion.local_difficulty = max(0,GlobalData.difficulty + randi_range(-2 , 2))
	new_minion.initialize_enemy(new_minion.local_difficulty)
	minion_queue.append(new_minion)
	enemies_created.emit()

func _on_minion_died(damage_to_boss):
	GlobalData.minion.died.disconnect(_on_minion_died)
	health -= damage_to_boss
	$TextureProgressBar.value = health
	$TextureProgressBar.texture_progress_offset = Vector2(float(-$TextureProgressBar.size.x) * (1-$TextureProgressBar.value/$TextureProgressBar.max_value),0)
	print("Boss health is now "+str(health))
	if health <= 0:
		destroy_boss()
	else:
		spawn_next_minion()

func destroy_boss():
	queue_free()
