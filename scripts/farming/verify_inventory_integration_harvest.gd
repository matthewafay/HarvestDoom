extends Node
## Verification script for Task 6.2.5: Harvest with Inventory Addition
##
## This script verifies that the harvest_crop method correctly adds
## harvested resources to the GameManager inventory.
##
## Run this script in Godot to verify the implementation.

func _ready() -> void:
	print("=== Task 6.2.5 Verification: Harvest with Inventory Addition ===\n")
	
	# Reset GameManager inventory
	GameManager.inventory.clear()
	GameManager._initialize_inventory()
	
	var all_tests_passed = true
	
	all_tests_passed = test_basic_harvest_inventory_addition() and all_tests_passed
	all_tests_passed = test_multiple_harvests_accumulate() and all_tests_passed
	all_tests_passed = test_different_crop_types() and all_tests_passed
	all_tests_passed = test_failed_harvest_no_inventory_change() and all_tests_passed
	all_tests_passed = test_harvest_resets_plot() and all_tests_passed
	all_tests_passed = test_plant_harvest_cycle() and all_tests_passed
	
	print("\n=== Verification Complete ===")
	if all_tests_passed:
		print("✅ All tests PASSED")
	else:
		print("❌ Some tests FAILED")
	
	# Exit after verification
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func test_basic_harvest_inventory_addition() -> bool:
	print("\n--- Test: Basic Harvest Inventory Addition ---")
	
	# Create grid and crop
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("tomato", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds and plant
	GameManager.add_to_inventory("generic_seeds", 20)
	grid.plant_crop(target_plot, crop)
	
	# Grow to harvestable
	target_plot.growth_progress = 10.0
	target_plot.state = Plot.PlotState.HARVESTABLE
	
	# Record initial inventory
	var initial_tomato = GameManager.get_inventory_amount("tomato")
	var initial_buff = GameManager.get_inventory_amount("tomato_buff")
	
	# Harvest
	var result = grid.harvest_crop(target_plot)
	
	# Verify
	var success = true
	if result.is_empty():
		print("❌ FAILED: Harvest returned empty result")
		success = false
	elif GameManager.get_inventory_amount("tomato") != initial_tomato + 1:
		print("❌ FAILED: Crop not added to inventory")
		success = false
	elif GameManager.get_inventory_amount("tomato_buff") != initial_buff + 1:
		print("❌ FAILED: Buff not added to inventory")
		success = false
	else:
		print("✅ PASSED: Harvest correctly added to inventory")
	
	grid.queue_free()
	return success

func test_multiple_harvests_accumulate() -> bool:
	print("\n--- Test: Multiple Harvests Accumulate ---")
	
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("carrot", 10.0)
	var plots = grid.get_all_plots()
	
	# Add seeds and plant all plots
	GameManager.add_to_inventory("generic_seeds", 50)
	for plot in plots:
		grid.plant_crop(plot, crop)
		plot.growth_progress = 10.0
		plot.state = Plot.PlotState.HARVESTABLE
	
	# Record initial inventory
	var initial_carrot = GameManager.get_inventory_amount("carrot")
	
	# Harvest all
	for plot in plots:
		grid.harvest_crop(plot)
	
	# Verify
	var success = true
	var expected = initial_carrot + 4
	var actual = GameManager.get_inventory_amount("carrot")
	if actual != expected:
		print("❌ FAILED: Expected %d carrots, got %d" % [expected, actual])
		success = false
	else:
		print("✅ PASSED: Multiple harvests accumulated correctly")
	
	grid.queue_free()
	return success

func test_different_crop_types() -> bool:
	print("\n--- Test: Different Crop Types ---")
	
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)
	add_child(grid)
	await get_tree().process_frame
	
	var plots = grid.get_all_plots()
	
	# Add seeds
	GameManager.add_to_inventory("health_seeds", 20)
	GameManager.add_to_inventory("ammo_seeds", 20)
	GameManager.add_to_inventory("weapon_mod_seeds", 20)
	
	# Plant different crop types
	var health_crop = create_test_crop("health_berry", 10.0)
	var ammo_crop = create_test_crop("ammo_grain", 10.0)
	var weapon_crop = create_test_crop("weapon_mod_flower", 10.0)
	
	grid.plant_crop(plots[0], health_crop)
	plots[0].growth_progress = 10.0
	plots[0].state = Plot.PlotState.HARVESTABLE
	
	grid.plant_crop(plots[1], ammo_crop)
	plots[1].growth_progress = 10.0
	plots[1].state = Plot.PlotState.HARVESTABLE
	
	grid.plant_crop(plots[2], weapon_crop)
	plots[2].growth_progress = 10.0
	plots[2].state = Plot.PlotState.HARVESTABLE
	
	# Harvest all
	grid.harvest_crop(plots[0])
	grid.harvest_crop(plots[1])
	grid.harvest_crop(plots[2])
	
	# Verify
	var success = true
	if GameManager.get_inventory_amount("health_berry") != 1:
		print("❌ FAILED: Health berry not added")
		success = false
	elif GameManager.get_inventory_amount("ammo_grain") != 1:
		print("❌ FAILED: Ammo grain not added")
		success = false
	elif GameManager.get_inventory_amount("weapon_mod_flower") != 1:
		print("❌ FAILED: Weapon mod flower not added")
		success = false
	else:
		print("✅ PASSED: Different crop types handled correctly")
	
	grid.queue_free()
	return success

func test_failed_harvest_no_inventory_change() -> bool:
	print("\n--- Test: Failed Harvest No Inventory Change ---")
	
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("potato", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds and plant
	GameManager.add_to_inventory("generic_seeds", 20)
	grid.plant_crop(target_plot, crop)
	
	# Don't complete growth
	target_plot.growth_progress = 5.0
	
	# Record inventory
	var initial_potato = GameManager.get_inventory_amount("potato")
	
	# Try to harvest (should fail)
	var result = grid.harvest_crop(target_plot)
	
	# Verify
	var success = true
	if not result.is_empty():
		print("❌ FAILED: Harvest should have failed")
		success = false
	elif GameManager.get_inventory_amount("potato") != initial_potato:
		print("❌ FAILED: Inventory changed on failed harvest")
		success = false
	else:
		print("✅ PASSED: Failed harvest didn't change inventory")
	
	grid.queue_free()
	return success

func test_harvest_resets_plot() -> bool:
	print("\n--- Test: Harvest Resets Plot ---")
	
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("wheat", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds and plant
	GameManager.add_to_inventory("generic_seeds", 20)
	grid.plant_crop(target_plot, crop)
	
	# Grow to harvestable
	target_plot.growth_progress = 10.0
	target_plot.state = Plot.PlotState.HARVESTABLE
	
	# Harvest
	grid.harvest_crop(target_plot)
	
	# Verify plot is reset
	var success = true
	if target_plot.state != Plot.PlotState.EMPTY:
		print("❌ FAILED: Plot not reset to EMPTY")
		success = false
	elif target_plot.crop_type != "":
		print("❌ FAILED: Crop type not cleared")
		success = false
	elif target_plot.growth_progress != 0.0:
		print("❌ FAILED: Growth progress not reset")
		success = false
	else:
		print("✅ PASSED: Plot correctly reset after harvest")
	
	grid.queue_free()
	return success

func test_plant_harvest_cycle() -> bool:
	print("\n--- Test: Plant-Harvest Cycle ---")
	
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("corn", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds
	GameManager.add_to_inventory("generic_seeds", 50)
	
	var initial_corn = GameManager.get_inventory_amount("corn")
	
	# Perform 3 cycles
	for cycle in range(3):
		# Plant
		grid.plant_crop(target_plot, crop)
		
		# Grow
		target_plot.growth_progress = 10.0
		target_plot.state = Plot.PlotState.HARVESTABLE
		
		# Harvest
		grid.harvest_crop(target_plot)
	
	# Verify
	var success = true
	var expected = initial_corn + 3
	var actual = GameManager.get_inventory_amount("corn")
	if actual != expected:
		print("❌ FAILED: Expected %d corn, got %d" % [expected, actual])
		success = false
	elif target_plot.state != Plot.PlotState.EMPTY:
		print("❌ FAILED: Plot not ready for next cycle")
		success = false
	else:
		print("✅ PASSED: Plant-harvest cycle works correctly")
	
	grid.queue_free()
	return success

# Helper to create test crop
func create_test_crop(crop_id: String, growth_time: float) -> CropData:
	var crop = CropData.new()
	crop.crop_id = crop_id
	crop.display_name = "Test " + crop_id
	crop.growth_time = growth_time
	crop.growth_mode = "time"
	crop.seed_cost = 10
	crop.base_color = Color.GREEN
	crop.shape_type = "round"
	
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	crop.buff_provided = buff
	
	return crop
