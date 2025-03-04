extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GlobalData.hid_menu.connect(focus_grabby)
	GlobalData.hide_stat.connect(focus_grabby)
	self.pressed.connect(_on_button_pressed)
	grab_focus()

func focus_grabby():
	if self.visible:
		grab_focus()

func _on_button_pressed():
	self.visible = false
	GlobalData.start_game.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
