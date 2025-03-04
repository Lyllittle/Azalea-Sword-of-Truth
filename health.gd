extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.max_value = GlobalData.game_data["stats"]["max_health"]
	self.value = GlobalData.game_data["stats"]["health"]
	self.texture_progress_offset = Vector2(float(-self.size.x) * (1-self.value/self.max_value),0)
	GlobalData.health_updated.connect(_health_updated)

func _health_updated():
	self.max_value = GlobalData.game_data["stats"]["max_health"]
	self.value = GlobalData.game_data["stats"]["health"]
	self.texture_progress_offset = Vector2(float(-self.size.x) * (1-self.value/self.max_value),0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
