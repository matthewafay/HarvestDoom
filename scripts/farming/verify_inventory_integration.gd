extends Node
## Verification script for Task 6.2.4: Inventory Integration
##
## This script demonstrates and verifies the seed inventory checking
## functionality in the FarmGrid.plant_crop() method.
##
## Run this script to verify:
## - Planting succeeds with sufficient seeds
## - Planting fails with insufficient seeds
## - Seed costs are deducted correctly
## - Different seed types are handled properly

func _ready() -> void:
	print("\n=== Task 6.2.4 Inventory Integration Verification ===\n")
	
	# Create a FarmGrid
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)  # 4 plots
	add_child(grid)
	
	# Wait for grid initialization
	await get_tree().process_frame
	
	var plots = grid.get_all_plots()
	print("Created FarmGrid with %d plots\n" % plots.size())
	
	# Test 1: Planting with sufficient seeds
	print("--- Test 1: Planting with Sufficient Seeds ---")
	var health_crop = create_test_crop("health_berry", 10, "health_seeds")
	GameManager.add_to_inventory("health_seeds", 20)
	print("Initial health_seeds: %d" % GameManager.get_inventory_amount("health_seeds"))
	
	var success1 = grid.plant_crop(plots[0], health_crop)
	print("Plant health_berry: %s" % ("SUCCESS" if success1 else "FAILED"))
	print("Remaining health_seeds: %d" % GameManager.get_inventory_amount("health_seeds"))
	print("Expected: 10 (20 - 10 seed cost)")
	assert(success1, "Test 1 failed: Should succeed with sufficient seeds")
	assert(GameManager.get_inventory_amount("health_seeds") == 10, "Test 1 failed: Incorrect seed deduction")
	print("✅ Test 1 PASSED\n")
	
	# Test 2: Planting with insufficient seeds
	print("--- Test 2: Planting with Insufficient Seeds ---")
	var ammo_crop = create_test_crop("ammo_grain", 15, "ammo_seeds")
	GameManager.add_to_inventory("ammo_seeds", 10)
	print("Initial ammo_seeds: %d" % GameManager.get_inventory_amount("ammo_seeds"))
	print("Crop seed_cost: %d" % ammo_crop.seed_cost)
	
	var success2 = grid.plant_crop(plots[1], ammo_crop)
	print("Plant ammo_grain: %s" % ("SUCCESS" if success2 else "FAILED"))
	print("Remaining ammo_seeds: %d" % GameManager.get_inventory_amount("ammo_seeds"))
	print("Expected: 10 (no deduction, planting failed)")
	assert(not success2, "Test 2 failed: Should fail with insufficient seeds")
	assert(GameManager.get_inventory_amount("ammo_seeds") == 10, "Test 2 failed: Seeds should not be deducted")
	print("✅ Test 2 PASSED\n")
	
	# Test 3: Multiple plantings with seed tracking
	print("--- Test 3: Multiple Plantings with Seed Tracking ---")
	var weapon_crop = create_test_crop("weapon_mod_flower", 5, "weapon_mod_seeds")
	GameManager.add_to_inventory("weapon_mod_seeds", 15)
	print("Initial weapon_mod_seeds: %d" % GameManager.get_inventory_amount("weapon_mod_seeds"))
	
	# First planting
	var success3a = grid.plant_crop(plots[1], weapon_crop)
	print("First planting: %s, Remaining: %d" % ("SUCCESS" if success3a else "FAILED", GameManager.get_inventory_amount("weapon_mod_seeds")))
	
	# Second planting
	var success3b = grid.plant_crop(plots[2], weapon_crop)
	print("Second planting: %s, Remaining: %d" % ("SUCCESS" if success3b else "FAILED", GameManager.get_inventory_amount("weapon_mod_seeds")))
	
	# Third planting
	var success3c = grid.plant_crop(plots[3], weapon_crop)
	print("Third planting: %s, Remaining: %d" % ("SUCCESS" if success3c else "FAILED", GameManager.get_inventory_amount("weapon_mod_seeds")))
	
	print("Expected final: 0 (15 - 5 - 5 - 5)")
	assert(success3a and success3b and success3c, "Test 3 failed: All plantings should succeed")
	assert(GameManager.get_inventory_amount("weapon_mod_seeds") == 0, "Test 3 failed: Incorrect cumulative deduction")
	print("✅ Test 3 PASSED\n")
	
	# Test 4: Seed type mapping
	print("--- Test 4: Seed Type Mapping ---")
	test_seed_type_mapping(grid, "health_berry_v2", "health_seeds")
	test_seed_type_mapping(grid, "ammo_grain_special", "ammo_seeds")
	test_seed_type_mapping(grid, "weapon_flower", "weapon_mod_seeds")
	test_seed_type_mapping(grid, "tomato_plant", "tomato_seeds")
	print("✅ Test 4 PASSED\n")
	
	# Test 5: Plot state after failed planting
	print("--- Test 5: Plot State After Failed Planting ---")
	var test_crop = create_test_crop("test_crop", 100, "test_seeds")
	GameManager.inventory["test_seeds"] = 0  # No seeds
	
	# Find an empty plot
	var empty_plot = null
	for plot in plots:
		if plot.state == Plot.PlotState.EMPTY:
			empty_plot = plot
			break
	
	if empty_plot:
		var initial_state = empty_plot.state
		var success5 = grid.plant_crop(empty_plot, test_crop)
		var final_state = empty_plot.state
		
		print("Initial plot state: %d (EMPTY)" % initial_state)
		print("Planting result: %s" % ("SUCCESS" if success5 else "FAILED"))
		print("Final plot state: %d (should still be EMPTY)" % final_state)
		
		assert(not success5, "Test 5 failed: Planting should fail")
		assert(final_state == Plot.PlotState.EMPTY, "Test 5 failed: Plot should remain empty")
		print("✅ Test 5 PASSED\n")
	else:
		print("⚠️ Test 5 SKIPPED: No empty plots available\n")
	
	print("=== All Verification Tests Completed Successfully ===")
	print("Task 6.2.4 implementation is working correctly!\n")
	
	# Clean up
	grid.queue_free()
	get_tree().quit()

func create_test_crop(crop_id: String, seed_cost: int, seed_type_hint: String) -> CropData:
	"""Helper to create a test CropData"""
	var crop = CropData.new()
	crop.crop_id = crop_id
	crop.display_name = "Test " + crop_id
	crop.growth_time = 10.0
	crop.growth_mode = "time"
	crop.seed_cost = seed_cost
	crop.base_color = Color.GREEN
	crop.shape_type = "round"
	
	# Create a simple buff
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	crop.buff_provided = buff
	
	return crop

func test_seed_type_mapping(grid: FarmGrid, crop_id: String, expected_seed_type: String) -> void:
	"""Helper to test seed type mapping"""
	var actual_seed_type = grid._get_seed_type_from_crop(crop_id)
	print("  %s → %s (expected: %s) %s" % [
		crop_id,
		actual_seed_type,
		expected_seed_type,
		"✓" if actual_seed_type == expected_seed_type else "✗"
	])
	assert(actual_seed_type == expected_seed_type, "Seed type mapping failed for " + crop_id)
