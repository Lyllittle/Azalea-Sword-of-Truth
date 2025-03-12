extends Area2D

# __________ VARIABLES AND CONSTANTS __________

var velocity = 0
var direction

var special_effect : String
var local_difficulty
var SPRAY_ANGLE = 90
var stunned = false
var stun_timer


const PROJECTILE_DIRECTION = 180

var shoot_delay = 0.2
var projectile_count = 0
var shooting = false
var angle_step = 0
var random_increment = 0
var current_shooting_mode = ""
var ray_angles = []
var burst_angles = []


var traits = {}

var zigzag_amplitude = 500.0
var zigzag_frequency = 1.5
var zigzag_speed = 50
var zigzag_vertical_speed = 250
var points_count = 5
var zigzag_duration = 2.0

var target_points: Array = []
var current_target_index = 0
var zigzag_timer = 0.0
var moving_direction = 1

var wander_radius = 0.75
var wander_speed = 100
var wander_ease_duration = 5.0

var wander_target_position: Vector2
var wander_timer = 0.0


var hover_target_position = Vector2()
var hover_timer = 0.0
var hover_oscillation_count = 0
var hover_forward = true
var hover_speed = 500.0
var hover_oscillation_timer = 0.0
var hover_oscillation_forward = true
var hover_oscillation_duration = 0.5
var oscillation_ongoing = false
var hover_oscillation_target = Vector2()
var base_position = Vector2()

var orbit_target_position = Vector2()
var orbit_timer = 0.0
var orbit_speed = 50.0
var orbit_pull_strength = 100.0

var patrol_points = []
var patrol_index = 0
var patrol_timer = 0
var patrol_ease_duration = 0.75
var patrol_dome_resolution = 15
var patrol_dome_radius = 300
var patrol_dome_duration = 1.5

var damage_ranges = {
	0: [3, 5],
	1: [5, 7],
	2: [7, 10],
	3: [10, 15],
	4: [15, 20],
	5: [20, 25],
	6: [25, 30],
	7: [30, 40],
	8: [40, 50],
	9: [50, 70],
	10: [70, 100]
}

var projectile_count_ranges = {
	0: [1, 3],
	1: [3, 4],
	2: [4, 5],
	3: [5, 6],
	4: [6, 7],
	5: [7, 9],
	6: [9, 11],
	7: [11, 14],
	8: [14, 17],
	9: [17, 20],
	10: [20, 25]
}

var attack_delay_ranges = {
	0: [1.8, 2.0],
	1: [1.6, 1.8],
	2: [1.4, 1.6],
	3: [1.2, 1.4],
	4: [1.0, 1.2],
	5: [0.8, 1.0],
	6: [0.7, 0.9],
	7: [0.6, 0.8],
	8: [0.5, 0.7],
	9: [0.4, 0.6],
	10: [0.3, 0.5]
}

var shooting_pattern_ranges = {
	0: ["static"],
	1: ["static", "spread"],
	2: ["static", "spread", "circles"],
	3: ["spread", "circles", "burst"],
	4: ["circles", "burst", "rays"],
	5: ["burst", "spiral", "rays"],
	6: ["spiral", "spread", "rays"],
	7: ["spiral", "rays", "burst", "circles"],
	8: ["circles", "burst", "rays", "spiral", "spread"],
	9: ["spiral", "rays", "burst", "circles", "spread"],
	10: ["circles", "rays", "burst", "spiral", "spread"]
}

var moving_pattern_ranges = {
	0: ["static"],
	1: ["static", "wander"],
	2: ["static", "wander", "zigzag"],
	3: ["wander", "zigzag", "hover"],
	4: ["zigzag", "hover", "orbit"],
	5: ["hover", "orbit", "patrol"],
	6: ["orbit", "patrol", "chase"],
	7: ["patrol", "chase", "hover_chase"],
	8: ["chase", "hover_chase", "warp"],
	9: ["hover_chase", "warp", "erratic"],
	10: ["warp", "erratic", "hover_chase"]
}

var health_ranges = {
	0: [10, 20],
	1: [20, 30],
	2: [30, 40],
	3: [40, 50],
	4: [50, 60],
	5: [60, 70],
	6: [70, 80],
	7: [80, 90],
	8: [90, 95],
	9: [95, 100],
	10: [100, 100]
}

signal died()

# __________ FUNCTIONS __________

func move_to(destination: Vector2):
	self.position = destination

func process_velocity():
	move_to(get_global_position() + velocity * Vector2(direction))

func move(delta):
	match traits["moving_pattern"]:
		"wander":
			wander(delta)
		"zigzag":
			zigzag(delta)
		"hover":
			hover(delta)
		"orbit":
			orbit(delta)
		"patrol":
			patrol(delta)


func select_move():
	match traits["moving_pattern"]:
		"wander":
			initialize_wander()
		"zigzag":
			initialize_zigzag()
		"hover":
			initialize_hover()
		"orbit":
			initialize_orbit()
		"patrol":
			initialize_patrol()


func attack():
	match traits["shooting_patterns"]:
		"spiral":
			shoot_in_spiral()
		"spread":
			shoot_spread_over_time()
		"rays":
			shoot_rays_over_time()
		"circles":
			shoot_in_circle()
		"static":
			shoot_static()
		"burst":
			shoot_burst()


func initialize_enemy(difficulty):
	# Clamp difficulty to a maximum of 10
	var clamped_difficulty = min(difficulty, 10)
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Randomly select traits from ranges
	traits["damage"] = rng.randi_range(damage_ranges[clamped_difficulty][0], damage_ranges[clamped_difficulty][1])
	traits["projectile_count"] = 2 * rng.randi_range(projectile_count_ranges[clamped_difficulty][0], projectile_count_ranges[clamped_difficulty][1])
	traits["health"] = rng.randi_range(health_ranges[clamped_difficulty][0], health_ranges[clamped_difficulty][1])
	traits["attack_delay"] = rng.randf_range(attack_delay_ranges[clamped_difficulty][0], attack_delay_ranges[clamped_difficulty][1])
	traits["shooting_patterns"] = shooting_pattern_ranges[clamped_difficulty].pick_random()
	traits["moving_pattern"] = moving_pattern_ranges[clamped_difficulty].pick_random()

	# Exponential scaling for difficulty >10
	if difficulty > 10:
		var scaling_factor = pow(1.1, difficulty - 10)  # Exponential scaling
		traits["damage"] *= scaling_factor
		traits["projectile_count"] += int((difficulty - 10) / 2)
		traits["health"] *= scaling_factor
		traits["attack_delay"] = max(0.3, traits["attack_delay"] - (difficulty - 10) * 0.02)
		traits["shooting_patterns"].append_array(["burst", "circle", "spiral"])  # Add advanced patterns
		traits["moving_pattern"] = rng.pick(["warp", "erratic", "hover_chase", "patrol"])
	#print(str(traits["moving_pattern"])+str(traits["shooting_patterns"]))


func initialize_patrol():
	patrol_points = []
	patrol_index = 0

	var screen_size = get_viewport_rect().size
	#print("screen size is "+str(screen_size))
	var start_pos = Vector2(float(screen_size.x) * 0.75, float(screen_size.y) / 2)
	#print("start_pos is "+str(start_pos))
	var up_pos = start_pos + Vector2(0, float(screen_size.y) * 0.75 * 0.5)
	var down_pos = start_pos - Vector2(0, float(screen_size.y) * 0.75 * 0.5)
	var dome_up = [down_pos]
	var dome_down = [up_pos]

	for i in range(patrol_dome_resolution):
		var angle = deg_to_rad(float(90+ i * 180) / (patrol_dome_resolution-1))

		var x_offset = patrol_dome_radius * cos(angle)
		var y_offset = patrol_dome_radius * sin(angle)

		dome_up.append(start_pos + Vector2(x_offset, -y_offset))
		dome_down.append(start_pos + Vector2(x_offset, y_offset))
	
	dome_up.append(up_pos)
	dome_down.append(down_pos)
	patrol_points.append(up_pos)
	patrol_points.append(down_pos)
	patrol_points.append(dome_up)
	patrol_points.append(down_pos)
	patrol_points.append(up_pos) 
	patrol_points.append(dome_down)

	patrol_timer = patrol_ease_duration

func patrol(delta):
	patrol_timer -= delta
	if patrol_timer <= 0.001:
			patrol_timer = 0
			patrol_index += 1

			if patrol_index >= patrol_points.size():
				patrol_index = 0
				patrol_timer = patrol_ease_duration
			elif typeof(patrol_points[patrol_index]) == TYPE_ARRAY:
				patrol_timer = patrol_dome_duration
			else:
				patrol_timer = patrol_ease_duration

	elif patrol_timer > 0:
		if patrol_index < patrol_points.size():
			if typeof(patrol_points[patrol_index]) == TYPE_ARRAY:
				var t2 = 1.0 - (patrol_timer / patrol_dome_duration)
				t2 = t2 * t2 * (3 - 2 * t2)
				var dome_points = patrol_points[patrol_index]
				var current_index = floor(t2*float(dome_points.size() -1))
				var current_pos = dome_points[current_index]
				var next_pos = dome_points[min(current_index+1,dome_points.size()-1)]
				#print("delta is "+str(t2-(float(current_index) / (dome_points.size()-1))))
				move_to(current_pos.lerp(next_pos, dome_points.size()*(t2-(float(current_index) / (dome_points.size()-1)))))
			else:
				var t = 1.0 - (patrol_timer / patrol_ease_duration)
				t = t * t * (3 - 2 * t)
				var target_position = patrol_points[patrol_index]
				move_to(self.position.lerp(target_position, t))


func initialize_orbit():
	var screen_size = get_viewport_rect().size
	var player_position = GlobalData.player.global_position
	var radius = float(screen_size.y) * wander_radius / 2
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var angle = rng.randf_range(0, 2 * PI)
	var distance = rng.randf_range(radius * 0.5, radius)

	orbit_target_position = player_position + Vector2(cos(angle), sin(angle)) * distance
	orbit_timer = wander_ease_duration

func orbit(delta):
	if orbit_timer > 0:
		orbit_timer -= delta
		var t = 1.0 - (orbit_timer / wander_ease_duration)
		t = t * t * (3 - 2 * t)

		move_to(position.lerp(orbit_target_position, t))

		var player_position = GlobalData.player.global_position
		var attraction = (player_position - position).normalized() * orbit_pull_strength * delta
		position += attraction

		if position.distance_to(orbit_target_position) < 10:
			orbit_target_position = player_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
			orbit_timer = wander_ease_duration
	else:
		initialize_orbit()


func initialize_hover():
	var screen_size = get_viewport_rect().size
	var center = Vector2(float(screen_size.x) * 0.75, float(screen_size.y) / 2)
	var radius = float(screen_size.y) * wander_radius / 2
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var angle = rng.randf_range(0, 2 * PI)
	var distance = rng.randf_range(0, radius)

	hover_target_position = center + Vector2(cos(angle), sin(angle)) * distance
	hover_timer = wander_ease_duration
	hover_oscillation_count = 0
	hover_forward = true
	hover_oscillation_timer = 0.0
	hover_oscillation_forward = true
	oscillation_ongoing = false

func hover(delta):
	if hover_oscillation_count >= 3:
		initialize_hover()
	elif (position.distance_to(hover_target_position) < 10 and hover_oscillation_count < 3) or oscillation_ongoing:
		if not oscillation_ongoing:
			oscillation_ongoing = true
			var player_position = GlobalData.player.position
			hover_oscillation_target = player_position.lerp(self.position,0.85)
			base_position = self.position
		perform_hover_oscillation(delta)
	else:
		hover_timer -= delta
		var t = 1.0 - (hover_timer / wander_ease_duration)
		t = t * t * (3 - 2 * t)
		position = position.lerp(hover_target_position, t)

func perform_hover_oscillation(delta):
	#print("delta is "+str(delta))
	#print("oscillation_timer and duration are "+str(hover_oscillation_timer)+" and "+str(hover_oscillation_duration))
	hover_oscillation_timer += delta
	if hover_oscillation_timer > hover_oscillation_duration:
		#print("One oscillation done")
		hover_oscillation_timer = 0.0
		hover_oscillation_count += 1
		hover_oscillation_forward = !hover_oscillation_forward

	var t = hover_oscillation_timer / hover_oscillation_duration
	t = t * t * (3 - 2 * t)
	if hover_oscillation_forward:
		position = position.lerp(hover_oscillation_target,t)  
	else:
		position = position.lerp(base_position.move_toward(hover_oscillation_target, -1 * base_position.distance_to(hover_oscillation_target)),t)

		
func initialize_zigzag():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	target_points.clear()
	moving_direction = [-1,1].pick_random()
	var current_x = position.x
	var current_y = position.y
	for i in range(points_count):
		current_x -= (zigzag_amplitude / points_count)
		current_y = position.y + moving_direction * (rng.randf_range(50,zigzag_vertical_speed))
		target_points.append(Vector2(current_x, current_y))
		moving_direction *= -1
	target_points.append(position)
	current_target_index = 0
	zigzag_timer = zigzag_duration

func zigzag(delta):
	if current_target_index < target_points.size():
		var target_position = target_points[current_target_index]
		zigzag_timer -= delta
		var t = 1.0 - (zigzag_timer / zigzag_duration)
		t = t * t * (3 - 2 * t)

		position = position.lerp(target_position, t)

		if position.distance_to(target_position) < 10:
			current_target_index += 1
			zigzag_timer = zigzag_duration

	else:
		initialize_zigzag()

func initialize_wander():
	var screen_size = get_viewport_rect().size
	var center = Vector2(float(screen_size.x) * 0.75, float(screen_size.y) / 2)
	var radius = float(screen_size.y) * wander_radius / 2
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var angle = rng.randf_range(0, 2 * PI)
	var distance = rng.randf_range(0, radius)
	#print(str(distance)+ "et"+str(angle))
	wander_target_position = center + Vector2(cos(angle), sin(angle)) * distance

	wander_timer = wander_ease_duration

func wander(delta):
	if wander_timer > 0:
		wander_timer -= delta
		var t = 1.0 - (wander_timer / wander_ease_duration)
		t = t * t * (3 - 2 * t)

		move_to(position.lerp(wander_target_position, t))

		if position.distance_to(wander_target_position) < 10:
			initialize_wander()
	else:
		initialize_wander()


func shoot_static():
	current_shooting_mode = "static"
	if not shooting:
		projectile_count = 0
		var rng = RandomNumberGenerator.new()
		var random_angle = PROJECTILE_DIRECTION + rng.randf_range(-SPRAY_ANGLE, SPRAY_ANGLE)
		ray_angles.clear()
		ray_angles.append(random_angle)
		start_shooting()

func shoot_in_spiral():
	current_shooting_mode = "circle"
	if not shooting:	
		projectile_count = 0
		angle_step = 720 / traits["projectile_count"]
		random_increment = RandomNumberGenerator.new().randi_range(0, angle_step)
		angle_step += random_increment
		start_shooting()

func shoot_burst():
	current_shooting_mode = "burst"
	if not shooting:
		projectile_count = 0
		burst_angles = []
		var rng = RandomNumberGenerator.new()
		var player_direction = (GlobalData.player.global_position - global_position).angle()
		for i in range(traits["projectile_count"]):
			var random_angle = player_direction + deg_to_rad(rng.randf_range(-5, 5))
			burst_angles.append(random_angle)
		start_shooting()

func shoot_spread_over_time():
	current_shooting_mode = "spread"
	if not shooting:
		projectile_count = 0
		start_shooting()

func start_shooting():
	shoot_delay = traits["attack_delay"] / 2 / traits["projectile_count"]
	shooting = true
	var timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = shoot_delay
	timer.timeout.connect(_on_shooting_timer_timeout.bind(timer))
	add_child(timer)
	timer.start()

func _on_shooting_timer_timeout(timer):
	if projectile_count >= traits["projectile_count"]:
		shooting = false
		timer.queue_free()
		return

	if current_shooting_mode == "circle":
		var angle = projectile_count * angle_step + random_increment
		var projectile = preload("res://enemy_projectile.tscn").instantiate()
		projectile.damage = traits["damage"]
		projectile.movement_pattern = "spiral"
		projectile.rotation_degrees = angle
		projectile.position = self.position
		get_parent().add_child(projectile)
	elif current_shooting_mode == "spread":
		var projectile = preload("res://enemy_projectile.tscn").instantiate()
		projectile.damage = traits["damage"]
		var angle = PROJECTILE_DIRECTION - (SPRAY_ANGLE/3.6 * sin(projectile_count))
		projectile.rotation_degrees = angle
		projectile.position = position
		get_parent().add_child(projectile)
	elif current_shooting_mode == "rays":
		var angle = ray_angles[floor(float(projectile_count)/10)]
		var projectile = preload("res://enemy_projectile.tscn").instantiate()
		projectile.damage = traits["damage"]
		projectile.rotation_degrees = angle
		projectile.position = position
		get_parent().add_child(projectile)
	elif current_shooting_mode == "static":
		var angle = ray_angles[0]
		var projectile = preload("res://enemy_projectile.tscn").instantiate()
		projectile.damage = traits["damage"]
		projectile.rotation_degrees = angle
		projectile.position = position
		get_parent().add_child(projectile)
	elif current_shooting_mode == "burst":
		var angle = burst_angles[projectile_count]
		var projectile = preload("res://enemy_projectile.tscn").instantiate()
		projectile.damage = traits["damage"]
		projectile.rotation = angle
		projectile.position = position
		get_parent().add_child(projectile)
	projectile_count += 1

func shoot_rays_over_time():
	current_shooting_mode = "rays"
	if not shooting:
		projectile_count = 0
		ray_angles = []
		var rng = RandomNumberGenerator.new()
		for i in range(ceil(float(traits["projectile_count"]) / 10)):
			var random_angle = PROJECTILE_DIRECTION + rng.randf_range(-SPRAY_ANGLE, SPRAY_ANGLE)
			ray_angles.append(random_angle)
		start_shooting()

func shoot_in_circle():
	angle_step = 360.0 / traits["projectile_count"]
	random_increment = RandomNumberGenerator.new().randi_range(0, angle_step)
	for i in range(traits["projectile_count"]):
		var projectile = preload("res://enemy_projectile.tscn").instantiate()
		var angle = i * angle_step + random_increment
		projectile.rotation_degrees = angle
		projectile.position = self.position
		get_parent().add_child(projectile)
		
func take_damage(damage):
	traits["health"] -= damage
	if traits["health"] <= 0:
		die()

func die():
	print("Enemy defeated")
	died.emit()

func stun(duration):
	stun_timer = duration
	stunned = true

# __________ MAIN FUNCTIONS __________

	
var time_since_last_attack = 0.0

func _ready() -> void:
	select_move()
	if traits["shooting_patterns"] == "spiral":
		traits["attack_delay"] *= 2
		traits["projectile_count"] = ceil(traits["projectile_count"] / 1.5)
	time_since_last_attack = traits["attack_delay"] / 1.5

func _process(delta):
	#print("My traits are "+str(traits))
	if GlobalData.combat_ongoing and !stunned:
		time_since_last_attack += delta
		if time_since_last_attack >= traits["attack_delay"]:
			attack()
			time_since_last_attack = 0.0
		move(delta)
	elif stunned:
		stun_timer-=delta
		if stun_timer <= 0:
			stunned = false
