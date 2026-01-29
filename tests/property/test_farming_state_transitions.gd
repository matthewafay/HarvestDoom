extends GdUnitTestSuite
## Property-Based Tests for Farming State Transitions (Property 4)
##
## This test suite validates Property 4 from the design document:
## "Plot state transitions follow the strict sequence: EMPTY → GROWING → HARVESTABLE → EMPTY.
## Growth progress is monotonically increasing."
##
## These tests verify the complete farming cycle with random inputs, testing:
## - State transition validity across the entire system
## - Growth progress monotonicity
## - Inventory operations correctness
## - Multi-plot state management
## - Complete farming cycles with 100+ iterations
##
## **Validates: Requirements 4.1, 4.2, 4.3, 4.4**

const PROPERTY_TEST_ITERATIONS = 100

# Test fixtures
var rng: RandomNumberGenerator
var test_grid: FarmGrid
var crop_database: Dictionary

func before_test() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Reset GameManager inventory
	GameManager.inventory.clear()
	GameManager._initialize_inventory()
	
	# Add plenty of seeds for testing
	GameManager.add_to_inventory("health_seeds", 10000)
	GameManager.add_to_inventory("ammo_seeds", 10000)
	GameManager.add_to_inventory("weapon_mod_seeds", 10000)
	GameManager.add_to_inventory("generic_seeds", 10000)
	
	# Create crop database with various crop types
	crop_database = _create_crop_database()

func after_test() -> void:
	if is_instance_valid(test_grid):
		test_grid.queue_free()
		test_grid = null
	rng = null
	crop_database.clear()

## Helper: Create a crop database with various crop types
func _create_crop_database() -> Dictionary:
	var database = {}
	
	# Health crops (time-based)
	for i in range(3):
		var crop = CropData.new()
		crop.crop_id = "health_berry_%d" % i
		crop.display_name = "Health Berry %d" % i
		crop.growth_time = rng.randf_range(5.0, 20.0)
		crop.growth_mode = "time"
		crop.seed_cost = rng.randi_range(5, 15)
		crop.base_color = Color(1.0, 0.0, 0.0)
		crop.shape_type = "round"
		
		var buff = Buff.new()
		buff.buff_type = Buff.BuffType.HEALTH
		buff.value = rng.randi_range(10, 50)
		crop.buff_provided = buff
		
		database[crop.crop_id] = crop
	
	# Ammo crops (run-based)
	for i in range(3):
		var crop = CropData.new()
		crop.crop_id = "ammo_grain_%d" % i
		crop.display_name = "Ammo Grain %d" % i
		crop.growth_time = float(rng.randi_range(2, 5))  # 2-5 runs
		crop.growth_mode = "runs"
		crop.seed_cost = rng.randi_range(5, 15)
		crop.base_color = Color(1.0, 1.0, 0.0)
		crop.shape_type = "tall"
		
		var buff = Buff.new()
		buff.buff_type = Buff.BuffType.AMMO
		buff.value = rng.randi_range(20, 100)
		crop.buff_provided = buff
		
		database[crop.crop_id] = crop
	
	# Weapon mod crops (mixed)
	for i in range(2):
		var crop = CropData.new()
		crop.crop_id = "weapon_mod_flower_%d" % i
		crop.display_name = "Weapon Mod Flower %d" % i
		crop.growth_time = rng.randf_range(10.0, 30.0) if i == 0 else float(rng.randi_range(3, 6))
		crop.growth_mode = "time" if i == 0 else "runs"
		crop.seed_cost = rng.randi_range(10, 20)
		crop.base_color = Color(0.5, 0.0, 1.0)
		crop.shape_type = "leafy"
		
		var buff = Buff.new()
		buff.buff_type = Buff.BuffType.WEAPON_MOD
		buff.value = rng.randi_range(1, 3)
		buff.weapon_mod_type = "damage_boost"
		crop.buff_provided = buff
		
		database[crop.crop_id] = crop
	
	return database

## Helper: Create a test grid
func _create_test_grid() -> FarmGrid:
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(3, 4)  # 12 plots
	grid.plot_size = 64.0
	add_child(grid)
	return grid

## Helper: Get a random crop from the database
func _get_random_crop() -> CropData:
	var crop_ids = crop_database.keys()
	var random_id = crop_ids[rng.randi() % crop_ids.size()]
	return crop_database[random_id]

## Helper: Complete growth for a plot based on its crop's growth mode
func _complete_growth(grid: FarmGrid, plot: Plot) -> void:
	if plot.crop_data == null:
		return
	
	if plot.crop_data.growth_mode == "time":
		grid.update_crop_growth(plot.growth_time)
	else:
		for i in range(int(plot.growth_time)):
			grid.increment_run_growth()

## Property 4.1: State transitions always follow EMPTY → GROWING → HARVESTABLE → EMPTY
## **Validates: Requirements 4.2, 4.3, 4.4**
func test_property_state_transition_sequence() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var test_plot = plots[rng.randi() % plots.size()]
		var crop = _get_random_crop()
		
		# Initial state: EMPTY
		assert_int(test_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		# Transition 1: EMPTY → GROWING (via plant)
		var plant_result = test_grid.plant_crop(test_plot, crop)
		assert_bool(plant_result).is_true()
		assert_int(test_plot.state).is_equal(Plot.PlotState.GROWING)
		
		# Cannot skip to HARVESTABLE
		var premature_harvest = test_grid.harvest_crop(test_plot)
		assert_bool(premature_harvest.is_empty()).is_true()
		assert_int(test_plot.state).is_equal(Plot.PlotState.GROWING)
		
		# Transition 2: GROWING → HARVESTABLE (via growth completion)
		_complete_growth(test_grid, test_plot)
		assert_int(test_plot.state).is_equal(Plot.PlotState.HARVESTABLE)
		
		# Transition 3: HARVESTABLE → EMPTY (via harvest)
		var harvest_result = test_grid.harvest_crop(test_plot)
		assert_bool(harvest_result.is_empty()).is_false()
		assert_int(test_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.2: Growth progress is monotonically increasing (never decreases)
## **Validates: Requirements 4.3, 4.5**
func test_property_growth_monotonic() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var test_plot = plots[rng.randi() % plots.size()]
		var crop = _get_random_crop()
		
		test_grid.plant_crop(test_plot, crop)
		
		var prev_progress = test_plot.growth_progress
		var update_count = rng.randi_range(10, 30)
		
		for i in range(update_count):
			if crop.growth_mode == "time":
				test_grid.update_crop_growth(rng.randf_range(0.1, 2.0))
			else:
				test_grid.increment_run_growth()
			
			var current_progress = test_plot.growth_progress
			
			# Progress must never decrease
			assert_float(current_progress).is_greater_equal(prev_progress)
			prev_progress = current_progress
			
			# Stop if harvestable
			if test_plot.state == Plot.PlotState.HARVESTABLE:
				break
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.3: Multiple plots maintain independent state transitions
## **Validates: Requirements 4.1, 4.2, 4.3, 4.4**
func test_property_multi_plot_independence() -> void:
	for iteration in range(50):  # Fewer iterations due to complexity
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var plot_count = plots.size()
		
		# Plant different crops in random plots
		var planted_plots = []
		var plant_count = rng.randi_range(3, plot_count)
		
		for i in range(plant_count):
			var plot = plots[i]
			var crop = _get_random_crop()
			test_grid.plant_crop(plot, crop)
			planted_plots.append(plot)
		
		# Record initial states
		var initial_states = []
		var initial_progress = []
		for plot in planted_plots:
			initial_states.append(plot.state)
			initial_progress.append(plot.growth_progress)
		
		# Perform random growth updates
		var update_count = rng.randi_range(5, 15)
		for i in range(update_count):
			if rng.randf() < 0.5:
				test_grid.update_crop_growth(rng.randf_range(0.5, 2.0))
			else:
				test_grid.increment_run_growth()
		
		# Verify each plot progressed independently
		for i in range(planted_plots.size()):
			var plot = planted_plots[i]
			
			# State should be GROWING or HARVESTABLE (never EMPTY without harvest)
			assert_bool(plot.state == Plot.PlotState.GROWING or plot.state == Plot.PlotState.HARVESTABLE).is_true()
			
			# Progress should have increased (unless already harvestable)
			if plot.state == Plot.PlotState.GROWING:
				assert_float(plot.growth_progress).is_greater(initial_progress[i])
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.4: Complete farming cycle preserves inventory correctness
## **Validates: Requirements 4.2, 4.4**
func test_property_complete_cycle_inventory() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var test_plot = plots[rng.randi() % plots.size()]
		var crop = _get_random_crop()
		
		# Record initial inventory
		var seed_type = test_grid._get_seed_type_from_crop(crop.crop_id)
		var initial_seeds = GameManager.get_inventory_amount(seed_type)
		var initial_crops = GameManager.get_inventory_amount(crop.crop_id)
		var initial_buffs = GameManager.get_inventory_amount(crop.crop_id + "_buff")
		
		# Plant (should deduct seeds)
		test_grid.plant_crop(test_plot, crop)
		assert_int(GameManager.get_inventory_amount(seed_type)).is_equal(initial_seeds - crop.seed_cost)
		
		# Grow to harvestable
		_complete_growth(test_grid, test_plot)
		
		# Harvest (should add crop and buff)
		test_grid.harvest_crop(test_plot)
		assert_int(GameManager.get_inventory_amount(crop.crop_id)).is_equal(initial_crops + 1)
		assert_int(GameManager.get_inventory_amount(crop.crop_id + "_buff")).is_equal(initial_buffs + 1)
		
		# Net result: -seeds, +crop, +buff
		assert_int(GameManager.get_inventory_amount(seed_type)).is_equal(initial_seeds - crop.seed_cost)
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.5: Random planting and harvesting sequences maintain valid states
## **Validates: Requirements 4.1, 4.2, 4.3, 4.4**
func test_property_random_sequence_validity() -> void:
	for iteration in range(50):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var action_count = rng.randi_range(20, 50)
		
		for action_num in range(action_count):
			var random_plot = plots[rng.randi() % plots.size()]
			var action = rng.randf()
			
			if action < 0.4:
				# Try to plant
				var crop = _get_random_crop()
				test_grid.plant_crop(random_plot, crop)
			elif action < 0.6:
				# Try to harvest
				test_grid.harvest_crop(random_plot)
			elif action < 0.8:
				# Update time-based growth
				test_grid.update_crop_growth(rng.randf_range(0.5, 3.0))
			else:
				# Update run-based growth
				test_grid.increment_run_growth()
			
			# After every action, verify all plots are in valid states
			for plot in plots:
				# State must be one of the three valid states
				assert_bool(
					plot.state == Plot.PlotState.EMPTY or
					plot.state == Plot.PlotState.GROWING or
					plot.state == Plot.PlotState.HARVESTABLE
				).is_true()
				
				# If GROWING or HARVESTABLE, must have crop_data
				if plot.state != Plot.PlotState.EMPTY:
					assert_object(plot.crop_data).is_not_null()
					assert_str(plot.crop_type).is_not_empty()
				else:
					# If EMPTY, must not have crop_data
					assert_object(plot.crop_data).is_null()
					assert_str(plot.crop_type).is_empty()
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.6: Growth mode isolation (time crops ignore runs, run crops ignore time)
## **Validates: Requirements 4.5**
func test_property_growth_mode_isolation() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		
		# Find or create time-based and run-based crops
		var time_crop: CropData = null
		var run_crop: CropData = null
		
		for crop_id in crop_database.keys():
			var crop = crop_database[crop_id]
			if crop.growth_mode == "time" and time_crop == null:
				time_crop = crop
			elif crop.growth_mode == "runs" and run_crop == null:
				run_crop = crop
		
		if time_crop == null or run_crop == null:
			continue  # Skip if we don't have both types
		
		# Plant time-based crop in plot 0
		var time_plot = plots[0]
		test_grid.plant_crop(time_plot, time_crop)
		var time_initial_progress = time_plot.growth_progress
		
		# Plant run-based crop in plot 1
		var run_plot = plots[1]
		test_grid.plant_crop(run_plot, run_crop)
		var run_initial_progress = run_plot.growth_progress
		
		# Update runs (should only affect run-based crop)
		for i in range(5):
			test_grid.increment_run_growth()
		
		# Time crop should not have changed
		assert_float(time_plot.growth_progress).is_equal(time_initial_progress)
		
		# Run crop should have changed
		assert_float(run_plot.growth_progress).is_greater(run_initial_progress)
		
		# Reset run crop progress
		run_initial_progress = run_plot.growth_progress
		
		# Update time (should only affect time-based crop)
		test_grid.update_crop_growth(10.0)
		
		# Time crop should have changed
		assert_float(time_plot.growth_progress).is_greater(time_initial_progress)
		
		# Run crop should not have changed
		assert_float(run_plot.growth_progress).is_equal(run_initial_progress)
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.7: Serialization preserves complete farming state
## **Validates: Requirements 4.1, 4.2, 4.3, 4.4**
func test_property_serialization_preserves_state() -> void:
	for iteration in range(50):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		
		# Create random farming state
		for plot in plots:
			var action = rng.randf()
			if action < 0.3:
				# Leave empty
				pass
			elif action < 0.7:
				# Plant and partially grow
				var crop = _get_random_crop()
				test_grid.plant_crop(plot, crop)
				
				if crop.growth_mode == "time":
					test_grid.update_crop_growth(rng.randf_range(0, crop.growth_time * 0.8))
				else:
					for i in range(rng.randi_range(0, int(crop.growth_time) - 1)):
						test_grid.increment_run_growth()
			else:
				# Plant and make harvestable
				var crop = _get_random_crop()
				test_grid.plant_crop(plot, crop)
				_complete_growth(test_grid, plot)
		
		# Serialize
		var plot_states = test_grid.serialize_plots()
		
		# Create new grid and deserialize
		var test_grid2 = _create_test_grid()
		await get_tree().process_frame
		test_grid2.deserialize_plots(plot_states, crop_database)
		
		var plots2 = test_grid2.get_all_plots()
		
		# Verify all states match
		for i in range(plots.size()):
			assert_int(plots2[i].state).is_equal(plots[i].state)
			assert_str(plots2[i].crop_type).is_equal(plots[i].crop_type)
			assert_float(plots2[i].growth_progress).is_equal_approx(plots[i].growth_progress, 0.01)
			assert_float(plots2[i].growth_time).is_equal_approx(plots[i].growth_time, 0.01)
		
		test_grid.queue_free()
		test_grid2.queue_free()
		await get_tree().process_frame

## Property 4.8: Harvest only succeeds in HARVESTABLE state, never in other states
## **Validates: Requirements 4.4**
func test_property_harvest_state_requirement() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var test_plot = plots[rng.randi() % plots.size()]
		var crop = _get_random_crop()
		
		# Harvest EMPTY plot should fail
		var empty_result = test_grid.harvest_crop(test_plot)
		assert_bool(empty_result.is_empty()).is_true()
		assert_int(test_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		# Plant crop
		test_grid.plant_crop(test_plot, crop)
		
		# Harvest GROWING plot should fail
		var growing_result = test_grid.harvest_crop(test_plot)
		assert_bool(growing_result.is_empty()).is_true()
		assert_int(test_plot.state).is_equal(Plot.PlotState.GROWING)
		
		# Complete growth
		_complete_growth(test_grid, test_plot)
		
		# Harvest HARVESTABLE plot should succeed
		var harvestable_result = test_grid.harvest_crop(test_plot)
		assert_bool(harvestable_result.is_empty()).is_false()
		assert_int(test_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		# Harvest EMPTY plot again should fail
		var empty_again_result = test_grid.harvest_crop(test_plot)
		assert_bool(empty_again_result.is_empty()).is_true()
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.9: Plant-harvest cycles are repeatable indefinitely
## **Validates: Requirements 4.2, 4.4**
func test_property_cycle_repeatability() -> void:
	for iteration in range(50):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var test_plot = plots[rng.randi() % plots.size()]
		var crop = _get_random_crop()
		
		var cycles = rng.randi_range(3, 7)
		var initial_crop_count = GameManager.get_inventory_amount(crop.crop_id)
		
		for cycle in range(cycles):
			# Plant
			var plant_success = test_grid.plant_crop(test_plot, crop)
			assert_bool(plant_success).is_true()
			assert_int(test_plot.state).is_equal(Plot.PlotState.GROWING)
			
			# Grow
			_complete_growth(test_grid, test_plot)
			assert_int(test_plot.state).is_equal(Plot.PlotState.HARVESTABLE)
			
			# Harvest
			var harvest_result = test_grid.harvest_crop(test_plot)
			assert_bool(harvest_result.is_empty()).is_false()
			assert_int(test_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		# Verify total harvests
		var final_crop_count = GameManager.get_inventory_amount(crop.crop_id)
		assert_int(final_crop_count).is_equal(initial_crop_count + cycles)
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.10: Failed operations never modify state or inventory
## **Validates: Requirements 4.2, 4.4**
func test_property_failed_operations_no_side_effects() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var test_plot = plots[rng.randi() % plots.size()]
		var crop = _get_random_crop()
		
		# Take inventory snapshot
		var inventory_snapshot = GameManager.inventory.duplicate()
		
		# Failed harvest on empty plot
		var result1 = test_grid.harvest_crop(test_plot)
		assert_bool(result1.is_empty()).is_true()
		assert_int(test_plot.state).is_equal(Plot.PlotState.EMPTY)
		assert_object(GameManager.inventory).is_equal(inventory_snapshot)
		
		# Plant crop
		test_grid.plant_crop(test_plot, crop)
		var inventory_after_plant = GameManager.inventory.duplicate()
		
		# Failed harvest on growing plot
		var result2 = test_grid.harvest_crop(test_plot)
		assert_bool(result2.is_empty()).is_true()
		assert_int(test_plot.state).is_equal(Plot.PlotState.GROWING)
		assert_object(GameManager.inventory).is_equal(inventory_after_plant)
		
		# Failed plant on non-empty plot
		var crop2 = _get_random_crop()
		var inventory_before_failed_plant = GameManager.inventory.duplicate()
		var result3 = test_grid.plant_crop(test_plot, crop2)
		assert_bool(result3).is_false()
		assert_int(test_plot.state).is_equal(Plot.PlotState.GROWING)
		assert_str(test_plot.crop_type).is_equal(crop.crop_id)  # Original crop unchanged
		assert_object(GameManager.inventory).is_equal(inventory_before_failed_plant)
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.11: Growth completion signal emits exactly once per cycle
## **Validates: Requirements 4.3**
func test_property_growth_signal_once_per_cycle() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		var test_plot = plots[rng.randi() % plots.size()]
		var crop = _get_random_crop()
		
		test_grid.plant_crop(test_plot, crop)
		
		var signal_monitor = monitor_signal(test_plot, "growth_completed")
		
		# Complete growth (possibly with overshoot)
		if crop.growth_mode == "time":
			test_grid.update_crop_growth(crop.growth_time * rng.randf_range(1.0, 3.0))
		else:
			for i in range(int(crop.growth_time) * rng.randi_range(1, 4)):
				test_grid.increment_run_growth()
		
		# Signal should emit exactly once
		assert_int(signal_monitor.get_count()).is_equal(1)
		
		test_grid.queue_free()
		await get_tree().process_frame

## Property 4.12: All plots in grid maintain valid state invariants simultaneously
## **Validates: Requirements 4.1, 4.2, 4.3, 4.4**
func test_property_grid_wide_state_invariants() -> void:
	for iteration in range(50):
		test_grid = _create_test_grid()
		await get_tree().process_frame
		
		var plots = test_grid.get_all_plots()
		
		# Create complex multi-plot state
		for i in range(plots.size()):
			if rng.randf() < 0.7:  # 70% chance to plant
				var crop = _get_random_crop()
				test_grid.plant_crop(plots[i], crop)
		
		# Perform many random operations
		for operation in range(50):
			var action = rng.randf()
			
			if action < 0.5:
				test_grid.update_crop_growth(rng.randf_range(0.5, 2.0))
			else:
				test_grid.increment_run_growth()
			
			# After each operation, verify ALL plots maintain invariants
			for plot in plots:
				# Invariant 1: State is valid
				assert_bool(
					plot.state == Plot.PlotState.EMPTY or
					plot.state == Plot.PlotState.GROWING or
					plot.state == Plot.PlotState.HARVESTABLE
				).is_true()
				
				# Invariant 2: Non-empty plots have crop data
				if plot.state != Plot.PlotState.EMPTY:
					assert_object(plot.crop_data).is_not_null()
					assert_str(plot.crop_type).is_not_empty()
					assert_float(plot.growth_time).is_greater(0.0)
				
				# Invariant 3: Empty plots have no crop data
				if plot.state == Plot.PlotState.EMPTY:
					assert_object(plot.crop_data).is_null()
					assert_str(plot.crop_type).is_empty()
					assert_float(plot.growth_progress).is_equal(0.0)
				
				# Invariant 4: Growth progress is bounded
				assert_float(plot.growth_progress).is_greater_equal(0.0)
				if plot.state == Plot.PlotState.HARVESTABLE:
					assert_float(plot.growth_progress).is_greater_equal(plot.growth_time)
		
		test_grid.queue_free()
		await get_tree().process_frame
