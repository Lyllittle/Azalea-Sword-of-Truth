extends CanvasLayer

var attack_textures_selected = []
var spell_textures_selected = []
var select_textures_selected = []
var artifacts_textures_selected = []
var attack_textures = []
var attack_labels = []
var spell_textures = []
var spell_labels = []
var select_textures = []
var select_labels = ["Attack","Spell","Artifacts","Bribe"]
var artifacts_textures = []
var artifacts_labels = []
var last_spell_selected = 0
var last_attack_selected = 0
var last_artifact_selected = 0
var last_select_selected = 0

@onready var icon_buttons = [
	$GridContainer/VBoxContainer/Button1,
	$GridContainer/VBoxContainer2/Button2,
	$GridContainer/VBoxContainer3/Button3,
	$GridContainer/VBoxContainer4/Button4
]
@onready var label_nodes = [
	$GridContainer/VBoxContainer/Label1,
	$GridContainer/VBoxContainer2/Label2,
	$GridContainer/VBoxContainer3/Label3,
	$GridContainer/VBoxContainer4/Label4
]

var current_state: String = "selection"

func _ready():
	self.visible = true
	GlobalData.hid_menu.connect(update_menu)
	GlobalData.enemy_killed.connect(need_to_show_again)
	GlobalData.hide_stat.connect(update_menu)
	update_menu()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Back") and (current_state != "selection"):
		current_state = "selection"
		update_menu()

func need_to_show_again():
	visible = true
	update_menu()

func update_menu():
	get_labels()
	get_textures()
	disconnect_buttons()
	if current_state == "selection":
		for i in range(icon_buttons.size()):
			icon_buttons[i].texture_normal = select_textures[i]
			icon_buttons[i].texture_focused = select_textures_selected[i]
			label_nodes[i].text = select_labels[i]
		icon_buttons[0].pressed.connect(_on_attack_button_pressed)
		icon_buttons[1].pressed.connect(_on_spell_button_pressed)
		icon_buttons[2].pressed.connect(_on_artifacts_button_pressed)
		icon_buttons[3].pressed.connect(_on_bribe_button_pressed)
		icon_buttons[last_select_selected].grab_focus()
	elif current_state == "attack":
		for i in range(icon_buttons.size()):
			icon_buttons[i].texture_normal = attack_textures[i]
			icon_buttons[i].texture_focused = attack_textures_selected[i]
			label_nodes[i].text = attack_labels[i]
			icon_buttons[i].pressed.connect(_on_button_pressed.bind(i,"attack"))
		icon_buttons[last_attack_selected].grab_focus()
	elif current_state == "spell":
		for i in range(icon_buttons.size()):
			icon_buttons[i].texture_normal = spell_textures[i]
			icon_buttons[i].texture_focused = spell_textures_selected[i]
			label_nodes[i].text = spell_labels[i]
			icon_buttons[i].pressed.connect(_on_button_pressed.bind(i,"spell"))
		icon_buttons[last_spell_selected].grab_focus()
	elif current_state == "artifacts":
		for i in range(icon_buttons.size()):
			icon_buttons[i].texture_normal = artifacts_textures[i]
			icon_buttons[i].texture_focused = artifacts_textures_selected[i]
			label_nodes[i].text = artifacts_labels[i]
			icon_buttons[i].pressed.connect(_on_button_pressed.bind(i,"artifacts"))
		icon_buttons[last_artifact_selected].grab_focus()

func disconnect_buttons():
	for i in range(icon_buttons.size()):
		var signals = icon_buttons[i].pressed.get_connections()
		for i2 in signals.size():
			icon_buttons[i].pressed.disconnect(signals[i2]["callable"])
		

func get_labels():
	var spells = GlobalData.game_data["spells"]
	var attacks = GlobalData.game_data["attacks"]
	get_labels_spells(spells)
	get_labels_attacks(attacks)
	correct_labels()

func correct_labels():
	for i in range(4-attack_labels.size()):
		attack_labels.append("")
	for i in range(4-spell_labels.size()):
		spell_labels.append("")

func get_labels_spells(spells):
	var labels = []
	for spell in spells:
		labels.append(GlobalData.base_spells[spell]["name"])
	spell_labels = labels

func get_labels_attacks(attacks):
	var labels = []
	for attack in attacks:
		labels.append(GlobalData.base_attacks[attack]["name"])
	attack_labels = labels

func get_textures():
	var spells = GlobalData.game_data["spells"]
	var attacks = GlobalData.game_data["attacks"]
	get_textures_spells(spells)
	get_textures_attacks(attacks)
	select_textures = []
	for i in range(4):
		select_textures.append(preload("res://Assets/Sprites/SelectMenuButtonBasic.tres"))
	for i in range(4):
		select_textures_selected.append(preload("res://Assets/Sprites/SelectMenuButtonBasicSelected.tres"))
	
func get_textures_spells(spells):
	spell_textures = []
	for i in range(4):
		spell_textures.append(preload("res://Assets/Sprites/SelectMenuButtonBasic.tres"))
	for i in range(4):
		spell_textures_selected.append(preload("res://Assets/Sprites/SelectMenuButtonBasicSelected.tres"))
	#for spell in spells:

func get_textures_attacks(attacks):
	attack_textures = []
	for i in range(4):
		attack_textures.append(preload("res://Assets/Sprites/SelectMenuButtonBasic.tres"))
	for i in range(4):
		attack_textures_selected.append(preload("res://Assets/Sprites/SelectMenuButtonBasicSelected.tres"))
	
func _on_attack_button_pressed():
	last_select_selected = 0
	current_state = "attack"
	update_menu()

func _on_spell_button_pressed():
	last_select_selected = 1
	current_state = "spell"
	update_menu()

func _on_bribe_button_pressed():
	last_select_selected = 3
	GlobalData.bribe.emit()
	
func _on_artifacts_button_pressed():
	last_select_selected = 2
	current_state = "artifacts"
	update_menu()

func _on_button_pressed(i, action_type):
	if action_type == "spell":
		if GlobalData.can_cast_spell(GlobalData.base_spells[GlobalData.game_data["spells"][i]]["mana_cost"]):
			GlobalData.set_stat("mana",GlobalData.game_data["stats"]["mana"]-GlobalData.base_spells[GlobalData.game_data["spells"][i]]["mana_cost"])
			last_spell_selected = i
			GlobalData.current_attack_damage = GlobalData.base_spells[GlobalData.game_data["spells"][i]]["damage"]
			GlobalData.start_combat.emit(GlobalData.base_spells[GlobalData.game_data["spells"][i]],GlobalData.minion)
			visible = false
			current_state = "selection"
	elif action_type == "attack":
		if GlobalData.can_cast_spell(GlobalData.base_attacks[GlobalData.game_data["attacks"][i]]["mana_cost"]):
			GlobalData.set_stat("mana",GlobalData.game_data["stats"]["mana"]-GlobalData.base_attacks[GlobalData.game_data["attacks"][i]]["mana_cost"])
			last_attack_selected = i
			GlobalData.current_attack_damage = GlobalData.base_attacks[GlobalData.game_data["attacks"][i]]["damage"]
			GlobalData.start_combat.emit(GlobalData.base_attacks[GlobalData.game_data["attacks"][i]],GlobalData.minion)
			visible = false
			current_state = "selection"
