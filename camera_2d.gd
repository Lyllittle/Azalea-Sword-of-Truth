extends Camera2D

func _ready() -> void:
	limit_left = get_parent().get_parent().arena_rect.position.x - 100
	limit_right = get_parent().get_parent().arena_rect.end.x + 100
	limit_top = get_parent().get_parent().arena_rect.position.y -100
	limit_bottom = get_parent().get_parent().arena_rect.end.y + 100
	make_current()
