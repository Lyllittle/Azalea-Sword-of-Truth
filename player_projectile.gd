extends Area2D

var raycast = RayCast2D.new()
var has_hit := false
var hit_position := Vector2()
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
var is_ethereal = false

func get_projectile_speed():
	return GlobalData.game_data["stats"]["projectile_speed"]

func get_projectile_damage():
	return GlobalData.game_data["stats"]["projectile_damage"]

func _ready():
	self.area_entered.connect(_on_area_entered)
	speed = get_projectile_speed()
	if !is_melee:
		if custom_animation != null:
			$AnimatedSprite2D.animation = custom_animation
		else:
			$AnimatedSprite2D.animation = "default"
	else:
		$AnimatedSprite2D.animation = "melee_slash"
		position = position + Vector2(cos(rotation), sin(rotation)) * 100
		$AnimatedSprite2D.rotation_degrees += 90
		$AnimatedSprite2D.animation_finished.connect(queue_free)
		
	$AnimatedSprite2D.play()
	
func _process(delta):
	if GlobalData.combat_ongoing:
		scale_up_projectile(delta)
		if !is_melee:
			move(delta)
			if is_out_of_bounds():
				queue_free()
		else:
			position = GlobalData.player.position + Vector2(cos(rotation), sin(rotation)) * 100

func move(delta):
	if has_hit:
		position = hit_position
		
	# Calculate movement vector
	var direction = Vector2(cos(rotation), sin(rotation))
	var movement = direction * speed * delta * fastness_multiplier
	
	# Configure raycast
	raycast.target_position = direction * movement.length()
	
	if raycast.is_colliding():
		# Stop at collision point
		var collision_point = raycast.get_collision_point()
		position = collision_point - direction * 2
		if should_collide(raycast.get_collider()):
			has_hit = true
			hit_position = collision_point
	else:
		# Normal movement
		position += movement
		speed = min(speed + speed, MAX_SPEED)

func should_collide(collider):
	if is_ethereal:
		if collider.is_in_group("enemies_projectiles"):
			return RandomNumberGenerator.new().randi_range(0,1)>0
		elif collider.is_in_group("enemies"):
			return true
	else:
		if collider.is_in_group("enemies_projectiles"):
			return false
		elif collider.is_in_group("enemies"):
			return true

func scale_up_projectile(delta):
	var collisionscale = $CollisionShape2D.shape.radius
	var animationscale = $AnimatedSprite2D.scale
	collisionscale = collisionscale+0.5*collisionscale*delta
	animationscale = animationscale+0.5*animationscale*delta

func is_out_of_bounds():
	return !get_parent().arena_rect.grow(100).has_point(self.position)

func _on_area_entered(area):
	if self.is_projectile_area_damage:
		_handle_area_damage_case(area)
	else:
		_handle_direct_hit_case(area)


func _handle_area_damage_case(area):
	_process_overlapping_areas()
	_handle_explosion_and_piercing(area)

func _process_overlapping_areas():
	for area_enemy in $AreaOfEffect.get_overlapping_areas():
		if GlobalData.combat_ongoing:
			if is_melee:
				_process_melee_hit(area_enemy)
			else:
				_process_ranged_hit(area_enemy)

func _process_ranged_hit(area_enemy):
	if area_enemy.is_in_group("enemies"):
		area_enemy.take_damage(get_projectile_damage())
		_destroy_self()
		if is_stunning:
			area_enemy.stun(2)
	elif area_enemy.is_in_group("enemies_projectiles") and is_ethereal:
		_destroy_both_projectiles(area_enemy)

func _process_melee_hit(area_enemy):
	if area_enemy.is_in_group("enemies"):
		var damage = get_projectile_damage() / 3 * get_process_delta_time()
		area_enemy.take_damage(damage)

func _handle_explosion_and_piercing(area):
	if (area.is_in_group("enemies") or area.is_in_group("enemies_projectiles")) and !is_melee:
		if area_of_effect_type == "explosion":
			_create_explosion_effect()

func _create_explosion_effect():
	var explosion = AnimatedSprite2D.new()
	explosion.sprite_frames = preload("res://Assets/SpriteSheets/sprites.tres")
	explosion.animation = "explosion"
	explosion.position = self.position
	explosion.scale = Vector2(8, 8)
	explosion.animation_finished.connect(explosion.queue_free)
	get_parent().add_child(explosion)
	explosion.play()

func _handle_piercing_logic():
	if is_piercing:
		piercing_pierce_remaining -= 1

func _handle_direct_hit_case(area):
	if area.is_in_group("enemies"):
		area.take_damage(get_projectile_damage())
		_destroy_self()
	elif area.is_in_group("enemies_projectiles") and is_ethereal:
		_destroy_both_projectiles(area)

func _destroy_enemy_projectile(projectile):
	projectile.queue_free()

func _destroy_self():
	if is_piercing:
		if piercing_pierce_remaining > 0:
			_handle_piercing_logic()
		else:
			queue_free()
	else:
		queue_free()

func _destroy_both_projectiles(projectile):
	_destroy_enemy_projectile(projectile)
	_destroy_self()
