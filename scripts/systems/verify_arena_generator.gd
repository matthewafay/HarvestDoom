extends Node

## Verification script for ArenaGenerator
## This script can be run in the Godot editor to manually verify arena generation

func _ready() -> void:
	print("=== ArenaGenerator Verification ===")
	
	# Create arena generator
	var arena_gen = ArenaGenerator.new()
	add_child(arena_gen)
	
	# Test 1: Generate arena with seed
	print("\nTest 1: Generate arena with seed 12345")
	arena_gen.generate_arena(12345)
	print("  - Boundaries created: %d" % arena_gen.arena_boundaries.size())
	print("  - Cover objects created: %d" % arena_gen.cover_objects.size())
	print("  - Spawn points created: %d" % arena_gen.spawn_points.size())
	print("  - Template selected: %s" % arena_gen.current_template)
	
	# Test 2: Verify determinism
	print("\nTest 2: Verify determinism (same seed)")
	var first_spawn_points = arena_gen.spawn_points.duplicate()
	var first_cover_count = arena_gen.cover_objects.size()
	
	arena_gen.generate_arena(12345)
	var second_spawn_points = arena_gen.spawn_points.duplicate()
	var second_cover_count = arena_gen.cover_objects.size()
	
	var deterministic = true
	if first_spawn_points.size() != second_spawn_points.size():
		deterministic = false
	else:
		for i in range(first_spawn_points.size()):
			if not first_spawn_points[i].is_equal_approx(second_spawn_points[i]):
				deterministic = false
				break
	
	if first_cover_count != second_cover_count:
		deterministic = false
	
	print("  - Deterministic: %s" % ("PASS" if deterministic else "FAIL"))
	
	# Test 3: Different seeds produce different results
	print("\nTest 3: Different seeds produce different results")
	arena_gen.generate_arena(100)
	var spawn_points_100 = arena_gen.spawn_points.duplicate()
	
	arena_gen.generate_arena(200)
	var spawn_points_200 = arena_gen.spawn_points.duplicate()
	
	var different = false
	if spawn_points_100.size() != spawn_points_200.size():
		different = true
	else:
		for i in range(spawn_points_100.size()):
			if not spawn_points_100[i].is_equal_approx(spawn_points_200[i]):
				different = true
				break
	
	print("  - Different results: %s" % ("PASS" if different else "FAIL"))
	
	# Test 4: Verify spawn points are away from center
	print("\nTest 4: Verify spawn points are away from center")
	arena_gen.generate_arena(555)
	var min_distance = 5.0
	var all_away_from_center = true
	
	for spawn_point in arena_gen.spawn_points:
		if spawn_point.length() < min_distance:
			all_away_from_center = false
			print("  - WARNING: Spawn point too close to center: %s (distance: %.2f)" % [spawn_point, spawn_point.length()])
	
	print("  - All spawn points away from center: %s" % ("PASS" if all_away_from_center else "FAIL"))
	
	# Test 5: Verify boundaries exist
	print("\nTest 5: Verify boundaries")
	var all_boundaries_valid = true
	for boundary in arena_gen.arena_boundaries:
		if not is_instance_valid(boundary):
			all_boundaries_valid = false
		elif not boundary is StaticBody3D:
			all_boundaries_valid = false
		elif boundary.collision_layer != 8:
			all_boundaries_valid = false
			print("  - WARNING: Boundary has wrong collision layer: %d" % boundary.collision_layer)
	
	print("  - All boundaries valid: %s" % ("PASS" if all_boundaries_valid else "FAIL"))
	
	# Test 6: Verify cover objects
	print("\nTest 6: Verify cover objects")
	var all_cover_valid = true
	for cover in arena_gen.cover_objects:
		if not is_instance_valid(cover):
			all_cover_valid = false
		elif not cover is StaticBody3D:
			all_cover_valid = false
		elif cover.collision_layer != 8:
			all_cover_valid = false
			print("  - WARNING: Cover has wrong collision layer: %d" % cover.collision_layer)
	
	print("  - All cover objects valid: %s" % ("PASS" if all_cover_valid else "FAIL"))
	
	# Test 7: Verify clearing works
	print("\nTest 7: Verify arena clearing")
	var initial_boundary_count = arena_gen.arena_boundaries.size()
	var initial_cover_count = arena_gen.cover_objects.size()
	var initial_spawn_count = arena_gen.spawn_points.size()
	
	arena_gen.generate_arena(999)
	
	var new_boundary_count = arena_gen.arena_boundaries.size()
	var new_cover_count = arena_gen.cover_objects.size()
	var new_spawn_count = arena_gen.spawn_points.size()
	
	# Boundaries should always be 4
	var clearing_works = (new_boundary_count == 4)
	
	print("  - Clearing works: %s" % ("PASS" if clearing_works else "FAIL"))
	print("  - Previous: boundaries=%d, cover=%d, spawns=%d" % [initial_boundary_count, initial_cover_count, initial_spawn_count])
	print("  - New: boundaries=%d, cover=%d, spawns=%d" % [new_boundary_count, new_cover_count, new_spawn_count])
	
	print("\n=== Verification Complete ===")
	print("Run this script in the Godot editor to verify ArenaGenerator implementation")
