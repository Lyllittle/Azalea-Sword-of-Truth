extends Area2D

@export var speed = 25
@export var damage = 15
var MAX_SPEED = 200
var movement_pattern = "straight"
var base_position
var time_elapsed = 0

func _ready():
	base_position = self.position
	area_entered.connect(_on_area_entered)

func _process(delta):
	if GlobalData.combat_ongoing:
		if movement_pattern == "straight":
			position += Vector2(cos(rotation), sin(rotation)) * speed * delta
		if movement_pattern == "spiral":
			time_elapsed += delta
			var angle = deg_to_rad(time_elapsed*45) + rotation
			var distance = time_elapsed * 50
			position = base_position + Vector2(cos(angle), sin(angle)) * distance
		speed = min(speed + speed, MAX_SPEED)
		var viewport = get_viewport_rect()
		if position.x > viewport.size.x*4 or position.x < -viewport.size.x*4 or position.y > viewport.size.y*4 or position.y < -viewport.size.y*4:
			queue_free()
		if time_elapsed > 5:
			queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):  # Use a group to tag the player
		area.take_damage(damage)
		queue_free()
