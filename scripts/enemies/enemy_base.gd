extends CharacterBody3D
## EnemyBase - Base class for all enemy types
##
## Provides common functionality for all enemies including health management,
## damage handling, death, and loot dropping.
##
## Responsibilities:
## - Manage enemy health
## - Handle damage and death
## - Spawn loot on death
## - Track player target
## - Provide base AI behavior (to be overridden)
##
## Validates: Requirements 3.3, 3.4, 3.5

class_name EnemyBase

# Stats
@export var max_health: int = 100
@export var move_speed: float = 3.0
@export var damage: int = 10
@export var loot_drop: Dictionary = {"credits": 10}

# State
var current_health: int
var target: Node3D = null  # Player reference
var is_dead: bool = false

# Signals
signal died(loot: Dictionary)
signal attacked_player(damage: int)

func _ready() -> void:
	# Initialize health
	current_health = max_health
	
	# Set up collision
	var collision_mgr = CollisionManager.new()
	collision_mgr.setup_enemy_collision(self)
	collision_mgr.queue_free()
	
	# Find player
	_find_player()
	
	# Apply procedurally generated sprite
	_apply_procedural_sprite()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Update AI (to be overridden by subclasses)
	_update_ai(delta)
	
	# Apply physics
	move_and_slide()

func _update_ai(delta: float) -> void:
	"""Update AI behavior. Override in subclasses."""
	pass

func _find_player() -> void:
	"""Find and set the player as target."""
	# Look for player in scene tree
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		target = player_node

func take_damage(amount: int) -> void:
	"""Apply damage to the enemy.
	
	Args:
		amount: Damage amount to apply
		
	Validates: Requirement 3.3
	"""
	if is_dead:
		return
	
	current_health -= amount
	
	# Visual feedback
	_show_damage_feedback(amount)
	
	# Check for death
	if current_health <= 0:
		die()

func _show_damage_feedback(amount: int) -> void:
	"""Show visual feedback for damage taken."""
	# TODO: Integrate with FeedbackSystem when implemented
	# For now, just flash the sprite
	pass

func die() -> void:
	"""Handle enemy death.
	
	Validates: Requirement 3.4
	"""
	if is_dead:
		return
	
	is_dead = true
	
	# Emit death signal with loot
	died.emit(loot_drop)
	
	# Spawn loot
	_spawn_loot()
	
	# Remove enemy from scene
	queue_free()

func _spawn_loot() -> void:
	"""Spawn loot items at enemy position.
	
	Adds loot to GameManager's run_loot (temporary collection during combat).
	Run loot is only added to permanent inventory on successful run completion.
	"""
	# Add loot to GameManager run loot (not permanent inventory yet)
	if GameManager:
		for resource_type in loot_drop.keys():
			var amount = loot_drop[resource_type]
			GameManager.add_to_run_loot(resource_type, amount)

func attack_player() -> void:
	"""Deal damage to the player.
	
	Validates: Requirement 3.5
	"""
	if not target or is_dead:
		return
	
	# Check if player has take_damage method
	if target.has_method("take_damage"):
		target.take_damage(damage)
		attacked_player.emit(damage)

func _apply_procedural_sprite() -> void:
	"""Apply procedurally generated sprite to enemy.
	
	Validates: Requirement 12.6
	"""
	# Get enemy type name
	var enemy_type = get_script().get_global_name()
	if enemy_type.is_empty():
		enemy_type = "generic"
	
	# Generate sprite using ProceduralArtGenerator
	# TODO: Integrate with ProceduralArtGenerator when visual system is ready
	pass

func get_distance_to_player() -> float:
	"""Get distance to player target.
	
	Returns:
		Distance in units, or INF if no target
	"""
	if not target:
		return INF
	
	return global_position.distance_to(target.global_position)

func get_direction_to_player() -> Vector3:
	"""Get normalized direction vector to player.
	
	Returns:
		Direction vector, or ZERO if no target
	"""
	if not target:
		return Vector3.ZERO
	
	return (target.global_position - global_position).normalized()

func is_player_in_range(range_distance: float) -> bool:
	"""Check if player is within specified range.
	
	Args:
		range_distance: Maximum distance to check
		
	Returns:
		True if player is within range
	"""
	return get_distance_to_player() <= range_distance
