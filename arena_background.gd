extends TextureRect

func _ready() -> void:
	custom_minimum_size = get_parent().arena_rect.grow(100).size
	position = get_parent().arena_rect.grow(100).position
	
