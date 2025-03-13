extends ColorRect

var mouse_selected = true
var last_mouse_pos = Vector2.ZERO

func _process(delta):
	var mouse_pos
	if (get_viewport().get_mouse_position() / Vector2(get_viewport().size) - last_mouse_pos).length()*get_viewport().size.length() >=5 and not mouse_selected:
		mouse_selected = true
	elif Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down").length() >= 0.4 and mouse_selected:
		mouse_selected = false
	if mouse_selected:
		mouse_pos = get_viewport().get_mouse_position() / Vector2(get_viewport().size)
	else:
		mouse_pos = get_viewport_rect().get_center() + Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down") /3
	mouse_pos /= 2
	material.set_shader_parameter("mouse_pos", mouse_pos)
	last_mouse_pos = get_viewport().get_mouse_position() / Vector2(get_viewport().size)
