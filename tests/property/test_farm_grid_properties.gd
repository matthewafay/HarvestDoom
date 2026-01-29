extends GdUnitTestSuite
## Property-Based Tests for FarmGrid
##
## These tests verify universal properties that should hold true
## for all valid inputs and states of the FarmGrid system.
##
## Properties Tested:
## 1. Grid Consistency - Plot count always matches grid_size dimensions
## 2. Position Determinism - Same grid configuration produces same plot positions
## 3. State Preservation - Serialize/deserialize preserves all plot states
## 4. Growth Monotonicity - Growth progress never decreases
## 5. State Transition Validity - Plots follow valid state transitions
##
## **Validates: Requirements 4.1, 4.2, 4.3, 4.4**

const PROPERTY_TEST_ITERATIONS = 100

# Random number generator for property tests
var rng: RandomNumberGenerator

func before_test() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	# Reset GameManager inventory to a clean state
	GameManager.inventory.clear()
	GameManager._initialize_inventory()
	# Add plenty of seeds for property tests
	GameManager.add_to_inventory("health_seeds", 1000)
	GameManager.add_to_inventory("ammo_seeds", 1000)
	GameManager.add_to_inventory("weapon_mod_seeds", 1000)
	GameManager.add_to_inventory("generic_seeds", 1000)

# Helper to create random CropData
func create_random_crop() -> CropData:
	var crop = CropData.new()
	crop.crop_id = "crop_" + str(rng.randi())
	crop.display_name = "Test Crop"
	crop.growth_time = rng.randf_range(5.0, 30.0)
	crop.growth_mode = "time" if rng.randf() < 0.5 else "runs"
	crop.seed_cost = rng.randi_range(5, 20)
	crop.base_color = Color(rng.randf(), rng.randf(), rng.randf())
	crop.shape_type = ["round", "tall", "leafy"][rng.randi() % 3]
	
	var buff = Buff.new()
	buff.buff_type = [Buff.BuffType.HEALTH, Buff.BuffType.AMMO, Buff.BuffType.WEAPON_MOD][rng.randi() % 3]
	buff.value = rng.randi_range(10, 50)
	crop.buff_provided = buff
	
	return crop

# Helper to create random grid size within valid range (6-12 plots)
func create_random_grid_size() -> Vector2i:
	# Valid configurations for 6-12 plots:
	# 2x3=6, 3x2=6, 2x4=8, 4x2=8, 3x3=9, 2x5=10, 5x2=10, 2x6=12, 6x2=12, 3x4=12, 4x3=12
	var valid_configs = [
		Vector2i(2, 3), Vector2i(3, 2),
		Vector2i(2, 4), Vector2i(4, 2),
		Vector2i(3, 3),
		Vector2i(2, 5), Vector2i(5, 2),
		Vector2i(2, 6), Vector2i(6, 2),
		Vector2i(3, 4), Vector2i(4, 3)
	]
	return valid_configs[rng.randi() % valid_configs.size()]

func test_property_grid_consistency() -> void:
	# Property: For all valid grid_size configurations, plot count equals grid_size.x * grid_size.y
	# This ensures the grid always creates the correct number of plots
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		var grid_size = create_random_grid_size()
		grid.grid_size = grid_size
		grid.plot_size = rng.randf_range(32.0, 128.0)
		
		add_child(grid)
		await get_tree().process_frame
		
		# Verify plot count matches grid dimensions
		var expected_count = grid_size.x * grid_size.y
		var actual_count = grid.get_plot_count()
		
		assert_int(actual_count).is_equal(expected_count)
		
		# Verify all plots are valid instances
		var plots = grid.get_all_plots()
		assert_int(plots.size()).is_equal(expected_count)
		
		for plot in plots:
			assert_object(plot).is_not_null()
			assert_bool(is_instance_valid(plot)).is_true()
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_position_determinism() -> void:
	# Property: For the same grid configuration, plot positions are always identical
	# This ensures deterministic layout generation
	
	for iteration in range(50):  # Fewer iterations since we create 2 grids per test
		var grid_size = create_random_grid_size()
		var plot_size = rng.randf_range(32.0, 128.0)
		
		# Create first grid
		var grid1 = FarmGrid.new()
		grid1.grid_size = grid_size
		grid1.plot_size = plot_size
		add_child(grid1)
		await get_tree().process_frame
		
		# Create second grid with same configuration
		var grid2 = FarmGrid.new()
		grid2.grid_size = grid_size
		grid2.plot_size = plot_size
		add_child(grid2)
		await get_tree().process_frame
		
		# Verify positions match
		var plots1 = grid1.get_all_plots()
		var plots2 = grid2.get_all_plots()
		
		assert_int(plots1.size()).is_equal(plots2.size())
		
		for i in range(plots1.size()):
			assert_float(plots1[i].position.x).is_equal_approx(plots2[i].position.x, 0.01)
			assert_float(plots1[i].position.y).is_equal_approx(plots2[i].position.y, 0.01)
		
		grid1.queue_free()
		grid2.queue_free()
		await get_tree().process_frame

func test_property_state_preservation() -> void:
	# Property: Serialize followed by deserialize preserves all plot states exactly
	# This ensures save/load functionality is lossless
	
	for iteration in range(50):
		var grid = FarmGrid.new()
		grid.grid_size = create_random_grid_size()
		add_child(grid)
		await get_tree().process_frame
		
		# Create crop database
		var crop_database = {}
		for i in range(5):
			var crop = create_random_crop()
			crop_database[crop.crop_id] = crop
		
		var plots = grid.get_all_plots()
		var crop_ids = crop_database.keys()
		
		# Randomly plant crops and set states
		for plot in plots:
			var action = rng.randf()
			if action < 0.3:
				# Leave empty
				pass
			elif action < 0.7:
				# Plant and set random growth
				var crop_id = crop_ids[rng.randi() % crop_ids.size()]
				var crop = crop_database[crop_id]
				grid.plant_crop(plot, crop)
				plot.growth_progress = rng.randf_range(0.0, crop.growth_time)
			else:
				# Plant and make harvestable
				var crop_id = crop_ids[rng.randi() % crop_ids.size()]
				var crop = crop_database[crop_id]
				grid.plant_crop(plot, crop)
				plot.growth_progress = crop.growth_time
				plot.state = Plot.PlotState.HARVESTABLE
		
		# Serialize
		var plot_states = grid.serialize_plots()
		
		# Create new grid and deserialize
		var grid2 = FarmGrid.new()
		grid2.grid_size = grid.grid_size
		add_child(grid2)
		await get_tree().process_frame
		
		grid2.deserialize_plots(plot_states, crop_database)
		
		# Verify all states match
		var plots2 = grid2.get_all_plots()
		for i in range(plots.size()):
			assert_int(plots2[i].state).is_equal(plots[i].state)
			assert_str(plots2[i].crop_type).is_equal(plots[i].crop_type)
			assert_float(plots2[i].growth_progress).is_equal_approx(plots[i].growth_progress, 0.01)
			assert_float(plots2[i].growth_time).is_equal_approx(plots[i].growth_time, 0.01)
		
		grid.queue_free()
		grid2.queue_free()
		await get_tree().process_frame

func test_property_growth_monotonicity() -> void:
	# Property: Growth progress never decreases (except on harvest which resets to 0)
	# This ensures crops always progress forward in time
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		crop.growth_mode = "time"  # Use time-based for this test
		
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Plant the crop
		grid.plant_crop(target_plot, crop)
		
		var previous_progress = 0.0
		var update_count = rng.randi_range(5, 20)
		
		# Perform multiple growth updates
		for i in range(update_count):
			var delta = rng.randf_range(0.1, 2.0)
			grid.update_crop_growth(delta)
			
			var current_progress = target_plot.growth_progress
			
			# Growth should never decrease
			assert_float(current_progress).is_greater_equal(previous_progress)
			
			previous_progress = current_progress
			
			# Stop if harvestable
			if target_plot.state == Plot.PlotState.HARVESTABLE:
				break
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_state_transition_validity() -> void:
	# Property: Plot state transitions always follow valid paths
	# Valid transitions: EMPTY -> GROWING -> HARVESTABLE -> EMPTY
	# Invalid: Any other transition path
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Track state transitions
		var states_seen = [Plot.PlotState.EMPTY]
		
		# Plant crop (EMPTY -> GROWING)
		grid.plant_crop(target_plot, crop)
		states_seen.append(target_plot.state)
		assert_int(target_plot.state).is_equal(Plot.PlotState.GROWING)
		
		# Grow to completion (GROWING -> HARVESTABLE)
		if crop.growth_mode == "time":
			grid.update_crop_growth(crop.growth_time)
		else:
			for i in range(int(crop.growth_time)):
				grid.increment_run_growth()
		
		states_seen.append(target_plot.state)
		assert_int(target_plot.state).is_equal(Plot.PlotState.HARVESTABLE)
		
		# Harvest (HARVESTABLE -> EMPTY)
		grid.harvest_crop(target_plot)
		states_seen.append(target_plot.state)
		assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		# Verify the complete transition sequence
		assert_array(states_seen).is_equal([
			Plot.PlotState.EMPTY,
			Plot.PlotState.GROWING,
			Plot.PlotState.HARVESTABLE,
			Plot.PlotState.EMPTY
		])
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_plot_retrieval_consistency() -> void:
	# Property: get_plot_at_position always returns the closest plot within range
	# or null if no plot is within range
	
	for iteration in range(50):
		var grid = FarmGrid.new()
		grid.grid_size = create_random_grid_size()
		grid.plot_size = 64.0
		add_child(grid)
		await get_tree().process_frame
		
		var plots = grid.get_all_plots()
		
		# Test positions near each plot
		for plot in plots:
			# Position exactly at plot center should return that plot
			var found_plot = grid.get_plot_at_position(plot.position)
			assert_object(found_plot).is_equal(plot)
			
			# Position slightly offset should still return the same plot
			var offset = Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10))
			found_plot = grid.get_plot_at_position(plot.position + offset)
			# Should either be the same plot or a nearby plot, but not null
			assert_object(found_plot).is_not_null()
		
		# Test position far from all plots
		var far_position = Vector2(10000, 10000)
		var found_plot = grid.get_plot_at_position(far_position)
		assert_object(found_plot).is_null()
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_signal_emission_consistency() -> void:
	# Property: Signals are emitted if and only if the operation succeeds
	
	for iteration in range(50):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Test crop_planted signal
		var plant_monitor = monitor_signal(grid, "crop_planted")
		var plant_success = grid.plant_crop(target_plot, crop)
		
		if plant_success:
			assert_int(plant_monitor.get_count()).is_equal(1)
		else:
			assert_int(plant_monitor.get_count()).is_equal(0)
		
		# Grow to harvestable
		if crop.growth_mode == "time":
			grid.update_crop_growth(crop.growth_time)
		else:
			for i in range(int(crop.growth_time)):
				grid.increment_run_growth()
		
		# Test crop_harvested signal
		var harvest_monitor = monitor_signal(grid, "crop_harvested")
		var harvest_result = grid.harvest_crop(target_plot)
		
		if not harvest_result.is_empty():
			assert_int(harvest_monitor.get_count()).is_equal(1)
		else:
			assert_int(harvest_monitor.get_count()).is_equal(0)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_grid_size_requirement() -> void:
	# Property: Grid always contains between 6 and 12 plots (Requirement 4.1)
	# **Validates: Requirements 4.1**
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		var grid_size = create_random_grid_size()
		grid.grid_size = grid_size
		add_child(grid)
		await get_tree().process_frame
		
		var plot_count = grid.get_plot_count()
		
		# Verify plot count is within required range
		assert_int(plot_count).is_greater_equal(6)
		assert_int(plot_count).is_less_equal(12)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_multiple_crop_independence() -> void:
	# Property: Growth updates to one plot do not affect other plots
	# Each plot maintains independent state
	
	for iteration in range(50):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(3, 2)  # 6 plots
		add_child(grid)
		await get_tree().process_frame
		
		var plots = grid.get_all_plots()
		
		# Plant different crops with different growth times
		var crops = []
		for i in range(plots.size()):
			var crop = create_random_crop()
			crop.growth_mode = "time"
			crops.append(crop)
			grid.plant_crop(plots[i], crop)
		
		# Record initial states
		var initial_progress = []
		for plot in plots:
			initial_progress.append(plot.growth_progress)
		
		# Update growth
		var delta = rng.randf_range(1.0, 5.0)
		grid.update_crop_growth(delta)
		
		# Verify each plot progressed independently
		for i in range(plots.size()):
			var expected_progress = initial_progress[i] + delta
			var actual_progress = plots[i].growth_progress
			
			# Progress should increase by exactly delta (unless harvestable)
			if plots[i].state == Plot.PlotState.GROWING:
				assert_float(actual_progress).is_equal_approx(expected_progress, 0.01)
			else:
				# If harvestable, progress should be clamped to growth_time
				assert_float(actual_progress).is_equal_approx(plots[i].growth_time, 0.01)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_inventory_check_prevents_planting() -> void:
	# Property: Planting always fails when insufficient seeds, always succeeds when sufficient
	# **Validates: Requirements 4.2**
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Determine seed type
		var seed_type = grid._get_seed_type_from_crop(crop.crop_id)
		
		# Test with insufficient seeds
		GameManager.inventory[seed_type] = crop.seed_cost - 1
		var initial_amount = GameManager.get_inventory_amount(seed_type)
		
		var fail_result = grid.plant_crop(target_plot, crop)
		
		# Should fail and not deduct seeds
		assert_bool(fail_result).is_false()
		assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
		assert_int(GameManager.get_inventory_amount(seed_type)).is_equal(initial_amount)
		
		# Test with sufficient seeds
		GameManager.inventory[seed_type] = crop.seed_cost + rng.randi_range(0, 50)
		var sufficient_amount = GameManager.get_inventory_amount(seed_type)
		
		var success_result = grid.plant_crop(target_plot, crop)
		
		# Should succeed and deduct seeds
		assert_bool(success_result).is_true()
		assert_int(target_plot.state).is_equal(Plot.PlotState.GROWING)
		assert_int(GameManager.get_inventory_amount(seed_type)).is_equal(sufficient_amount - crop.seed_cost)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_seed_deduction_is_exact() -> void:
	# Property: Seed deduction always equals crop.seed_cost, never more or less
	# **Validates: Requirements 4.2**
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Determine seed type
		var seed_type = grid._get_seed_type_from_crop(crop.crop_id)
		
		# Set random initial seed amount (sufficient for planting)
		var initial_seeds = crop.seed_cost + rng.randi_range(0, 100)
		GameManager.inventory[seed_type] = initial_seeds
		
		# Plant the crop
		var success = grid.plant_crop(target_plot, crop)
		
		if success:
			# Verify exact deduction
			var final_seeds = GameManager.get_inventory_amount(seed_type)
			var deducted = initial_seeds - final_seeds
			
			assert_int(deducted).is_equal(crop.seed_cost)
			assert_int(final_seeds).is_equal(initial_seeds - crop.seed_cost)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_seed_type_mapping_consistency() -> void:
	# Property: Seed type mapping is consistent and deterministic
	# Same crop_id prefix always maps to same seed type
	# **Validates: Requirements 4.2**
	
	for iteration in range(50):
		var grid = FarmGrid.new()
		add_child(grid)
		await get_tree().process_frame
		
		# Test health crops
		var health_crop = create_random_crop()
		health_crop.crop_id = "health_berry_" + str(rng.randi())
		var health_seed_type = grid._get_seed_type_from_crop(health_crop.crop_id)
		assert_str(health_seed_type).is_equal("health_seeds")
		
		# Test ammo crops
		var ammo_crop = create_random_crop()
		ammo_crop.crop_id = "ammo_grain_" + str(rng.randi())
		var ammo_seed_type = grid._get_seed_type_from_crop(ammo_crop.crop_id)
		assert_str(ammo_seed_type).is_equal("ammo_seeds")
		
		# Test weapon mod crops
		var weapon_crop = create_random_crop()
		weapon_crop.crop_id = "weapon_mod_flower_" + str(rng.randi())
		var weapon_seed_type = grid._get_seed_type_from_crop(weapon_crop.crop_id)
		assert_str(weapon_seed_type).is_equal("weapon_mod_seeds")
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_multiple_plantings_cumulative_deduction() -> void:
	# Property: Multiple plantings correctly accumulate seed deductions
	# Total deduction equals sum of individual seed costs
	# **Validates: Requirements 4.2**
	
	for iteration in range(50):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(3, 2)  # 6 plots
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var seed_type = grid._get_seed_type_from_crop(crop.crop_id)
		
		# Set initial seed amount
		var initial_seeds = crop.seed_cost * 10  # Enough for multiple plantings
		GameManager.inventory[seed_type] = initial_seeds
		
		var plots = grid.get_all_plots()
		var successful_plantings = 0
		var expected_total_deduction = 0
		
		# Attempt to plant in all plots
		for plot in plots:
			var current_seeds = GameManager.get_inventory_amount(seed_type)
			if current_seeds >= crop.seed_cost:
				var success = grid.plant_crop(plot, crop)
				if success:
					successful_plantings += 1
					expected_total_deduction += crop.seed_cost
		
		# Verify total deduction
		var final_seeds = GameManager.get_inventory_amount(seed_type)
		var actual_deduction = initial_seeds - final_seeds
		
		assert_int(actual_deduction).is_equal(expected_total_deduction)
		assert_int(successful_plantings * crop.seed_cost).is_equal(actual_deduction)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_harvest_adds_to_inventory() -> void:
	# Property: Harvesting always adds exactly 1 crop and 1 buff to inventory
	# **Validates: Requirements 4.4**
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Plant and grow to harvestable
		grid.plant_crop(target_plot, crop)
		if crop.growth_mode == "time":
			grid.update_crop_growth(crop.growth_time)
		else:
			for i in range(int(crop.growth_time)):
				grid.increment_run_growth()
		
		# Record initial inventory
		var initial_crop_count = GameManager.get_inventory_amount(crop.crop_id)
		var initial_buff_count = GameManager.get_inventory_amount(crop.crop_id + "_buff")
		
		# Harvest
		var resources = grid.harvest_crop(target_plot)
		
		if not resources.is_empty():
			# Verify exactly 1 crop and 1 buff added
			assert_int(GameManager.get_inventory_amount(crop.crop_id)).is_equal(initial_crop_count + 1)
			assert_int(GameManager.get_inventory_amount(crop.crop_id + "_buff")).is_equal(initial_buff_count + 1)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_harvest_only_when_harvestable() -> void:
	# Property: Harvest succeeds if and only if plot state is HARVESTABLE
	# **Validates: Requirements 4.4**
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Test harvest on empty plot
		var empty_result = grid.harvest_crop(target_plot)
		assert_bool(empty_result.is_empty()).is_true()
		assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		# Plant crop
		grid.plant_crop(target_plot, crop)
		
		# Test harvest on growing plot
		var growing_result = grid.harvest_crop(target_plot)
		assert_bool(growing_result.is_empty()).is_true()
		assert_int(target_plot.state).is_equal(Plot.PlotState.GROWING)
		
		# Grow to harvestable
		if crop.growth_mode == "time":
			grid.update_crop_growth(crop.growth_time)
		else:
			for i in range(int(crop.growth_time)):
				grid.increment_run_growth()
		
		# Test harvest on harvestable plot
		var harvestable_result = grid.harvest_crop(target_plot)
		assert_bool(harvestable_result.is_empty()).is_false()
		assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_multiple_harvests_accumulate() -> void:
	# Property: Multiple harvests correctly accumulate in inventory
	# Total inventory equals number of successful harvests
	# **Validates: Requirements 4.4**
	
	for iteration in range(50):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(3, 2)  # 6 plots
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		crop.growth_mode = "time"  # Use time-based for faster testing
		var plots = grid.get_all_plots()
		
		# Plant all plots
		for plot in plots:
			grid.plant_crop(plot, crop)
		
		# Grow all to harvestable
		grid.update_crop_growth(crop.growth_time)
		
		# Record initial inventory
		var initial_crop_count = GameManager.get_inventory_amount(crop.crop_id)
		var initial_buff_count = GameManager.get_inventory_amount(crop.crop_id + "_buff")
		
		# Harvest all plots
		var successful_harvests = 0
		for plot in plots:
			var result = grid.harvest_crop(plot)
			if not result.is_empty():
				successful_harvests += 1
		
		# Verify accumulation
		var final_crop_count = GameManager.get_inventory_amount(crop.crop_id)
		var final_buff_count = GameManager.get_inventory_amount(crop.crop_id + "_buff")
		
		assert_int(final_crop_count).is_equal(initial_crop_count + successful_harvests)
		assert_int(final_buff_count).is_equal(initial_buff_count + successful_harvests)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_failed_harvest_no_inventory_change() -> void:
	# Property: Failed harvest never modifies inventory
	# **Validates: Requirements 4.4**
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Take snapshot of entire inventory
		var initial_inventory = GameManager.inventory.duplicate()
		
		# Attempt harvest on empty plot (should fail)
		var result1 = grid.harvest_crop(target_plot)
		assert_bool(result1.is_empty()).is_true()
		assert_object(GameManager.inventory).is_equal(initial_inventory)
		
		# Plant but don't complete growth
		grid.plant_crop(target_plot, crop)
		var inventory_after_plant = GameManager.inventory.duplicate()
		
		# Attempt harvest on growing plot (should fail)
		var result2 = grid.harvest_crop(target_plot)
		assert_bool(result2.is_empty()).is_true()
		assert_object(GameManager.inventory).is_equal(inventory_after_plant)
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_harvest_resets_plot_state() -> void:
	# Property: Successful harvest always resets plot to EMPTY state
	# **Validates: Requirements 4.4**
	
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		# Plant and grow to harvestable
		grid.plant_crop(target_plot, crop)
		if crop.growth_mode == "time":
			grid.update_crop_growth(crop.growth_time)
		else:
			for i in range(int(crop.growth_time)):
				grid.increment_run_growth()
		
		assert_int(target_plot.state).is_equal(Plot.PlotState.HARVESTABLE)
		
		# Harvest
		var result = grid.harvest_crop(target_plot)
		
		if not result.is_empty():
			# Verify plot is reset
			assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
			assert_str(target_plot.crop_type).is_equal("")
			assert_float(target_plot.growth_progress).is_equal(0.0)
			assert_object(target_plot.crop_data).is_null()
		
		grid.queue_free()
		await get_tree().process_frame

func test_property_plant_harvest_cycle_repeatable() -> void:
	# Property: Plant-harvest cycle can be repeated indefinitely on same plot
	# **Validates: Requirements 4.2, 4.4**
	
	for iteration in range(50):
		var grid = FarmGrid.new()
		grid.grid_size = Vector2i(2, 2)
		add_child(grid)
		await get_tree().process_frame
		
		var crop = create_random_crop()
		crop.growth_mode = "time"
		var plots = grid.get_all_plots()
		var target_plot = plots[0]
		
		var cycles = rng.randi_range(2, 5)
		var initial_crop_count = GameManager.get_inventory_amount(crop.crop_id)
		
		for cycle in range(cycles):
			# Plant
			var plant_success = grid.plant_crop(target_plot, crop)
			assert_bool(plant_success).is_true()
			assert_int(target_plot.state).is_equal(Plot.PlotState.GROWING)
			
			# Grow
			grid.update_crop_growth(crop.growth_time)
			assert_int(target_plot.state).is_equal(Plot.PlotState.HARVESTABLE)
			
			# Harvest
			var harvest_result = grid.harvest_crop(target_plot)
			assert_bool(harvest_result.is_empty()).is_false()
			assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
		
		# Verify total harvests
		var final_crop_count = GameManager.get_inventory_amount(crop.crop_id)
		assert_int(final_crop_count).is_equal(initial_crop_count + cycles)
		
		grid.queue_free()
		await get_tree().process_frame
