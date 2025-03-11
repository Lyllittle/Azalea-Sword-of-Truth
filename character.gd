extends Area2D

@export var max_speed = 500
@export var speed = 200  # Movement speed
@export var friction = 0.25
var velocity = Vector2.ZERO
@onready var timer: Timer
@onready var timer_immunity: Timer
var shoot_cooldown = 0.2
var immunity_frames = 0.1
var active_attack_traits = []
var is_though = false
var area_of_effect = false
var custom_animation = null
var area_of_effect_type = ""
var remaining_to_melee
var number_of_hits_before_melee = 5
var projectile_velocity = 1.0
var is_piercing = false
var is_stunning = false


func _ready() -> void:
	remaining_to_melee = number_of_hits_before_melee
	timer = Timer.new()
	timer.wait_time = shoot_cooldown
	timer.one_shot = true
	add_child(timer)
	timer_immunity = Timer.new()
	timer_immunity.wait_time = immunity_frames
	timer_immunity.one_shot = true
	add_child(timer_immunity)
	print("my traits are "+str(active_attack_traits))
	for traits in active_attack_traits:
		if traits == "quick":
			timer.wait_time = shoot_cooldown / 2
		elif traits == "defensive_buff":
			timer_immunity.wait_time = immunity_frames * 2
			is_though = true
		elif traits == "slower_attack":
			timer.wait_time = shoot_cooldown * 1.5
		elif traits == "area_of_effect":
			self.area_of_effect = true
		elif traits == "fire":
			custom_animation = "fire_projectile"
		elif traits == "blade_projectile":
			custom_animation = "blade_projectile"
		elif traits == "explosion":
			area_of_effect_type = "explosion"
		elif traits == "sharp_projectile":
			custom_animation = "sharp_projectile"
		elif traits == "high_velocity":
			projectile_velocity = 3.0
		elif traits == "piercing":
			is_piercing = true
		elif traits == "stun":
			is_stunning = true

func _process(delta):
	if Input.is_action_pressed("Shoot") and timer.is_stopped() :
		timer.start()
		Input.start_joy_vibration(0, 0.5, 0.25, 0.5)
		var projectile = preload("res://player_projectile.tscn").instantiate()
		projectile.is_projectile_area_damage = area_of_effect
		var aim_direction = Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down")
		if aim_direction != Vector2.ZERO:
			projectile.rotation = aim_direction.angle()
		projectile.position = self.position + Vector2(cos(projectile.rotation), sin(projectile.rotation)) * 50
		projectile.fastness_multiplier = projectile_velocity
		projectile.custom_animation = custom_animation
		projectile.area_of_effect_type = area_of_effect_type
		if is_piercing:
			projectile.is_piercing = true
			projectile.piercing_pierce_remaining = 3
		if is_stunning:
			projectile.is_stunning = true
		get_parent().add_child(projectile)
		remaining_to_melee -= 1
		if "melee" in active_attack_traits and remaining_to_melee<=0:
			projectile = preload("res://player_projectile.tscn").instantiate()
			projectile.is_projectile_area_damage = area_of_effect
			projectile.position = self.position
			projectile.is_melee = true
			projectile.area_of_effect_type = ""
			projectile.is_projectile_area_damage = true
			get_parent().add_child(projectile)
			remaining_to_melee = number_of_hits_before_melee
	var velocity2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity += velocity2.normalized() * speed
	velocity = velocity.limit_length(max_speed)
	if not(Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_right")):
		velocity = velocity.move_toward(Vector2.ZERO, friction * speed)
	position += velocity * delta
	position = position.clamp(get_parent().arena_rect.position, get_parent().arena_rect.end)

func take_damage(damage):
	if timer_immunity.is_stopped():
		if !is_though:
			GlobalData.set_stat("health", max(GlobalData.game_data["stats"]["health"]-damage,0))
		else:
			GlobalData.set_stat("health", max(GlobalData.game_data["stats"]["health"]-(damage*0.5),0))
		timer_immunity.start()
		if GlobalData.game_data["stats"]["health"] <= 0 :
			die()

func die():
	print("Player has been defeated")
	GlobalData.combat_ongoing = false
	GlobalData.player_died.emit()

	queue_free()



#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
