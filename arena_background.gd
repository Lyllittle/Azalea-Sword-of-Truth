extends TextureRect

func _ready() -> void:
	custom_minimum_size = get_parent().arena_rect.size
