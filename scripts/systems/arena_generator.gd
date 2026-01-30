class_name ArenaGenerator extends Node3D

## ArenaGenerator
## Responsibility: Generate combat arena layouts and enemy spawn patterns.
## Validates: Requirements 8.1, 8.2, 8.3, 8.5

# Arena templates define different arena configurations
# Each template specifies size, cover count, and spawn points
var arena_templates: Array[Dictionary] = [
	{
		"size": Vector2(20, 20),
		"cover_count": 5,
		"spawn_points": 4
	},
	{
		"size": Vector2(25, 15),
		"cover_count": 7,
		"spawn_points": 6
	}
]

# Signals
signal wave_completed(wave_number: int)
signal arena_completed()

# Current arena state
var current_template: Dictionary = {}
var spawn_points: Array[Vector3] = []
var cover_objects: Array[Node3D] = []
var arena_boundaries: Array[Node3D] = []

# Wave management
var current_wave: int = 0
var active_enemies: Array = []  # Array of EnemyBase instances
var total_waves: int = 5  # Total number of waves in the arena
var wave_complete_emitted: bool = false  # Track if wave_completed signal was emitted for current wave
var auto_progress_enabled: bool = true  # Enable automatic wave progression
var wave_transition_delay: float = 3.0  # Delay in seconds between waves
var wave_transition_timer: float = 0.0  # Timer for wave transition
var is_transitioning: bool = false  # Track if we're between waves

# Run completion tracking
var run_completed: bool = false  # Track if the entire run (all waves) has been completed
var arena_complete_emitted: bool = false  # Track if arena_completed signal was emitted
var total_run_loot: Dictionary = {}  # Track total loot collected during the run

# Wave configurations define enemy composition per wave
# Each wave specifies enemy types and counts
var wave_configurations: Array[Dictionary] = [
	# Wave 1: Easy start with melee enemies
	{
		"enemies": [
			{"type": "MeleeCharger", "count": 3}
		]
	},
	# Wave 2: Mix of melee and ranged
	{
		"enemies": [
			{"type": "MeleeCharger", "count": 2},
			{"type": "RangedShooter", "count": 2}
		]
	},
	# Wave 3: Introduce tank
	{
		"enemies": [
			{"type": "MeleeCharger", "count": 3},
			{"type": "RangedShooter", "count": 2},
			{"type": "TankEnemy", "count": 1}
		]
	},
	# Wave 4: Harder mix
	{
		"enemies": [
			{"type": "MeleeCharger", "count": 4},
			{"type": "RangedShooter", "count": 3},
			{"type": "TankEnemy", "count": 2}
		]
	},
	# Wave 5: Final wave
	{
		"enemies": [
			{"type": "MeleeCharger", "count": 5},
			{"type": "RangedShooter", "count": 4},
			{"type": "TankEnemy", "count": 3}
		]
	}
]

# Methods to be implemented in subsequent tasks:
# (none - all core methods implemented)

## Process method to check wave completion, emit signals, and handle wave progression
## Validates: Requirements 8.2, 8.4
func _process(delta: float) -> void:
	# Handle wave transition timer
	if is_transitioning:
		wave_transition_timer -= delta
		if wave_transition_timer <= 0.0:
			is_transitioning = false
			# Spawn next wave if auto-progression is enabled and not at final wave
			if auto_progress_enabled and current_wave < total_waves:
				spawn_wave(current_wave + 1)
	
	# Only check if we have an active wave and not transitioning
	if current_wave > 0 and not wave_complete_emitted and not is_transitioning:
		# Check if the current wave is complete
		if is_wave_complete():
			# Emit wave_completed signal
			wave_completed.emit(current_wave)
			wave_complete_emitted = true
			
			print("Wave %d completed!" % current_wave)
			
			# Check if this was the final wave
			if current_wave >= total_waves:
				# Mark run as completed
				run_completed = true
				
				# Emit arena_completed signal (only once)
				if not arena_complete_emitted:
					arena_completed.emit()
					arena_complete_emitted = true
					print("Arena completed! All waves cleared.")
			else:
				# Start transition to next wave
				if auto_progress_enabled:
					is_transitioning = true
					wave_transition_timer = wave_transition_delay
					print("Next wave spawning in %.1f seconds..." % wave_transition_delay)


## Generate an arena layout using a seeded random number generator
## This method selects a template, creates boundaries, cover elements, and spawn points
## @param seed_value: The seed for deterministic random generation
func generate_arena(seed_value: int) -> void:
	# Seed the random number generator for deterministic output
	seed(seed_value)
	
	# Clear any existing arena elements
	_clear_arena()
	
	# Reset run completion state
	run_completed = false
	arena_complete_emitted = false
	current_wave = 0
	wave_complete_emitted = false
	total_run_loot.clear()
	
	# Select a random template from arena_templates
	var template_index = randi() % arena_templates.size()
	current_template = arena_templates[template_index]
	
	# Extract template parameters
	var arena_size: Vector2 = current_template["size"]
	var cover_count: int = current_template["cover_count"]
	var spawn_point_count: int = current_template["spawn_points"]
	
	# Generate arena boundaries
	_generate_boundaries(arena_size)
	
	# Generate cover elements
	_generate_cover_elements(arena_size, cover_count)
	
	# Generate spawn points
	_generate_spawn_points(arena_size, spawn_point_count)
	
	print("Arena generated with seed %d: size=%s, cover=%d, spawns=%d" % [seed_value, arena_size, cover_count, spawn_point_count])

## Clear all existing arena elements
func _clear_arena() -> void:
	# Remove all boundary objects
	for boundary in arena_boundaries:
		if is_instance_valid(boundary):
			boundary.queue_free()
	arena_boundaries.clear()
	
	# Remove all cover objects
	for cover in cover_objects:
		if is_instance_valid(cover):
			cover.queue_free()
	cover_objects.clear()
	
	# Clear spawn points array
	spawn_points.clear()
	
	# Reset current template
	current_template = {}

## Generate arena boundaries (walls) around the perimeter
## @param arena_size: The size of the arena (width, height)
func _generate_boundaries(arena_size: Vector2) -> void:
	var half_width = arena_size.x / 2.0
	var half_height = arena_size.y / 2.0
	var wall_height = 3.0
	var wall_thickness = 0.5
	
	# Create four walls: North, South, East, West
	var wall_configs = [
		{"pos": Vector3(0, wall_height / 2, -half_height), "size": Vector3(arena_size.x, wall_height, wall_thickness)},  # North
		{"pos": Vector3(0, wall_height / 2, half_height), "size": Vector3(arena_size.x, wall_height, wall_thickness)},   # South
		{"pos": Vector3(-half_width, wall_height / 2, 0), "size": Vector3(wall_thickness, wall_height, arena_size.y)},   # West
		{"pos": Vector3(half_width, wall_height / 2, 0), "size": Vector3(wall_thickness, wall_height, arena_size.y)}     # East
	]
	
	for config in wall_configs:
		var wall = _create_wall(config["pos"], config["size"])
		arena_boundaries.append(wall)
		add_child(wall)

## Create a single wall with collision
## @param position: The position of the wall
## @param size: The size of the wall (width, height, depth)
## @return: A StaticBody3D representing the wall
func _create_wall(position: Vector3, size: Vector3) -> StaticBody3D:
	var wall = StaticBody3D.new()
	wall.position = position
	
	# Add collision shape
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = size
	collision_shape.shape = box_shape
	wall.add_child(collision_shape)
	
	# Add visual mesh
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	
	# Create material with combat palette color
	var art_gen_script = load("res://scripts/systems/procedural_art_generator.gd")
	var combat_palette = art_gen_script.COMBAT_PALETTE
	var material = StandardMaterial3D.new()
	material.albedo_color = combat_palette[randi() % combat_palette.size()]
	mesh_instance.material_override = material
	
	wall.add_child(mesh_instance)
	
	# Set collision layer (LAYER_ENVIRONMENT = 8)
	wall.collision_layer = 8
	wall.collision_mask = 0
	
	return wall

## Generate cover elements scattered throughout the arena
## @param arena_size: The size of the arena
## @param cover_count: The number of cover elements to generate
func _generate_cover_elements(arena_size: Vector2, cover_count: int) -> void:
	var half_width = arena_size.x / 2.0
	var half_height = arena_size.y / 2.0
	var min_distance_from_center = 3.0  # Keep center area clear
	var min_distance_between_cover = 2.0  # Minimum spacing between cover
	
	for i in range(cover_count):
		var attempts = 0
		var max_attempts = 20
		var valid_position = false
		var cover_pos = Vector3.ZERO
		
		# Try to find a valid position for the cover
		while not valid_position and attempts < max_attempts:
			# Random position within arena bounds (with margin)
			var x = randf_range(-half_width + 2, half_width - 2)
			var z = randf_range(-half_height + 2, half_height - 2)
			cover_pos = Vector3(x, 0, z)
			
			# Check if position is far enough from center
			if cover_pos.length() < min_distance_from_center:
				attempts += 1
				continue
			
			# Check if position is far enough from other cover
			valid_position = true
			for existing_cover in cover_objects:
				if existing_cover.position.distance_to(cover_pos) < min_distance_between_cover:
					valid_position = false
					break
			
			attempts += 1
		
		# Create cover object if valid position found
		if valid_position:
			var cover = _create_cover_object(cover_pos)
			cover_objects.append(cover)
			add_child(cover)

## Create a single cover object with collision
## @param position: The position of the cover object
## @return: A StaticBody3D representing the cover
func _create_cover_object(position: Vector3) -> StaticBody3D:
	var cover = StaticBody3D.new()
	cover.position = position
	
	# Randomize cover size and shape
	var cover_type = randi() % 3
	var size: Vector3
	var shape: Shape3D
	var mesh: Mesh
	
	match cover_type:
		0:  # Box cover (crate-like)
			size = Vector3(randf_range(1.0, 2.0), randf_range(1.0, 1.5), randf_range(1.0, 2.0))
			shape = BoxShape3D.new()
			shape.size = size
			mesh = BoxMesh.new()
			mesh.size = size
		1:  # Cylinder cover (pillar-like)
			var radius = randf_range(0.5, 1.0)
			var height = randf_range(1.5, 2.5)
			size = Vector3(radius * 2, height, radius * 2)
			shape = CylinderShape3D.new()
			shape.radius = radius
			shape.height = height
			mesh = CylinderMesh.new()
			mesh.top_radius = radius
			mesh.bottom_radius = radius
			mesh.height = height
		_:  # Capsule cover (rounded)
			var radius = randf_range(0.4, 0.8)
			var height = randf_range(1.2, 2.0)
			size = Vector3(radius * 2, height, radius * 2)
			shape = CapsuleShape3D.new()
			shape.radius = radius
			shape.height = height
			mesh = CapsuleMesh.new()
			mesh.radius = radius
			mesh.height = height
	
	# Add collision shape
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = shape
	collision_shape.position.y = size.y / 2  # Raise to sit on ground
	cover.add_child(collision_shape)
	
	# Add visual mesh
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position.y = size.y / 2  # Raise to sit on ground
	
	# Create material with combat palette color
	var art_gen_script = load("res://scripts/systems/procedural_art_generator.gd")
	var combat_palette = art_gen_script.COMBAT_PALETTE
	var material = StandardMaterial3D.new()
	material.albedo_color = combat_palette[randi() % combat_palette.size()]
	mesh_instance.material_override = material
	
	cover.add_child(mesh_instance)
	
	# Set collision layer (LAYER_ENVIRONMENT = 8)
	cover.collision_layer = 8
	cover.collision_mask = 0
	
	return cover

## Generate spawn points for enemy placement
## @param arena_size: The size of the arena
## @param spawn_point_count: The number of spawn points to generate
func _generate_spawn_points(arena_size: Vector2, spawn_point_count: int) -> void:
	var half_width = arena_size.x / 2.0
	var half_height = arena_size.y / 2.0
	var min_distance_from_center = 5.0  # Spawn enemies away from center (where player starts)
	var spawn_margin = 3.0  # Distance from walls
	
	for i in range(spawn_point_count):
		var attempts = 0
		var max_attempts = 20
		var valid_position = false
		var spawn_pos = Vector3.ZERO
		
		# Try to find a valid spawn position
		while not valid_position and attempts < max_attempts:
			# Random position within arena bounds (with margin from walls)
			var x = randf_range(-half_width + spawn_margin, half_width - spawn_margin)
			var z = randf_range(-half_height + spawn_margin, half_height - spawn_margin)
			spawn_pos = Vector3(x, 0, z)
			
			# Check if position is far enough from center (player spawn)
			if spawn_pos.length() >= min_distance_from_center:
				valid_position = true
			
			attempts += 1
		
		# Add spawn point if valid position found
		if valid_position:
			spawn_points.append(spawn_pos)

## Spawn a wave of enemies at spawn points
## @param wave_number: The wave number to spawn (1-indexed)
## Validates: Requirements 8.1, 8.2, 8.3, 8.5
func spawn_wave(wave_number: int) -> void:
	# Validate wave number
	if wave_number < 1:
		push_error("Invalid wave number: %d. Wave numbers must be >= 1" % wave_number)
		return
	
	# Check if spawn points are available
	if spawn_points.is_empty():
		push_error("Cannot spawn wave: no spawn points available. Call generate_arena first.")
		return
	
	# Clear any existing active enemies
	_clear_active_enemies()
	
	# Update current wave
	current_wave = wave_number
	
	# Reset wave completion flag for new wave
	wave_complete_emitted = false
	
	# Reset transition state
	is_transitioning = false
	wave_transition_timer = 0.0
	
	# Get wave configuration (loop if wave number exceeds configurations)
	var config_index = (wave_number - 1) % wave_configurations.size()
	var wave_config = wave_configurations[config_index]
	
	# Track spawn point index for distribution
	var spawn_index = 0
	
	# Spawn each enemy type in the wave configuration
	for enemy_config in wave_config["enemies"]:
		var enemy_type: String = enemy_config["type"]
		var enemy_count: int = enemy_config["count"]
		
		# Spawn the specified number of enemies of this type
		for i in range(enemy_count):
			var enemy = _create_enemy(enemy_type)
			
			if enemy:
				# Get spawn position (cycle through spawn points)
				var spawn_pos = spawn_points[spawn_index % spawn_points.size()]
				enemy.global_position = spawn_pos
				
				# Add enemy to scene
				add_child(enemy)
				
				# Track active enemy
				active_enemies.append(enemy)
				
				# Connect to enemy death signal
				enemy.died.connect(_on_enemy_died)
				
				# Move to next spawn point
				spawn_index += 1
	
	print("Spawned wave %d with %d enemies" % [wave_number, active_enemies.size()])

## Create an enemy instance based on type string
## @param enemy_type: The enemy type name ("MeleeCharger", "RangedShooter", "TankEnemy")
## @return: An enemy instance or null if type is invalid
func _create_enemy(enemy_type: String):
	var enemy = null
	
	var melee_script = load("res://scripts/enemies/melee_charger.gd")
	var ranged_script = load("res://scripts/enemies/ranged_shooter.gd")
	var tank_script = load("res://scripts/enemies/tank_enemy.gd")
	
	if enemy_type == "MeleeCharger":
		enemy = CharacterBody3D.new()
		enemy.set_script(melee_script)
	elif enemy_type == "RangedShooter":
		enemy = CharacterBody3D.new()
		enemy.set_script(ranged_script)
	elif enemy_type == "TankEnemy":
		enemy = CharacterBody3D.new()
		enemy.set_script(tank_script)
	else:
		push_error("Unknown enemy type: %s" % enemy_type)
		return null
	
	return enemy

## Clear all active enemies from the arena
func _clear_active_enemies() -> void:
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()

## Handle enemy death
## @param loot: The loot dropped by the enemy
## Validates: Requirement 8.4 (loot collection during combat)
func _on_enemy_died(loot: Dictionary) -> void:
	# Track loot collected during the run
	for resource_type in loot.keys():
		var amount = loot[resource_type]
		if not total_run_loot.has(resource_type):
			total_run_loot[resource_type] = 0
		total_run_loot[resource_type] += amount
	
	# Note: The enemy will be removed from active_enemies array when is_wave_complete() is called
	# The loot is already added to GameManager.run_loot by EnemyBase._spawn_loot()

## Get a random spawn point from the available spawn points
## Returns a random Vector3 position from the spawn_points array
## Returns Vector3.ZERO if no spawn points are available
## Validates: Requirements 8.1, 8.2, 8.3, 8.5
func get_random_spawn_point() -> Vector3:
	# Check if spawn points are available
	if spawn_points.is_empty():
		push_warning("No spawn points available. Call generate_arena first.")
		return Vector3.ZERO
	
	# Return a random spawn point from the array
	var random_index = randi() % spawn_points.size()
	return spawn_points[random_index]

## Check if the current wave is complete (all enemies defeated)
## Returns true if all enemies in the active_enemies array are dead or invalid
## Returns false if any enemies are still alive
## Validates: Requirements 8.2, 8.4
func is_wave_complete() -> bool:
	# Clean up the active_enemies array by removing invalid/dead enemies
	var alive_enemies: Array = []
	
	for enemy in active_enemies:
		# Check if enemy is still a valid instance and not dead
		if is_instance_valid(enemy) and not enemy.is_dead:
			alive_enemies.append(enemy)
	
	# Update the active_enemies array to only contain alive enemies
	active_enemies = alive_enemies
	
	# Wave is complete if no alive enemies remain
	return active_enemies.is_empty()

## Check if the entire run is complete (all waves cleared)
## Returns true if all waves have been completed and the run is finished
## Returns false if there are still waves remaining or no waves have been started
## Validates: Requirement 8.4
func is_run_complete() -> bool:
	# Run is complete if:
	# 1. We have started waves (current_wave > 0)
	# 2. We have completed at least the total number of waves
	# 3. The current wave is complete (no active enemies)
	# 4. The run_completed flag is set
	return run_completed and current_wave >= total_waves and is_wave_complete()

## Enable or disable automatic wave progression
## When enabled, the next wave will spawn automatically after wave_transition_delay seconds
## When disabled, waves must be spawned manually via spawn_wave()
## @param enabled: Whether to enable automatic wave progression
func set_auto_progress(enabled: bool) -> void:
	auto_progress_enabled = enabled

## Set the delay between wave completion and next wave spawn
## @param delay: Delay in seconds (must be >= 0)
func set_wave_transition_delay(delay: float) -> void:
	if delay < 0.0:
		push_warning("Wave transition delay cannot be negative. Setting to 0.")
		wave_transition_delay = 0.0
	else:
		wave_transition_delay = delay

## Check if the arena is currently transitioning between waves
## @return: True if transitioning, false otherwise
func is_wave_transitioning() -> bool:
	return is_transitioning

## Get the remaining time until the next wave spawns
## @return: Remaining time in seconds, or 0 if not transitioning
func get_wave_transition_time_remaining() -> float:
	if is_transitioning:
		return max(0.0, wave_transition_timer)
	return 0.0

## Reset the run state to start a new run
## This clears all wave and run completion flags
## Useful for restarting the arena or testing
func reset_run_state() -> void:
	run_completed = false
	arena_complete_emitted = false
	current_wave = 0
	wave_complete_emitted = false
	is_transitioning = false
	wave_transition_timer = 0.0
	total_run_loot.clear()
	_clear_active_enemies()
	print("Run state reset")

## Get the total loot collected during the current run
## @return: Dictionary of resource_type: amount
## Validates: Requirement 8.4 (loot collection during combat)
func get_total_run_loot() -> Dictionary:
	return total_run_loot.duplicate()

## Get the amount of a specific resource collected during the run
## @param resource_type: The type of resource to query
## @return: The amount collected, or 0 if not found
func get_run_loot_amount(resource_type: String) -> int:
	return total_run_loot.get(resource_type, 0)
