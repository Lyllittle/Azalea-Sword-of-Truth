extends VBoxContainer

# __________ VARIABLES AND CONSTANTS __________

@onready var stats_container = $StatsContainer
@onready var attacks_container = $AttacksContainer
@onready var spells_container = $SpellsContainer
var last_selected = 0

# __________ FUNCTIONS __________

func _display_stats(stats: Dictionary):
	var list_of_buttons = []
	for stat_name_id in stats.keys().size():
		var stat_name = stats.keys()[stat_name_id]
		var stat_hbox = HBoxContainer.new()
		var stat_label = Label.new()
		stat_label.text = stat_name.capitalize() + ": " + str(stats[stat_name])
		var upgrade_button = Button.new()
		upgrade_button.text = "Upgrade"
		upgrade_button.pressed.connect(_on_upgrade_button_pressed.bind(stat_name,stat_name_id))
		list_of_buttons.append(upgrade_button)
		stat_hbox.add_child(stat_label)
		stat_hbox.add_child(upgrade_button)

		stats_container.add_child(stat_hbox)
	update_focus_system(list_of_buttons)

func update_last_selected(i):
	last_selected = i

func update_focus_system(list):
	for button_id in range(0,list.size()-1):
		list[button_id].focus_neighbor_bottom = list[button_id +1].get_path()
	for button_id in range(1,list.size()):
		list[button_id].focus_neighbor_top = list[button_id - 1].get_path()

func _display_attacks(attacks: Array):
	for attack in attacks:
		var attack_hbox = HBoxContainer.new()
		var attack_label = Label.new()
		attack_label.text = attack.capitalize()

		attack_hbox.add_child(attack_label)

		attacks_container.add_child(attack_hbox)

func _display_spells(spells: Array):
	for spell in spells:
		var spell_hbox = HBoxContainer.new()
		var spell_label = Label.new()
		spell_label.text = spell.capitalize()

		spell_hbox.add_child(spell_label)

		spells_container.add_child(spell_hbox)

func _on_upgrade_button_pressed(stat_name: String,stat_name_id):
	update_last_selected(stat_name_id)
	GlobalData.set_stat(stat_name,GlobalData.game_data["stats"][stat_name]+1)
	call_deferred("grab_focus_please")
	#print(stat_name + " upgraded to " + str(GlobalData.game_data["stats"][stat_name]))

func _refresh_ui():
	for child in stats_container.get_children():
		stats_container.remove_child(child)
		child.queue_free()
	_display_stats(GlobalData.game_data["stats"])
	for child in attacks_container.get_children():
		attacks_container.remove_child(child)
		child.queue_free()
	_display_attacks(GlobalData.game_data["attacks"])
	for child in spells_container.get_children():
		spells_container.remove_child(child)
		child.queue_free()
	_display_spells(GlobalData.game_data["spells"])
	if self.visible:
		grab_focus_please()
	
func grab_focus_please():
	stats_container.get_children()[last_selected].get_children()[1].grab_focus()


func show_screen():
	self.visible = true
	grab_focus_please()
	
func hide_screen():
	self.visible = false

# __________ MAIN FUNCTIONS __________

func _ready() -> void:
	self.visible = false
	_refresh_ui()
	GlobalData.show_stat.connect(show_screen)
	GlobalData.hide_stat.connect(hide_screen)
	GlobalData.stats_updated.connect(_refresh_ui)


func _process(delta: float) -> void:
	pass
