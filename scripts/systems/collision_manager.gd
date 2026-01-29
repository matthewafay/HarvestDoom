extends Node
## CollisionManager - Handles collision detection and physics interactions
##
## Manages collision layers and masks for all game entities to ensure
## proper physics interactions between player, enemies, projectiles, and environment.
##
## Responsibilities:
## - Set up collision layers and masks for entities
## - Provide line-of-sight checking for ranged enemies
## - Ensure proper collision filtering
##
## Validates: Requirements 1.5, 2.3, 3.5

class_name CollisionManager

# Collision layer constants (bit flags)
const LAYER_PLAYER = 1        # Layer 1
const LAYER_ENEMY = 2         # Layer 2
const LAYER_PROJECTILE = 4    # Layer 3
const LAYER_ENVIRONMENT = 8   # Layer 4
const LAYER_INTERACTIVE = 16  # Layer 5

func setup_player_collision(player: CharacterBody3D) -> void:
	"""Configure collision layers and masks for the player.
	
	Player should:
	- Be on LAYER_PLAYER
	- Collide with LAYER_ENEMY and LAYER_ENVIRONMENT
	
	Args:
		player: The player CharacterBody3D node
	"""
	if not player:
		push_error("CollisionManager.setup_player_collision: player is null")
		return
	
	player.collision_layer = LAYER_PLAYER
	player.collision_mask = LAYER_ENEMY | LAYER_ENVIRONMENT

func setup_enemy_collision(enemy: CharacterBody3D) -> void:
	"""Configure collision layers and masks for enemies.
	
	Enemies should:
	- Be on LAYER_ENEMY
	- Collide with LAYER_PLAYER and LAYER_ENVIRONMENT
	- NOT collide with other enemies (prevents clustering)
	
	Args:
		enemy: The enemy CharacterBody3D node
	"""
	if not enemy:
		push_error("CollisionManager.setup_enemy_collision: enemy is null")
		return
	
	enemy.collision_layer = LAYER_ENEMY
	enemy.collision_mask = LAYER_PLAYER | LAYER_ENVIRONMENT

func setup_projectile_collision(projectile: Area3D) -> void:
	"""Configure collision layers and masks for projectiles.
	
	Projectiles should:
	- Be on LAYER_PROJECTILE
	- Collide with LAYER_ENEMY and LAYER_ENVIRONMENT
	
	Args:
		projectile: The projectile Area3D node
	"""
	if not projectile:
		push_error("CollisionManager.setup_projectile_collision: projectile is null")
		return
	
	projectile.collision_layer = LAYER_PROJECTILE
	projectile.collision_mask = LAYER_ENEMY | LAYER_ENVIRONMENT

func check_line_of_sight(from: Vector3, to: Vector3, exclude: Array = []) -> bool:
	"""Check if there's a clear line of sight between two points.
	
	Uses raycasting to detect obstacles in the LAYER_ENVIRONMENT.
	Useful for ranged enemy AI to determine if they can see the player.
	
	Args:
		from: Starting position
		to: Target position
		exclude: Array of RIDs to exclude from the raycast
		
	Returns:
		True if line of sight is clear, False if blocked
	"""
	var space_state = PhysicsServer3D.space_get_direct_state(
		get_viewport().world_3d.space
	)
	
	if not space_state:
		push_error("CollisionManager.check_line_of_sight: Could not get space state")
		return false
	
	# Create ray query
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = LAYER_ENVIRONMENT | LAYER_PLAYER
	query.exclude = exclude
	
	# Perform raycast
	var result = space_state.intersect_ray(query)
	
	# If no hit, line of sight is clear
	# If hit something, check if it's the target or an obstacle
	return result.is_empty()

func setup_interactive_collision(interactive: Area3D) -> void:
	"""Configure collision layers and masks for interactive objects.
	
	Interactive objects (plots, portals, NPCs) should:
	- Be on LAYER_INTERACTIVE
	- Detect LAYER_PLAYER
	
	Args:
		interactive: The interactive Area3D node
	"""
	if not interactive:
		push_error("CollisionManager.setup_interactive_collision: interactive is null")
		return
	
	interactive.collision_layer = LAYER_INTERACTIVE
	interactive.collision_mask = LAYER_PLAYER

func get_layer_name(layer_bit: int) -> String:
	"""Get human-readable name for a collision layer.
	
	Args:
		layer_bit: The layer bit flag
		
	Returns:
		Layer name as string
	"""
	match layer_bit:
		LAYER_PLAYER:
			return "Player"
		LAYER_ENEMY:
			return "Enemy"
		LAYER_PROJECTILE:
			return "Projectile"
		LAYER_ENVIRONMENT:
			return "Environment"
		LAYER_INTERACTIVE:
			return "Interactive"
		_:
			return "Unknown"
