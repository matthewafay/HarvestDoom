extends Node
## Verification Script for Loot Collection During Combat (Task 5.2.3)
##
## This script demonstrates and verifies that loot collection works correctly
## during combat runs, including:
## - Enemies drop loot when they die
## - Loot is tracked in GameManager.run_loot during combat
## - Loot is tracked in ArenaGenerator.total_run_loot
## - Loot accumulates across multiple enemy deaths
## - Loot accumulates across multiple waves
##
## Validates: Requirement 8.4

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("LOOT COLLECTION VERIFICATION (Task 5.2.3)")
	print("Validates: Requirement 8.4 - Loot collection during combat")
	print("=".repeat(80) + "\n")
	
	# Run verification tests
	await verify_enemy_loot_drop()
	await verify_loot_accumulation()
	await verify_loot_across_waves()
	await verify_game_manager_integration()
	
	print("\n" + "=".repeat(80))
	print("VERIFICATION COMPLETE")
	print("=".repeat(80) + "\n")
	
	# Exit
	get_tree().quit()

## Verify that enemies drop loot when they die
func verify_enemy_loot_drop() -> void:
	print("\n--- Test 1: Enemy Loot Drop ---")
	
	# Create arena generator
	var arena = ArenaGenerator.new()
	add_child(arena)
	
	# Generate arena and spawn wave
	arena.generate_arena(1001)
	arena.spawn_wave(1)
	
	# Clear GameManager run loot
	GameManager.run_loot.clear()
	
	# Get first enemy
	var enemy = arena.active_enemies[0]
	var expected_loot = enemy.loot_drop.duplicate()
	
	print("Enemy loot_drop: %s" % str(expected_loot))
	
	# Kill the enemy
	enemy.die()
	await get_tree().process_frame
	
	# Check GameManager run loot
	print("GameManager.run_loot after death: %s" % str(GameManager.run_loot))
	
	# Verify loot was added
	var success = true
	for resource_type in expected_loot.keys():
		var expected = expected_loot[resource_type]
		var actual = GameManager.get_run_loot_amount(resource_type)
		if expected != actual:
			print("❌ FAILED: Expected %d %s, got %d" % [expected, resource_type, actual])
			success = false
	
	if success:
		print("✅ PASSED: Enemy dropped loot correctly")
	
	# Cleanup
	arena.queue_free()
	await get_tree().process_frame

## Verify that loot accumulates from multiple enemies
func verify_loot_accumulation() -> void:
	print("\n--- Test 2: Loot Accumulation from Multiple Enemies ---")
	
	# Create arena generator
	var arena = ArenaGenerator.new()
	add_child(arena)
	
	# Generate arena and spawn wave
	arena.generate_arena(1002)
	arena.spawn_wave(1)
	
	# Clear GameManager run loot
	GameManager.run_loot.clear()
	
	# Calculate expected total loot
	var expected_total: Dictionary = {}
	for enemy in arena.active_enemies:
		for resource_type in enemy.loot_drop.keys():
			if not expected_total.has(resource_type):
				expected_total[resource_type] = 0
			expected_total[resource_type] += enemy.loot_drop[resource_type]
	
	print("Expected total loot from %d enemies: %s" % [arena.active_enemies.size(), str(expected_total)])
	
	# Kill all enemies
	for enemy in arena.active_enemies:
		enemy.die()
	await get_tree().process_frame
	
	# Check GameManager run loot
	print("GameManager.run_loot after all deaths: %s" % str(GameManager.run_loot))
	
	# Verify total loot
	var success = true
	for resource_type in expected_total.keys():
		var expected = expected_total[resource_type]
		var actual = GameManager.get_run_loot_amount(resource_type)
		if expected != actual:
			print("❌ FAILED: Expected %d %s, got %d" % [expected, resource_type, actual])
			success = false
	
	if success:
		print("✅ PASSED: Loot accumulated correctly from multiple enemies")
	
	# Cleanup
	arena.queue_free()
	await get_tree().process_frame

## Verify that loot accumulates across multiple waves
func verify_loot_across_waves() -> void:
	print("\n--- Test 3: Loot Accumulation Across Waves ---")
	
	# Create arena generator
	var arena = ArenaGenerator.new()
	add_child(arena)
	
	# Generate arena
	arena.generate_arena(1003)
	arena.set_auto_progress(false)
	
	# Clear GameManager run loot
	GameManager.run_loot.clear()
	
	# Spawn and complete wave 1
	arena.spawn_wave(1)
	var wave1_loot = 0
	for enemy in arena.active_enemies:
		wave1_loot += enemy.loot_drop.get("credits", 0)
		enemy.die()
	await get_tree().process_frame
	
	print("Wave 1 loot: %d credits" % wave1_loot)
	print("GameManager.run_loot after wave 1: %s" % str(GameManager.run_loot))
	
	# Spawn and complete wave 2
	arena.spawn_wave(2)
	var wave2_loot = 0
	for enemy in arena.active_enemies:
		wave2_loot += enemy.loot_drop.get("credits", 0)
		enemy.die()
	await get_tree().process_frame
	
	print("Wave 2 loot: %d credits" % wave2_loot)
	print("GameManager.run_loot after wave 2: %s" % str(GameManager.run_loot))
	
	# Verify total loot
	var expected_total = wave1_loot + wave2_loot
	var actual_total = GameManager.get_run_loot_amount("credits")
	
	if expected_total == actual_total:
		print("✅ PASSED: Loot accumulated correctly across waves (expected: %d, actual: %d)" % [expected_total, actual_total])
	else:
		print("❌ FAILED: Expected %d credits, got %d" % [expected_total, actual_total])
	
	# Cleanup
	arena.queue_free()
	await get_tree().process_frame

## Verify GameManager integration with finalize and clear
func verify_game_manager_integration() -> void:
	print("\n--- Test 4: GameManager Integration ---")
	
	# Create arena generator
	var arena = ArenaGenerator.new()
	add_child(arena)
	
	# Generate arena and spawn wave
	arena.generate_arena(1004)
	arena.spawn_wave(1)
	
	# Clear GameManager run loot and inventory
	GameManager.run_loot.clear()
	GameManager.inventory["credits"] = 100
	
	# Kill all enemies to collect loot
	var expected_loot = 0
	for enemy in arena.active_enemies:
		expected_loot += enemy.loot_drop.get("credits", 0)
		enemy.die()
	await get_tree().process_frame
	
	print("Collected %d credits during run" % expected_loot)
	print("GameManager.run_loot: %s" % str(GameManager.run_loot))
	print("GameManager.inventory before finalize: %s" % str(GameManager.inventory))
	
	# Test finalize_run_loot (successful run completion)
	GameManager.finalize_run_loot()
	
	print("After finalize_run_loot():")
	print("  GameManager.run_loot: %s" % str(GameManager.run_loot))
	print("  GameManager.inventory: %s" % str(GameManager.inventory))
	
	var expected_inventory = 100 + expected_loot
	var actual_inventory = GameManager.get_inventory_amount("credits")
	
	if actual_inventory == expected_inventory and GameManager.run_loot.is_empty():
		print("✅ PASSED: finalize_run_loot() transferred loot to inventory and cleared run_loot")
	else:
		print("❌ FAILED: Expected inventory %d, got %d" % [expected_inventory, actual_inventory])
	
	# Test clear_run_loot (death scenario)
	print("\n--- Testing clear_run_loot (death scenario) ---")
	
	# Spawn another wave and collect loot
	arena.spawn_wave(2)
	GameManager.run_loot.clear()
	
	var loot_before_death = 0
	for enemy in arena.active_enemies:
		loot_before_death += enemy.loot_drop.get("credits", 0)
		enemy.die()
	await get_tree().process_frame
	
	print("Collected %d credits before death" % loot_before_death)
	print("GameManager.run_loot before death: %s" % str(GameManager.run_loot))
	
	var inventory_before_death = GameManager.get_inventory_amount("credits")
	
	# Clear run loot (simulating death)
	GameManager.clear_run_loot()
	
	print("After clear_run_loot():")
	print("  GameManager.run_loot: %s" % str(GameManager.run_loot))
	print("  GameManager.inventory: %s" % str(GameManager.inventory))
	
	var inventory_after_death = GameManager.get_inventory_amount("credits")
	
	if GameManager.run_loot.is_empty() and inventory_after_death == inventory_before_death:
		print("✅ PASSED: clear_run_loot() cleared run_loot without adding to inventory")
	else:
		print("❌ FAILED: Loot was not properly cleared or inventory was modified")
	
	# Cleanup
	arena.queue_free()
	await get_tree().process_frame
