extends Node2D

var selection_screen = preload("res://selection_menu.tscn").instantiate()
var menu = preload("res://menu.tscn").instantiate()

func _ready() -> void:
	GlobalData.start_combat.connect(_start_combat_please)
	GlobalData.start_game.connect(_start_game_please)
	GlobalData.hide_menu.connect(_hide_menu)

func _hide_menu():
	if get_children().all(func(child): return !child.is_in_group("menu")):
		GlobalData.combat_ongoing = !GlobalData.combat_ongoing
		print("creating menu")
		menu = preload("res://menu.tscn").instantiate()
		add_child(menu)
	else :
		GlobalData.combat_ongoing = !GlobalData.combat_ongoing
		GlobalData.hid_menu.emit()
		print("deleting menu")
		menu.queue_free()

func _start_game_please():
	if $MainLayer.get_children().all(func(child): return !child.is_in_group("select_screen")):
		$MainLayer.add_child(selection_screen)
	else :
		selection_screen.visible = true

func _start_combat_please(active_attack):
	var combat_scene = preload("res://combat.tscn").instantiate()
	combat_scene.active_attack = active_attack
	combat_scene.enemies_to_spawn = GlobalData.enemies
	$MainLayer.add_child(combat_scene)
