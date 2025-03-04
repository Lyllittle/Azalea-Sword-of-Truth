extends HBoxContainer

var minion_icon_scene = preload("res://minion_icon.tscn")

func _ready() -> void:
	update_queue_display()
	get_parent().enemies_created.connect(update_queue_display)

func update_queue_display():
	for child in get_children():
		child.queue_free()
	var next_minions = get_parent().minion_queue
	for minion in next_minions.slice(0, 3):
		var icon = minion_icon_scene.instantiate()
		icon.set_patterns(
			minion.traits["shooting_patterns"],
			minion.traits["moving_pattern"],
			minion.special_effect,
			minion.local_difficulty
		)
		add_child(icon)
