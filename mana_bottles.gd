extends HBoxContainer

func _ready():
	initial_setup()
	update_mana_ui()
	GlobalData.mana_updated.connect(update_mana_ui)

func get_current_mana():
	return GlobalData.game_data["stats"]["mana"]

func get_max_mana():
	return GlobalData.game_data["stats"]["max_mana"]

func get_bottles_multiplier():
	return GlobalData.game_data["stats"]["bottles_multiplier"]

func initial_setup():
	for child in get_children():
		child.queue_free()
	var num_bottles = ceil(float(get_max_mana()) / float(get_bottles_multiplier()))
	#print("Required Bottles number is"+str(num_bottles))
	#print("Starting Bottles Setup")
	for i in range(num_bottles):
		print("Setup Bottles:"+str(i+1)+"/"+str(num_bottles))
		var progress_bar = TextureProgressBar.new()
		progress_bar.custom_minimum_size = Vector2(25, 25)
		progress_bar.size_flags_horizontal = Control.SIZE_FILL
		progress_bar.size_flags_vertical = Control.SIZE_FILL
		progress_bar.offset_bottom = 0
		progress_bar.offset_right = 0
		progress_bar.offset_top = 0
		progress_bar.offset_left = 0
		progress_bar.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP
		progress_bar.value = 0
		progress_bar.max_value = get_bottles_multiplier()
		var texture_empty = load("res://EmptyBottle.tres")
		var texture_fill = load("res://FilledBottle.tres")
		progress_bar.texture_under = texture_empty
		progress_bar.texture_progress = texture_fill
		add_child(progress_bar)

func update_mana_ui():
	var multiplier = get_bottles_multiplier()
	var current_mana = get_current_mana()
	var max_mana = get_max_mana()
	var required_bottles = ceil(float(max_mana) / float(multiplier))
	#print("Required Bottles number is"+str(required_bottles))
	while get_child_count() < required_bottles:
		print("Updating number of bottles up")
		var progress_bar = TextureProgressBar.new()
		progress_bar.custom_minimum_size = Vector2(25, 25)
		progress_bar.size_flags_horizontal = Control.SIZE_FILL
		progress_bar.size_flags_vertical = Control.SIZE_FILL
		progress_bar.offset_bottom = 0
		progress_bar.offset_right = 0
		progress_bar.offset_top = 0
		progress_bar.offset_left = 0
		progress_bar.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP
		progress_bar.value = 0
		progress_bar.max_value = get_bottles_multiplier()
		var texture_empty = load("res://EmptyBottle.tres")
		var texture_fill = load("res://FilledBottle.tres")
		progress_bar.texture_under = texture_empty
		progress_bar.texture_progress = texture_fill
		add_child(progress_bar)
			
	while get_child_count() > required_bottles:
		print("updating number of bottles down")
		var last_child = get_child(get_child_count() - 1)
		remove_child(last_child)
		last_child.queue_free()

	for i in range(get_child_count()):
		var progress_bar = get_child(i)
		progress_bar.max_value = get_bottles_multiplier()
		var value = min(max((current_mana - i * multiplier), 0),multiplier)
		#print("Updating value of bottle number"+str(i+1)+"to"+str(value))
		progress_bar.value = value
