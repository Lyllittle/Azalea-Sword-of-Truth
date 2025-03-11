extends MarginContainer

const SHOOTING_PATTERN_ICONS = {
	"circles": preload("res://Assets/Sprites/circle_attack.png"),
	"spread": preload("res://Assets/Sprites/burst_attack.png"),
	"burst": preload("res://Assets/Sprites/burst_attack.png"),
	"rays": preload("res://Assets/Sprites/rays_attack.png"),
	"static": preload("res://Assets/Sprites/static_attack.png"),
	"spiral": preload("res://Assets/Sprites/spiral_attack.png")
}

const MOVE_PATTERN_ICONS = {
	
}

const SPECIAL_ICONS = {
	
}

func set_patterns(shooting_pattern, movement_pattern, warp_level, number):
	if shooting_pattern in SHOOTING_PATTERN_ICONS.keys():
		$GridContainer/ShootPatternIcon.texture = SHOOTING_PATTERN_ICONS[shooting_pattern]
	if shooting_pattern in MOVE_PATTERN_ICONS.keys():
		$GridContainer/MovePatternIcon.texture = MOVE_PATTERN_ICONS[shooting_pattern]
	$GridContainer/WarpLabel.text = str(warp_level) + " "
	$GridContainer/EnemiesNumberLabel.text = str(number) + " "
	
