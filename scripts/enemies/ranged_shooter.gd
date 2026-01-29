extends EnemyBase
## RangedShooter - Ranged enemy that fires projectiles at the player
##
## Maintains distance from player and fires projectiles when line of sight exists.
##
## Validates: Requirements 3.2, 3.5

class_name RangedShooter

@export var projectile_speed: float = 10.0
@export var fire_rate: float = 1.5
@export var optimal_range: float = 10.0
@export var min_range: float = 5.0

var last_fire_time: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")

func _ready() -> void:
	super._ready()
	
	# Override stats for ranged shooter
	max_health = 75
	current_health = max_health
	move_speed = 2.0
	damage = 8

func _update_ai(delta: float) -> void:
	"""Fire projectiles at player when line of sight exists.
	
	Validates: Requirement 3.2
	"""
	if not target:
		return
	
	var distance = get_distance_to_player()
	
	# Maintain optimal range
	if distance < min_range:
		# Move away from player
		var direction = -get_direction_to_player()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	elif distance > optimal_range:
		# Move toward player
		var direction = get_direction_to_player()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		# Stop moving
		velocity.x = 0.0
		velocity.z = 0.0
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# Fire at player if line of sight exists
	_try_fire_at_player()

func _try_fire_at_player() -> void:
	"""Attempt to fire projectile at player."""
	if not target:
		return
	
	# Check fire rate
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_fire_time < fire_rate:
		return
	
	# Check line of sight
	var collision_mgr = CollisionManager.new()
	var has_los = collision_mgr.check_line_of_sight(
		global_position + Vector3(0, 1, 0),  # Eye level
		target.global_position + Vector3(0, 1, 0)
	)
	collision_mgr.queue_free()
	
	if has_los:
		_fire_projectile()
		last_fire_time = current_time

func _fire_projectile() -> void:
	"""Fire a projectile toward the player."""
	if not projectile_scene:
		return
	
	var projectile = projectile_scene.instantiate()
	
	# Set projectile position and direction
	projectile.global_position = global_position + Vector3(0, 1, 0)
	projectile.direction = get_direction_to_player()
	projectile.speed = projectile_speed
	projectile.damage = damage
	
	# Add to scene
	get_tree().root.add_child(projectile)
