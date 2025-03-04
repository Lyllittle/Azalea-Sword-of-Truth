extends CanvasLayer

# __________ FUNCTIONS __________

func _on_save_selected(save_id: int):
	
	GlobalData.load_data_into_global(save_id)
	GlobalData.current_save = save_id
	
	get_tree().change_scene_to_file("res://main.tscn")

# __________ MAIN FUNCTIONS __________

func _ready() -> void:
	$VBoxContainer/CenterContainer/HBoxContainer/Save2Button.grab_focus()
	$VBoxContainer/CenterContainer/HBoxContainer/Save1Button.pressed.connect(_on_save_selected.bind(0))
	$VBoxContainer/CenterContainer/HBoxContainer/Save2Button.pressed.connect(_on_save_selected.bind(1))
	$VBoxContainer/CenterContainer/HBoxContainer/Save3Button.pressed.connect(_on_save_selected.bind(2))


func _process(delta: float) -> void:
	pass
