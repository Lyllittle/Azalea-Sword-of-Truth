extends CanvasLayer

func _save_and_load():
	GlobalData.save_game(GlobalData.current_save, GlobalData.game_data)
	get_tree().change_scene_to_file("res://save_select.tscn")

func _ready():
	get_node("TabContainer/Save and Load/GridContainer/Save").grab_focus()
	get_node("TabContainer/Save and Load/GridContainer/Save").pressed.connect(GlobalData.save_game.bind(GlobalData.current_save, GlobalData.game_data))
	get_node("TabContainer/Save and Load/GridContainer/Load").pressed.connect(_save_and_load)
	get_node("TabContainer/Save and Load/GridContainer/Reset").pressed.connect(reset_save)

func reset_save():
	GlobalData.game_data = GlobalData.default_data

func _process(delta):
	pass
