extends Button

func _ready():
	self.pressed.connect(GlobalData.show_menu)
