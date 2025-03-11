extends HBoxContainer

var minion_icon_scene = preload("res://minion_icon.tscn")

func _ready() -> void:
	get_parent().enemies_created.connect(update_queue_display)

func update_queue_display():
	for child in get_children():
		child.queue_free()
	var next_minions_traits = get_parent().generate_traits_for_display()
	var icon = minion_icon_scene.instantiate()
	icon.set_patterns(
		next_minions_traits["shooting_patterns"],
		next_minions_traits["moving_pattern"],
		next_minions_traits["warp_level"],
		next_minions_traits["enemies_number"]
	)
	add_child(icon)
