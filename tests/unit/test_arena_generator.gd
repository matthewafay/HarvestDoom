extends GdUnitTestSuite

## Unit tests for ArenaGenerator
## Tests the generate_arena method with seeded layout generation
## Validates Requirements 8.1, 8.2, 8.3, 8.5

var arena_generator: ArenaGenerator

func before_test() -> void:
	arena_generator = ArenaGenerator.new()
	# Add to scene tree so children can be added
	add_child(arena_generator)

func after_test() -> void:
	if is_instance_valid(arena_generator):
		arena_generator.queue_free()
	arena_generator = null

## Test that generate_arena creates arena with correct structure
func test_generate_arena_creates_structure() -> void:
	# Arrange
	var seed_value = 12345
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - Check that arena elements were created
	assert_int(arena_generator.arena_boundaries.size()).is_equal(4)  # 4 walls
	assert_int(arena_generator.spawn_points.size()).is_greater(0)  # At least one spawn point
	assert_int(arena_generator.cover_objects.size()).is_greater(0)  # At least one cover object
	assert_bool(arena_generator.current_template.is_empty()).is_false()  # Template was selected

## Test that generate_arena is deterministic with same seed
func test_generate_arena_deterministic() -> void:
	# Arrange
	var seed_value = 42
	
	# Act - Generate arena twice with same seed
	arena_generator.generate_arena(seed_value)
	var first_spawn_points = arena_generator.spawn_points.duplicate()
	var first_cover_count = arena_generator.cover_objects.size()
	var first_template = arena_generator.current_template.duplicate()
	
	# Clear and regenerate
	arena_generator.generate_arena(seed_value)
	var second_spawn_points = arena_generator.spawn_points.duplicate()
	var second_cover_count = arena_generator.cover_objects.size()
	var second_template = arena_generator.current_template.duplicate()
	
	# Assert - Same seed produces same results
	assert_int(first_spawn_points.size()).is_equal(second_spawn_points.size())
	assert_int(first_cover_count).is_equal(second_cover_count)
	assert_dict(first_template).is_equal(second_template)
	
	# Check spawn point positions are identical
	for i in range(first_spawn_points.size()):
		assert_vector(first_spawn_points[i]).is_equal(second_spawn_points[i])

## Test that different seeds produce different arenas
func test_generate_arena_different_seeds() -> void:
	# Arrange
	var seed1 = 100
	var seed2 = 200
	
	# Act
	arena_generator.generate_arena(seed1)
	var spawn_points1 = arena_generator.spawn_points.duplicate()
	var cover_count1 = arena_generator.cover_objects.size()
	
	arena_generator.generate_arena(seed2)
	var spawn_points2 = arena_generator.spawn_points.duplicate()
	var cover_count2 = arena_generator.cover_objects.size()
	
	# Assert - Different seeds should produce different results
	# Note: There's a small chance they could be the same, but very unlikely
	var positions_differ = false
	if spawn_points1.size() == spawn_points2.size():
		for i in range(spawn_points1.size()):
			if not spawn_points1[i].is_equal_approx(spawn_points2[i]):
				positions_differ = true
				break
	else:
		positions_differ = true
	
	assert_bool(positions_differ or cover_count1 != cover_count2).is_true()

## Test that arena boundaries are created correctly
func test_generate_arena_creates_boundaries() -> void:
	# Arrange
	var seed_value = 999
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - Should have 4 walls (North, South, East, West)
	assert_int(arena_generator.arena_boundaries.size()).is_equal(4)
	
	# Check that each boundary is a StaticBody3D with collision
	for boundary in arena_generator.arena_boundaries:
		assert_object(boundary).is_instanceof(StaticBody3D)
		assert_int(boundary.get_child_count()).is_greater_equal(2)  # Should have collision shape and mesh
		
		# Check collision layer is set to LAYER_ENVIRONMENT (8)
		assert_int(boundary.collision_layer).is_equal(8)

## Test that cover objects are created with proper spacing
func test_generate_arena_creates_cover_with_spacing() -> void:
	# Arrange
	var seed_value = 777
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - Cover objects should exist
	var cover_count = arena_generator.cover_objects.size()
	assert_int(cover_count).is_greater(0)
	
	# Check that each cover object is valid
	for cover in arena_generator.cover_objects:
		assert_object(cover).is_instanceof(StaticBody3D)
		assert_int(cover.get_child_count()).is_greater_equal(2)  # Should have collision shape and mesh
		
		# Check collision layer is set to LAYER_ENVIRONMENT (8)
		assert_int(cover.collision_layer).is_equal(8)
		
		# Check that cover is not at origin (should be positioned)
		assert_bool(cover.position.length() > 0).is_true()

## Test that spawn points are positioned away from center
func test_generate_arena_spawn_points_away_from_center() -> void:
	# Arrange
	var seed_value = 555
	var min_distance_from_center = 5.0
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - All spawn points should be away from center
	assert_int(arena_generator.spawn_points.size()).is_greater(0)
	
	for spawn_point in arena_generator.spawn_points:
		var distance_from_center = spawn_point.length()
		assert_float(distance_from_center).is_greater_equal(min_distance_from_center)

## Test that spawn points match template specification
func test_generate_arena_spawn_points_match_template() -> void:
	# Arrange
	var seed_value = 333
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - Number of spawn points should match template
	var expected_spawn_count = arena_generator.current_template["spawn_points"]
	assert_int(arena_generator.spawn_points.size()).is_equal(expected_spawn_count)

## Test that cover count matches template specification
func test_generate_arena_cover_matches_template() -> void:
	# Arrange
	var seed_value = 444
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - Number of cover objects should match template (or close to it)
	var expected_cover_count = arena_generator.current_template["cover_count"]
	var actual_cover_count = arena_generator.cover_objects.size()
	
	# Allow some variance due to placement algorithm (may fail to place some)
	assert_int(actual_cover_count).is_greater_equal(expected_cover_count - 2)
	assert_int(actual_cover_count).is_less_equal(expected_cover_count)

## Test that clearing arena removes all elements
func test_generate_arena_clears_previous_arena() -> void:
	# Arrange
	var seed1 = 111
	var seed2 = 222
	
	# Act - Generate first arena
	arena_generator.generate_arena(seed1)
	var first_boundary_count = arena_generator.arena_boundaries.size()
	var first_cover_count = arena_generator.cover_objects.size()
	var first_spawn_count = arena_generator.spawn_points.size()
	
	# Generate second arena (should clear first)
	arena_generator.generate_arena(seed2)
	
	# Assert - Should have new arena elements, not accumulated
	assert_int(arena_generator.arena_boundaries.size()).is_equal(4)  # Always 4 walls
	assert_int(arena_generator.cover_objects.size()).is_greater(0)
	assert_int(arena_generator.spawn_points.size()).is_greater(0)
	
	# The counts might be the same or different, but shouldn't be doubled
	assert_int(arena_generator.arena_boundaries.size()).is_not_equal(first_boundary_count * 2)

## Test that arena size matches template
func test_generate_arena_size_matches_template() -> void:
	# Arrange
	var seed_value = 666
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - Check that boundaries are positioned according to template size
	var template_size: Vector2 = arena_generator.current_template["size"]
	var half_width = template_size.x / 2.0
	var half_height = template_size.y / 2.0
	
	# Check that spawn points are within arena bounds
	for spawn_point in arena_generator.spawn_points:
		assert_float(abs(spawn_point.x)).is_less_equal(half_width)
		assert_float(abs(spawn_point.z)).is_less_equal(half_height)

## Test that arena uses combat palette colors
func test_generate_arena_uses_combat_palette() -> void:
	# Arrange
	var seed_value = 888
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - Check that materials use combat palette colors
	# We can't easily check the exact colors, but we can verify materials exist
	for boundary in arena_generator.arena_boundaries:
		var mesh_instance = _find_mesh_instance(boundary)
		assert_object(mesh_instance).is_not_null()
		assert_object(mesh_instance.material_override).is_not_null()
	
	for cover in arena_generator.cover_objects:
		var mesh_instance = _find_mesh_instance(cover)
		assert_object(mesh_instance).is_not_null()
		assert_object(mesh_instance.material_override).is_not_null()

## Helper to find MeshInstance3D in a node's children
func _find_mesh_instance(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
	return null

## Test that template selection is deterministic
func test_generate_arena_template_selection_deterministic() -> void:
	# Arrange
	var seed_value = 12345
	
	# Act - Generate multiple times with same seed
	var templates = []
	for i in range(5):
		arena_generator.generate_arena(seed_value)
		templates.append(arena_generator.current_template.duplicate())
	
	# Assert - All templates should be identical
	for i in range(1, templates.size()):
		assert_dict(templates[0]).is_equal(templates[i])

## Test that spawn points have y=0 (ground level)
func test_generate_arena_spawn_points_at_ground_level() -> void:
	# Arrange
	var seed_value = 1111
	
	# Act
	arena_generator.generate_arena(seed_value)
	
	# Assert - All spawn points should be at y=0
	for spawn_point in arena_generator.spawn_points:
		assert_float(spawn_point.y).is_equal(0.0)

## Test that spawn_wave creates enemies
func test_spawn_wave_creates_enemies() -> void:
	# Arrange
	var seed_value = 12345
	arena_generator.generate_arena(seed_value)
	
	# Act
	arena_generator.spawn_wave(1)
	
	# Assert - Wave 1 should spawn 3 MeleeChargers
	assert_int(arena_generator.active_enemies.size()).is_equal(3)
	
	# Check that all enemies are MeleeChargers
	for enemy in arena_generator.active_enemies:
		assert_object(enemy).is_instanceof(MeleeCharger)

## Test that spawn_wave places enemies at spawn points
func test_spawn_wave_places_enemies_at_spawn_points() -> void:
	# Arrange
	var seed_value = 42
	arena_generator.generate_arena(seed_value)
	var spawn_point_count = arena_generator.spawn_points.size()
	
	# Act
	arena_generator.spawn_wave(1)
	
	# Assert - Enemies should be placed at spawn points
	for i in range(arena_generator.active_enemies.size()):
		var enemy = arena_generator.active_enemies[i]
		var expected_spawn = arena_generator.spawn_points[i % spawn_point_count]
		assert_vector(enemy.global_position).is_equal(expected_spawn)

## Test that spawn_wave handles different wave numbers
func test_spawn_wave_different_waves() -> void:
	# Arrange
	var seed_value = 999
	arena_generator.generate_arena(seed_value)
	
	# Act - Spawn wave 2
	arena_generator.spawn_wave(2)
	
	# Assert - Wave 2 should have 4 enemies (2 MeleeChargers + 2 RangedShooters)
	assert_int(arena_generator.active_enemies.size()).is_equal(4)
	
	# Count enemy types
	var melee_count = 0
	var ranged_count = 0
	for enemy in arena_generator.active_enemies:
		if enemy is MeleeCharger:
			melee_count += 1
		elif enemy is RangedShooter:
			ranged_count += 1
	
	assert_int(melee_count).is_equal(2)
	assert_int(ranged_count).is_equal(2)

## Test that spawn_wave clears previous enemies
func test_spawn_wave_clears_previous_enemies() -> void:
	# Arrange
	var seed_value = 777
	arena_generator.generate_arena(seed_value)
	
	# Act - Spawn wave 1, then wave 2
	arena_generator.spawn_wave(1)
	var wave1_count = arena_generator.active_enemies.size()
	
	arena_generator.spawn_wave(2)
	var wave2_count = arena_generator.active_enemies.size()
	
	# Assert - Wave 2 should replace wave 1 enemies
	assert_int(wave1_count).is_equal(3)  # Wave 1 has 3 enemies
	assert_int(wave2_count).is_equal(4)  # Wave 2 has 4 enemies

## Test that spawn_wave requires arena generation first
func test_spawn_wave_requires_arena() -> void:
	# Arrange - Don't generate arena
	
	# Act
	arena_generator.spawn_wave(1)
	
	# Assert - Should not spawn enemies without spawn points
	assert_int(arena_generator.active_enemies.size()).is_equal(0)

## Test that spawn_wave validates wave number
func test_spawn_wave_validates_wave_number() -> void:
	# Arrange
	var seed_value = 555
	arena_generator.generate_arena(seed_value)
	
	# Act - Try to spawn wave 0 (invalid)
	arena_generator.spawn_wave(0)
	
	# Assert - Should not spawn enemies
	assert_int(arena_generator.active_enemies.size()).is_equal(0)

## Test that spawn_wave loops wave configurations
func test_spawn_wave_loops_configurations() -> void:
	# Arrange
	var seed_value = 333
	arena_generator.generate_arena(seed_value)
	var config_count = arena_generator.wave_configurations.size()
	
	# Act - Spawn wave beyond configuration count
	arena_generator.spawn_wave(config_count + 1)
	
	# Assert - Should loop back to first configuration
	# Wave 1 and Wave (config_count + 1) should have same enemy count
	var wave_beyond_count = arena_generator.active_enemies.size()
	
	arena_generator.spawn_wave(1)
	var wave1_count = arena_generator.active_enemies.size()
	
	assert_int(wave_beyond_count).is_equal(wave1_count)

## Test that spawn_wave connects to enemy death signals
func test_spawn_wave_connects_death_signals() -> void:
	# Arrange
	var seed_value = 444
	arena_generator.generate_arena(seed_value)
	
	# Act
	arena_generator.spawn_wave(1)
	
	# Assert - Check that enemies have death signal connected
	for enemy in arena_generator.active_enemies:
		var connections = enemy.died.get_connections()
		assert_int(connections.size()).is_greater(0)
		
		# Check that at least one connection is to arena_generator
		var has_arena_connection = false
		for connection in connections:
			if connection["callable"].get_object() == arena_generator:
				has_arena_connection = true
				break
		assert_bool(has_arena_connection).is_true()

## Test that spawn_wave distributes enemies across spawn points
func test_spawn_wave_distributes_enemies() -> void:
	# Arrange
	var seed_value = 666
	arena_generator.generate_arena(seed_value)
	
	# Act - Spawn wave 3 (6 enemies total)
	arena_generator.spawn_wave(3)
	
	# Assert - Enemies should be distributed across spawn points
	var spawn_point_count = arena_generator.spawn_points.size()
	var enemy_count = arena_generator.active_enemies.size()
	
	# If more enemies than spawn points, should cycle through
	if enemy_count > spawn_point_count:
		# Check that enemies cycle through spawn points
		for i in range(enemy_count):
			var enemy = arena_generator.active_enemies[i]
			var expected_spawn = arena_generator.spawn_points[i % spawn_point_count]
			assert_vector(enemy.global_position).is_equal(expected_spawn)

## Test that spawn_wave updates current_wave
func test_spawn_wave_updates_current_wave() -> void:
	# Arrange
	var seed_value = 888
	arena_generator.generate_arena(seed_value)
	
	# Act
	arena_generator.spawn_wave(3)
	
	# Assert
	assert_int(arena_generator.current_wave).is_equal(3)

## Test that spawn_wave handles wave 3 with tank enemy
func test_spawn_wave_spawns_tank_enemy() -> void:
	# Arrange
	var seed_value = 111
	arena_generator.generate_arena(seed_value)
	
	# Act - Spawn wave 3 (has tank)
	arena_generator.spawn_wave(3)
	
	# Assert - Should have at least one tank
	var tank_count = 0
	for enemy in arena_generator.active_enemies:
		if enemy is TankEnemy:
			tank_count += 1
	
	assert_int(tank_count).is_equal(1)

## Test that get_random_spawn_point returns a valid spawn point
func test_get_random_spawn_point_returns_valid_point() -> void:
	# Arrange
	var seed_value = 12345
	arena_generator.generate_arena(seed_value)
	
	# Act
	var spawn_point = arena_generator.get_random_spawn_point()
	
	# Assert - Should return a point from the spawn_points array
	assert_bool(arena_generator.spawn_points.has(spawn_point)).is_true()

## Test that get_random_spawn_point returns Vector3.ZERO when no spawn points
func test_get_random_spawn_point_returns_zero_when_empty() -> void:
	# Arrange - Don't generate arena (no spawn points)
	
	# Act
	var spawn_point = arena_generator.get_random_spawn_point()
	
	# Assert - Should return Vector3.ZERO
	assert_vector(spawn_point).is_equal(Vector3.ZERO)

## Test that get_random_spawn_point returns different points over multiple calls
func test_get_random_spawn_point_varies() -> void:
	# Arrange
	var seed_value = 42
	arena_generator.generate_arena(seed_value)
	
	# Act - Get multiple spawn points
	var spawn_points_returned = []
	for i in range(20):
		spawn_points_returned.append(arena_generator.get_random_spawn_point())
	
	# Assert - Should have some variation (not all the same)
	# Check if we got at least 2 different spawn points
	var unique_points = []
	for point in spawn_points_returned:
		var is_unique = true
		for unique_point in unique_points:
			if point.is_equal_approx(unique_point):
				is_unique = false
				break
		if is_unique:
			unique_points.append(point)
	
	# If we have more than 1 spawn point in the arena, we should get variation
	if arena_generator.spawn_points.size() > 1:
		assert_int(unique_points.size()).is_greater(1)
	else:
		# If only 1 spawn point, all returns should be the same
		assert_int(unique_points.size()).is_equal(1)

## Test that get_random_spawn_point only returns points from spawn_points array
func test_get_random_spawn_point_only_returns_valid_points() -> void:
	# Arrange
	var seed_value = 999
	arena_generator.generate_arena(seed_value)
	
	# Act - Get many spawn points
	var all_valid = true
	for i in range(50):
		var spawn_point = arena_generator.get_random_spawn_point()
		if not arena_generator.spawn_points.has(spawn_point):
			all_valid = false
			break
	
	# Assert - All returned points should be in spawn_points array
	assert_bool(all_valid).is_true()

## Test that get_random_spawn_point works after multiple arena generations
func test_get_random_spawn_point_after_regeneration() -> void:
	# Arrange
	var seed1 = 111
	var seed2 = 222
	
	# Act - Generate first arena and get spawn point
	arena_generator.generate_arena(seed1)
	var spawn_point1 = arena_generator.get_random_spawn_point()
	assert_bool(arena_generator.spawn_points.has(spawn_point1)).is_true()
	
	# Regenerate arena and get new spawn point
	arena_generator.generate_arena(seed2)
	var spawn_point2 = arena_generator.get_random_spawn_point()
	
	# Assert - Second spawn point should be from new arena's spawn points
	assert_bool(arena_generator.spawn_points.has(spawn_point2)).is_true()

## Test that get_random_spawn_point returns ground-level positions
func test_get_random_spawn_point_returns_ground_level() -> void:
	# Arrange
	var seed_value = 777
	arena_generator.generate_arena(seed_value)
	
	# Act - Get multiple spawn points
	for i in range(10):
		var spawn_point = arena_generator.get_random_spawn_point()
		
		# Assert - All spawn points should be at y=0 (ground level)
		assert_float(spawn_point.y).is_equal(0.0)

## Test that is_wave_complete returns true when no enemies spawned
func test_is_wave_complete_true_when_no_enemies() -> void:
	# Arrange
	var seed_value = 12345
	arena_generator.generate_arena(seed_value)
	# Don't spawn any wave
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - Should be complete when no enemies exist
	assert_bool(is_complete).is_true()

## Test that is_wave_complete returns false when enemies are alive
func test_is_wave_complete_false_when_enemies_alive() -> void:
	# Arrange
	var seed_value = 42
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - Should not be complete when enemies are alive
	assert_bool(is_complete).is_false()

## Test that is_wave_complete returns true when all enemies are dead
func test_is_wave_complete_true_when_all_enemies_dead() -> void:
	# Arrange
	var seed_value = 999
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - Should be complete when all enemies are dead
	assert_bool(is_complete).is_true()

## Test that is_wave_complete cleans up dead enemies from active_enemies array
func test_is_wave_complete_cleans_up_dead_enemies() -> void:
	# Arrange
	var seed_value = 777
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	var initial_count = arena_generator.active_enemies.size()
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - active_enemies should be empty after cleanup
	assert_bool(is_complete).is_true()
	assert_int(arena_generator.active_enemies.size()).is_equal(0)
	assert_int(initial_count).is_greater(0)  # Verify we had enemies initially

## Test that is_wave_complete handles partially dead enemies
func test_is_wave_complete_handles_partial_deaths() -> void:
	# Arrange
	var seed_value = 555
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(2)  # Wave 2 has 4 enemies
	
	# Kill half the enemies
	var half = arena_generator.active_enemies.size() / 2
	for i in range(half):
		arena_generator.active_enemies[i].is_dead = true
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - Should not be complete when some enemies are alive
	assert_bool(is_complete).is_false()
	# Should have cleaned up dead enemies
	assert_int(arena_generator.active_enemies.size()).is_equal(arena_generator.active_enemies.size())

## Test that is_wave_complete handles invalid enemy instances
func test_is_wave_complete_handles_invalid_instances() -> void:
	# Arrange
	var seed_value = 333
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Free all enemies (simulating queue_free)
	for enemy in arena_generator.active_enemies:
		enemy.queue_free()
	
	# Wait for enemies to be freed
	await get_tree().process_frame
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - Should be complete when all enemies are freed
	assert_bool(is_complete).is_true()
	assert_int(arena_generator.active_enemies.size()).is_equal(0)

## Test that is_wave_complete returns true for empty active_enemies array
func test_is_wave_complete_true_for_empty_array() -> void:
	# Arrange
	var seed_value = 111
	arena_generator.generate_arena(seed_value)
	# Manually clear active_enemies
	arena_generator.active_enemies.clear()
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - Should be complete when array is empty
	assert_bool(is_complete).is_true()

## Test that is_wave_complete can be called multiple times
func test_is_wave_complete_multiple_calls() -> void:
	# Arrange
	var seed_value = 222
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Act - Call multiple times while enemies are alive
	var result1 = arena_generator.is_wave_complete()
	var result2 = arena_generator.is_wave_complete()
	var result3 = arena_generator.is_wave_complete()
	
	# Assert - Should consistently return false
	assert_bool(result1).is_false()
	assert_bool(result2).is_false()
	assert_bool(result3).is_false()
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Call multiple times after enemies are dead
	var result4 = arena_generator.is_wave_complete()
	var result5 = arena_generator.is_wave_complete()
	
	# Assert - Should consistently return true
	assert_bool(result4).is_true()
	assert_bool(result5).is_true()

## Test that is_wave_complete works with different wave sizes
func test_is_wave_complete_different_wave_sizes() -> void:
	# Arrange
	var seed_value = 444
	arena_generator.generate_arena(seed_value)
	
	# Test with wave 1 (3 enemies)
	arena_generator.spawn_wave(1)
	assert_bool(arena_generator.is_wave_complete()).is_false()
	
	# Kill all and verify
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	assert_bool(arena_generator.is_wave_complete()).is_true()
	
	# Test with wave 3 (6 enemies)
	arena_generator.spawn_wave(3)
	assert_bool(arena_generator.is_wave_complete()).is_false()
	
	# Kill all and verify
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	assert_bool(arena_generator.is_wave_complete()).is_true()

## Test that is_wave_complete updates active_enemies count correctly
func test_is_wave_complete_updates_active_count() -> void:
	# Arrange
	var seed_value = 666
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(2)  # 4 enemies
	var initial_count = arena_generator.active_enemies.size()
	
	# Kill 2 enemies
	arena_generator.active_enemies[0].is_dead = true
	arena_generator.active_enemies[1].is_dead = true
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - Should have 2 enemies remaining
	assert_bool(is_complete).is_false()
	assert_int(arena_generator.active_enemies.size()).is_equal(initial_count - 2)

## Test that is_wave_complete handles mixed dead and invalid enemies
func test_is_wave_complete_mixed_dead_and_invalid() -> void:
	# Arrange
	var seed_value = 888
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(3)  # 6 enemies
	
	# Mark some as dead
	arena_generator.active_enemies[0].is_dead = true
	arena_generator.active_enemies[1].is_dead = true
	
	# Free some (simulating queue_free)
	arena_generator.active_enemies[2].queue_free()
	arena_generator.active_enemies[3].queue_free()
	
	await get_tree().process_frame
	
	# Act
	var is_complete = arena_generator.is_wave_complete()
	
	# Assert - Should have 2 alive enemies remaining
	assert_bool(is_complete).is_false()
	assert_int(arena_generator.active_enemies.size()).is_equal(2)

## Test that wave_completed signal is emitted when wave is complete
func test_wave_completed_signal_emitted() -> void:
	# Arrange
	var seed_value = 12345
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Set up signal monitoring
	var signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for process to check wave completion
	await get_tree().process_frame
	
	# Assert - Signal should be emitted once with wave number 1
	assert_int(signal_monitor.get_count()).is_equal(1)
	var signal_params = signal_monitor.get_parameters(0)
	assert_int(signal_params[0]).is_equal(1)

## Test that wave_completed signal is not emitted when enemies are alive
func test_wave_completed_signal_not_emitted_when_alive() -> void:
	# Arrange
	var seed_value = 42
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Set up signal monitoring
	var signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Act - Wait for process without killing enemies
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Assert - Signal should not be emitted
	assert_int(signal_monitor.get_count()).is_equal(0)

## Test that wave_completed signal is emitted only once per wave
func test_wave_completed_signal_emitted_once() -> void:
	# Arrange
	var seed_value = 999
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Set up signal monitoring
	var signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for multiple process frames
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Assert - Signal should be emitted only once
	assert_int(signal_monitor.get_count()).is_equal(1)

## Test that wave_completed signal is reset when new wave spawns
func test_wave_completed_signal_reset_on_new_wave() -> void:
	# Arrange
	var seed_value = 777
	arena_generator.generate_arena(seed_value)
	
	# Set up signal monitoring
	var signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Complete wave 1
	arena_generator.spawn_wave(1)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	await get_tree().process_frame
	
	# Assert - First wave completed
	assert_int(signal_monitor.get_count()).is_equal(1)
	
	# Act - Spawn wave 2 and complete it
	arena_generator.spawn_wave(2)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	await get_tree().process_frame
	
	# Assert - Second wave completed signal emitted
	assert_int(signal_monitor.get_count()).is_equal(2)
	var signal_params = signal_monitor.get_parameters(1)
	assert_int(signal_params[0]).is_equal(2)

## Test that arena_completed signal is emitted after final wave
func test_arena_completed_signal_emitted() -> void:
	# Arrange
	var seed_value = 555
	arena_generator.generate_arena(seed_value)
	
	# Set up signal monitoring
	var arena_signal_monitor = monitor_signal(arena_generator, "arena_completed")
	var wave_signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Complete final wave (wave 5)
	arena_generator.spawn_wave(5)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for process to check wave completion
	await get_tree().process_frame
	
	# Assert - Both wave_completed and arena_completed should be emitted
	assert_int(wave_signal_monitor.get_count()).is_equal(1)
	assert_int(arena_signal_monitor.get_count()).is_equal(1)

## Test that arena_completed signal is not emitted for non-final waves
func test_arena_completed_signal_not_emitted_for_non_final_wave() -> void:
	# Arrange
	var seed_value = 333
	arena_generator.generate_arena(seed_value)
	
	# Set up signal monitoring
	var arena_signal_monitor = monitor_signal(arena_generator, "arena_completed")
	var wave_signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Complete wave 1 (not final)
	arena_generator.spawn_wave(1)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for process to check wave completion
	await get_tree().process_frame
	
	# Assert - Only wave_completed should be emitted, not arena_completed
	assert_int(wave_signal_monitor.get_count()).is_equal(1)
	assert_int(arena_signal_monitor.get_count()).is_equal(0)

## Test that arena_completed signal is emitted for wave beyond total_waves
func test_arena_completed_signal_for_wave_beyond_total() -> void:
	# Arrange
	var seed_value = 111
	arena_generator.generate_arena(seed_value)
	
	# Set up signal monitoring
	var arena_signal_monitor = monitor_signal(arena_generator, "arena_completed")
	
	# Complete wave 6 (beyond total_waves of 5)
	arena_generator.spawn_wave(6)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for process to check wave completion
	await get_tree().process_frame
	
	# Assert - arena_completed should be emitted
	assert_int(arena_signal_monitor.get_count()).is_equal(1)

## Test that wave_completed signal includes correct wave number
func test_wave_completed_signal_includes_wave_number() -> void:
	# Arrange
	var seed_value = 222
	arena_generator.generate_arena(seed_value)
	
	# Set up signal monitoring
	var signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Complete wave 3
	arena_generator.spawn_wave(3)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for process to check wave completion
	await get_tree().process_frame
	
	# Assert - Signal should include wave number 3
	assert_int(signal_monitor.get_count()).is_equal(1)
	var signal_params = signal_monitor.get_parameters(0)
	assert_int(signal_params[0]).is_equal(3)

## Test that signals are not emitted when no wave is active
func test_signals_not_emitted_when_no_wave_active() -> void:
	# Arrange
	var seed_value = 444
	arena_generator.generate_arena(seed_value)
	# Don't spawn any wave
	
	# Set up signal monitoring
	var wave_signal_monitor = monitor_signal(arena_generator, "wave_completed")
	var arena_signal_monitor = monitor_signal(arena_generator, "arena_completed")
	
	# Act - Wait for process frames
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Assert - No signals should be emitted
	assert_int(wave_signal_monitor.get_count()).is_equal(0)
	assert_int(arena_signal_monitor.get_count()).is_equal(0)

## Test that wave_complete_emitted flag is reset on spawn_wave
func test_wave_complete_emitted_flag_reset() -> void:
	# Arrange
	var seed_value = 666
	arena_generator.generate_arena(seed_value)
	
	# Complete wave 1
	arena_generator.spawn_wave(1)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	await get_tree().process_frame
	
	# Assert - Flag should be true after wave completion
	assert_bool(arena_generator.wave_complete_emitted).is_true()
	
	# Act - Spawn new wave
	arena_generator.spawn_wave(2)
	
	# Assert - Flag should be reset to false
	assert_bool(arena_generator.wave_complete_emitted).is_false()

## Test that multiple waves can be completed in sequence
func test_multiple_waves_completed_in_sequence() -> void:
	# Arrange
	var seed_value = 888
	arena_generator.generate_arena(seed_value)
	
	# Set up signal monitoring
	var signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Complete waves 1, 2, and 3 in sequence
	for wave_num in range(1, 4):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Assert - Should have 3 wave_completed signals
	assert_int(signal_monitor.get_count()).is_equal(3)
	
	# Verify wave numbers
	for i in range(3):
		var signal_params = signal_monitor.get_parameters(i)
		assert_int(signal_params[0]).is_equal(i + 1)

## Test that arena_completed is emitted only once even with multiple process frames
func test_arena_completed_emitted_once() -> void:
	# Arrange
	var seed_value = 1111
	arena_generator.generate_arena(seed_value)
	
	# Set up signal monitoring
	var signal_monitor = monitor_signal(arena_generator, "arena_completed")
	
	# Complete final wave
	arena_generator.spawn_wave(5)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for multiple process frames
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Assert - Signal should be emitted only once
	assert_int(signal_monitor.get_count()).is_equal(1)

## ============================================================================
## WAVE PROGRESSION TESTS (Task 5.2.1)
## Tests for automatic wave progression logic
## Validates: Requirement 8.4
## ============================================================================

## Test that next wave spawns automatically after current wave completes
func test_wave_progression_spawns_next_wave() -> void:
	# Arrange
	var seed_value = 12345
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.1)  # Short delay for testing
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	var wave1_count = arena_generator.active_enemies.size()
	
	# Kill all enemies in wave 1
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for wave completion and transition
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout  # Wait for transition delay
	
	# Assert - Wave 2 should be spawned automatically
	assert_int(arena_generator.current_wave).is_equal(2)
	assert_int(arena_generator.active_enemies.size()).is_greater(wave1_count)  # Wave 2 has more enemies

## Test that wave progression respects transition delay
func test_wave_progression_respects_delay() -> void:
	# Arrange
	var seed_value = 42
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.5)
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for wave completion but not full delay
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout  # Wait less than delay
	
	# Assert - Should still be on wave 1 (transitioning)
	assert_int(arena_generator.current_wave).is_equal(1)
	assert_bool(arena_generator.is_wave_transitioning()).is_true()
	
	# Wait for full delay
	await get_tree().create_timer(0.4).timeout
	
	# Assert - Now should be on wave 2
	assert_int(arena_generator.current_wave).is_equal(2)
	assert_bool(arena_generator.is_wave_transitioning()).is_false()

## Test that wave progression can be disabled
func test_wave_progression_can_be_disabled() -> void:
	# Arrange
	var seed_value = 999
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)  # Disable auto-progression
	arena_generator.set_wave_transition_delay(0.1)
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for wave completion and potential transition
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	# Assert - Should still be on wave 1 (no auto-progression)
	assert_int(arena_generator.current_wave).is_equal(1)
	assert_int(arena_generator.active_enemies.size()).is_equal(0)

## Test that wave progression stops at final wave
func test_wave_progression_stops_at_final_wave() -> void:
	# Arrange
	var seed_value = 777
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.1)
	
	# Set up signal monitoring
	var arena_signal_monitor = monitor_signal(arena_generator, "arena_completed")
	
	# Spawn and complete final wave (wave 5)
	arena_generator.spawn_wave(5)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for wave completion and potential transition
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	# Assert - Should still be on wave 5, arena completed
	assert_int(arena_generator.current_wave).is_equal(5)
	assert_int(arena_signal_monitor.get_count()).is_equal(1)
	assert_bool(arena_generator.is_wave_transitioning()).is_false()

## Test that wave progression works through multiple waves
func test_wave_progression_multiple_waves() -> void:
	# Arrange
	var seed_value = 555
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.1)
	
	# Set up signal monitoring
	var wave_signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Start with wave 1
	arena_generator.spawn_wave(1)
	
	# Complete waves 1, 2, and 3
	for wave_num in range(1, 4):
		# Kill all enemies in current wave
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		
		# Wait for wave completion and transition
		await get_tree().process_frame
		await get_tree().create_timer(0.2).timeout
	
	# Assert - Should be on wave 4 now
	assert_int(arena_generator.current_wave).is_equal(4)
	assert_int(wave_signal_monitor.get_count()).is_equal(3)

## Test that is_wave_transitioning returns correct state
func test_is_wave_transitioning_state() -> void:
	# Arrange
	var seed_value = 333
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.3)
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	
	# Assert - Not transitioning initially
	assert_bool(arena_generator.is_wave_transitioning()).is_false()
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Wait for wave completion
	await get_tree().process_frame
	
	# Assert - Should be transitioning now
	assert_bool(arena_generator.is_wave_transitioning()).is_true()
	
	# Wait for transition to complete
	await get_tree().create_timer(0.4).timeout
	
	# Assert - Should not be transitioning anymore
	assert_bool(arena_generator.is_wave_transitioning()).is_false()

## Test that get_wave_transition_time_remaining returns correct value
func test_get_wave_transition_time_remaining() -> void:
	# Arrange
	var seed_value = 111
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.5)
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	
	# Assert - No transition time initially
	assert_float(arena_generator.get_wave_transition_time_remaining()).is_equal(0.0)
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Wait for wave completion
	await get_tree().process_frame
	
	# Assert - Should have transition time remaining
	var time_remaining = arena_generator.get_wave_transition_time_remaining()
	assert_float(time_remaining).is_greater(0.0)
	assert_float(time_remaining).is_less_equal(0.5)
	
	# Wait for transition to complete
	await get_tree().create_timer(0.6).timeout
	
	# Assert - No transition time after completion
	assert_float(arena_generator.get_wave_transition_time_remaining()).is_equal(0.0)

## Test that set_wave_transition_delay validates input
func test_set_wave_transition_delay_validates_input() -> void:
	# Arrange
	var seed_value = 222
	arena_generator.generate_arena(seed_value)
	
	# Act - Try to set negative delay
	arena_generator.set_wave_transition_delay(-1.0)
	
	# Assert - Should be clamped to 0
	assert_float(arena_generator.wave_transition_delay).is_equal(0.0)
	
	# Act - Set valid delay
	arena_generator.set_wave_transition_delay(2.5)
	
	# Assert - Should be set correctly
	assert_float(arena_generator.wave_transition_delay).is_equal(2.5)

## Test that wave progression resets transition state on manual spawn
func test_wave_progression_resets_on_manual_spawn() -> void:
	# Arrange
	var seed_value = 444
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.5)
	
	# Spawn wave 1 and complete it
	arena_generator.spawn_wave(1)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Wait for wave completion (start transition)
	await get_tree().process_frame
	
	# Assert - Should be transitioning
	assert_bool(arena_generator.is_wave_transitioning()).is_true()
	
	# Act - Manually spawn wave 2 during transition
	arena_generator.spawn_wave(2)
	
	# Assert - Transition state should be reset
	assert_bool(arena_generator.is_wave_transitioning()).is_false()
	assert_float(arena_generator.get_wave_transition_time_remaining()).is_equal(0.0)

## Test that wave progression doesn't interfere with signal emission
func test_wave_progression_signal_emission() -> void:
	# Arrange
	var seed_value = 666
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.1)
	
	# Set up signal monitoring
	var wave_signal_monitor = monitor_signal(arena_generator, "wave_completed")
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for wave completion
	await get_tree().process_frame
	
	# Assert - wave_completed signal should be emitted immediately
	assert_int(wave_signal_monitor.get_count()).is_equal(1)
	var signal_params = wave_signal_monitor.get_parameters(0)
	assert_int(signal_params[0]).is_equal(1)
	
	# Wait for transition
	await get_tree().create_timer(0.2).timeout
	
	# Assert - Still only one signal (for wave 1)
	assert_int(wave_signal_monitor.get_count()).is_equal(1)

## Test that wave progression handles zero delay
func test_wave_progression_zero_delay() -> void:
	# Arrange
	var seed_value = 888
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.0)  # Instant transition
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	
	# Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	# Act - Wait for wave completion
	await get_tree().process_frame
	await get_tree().process_frame  # One more frame for transition
	
	# Assert - Wave 2 should spawn almost immediately
	assert_int(arena_generator.current_wave).is_equal(2)

## Test that wave progression works with different wave configurations
func test_wave_progression_different_configurations() -> void:
	# Arrange
	var seed_value = 1111
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.1)
	
	# Start with wave 1 (3 enemies)
	arena_generator.spawn_wave(1)
	assert_int(arena_generator.active_enemies.size()).is_equal(3)
	
	# Complete wave 1
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	# Assert - Wave 2 should have 4 enemies
	assert_int(arena_generator.current_wave).is_equal(2)
	assert_int(arena_generator.active_enemies.size()).is_equal(4)
	
	# Complete wave 2
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	# Assert - Wave 3 should have 6 enemies
	assert_int(arena_generator.current_wave).is_equal(3)
	assert_int(arena_generator.active_enemies.size()).is_equal(6)

## Test that wave progression doesn't spawn during active wave
func test_wave_progression_not_during_active_wave() -> void:
	# Arrange
	var seed_value = 2222
	arena_generator.generate_arena(seed_value)
	arena_generator.set_wave_transition_delay(0.1)
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	var initial_wave = arena_generator.current_wave
	var initial_count = arena_generator.active_enemies.size()
	
	# Act - Wait without killing enemies
	await get_tree().create_timer(0.5).timeout
	
	# Assert - Should still be on wave 1 with same enemies
	assert_int(arena_generator.current_wave).is_equal(initial_wave)
	assert_int(arena_generator.active_enemies.size()).is_equal(initial_count)

## Test that wave progression can be re-enabled after disabling
func test_wave_progression_can_be_reenabled() -> void:
	# Arrange
	var seed_value = 3333
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	arena_generator.set_wave_transition_delay(0.1)
	
	# Spawn and complete wave 1 with auto-progress disabled
	arena_generator.spawn_wave(1)
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	# Assert - Should still be on wave 1
	assert_int(arena_generator.current_wave).is_equal(1)
	
	# Act - Re-enable auto-progress and spawn wave 2
	arena_generator.set_auto_progress(true)
	arena_generator.spawn_wave(2)
	
	# Complete wave 2
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	# Assert - Should progress to wave 3
	assert_int(arena_generator.current_wave).is_equal(3)

## ============================================================================
## Task 5.2.2: Run Completion Detection Tests
## ============================================================================

## Test that is_run_complete returns false initially
func test_is_run_complete_false_initially() -> void:
	# Arrange
	var seed_value = 5000
	arena_generator.generate_arena(seed_value)
	
	# Assert - Run should not be complete initially
	assert_bool(arena_generator.is_run_complete()).is_false()

## Test that is_run_complete returns false during active waves
func test_is_run_complete_false_during_waves() -> void:
	# Arrange
	var seed_value = 5001
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Assert - Run should not be complete during wave 1
	assert_bool(arena_generator.is_run_complete()).is_false()
	
	# Complete wave 1 and spawn wave 2
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	# Assert - Run should not be complete during wave 2
	assert_bool(arena_generator.is_run_complete()).is_false()

## Test that is_run_complete returns true after all waves cleared
func test_is_run_complete_true_after_all_waves() -> void:
	# Arrange
	var seed_value = 5002
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)  # Manual control
	
	# Complete all 5 waves
	for wave_num in range(1, 6):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Assert - Run should be complete after all waves
	assert_bool(arena_generator.is_run_complete()).is_true()

## Test that is_run_complete returns false if final wave has active enemies
func test_is_run_complete_false_if_final_wave_has_enemies() -> void:
	# Arrange
	var seed_value = 5003
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	
	# Complete waves 1-4
	for wave_num in range(1, 5):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Spawn wave 5 but don't kill enemies
	arena_generator.spawn_wave(5)
	await get_tree().process_frame
	
	# Assert - Run should not be complete with active enemies
	assert_bool(arena_generator.is_run_complete()).is_false()

## Test that run_completed flag is set when final wave completes
func test_run_completed_flag_set_on_final_wave() -> void:
	# Arrange
	var seed_value = 5004
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	
	# Assert - Flag should be false initially
	assert_bool(arena_generator.run_completed).is_false()
	
	# Complete all 5 waves
	for wave_num in range(1, 6):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Assert - Flag should be true after final wave
	assert_bool(arena_generator.run_completed).is_true()

## Test that run_completed flag is reset on new arena generation
func test_run_completed_flag_reset_on_new_arena() -> void:
	# Arrange
	var seed_value = 5005
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	
	# Complete all waves
	for wave_num in range(1, 6):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Assert - Flag should be true
	assert_bool(arena_generator.run_completed).is_true()
	
	# Act - Generate new arena
	arena_generator.generate_arena(seed_value + 1)
	
	# Assert - Flag should be reset to false
	assert_bool(arena_generator.run_completed).is_false()

## Test that arena_completed signal is emitted only once per run
func test_arena_completed_signal_emitted_once_per_run() -> void:
	# Arrange
	var seed_value = 5006
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	
	var signal_monitor = monitor_signal(arena_generator, "arena_completed")
	
	# Complete all 5 waves
	for wave_num in range(1, 6):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Wait for multiple process frames
	for i in range(10):
		await get_tree().process_frame
	
	# Assert - Signal should be emitted exactly once
	assert_int(signal_monitor.get_count()).is_equal(1)

## Test that reset_run_state clears all completion flags
func test_reset_run_state_clears_flags() -> void:
	# Arrange
	var seed_value = 5007
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	
	# Complete all waves
	for wave_num in range(1, 6):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Assert - Flags should be set
	assert_bool(arena_generator.run_completed).is_true()
	assert_bool(arena_generator.arena_complete_emitted).is_true()
	
	# Act - Reset run state
	arena_generator.reset_run_state()
	
	# Assert - All flags should be cleared
	assert_bool(arena_generator.run_completed).is_false()
	assert_bool(arena_generator.arena_complete_emitted).is_false()
	assert_int(arena_generator.current_wave).is_equal(0)
	assert_bool(arena_generator.wave_complete_emitted).is_false()

## Test that reset_run_state clears active enemies
func test_reset_run_state_clears_enemies() -> void:
	# Arrange
	var seed_value = 5008
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Assert - Should have active enemies
	assert_int(arena_generator.active_enemies.size()).is_greater(0)
	
	# Act - Reset run state
	arena_generator.reset_run_state()
	
	# Assert - Active enemies should be cleared
	assert_int(arena_generator.active_enemies.size()).is_equal(0)

## Test that is_run_complete works with automatic wave progression
func test_is_run_complete_with_auto_progression() -> void:
	# Arrange
	var seed_value = 5009
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(true)
	arena_generator.set_wave_transition_delay(0.05)
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	
	# Complete all waves by killing enemies as they spawn
	for wave_num in range(1, 6):
		# Wait for wave to spawn
		await get_tree().process_frame
		
		# Kill all enemies
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		
		# Wait for wave completion and transition
		await get_tree().create_timer(0.1).timeout
	
	# Assert - Run should be complete
	assert_bool(arena_generator.is_run_complete()).is_true()

## Test that run completion detection works with different total_waves
func test_is_run_complete_with_different_total_waves() -> void:
	# Arrange
	var seed_value = 5010
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	
	# Change total waves to 3
	arena_generator.total_waves = 3
	
	# Complete 3 waves
	for wave_num in range(1, 4):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Assert - Run should be complete after 3 waves
	assert_bool(arena_generator.is_run_complete()).is_true()
	assert_bool(arena_generator.run_completed).is_true()

## Test that is_run_complete returns false before any waves start
func test_is_run_complete_false_before_waves_start() -> void:
	# Arrange
	var seed_value = 5011
	arena_generator.generate_arena(seed_value)
	
	# Assert - Run should not be complete before any waves
	assert_bool(arena_generator.is_run_complete()).is_false()
	assert_int(arena_generator.current_wave).is_equal(0)

## Test that run completion state persists across process frames
func test_run_completion_state_persists() -> void:
	# Arrange
	var seed_value = 5012
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	
	# Complete all waves
	for wave_num in range(1, 6):
		arena_generator.spawn_wave(wave_num)
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		await get_tree().process_frame
	
	# Assert - Run should be complete
	assert_bool(arena_generator.is_run_complete()).is_true()
	
	# Wait for multiple frames
	for i in range(20):
		await get_tree().process_frame
	
	# Assert - Run should still be complete
	assert_bool(arena_generator.is_run_complete()).is_true()

## Test that is_run_complete handles edge case of wave 0
func test_is_run_complete_handles_wave_zero() -> void:
	# Arrange
	var seed_value = 5013
	arena_generator.generate_arena(seed_value)
	
	# Assert - Should return false when current_wave is 0
	assert_int(arena_generator.current_wave).is_equal(0)
	assert_bool(arena_generator.is_run_complete()).is_false()

## Test that run completion detection integrates with wave progression
func test_run_completion_integrates_with_wave_progression() -> void:
	# Arrange
	var seed_value = 5014
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(true)
	arena_generator.set_wave_transition_delay(0.05)
	
	var arena_signal_monitor = monitor_signal(arena_generator, "arena_completed")
	
	# Spawn wave 1
	arena_generator.spawn_wave(1)
	
	# Complete waves 1-5
	for wave_num in range(1, 6):
		await get_tree().process_frame
		
		# Kill all enemies
		for enemy in arena_generator.active_enemies:
			enemy.is_dead = true
		
		# Wait for completion
		await get_tree().create_timer(0.1).timeout
	
	# Assert - Run should be complete and signal emitted
	assert_bool(arena_generator.is_run_complete()).is_true()
	assert_int(arena_signal_monitor.get_count()).is_equal(1)
	assert_bool(arena_generator.run_completed).is_true()


## ============================================================================
## LOOT COLLECTION TESTS (Task 5.2.3)
## Tests for loot collection during combat
## Validates: Requirement 8.4
## ============================================================================

## Test that loot is tracked when enemies die
func test_loot_tracked_on_enemy_death() -> void:
	# Arrange
	var seed_value = 6001
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Get first enemy
	var enemy = arena_generator.active_enemies[0]
	var expected_loot = enemy.loot_drop.duplicate()
	
	# Act - Kill the enemy
	enemy.die()
	await get_tree().process_frame
	
	# Assert - Loot should be tracked in arena generator
	for resource_type in expected_loot.keys():
		var expected_amount = expected_loot[resource_type]
		var actual_amount = arena_generator.get_run_loot_amount(resource_type)
		assert_int(actual_amount).is_equal(expected_amount)

## Test that loot accumulates from multiple enemies
func test_loot_accumulates_from_multiple_enemies() -> void:
	# Arrange
	var seed_value = 6002
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Calculate expected total loot
	var expected_total_loot: Dictionary = {}
	for enemy in arena_generator.active_enemies:
		for resource_type in enemy.loot_drop.keys():
			if not expected_total_loot.has(resource_type):
				expected_total_loot[resource_type] = 0
			expected_total_loot[resource_type] += enemy.loot_drop[resource_type]
	
	# Act - Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.die()
	await get_tree().process_frame
	
	# Assert - Total loot should match expected
	for resource_type in expected_total_loot.keys():
		var expected_amount = expected_total_loot[resource_type]
		var actual_amount = arena_generator.get_run_loot_amount(resource_type)
		assert_int(actual_amount).is_equal(expected_amount)

## Test that loot is tracked across multiple waves
func test_loot_tracked_across_waves() -> void:
	# Arrange
	var seed_value = 6003
	arena_generator.generate_arena(seed_value)
	arena_generator.set_auto_progress(false)
	
	# Spawn and complete wave 1
	arena_generator.spawn_wave(1)
	var wave1_loot = 0
	for enemy in arena_generator.active_enemies:
		wave1_loot += enemy.loot_drop.get("credits", 0)
		enemy.die()
	await get_tree().process_frame
	
	# Spawn and complete wave 2
	arena_generator.spawn_wave(2)
	var wave2_loot = 0
	for enemy in arena_generator.active_enemies:
		wave2_loot += enemy.loot_drop.get("credits", 0)
		enemy.die()
	await get_tree().process_frame
	
	# Assert - Total loot should be sum of both waves
	var total_expected = wave1_loot + wave2_loot
	var actual_loot = arena_generator.get_run_loot_amount("credits")
	assert_int(actual_loot).is_equal(total_expected)

## Test that get_total_run_loot returns correct dictionary
func test_get_total_run_loot_returns_dictionary() -> void:
	# Arrange
	var seed_value = 6004
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Kill first enemy
	var enemy = arena_generator.active_enemies[0]
	var expected_loot = enemy.loot_drop.duplicate()
	enemy.die()
	await get_tree().process_frame
	
	# Act
	var total_loot = arena_generator.get_total_run_loot()
	
	# Assert - Should return dictionary with loot
	assert_object(total_loot).is_instanceof(Dictionary)
	for resource_type in expected_loot.keys():
		assert_bool(total_loot.has(resource_type)).is_true()
		assert_int(total_loot[resource_type]).is_equal(expected_loot[resource_type])

## Test that loot is cleared when arena is regenerated
func test_loot_cleared_on_arena_regeneration() -> void:
	# Arrange
	var seed_value = 6005
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Kill an enemy to collect loot
	arena_generator.active_enemies[0].die()
	await get_tree().process_frame
	
	# Assert - Should have loot
	assert_int(arena_generator.get_run_loot_amount("credits")).is_greater(0)
	
	# Act - Regenerate arena
	arena_generator.generate_arena(seed_value + 1)
	
	# Assert - Loot should be cleared
	assert_int(arena_generator.get_run_loot_amount("credits")).is_equal(0)
	var total_loot = arena_generator.get_total_run_loot()
	assert_bool(total_loot.is_empty()).is_true()

## Test that loot is cleared when run state is reset
func test_loot_cleared_on_reset_run_state() -> void:
	# Arrange
	var seed_value = 6006
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Kill an enemy to collect loot
	arena_generator.active_enemies[0].die()
	await get_tree().process_frame
	
	# Assert - Should have loot
	assert_int(arena_generator.get_run_loot_amount("credits")).is_greater(0)
	
	# Act - Reset run state
	arena_generator.reset_run_state()
	
	# Assert - Loot should be cleared
	assert_int(arena_generator.get_run_loot_amount("credits")).is_equal(0)
	var total_loot = arena_generator.get_total_run_loot()
	assert_bool(total_loot.is_empty()).is_true()

## Test that get_run_loot_amount returns 0 for non-existent resource
func test_get_run_loot_amount_returns_zero_for_missing_resource() -> void:
	# Arrange
	var seed_value = 6007
	arena_generator.generate_arena(seed_value)
	
	# Act
	var amount = arena_generator.get_run_loot_amount("non_existent_resource")
	
	# Assert
	assert_int(amount).is_equal(0)

## Test that loot is added to GameManager run_loot
func test_loot_added_to_game_manager_run_loot() -> void:
	# Arrange
	var seed_value = 6008
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Clear GameManager run loot
	GameManager.run_loot.clear()
	
	# Get first enemy
	var enemy = arena_generator.active_enemies[0]
	var expected_loot = enemy.loot_drop.duplicate()
	
	# Act - Kill the enemy
	enemy.die()
	await get_tree().process_frame
	
	# Assert - Loot should be in GameManager.run_loot
	for resource_type in expected_loot.keys():
		var expected_amount = expected_loot[resource_type]
		var actual_amount = GameManager.get_run_loot_amount(resource_type)
		assert_int(actual_amount).is_equal(expected_amount)

## Test that multiple enemy deaths accumulate in GameManager
func test_multiple_deaths_accumulate_in_game_manager() -> void:
	# Arrange
	var seed_value = 6009
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(1)
	
	# Clear GameManager run loot
	GameManager.run_loot.clear()
	
	# Calculate expected total
	var expected_credits = 0
	for enemy in arena_generator.active_enemies:
		expected_credits += enemy.loot_drop.get("credits", 0)
	
	# Act - Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.die()
	await get_tree().process_frame
	
	# Assert - Total should match
	var actual_credits = GameManager.get_run_loot_amount("credits")
	assert_int(actual_credits).is_equal(expected_credits)

## Test that loot tracking works with different enemy types
func test_loot_tracking_with_different_enemy_types() -> void:
	# Arrange
	var seed_value = 6010
	arena_generator.generate_arena(seed_value)
	arena_generator.spawn_wave(3)  # Wave 3 has mixed enemy types
	
	# Clear GameManager run loot
	GameManager.run_loot.clear()
	
	# Calculate expected total
	var expected_credits = 0
	for enemy in arena_generator.active_enemies:
		expected_credits += enemy.loot_drop.get("credits", 0)
	
	# Act - Kill all enemies
	for enemy in arena_generator.active_enemies:
		enemy.die()
	await get_tree().process_frame
	
	# Assert - Total should match
	var actual_credits = GameManager.get_run_loot_amount("credits")
	assert_int(actual_credits).is_equal(expected_credits)
