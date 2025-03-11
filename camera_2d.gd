extends Camera2D

func _ready() -> void:
	limit_left = get_parent().get_parent().arena_rect.position.x
	limit_right = get_parent().get_parent().arena_rect.end.x
	limit_top = get_parent().get_parent().arena_rect.position.y
	limit_bottom = get_parent().get_parent().arena_rect.end.y
	make_current()

func _process(delta: float) -> void:
	pass
