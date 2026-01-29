extends Node
## Verification Script for is_wave_complete Method
## 
## This script verifies that the is_wave_complete method works correctly
## by testing various scenarios with spawned enemies.
##
## Usage:
## 1. Open this script in Godot editor
## 2. Attach to a Node in a test scene
## 3. Run the scene
## 4. Check the Output console for verification results

func _ready() -> void:
	print("=== Starting is_wave_complete Verification ===\n")
	
	# Create arena generator
	var arena_generator = ArenaGenerator.new()
	add_child(arena_generator)
	
	# Wait for arena to be added to tree
	await get_tree().process_frame
	
	# Test 1: No enemies spawned
	print("Test 1: No enemies spawned")
	arena_generator.generate_arena(12345)
	var result1 = arena_generator.is_wave_complete()
	print("  Result: %s (Expected: true)" % result1)
	print("  Active enemies: %d" % arena_generator.active_enemies.size())
	assert(result1 == true, "Test 1 Failed: Should be complete with no enemies")
	print("  ✅ PASS\n")
	
	# Test 2: Enemies alive
	print("Test 2: Enemies alive")
	arena_generator.spawn_wave(1)
	var result2 = arena_generator.is_wave_complete()
	print("  Result: %s (Expected: false)" % result2)
	print("  Active enemies: %d" % arena_generator.active_enemies.size())
	assert(result2 == false, "Test 2 Failed: Should not be complete with alive enemies")
	print("  ✅ PASS\n")
	
	# Test 3: All enemies dead
	print("Test 3: All enemies dead")
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	var result3 = arena_generator.is_wave_complete()
	print("  Result: %s (Expected: true)" % result3)
	print("  Active enemies after cleanup: %d" % arena_generator.active_enemies.size())
	assert(result3 == true, "Test 3 Failed: Should be complete when all enemies dead")
	assert(arena_generator.active_enemies.size() == 0, "Test 3 Failed: Should clean up dead enemies")
	print("  ✅ PASS\n")
	
	# Test 4: Partial deaths
	print("Test 4: Partial deaths")
	arena_generator.spawn_wave(2)  # 4 enemies
	var initial_count = arena_generator.active_enemies.size()
	print("  Initial enemy count: %d" % initial_count)
	
	# Kill half
	var half = initial_count / 2
	for i in range(half):
		arena_generator.active_enemies[i].is_dead = true
	
	var result4 = arena_generator.is_wave_complete()
	print("  Result: %s (Expected: false)" % result4)
	print("  Active enemies after cleanup: %d (Expected: %d)" % [arena_generator.active_enemies.size(), initial_count - half])
	assert(result4 == false, "Test 4 Failed: Should not be complete with some alive enemies")
	assert(arena_generator.active_enemies.size() == initial_count - half, "Test 4 Failed: Should clean up only dead enemies")
	print("  ✅ PASS\n")
	
	# Test 5: Multiple calls consistency
	print("Test 5: Multiple calls consistency")
	arena_generator.spawn_wave(1)
	var result5a = arena_generator.is_wave_complete()
	var result5b = arena_generator.is_wave_complete()
	var result5c = arena_generator.is_wave_complete()
	print("  Results: %s, %s, %s (Expected: all false)" % [result5a, result5b, result5c])
	assert(result5a == false and result5b == false and result5c == false, "Test 5 Failed: Should be consistent")
	print("  ✅ PASS\n")
	
	# Test 6: Different wave sizes
	print("Test 6: Different wave sizes")
	
	# Wave 1 (3 enemies)
	arena_generator.spawn_wave(1)
	print("  Wave 1 spawned: %d enemies" % arena_generator.active_enemies.size())
	assert(arena_generator.is_wave_complete() == false, "Test 6a Failed")
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	assert(arena_generator.is_wave_complete() == true, "Test 6b Failed")
	print("  Wave 1: ✅")
	
	# Wave 3 (6 enemies)
	arena_generator.spawn_wave(3)
	print("  Wave 3 spawned: %d enemies" % arena_generator.active_enemies.size())
	assert(arena_generator.is_wave_complete() == false, "Test 6c Failed")
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	assert(arena_generator.is_wave_complete() == true, "Test 6d Failed")
	print("  Wave 3: ✅")
	print("  ✅ PASS\n")
	
	# Test 7: Invalid instances (freed enemies)
	print("Test 7: Invalid instances (freed enemies)")
	arena_generator.spawn_wave(1)
	print("  Spawned %d enemies" % arena_generator.active_enemies.size())
	
	# Free all enemies
	for enemy in arena_generator.active_enemies:
		enemy.queue_free()
	
	# Wait for enemies to be freed
	await get_tree().process_frame
	
	var result7 = arena_generator.is_wave_complete()
	print("  Result: %s (Expected: true)" % result7)
	print("  Active enemies after cleanup: %d (Expected: 0)" % arena_generator.active_enemies.size())
	assert(result7 == true, "Test 7 Failed: Should be complete when all enemies freed")
	assert(arena_generator.active_enemies.size() == 0, "Test 7 Failed: Should clean up freed enemies")
	print("  ✅ PASS\n")
	
	print("=== All Verification Tests Passed! ===")
	print("✅ is_wave_complete method is working correctly")
	
	# Clean up
	arena_generator.queue_free()
	
	# Exit after verification
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
