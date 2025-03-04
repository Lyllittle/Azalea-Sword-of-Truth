extends Area2D

var speed : float
var MAX_SPEED = 2000
var is_projectile_area_damage = false
var custom_texture
var custom_animation = null
var is_melee = false
var area_of_effect_type = ""
var fastness_multiplier = 1.0
var is_piercing = false
var piercing_pierce_remaining
var is_stunning = false

func get_projectile_speed():
	return GlobalData.game_data["stats"]["projectile_speed"]

func get_projectile_damage():
	return GlobalData.game_data["stats"]["projectile_damage"]

func _ready():
	self.area_entered.connect(_on_area_entered)
	speed = get_projectile_speed()
	self.rotation_degrees = 0
	if !is_melee:
		if custom_animation != null:
			$AnimatedSprite2D.animation = custom_animation
		else:
			$AnimatedSprite2D.animation = "default"
	else:
		$AnimatedSprite2D.animation = "melee_slash"
		position = position + Vector2(100,0)
		$AnimatedSprite2D.rotation_degrees = 90
		$AnimatedSprite2D.animation_finished.connect(queue_free)
		
	$AnimatedSprite2D.play()
	
func _process(delta):
	if GlobalData.combat_ongoing:
		var collisionscale = $CollisionShape2D.shape.radius
		var animationscale = $AnimatedSprite2D.scale
		collisionscale = collisionscale+0.5*collisionscale*delta
		animationscale = animationscale+0.5*animationscale*delta
		if !is_melee:
			position += Vector2(cos(rotation), sin(rotation)) * speed * delta * fastness_multiplier
			speed = min(speed + speed, MAX_SPEED)
			var viewport = get_viewport_rect()
			if position.x > viewport.size.x or position.x < -viewport.size.x:  # Out-of-bounds check
				queue_free()
		else :
			position = GlobalData.player.position +  + Vector2(100,0)

func _on_area_entered(area):
	if self.is_projectile_area_damage:
		for areaenemies in $AreaOfEffect.get_overlapping_areas():
			if GlobalData.combat_ongoing:
				if !is_melee:
					if areaenemies.is_in_group("enemies"):  # Use a group to tag enemies
						areaenemies.take_damage(get_projectile_damage())
						queue_free()
						if is_stunning:
							areaenemies.stun(2)
					elif areaenemies.is_in_group("enemies_projectiles"):
						areaenemies.queue_free()
				else:
					if areaenemies.is_in_group("enemies"):  # Use a group to tag enemies
						areaenemies.take_damage(get_projectile_damage()/3*get_process_delta_time())
						queue_free()
					elif areaenemies.is_in_group("enemies_projectiles"):
						areaenemies.queue_free()
		if (area.is_in_group("enemies") or area.is_in_group("enemies_projectiles")) and !self.is_melee:
			if area_of_effect_type == "explosion":
				var explosion = AnimatedSprite2D.new()
				explosion.sprite_frames = preload("res://Assets/SpriteSheets/sprites.tres")
				explosion.animation = "explosion"
				explosion.position = self.position
				explosion.scale = Vector2(8,8)
				explosion.animation_finished.connect(explosion.queue_free)
				get_parent().add_child(explosion)
				explosion.play()
			if !is_piercing or piercing_pierce_remaining<=0:
				queue_free()
			elif is_piercing:
				piercing_pierce_remaining -= 1
	else:
		if area.is_in_group("enemies"):  # Use a group to tag enemies
			area.take_damage(get_projectile_damage())
			queue_free()
		elif area.is_in_group("enemies_projectiles"):
			area.queue_free()
			queue_free()
