extends Node
## Verification script for Plot class
##
## This script verifies that the Plot class is properly implemented
## and can be instantiated and used correctly.

func _ready() -> void:
	print("=== Plot Class Verification ===")
	
	# Test 1: Create Plot instance
	print("\n1. Creating Plot instance...")
	var plot = Plot.new()
	if plot == null:
		print("  ❌ FAILED: Could not create Plot instance")
		return
	print("  ✓ Plot instance created successfully")
	
	# Test 2: Verify initial state
	print("\n2. Verifying initial state...")
	if plot.state != Plot.PlotState.EMPTY:
		print("  ❌ FAILED: Initial state is not EMPTY")
		plot.free()
		return
	print("  ✓ Initial state is EMPTY")
	
	# Test 3: Create test crop
	print("\n3. Creating test crop...")
	var test_crop = CropData.new()
	test_crop.crop_id = "test_crop"
	test_crop.display_name = "Test Crop"
	test_crop.growth_time = 10.0
	test_crop.growth_mode = "time"
	test_crop.seed_cost = 5
	test_crop.base_color = Color.GREEN
	test_crop.shape_type = "round"
	
	var test_buff = Buff.new()
	test_buff.buff_type = Buff.BuffType.HEALTH
	test_buff.value = 20
	test_crop.buff_provided = test_buff
	
	if not test_crop.is_valid():
		print("  ❌ FAILED: Test crop is not valid")
		plot.free()
		return
	print("  ✓ Test crop created successfully")
	
	# Test 4: Plant crop
	print("\n4. Planting crop...")
	var plant_result = plot.plant(test_crop)
	if not plant_result:
		print("  ❌ FAILED: Could not plant crop")
		plot.free()
		return
	if plot.state != Plot.PlotState.GROWING:
		print("  ❌ FAILED: State is not GROWING after planting")
		plot.free()
		return
	print("  ✓ Crop planted successfully, state is GROWING")
	
	# Test 5: Update growth
	print("\n5. Updating growth (5 seconds)...")
	plot.update_growth(5.0)
	if plot.growth_progress != 5.0:
		print("  ❌ FAILED: Growth progress is not 5.0")
		plot.free()
		return
	if plot.state != Plot.PlotState.GROWING:
		print("  ❌ FAILED: State changed unexpectedly")
		plot.free()
		return
	print("  ✓ Growth updated successfully, progress: %.1f/%.1f" % [plot.growth_progress, plot.growth_time])
	
	# Test 6: Complete growth
	print("\n6. Completing growth...")
	plot.update_growth(5.0)  # Total 10 seconds
	if plot.state != Plot.PlotState.HARVESTABLE:
		print("  ❌ FAILED: State is not HARVESTABLE after completing growth")
		plot.free()
		return
	print("  ✓ Growth completed, state is HARVESTABLE")
	
	# Test 7: Harvest crop
	print("\n7. Harvesting crop...")
	var harvest_result = plot.harvest()
	if harvest_result.is_empty():
		print("  ❌ FAILED: Harvest returned empty result")
		plot.free()
		return
	if harvest_result.get("crop_id") != "test_crop":
		print("  ❌ FAILED: Harvest returned wrong crop_id")
		plot.free()
		return
	if plot.state != Plot.PlotState.EMPTY:
		print("  ❌ FAILED: State is not EMPTY after harvest")
		plot.free()
		return
	print("  ✓ Crop harvested successfully, state is EMPTY")
	
	# Test 8: Visual stages
	print("\n8. Testing visual stages...")
	plot.plant(test_crop)
	
	var stage_0 = Plot.new()
	if stage_0.get_visual_stage() != 0:
		print("  ❌ FAILED: Empty plot visual stage is not 0")
		plot.free()
		stage_0.free()
		return
	stage_0.free()
	
	plot.growth_progress = 2.0  # 20% - should be stage 1
	if plot.get_visual_stage() != 1:
		print("  ❌ FAILED: Early growth visual stage is not 1")
		plot.free()
		return
	
	plot.growth_progress = 5.0  # 50% - should be stage 2
	if plot.get_visual_stage() != 2:
		print("  ❌ FAILED: Mid growth visual stage is not 2")
		plot.free()
		return
	
	plot.growth_progress = 8.0  # 80% - should be stage 3
	if plot.get_visual_stage() != 3:
		print("  ❌ FAILED: Late growth visual stage is not 3")
		plot.free()
		return
	
	print("  ✓ Visual stages working correctly")
	
	# Test 9: Run-based growth
	print("\n9. Testing run-based growth...")
	var run_plot = Plot.new()
	var run_crop = CropData.new()
	run_crop.crop_id = "run_crop"
	run_crop.display_name = "Run Crop"
	run_crop.growth_time = 3.0
	run_crop.growth_mode = "runs"
	run_crop.seed_cost = 10
	run_crop.base_color = Color.BLUE
	run_crop.shape_type = "tall"
	run_crop.buff_provided = test_buff
	
	run_plot.plant(run_crop)
	run_plot.increment_run_growth()
	run_plot.increment_run_growth()
	
	if run_plot.growth_progress != 2.0:
		print("  ❌ FAILED: Run-based growth progress is not 2.0")
		plot.free()
		run_plot.free()
		return
	
	run_plot.increment_run_growth()
	if run_plot.state != Plot.PlotState.HARVESTABLE:
		print("  ❌ FAILED: Run-based crop not harvestable after 3 runs")
		plot.free()
		run_plot.free()
		return
	
	print("  ✓ Run-based growth working correctly")
	run_plot.free()
	
	# Test 10: Serialization
	print("\n10. Testing serialization...")
	plot.harvest()  # Clear plot
	plot.plant(test_crop)
	plot.update_growth(7.5)
	
	var save_data = plot.to_dict()
	var load_plot = Plot.new()
	var crop_db = {"test_crop": test_crop}
	load_plot.from_dict(save_data, crop_db)
	
	if load_plot.state != plot.state:
		print("  ❌ FAILED: Loaded state doesn't match")
		plot.free()
		load_plot.free()
		return
	if load_plot.crop_type != plot.crop_type:
		print("  ❌ FAILED: Loaded crop_type doesn't match")
		plot.free()
		load_plot.free()
		return
	if load_plot.growth_progress != plot.growth_progress:
		print("  ❌ FAILED: Loaded growth_progress doesn't match")
		plot.free()
		load_plot.free()
		return
	
	print("  ✓ Serialization working correctly")
	load_plot.free()
	
	# Cleanup
	plot.free()
	
	print("\n=== All Verification Tests Passed! ===")
	print("Plot class is working correctly.")
	
	# Exit after verification
	get_tree().quit()
