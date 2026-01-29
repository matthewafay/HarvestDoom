extends GdUnitTestSuite
## Property-Based Tests for Plot class
##
## Tests universal properties that should hold for all valid inputs:
## - State transitions follow strict sequence
## - Growth progress is monotonically increasing
## - State invariants are maintained
##
## **Validates: Requirements 4.2, 4.3, 4.4, 4.5**

const PROPERTY_TEST_ITERATIONS = 100

# Test fixtures
var rng: RandomNumberGenerator

func before_test() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()

func after_test() -> void:
	rng = null

## Helper: Create a random valid CropData
func create_random_crop() -> CropData:
	var crop = CropData.new()
	crop.crop_id = "test_crop_%d" % rng.randi()
	crop.display_name = "Test Crop"
	crop.growth_time = rng.randf_range(1.0, 100.0)
	crop.growth_mode = "time" if rng.randf() < 0.5 else "runs"
	crop.seed_cost = rng.randi_range(1, 50)
	crop.base_color = Color(rng.randf(), rng.randf(), rng.randf())
	crop.shape_type = ["round", "tall", "leafy"][rng.randi_range(0, 2)]
	
	# Create a buff
	var buff = Buff.new()
	buff.buff_type = rng.randi_range(0, 2)  # HEALTH, AMMO, or WEAPON_MOD
	buff.value = rng.randi_range(10, 100)
	crop.buff_provided = buff
	
	return crop

## Helper: Generate random growth updates
func generate_random_growth_updates(count: int) -> Array:
	var updates = []
	for i in range(count):
		updates.append(rng.randf_range(0.1, 5.0))
	return updates

## Property 1: State transitions follow strict sequence EMPTY -> GROWING -> HARVESTABLE -> EMPTY
## **Validates: Requirements 4.2, 4.3, 4.4**
func test_property_state_transition_sequence() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot = Plot.new()
		var crop = create_random_crop()
		
		# Initial state must be EMPTY
		assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
		
		# Plant transitions to GROWING
		var plant_result = plot.plant(crop)
		assert_bool(plant_result).is_true()
		assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
		
		# Cannot skip to HARVESTABLE without completing growth
		var harvest_result = plot.harvest()
		assert_that(harvest_result).is_empty()
		assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
		
		# Complete growth transitions to HARVESTABLE
		if crop.growth_mode == "time":
			plot.update_growth(crop.growth_time)
		else:
			for i in range(int(crop.growth_time)):
				plot.increment_run_growth()
		
		assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
		
		# Harvest transitions back to EMPTY
		harvest_result = plot.harvest()
		assert_that(harvest_result).is_not_empty()
		assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
		
		plot.free()

## Property 2: Growth progress is monotonically increasing
## **Validates: Requirements 4.3, 4.5**
func test_property_growth_monotonic() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot = Plot.new()
		var crop = create_random_crop()
		
		plot.plant(crop)
		
		var prev_progress = plot.growth_progress
		var update_count = rng.randi_range(5, 20)
		
		for i in range(update_count):
			if crop.growth_mode == "time":
				plot.update_growth(rng.randf_range(0.1, 2.0))
			else:
				plot.increment_run_growth()
			
			# Progress should never decrease
			assert_that(plot.growth_progress).is_greater_equal(prev_progress)
			prev_progress = plot.growth_progress
		
		plot.free()

## Property 3: Cannot plant in non-empty plot
## **Validates: Requirements 4.2**
func test_property_cannot_plant_non_empty() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot = Plot.new()
		var crop1 = create_random_crop()
		var crop2 = create_random_crop()
		
		# Plant first crop
		var result1 = plot.plant(crop1)
		assert_bool(result1).is_true()
		
		var original_crop_type = plot.crop_type
		
		# Attempt to plant second crop should fail
		var result2 = plot.plant(crop2)
		assert_bool(result2).is_false()
		
		# Original crop should be unchanged
		assert_that(plot.crop_type).is_equal(original_crop_type)
		
		plot.free()

## Property 4: Harvest only succeeds in HARVESTABLE state
## **Validates: Requirements 4.4**
func test_property_harvest_only_when_harvestable() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot = Plot.new()
		var crop = create_random_crop()
		
		# Cannot harvest empty plot
		var result = plot.harvest()
		assert_that(result).is_empty()
		
		# Plant crop
		plot.plant(crop)
		
		# Cannot harvest while growing
		result = plot.harvest()
		assert_that(result).is_empty()
		assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
		
		# Complete growth
		if crop.growth_mode == "time":
			plot.update_growth(crop.growth_time)
		else:
			for i in range(int(crop.growth_time)):
				plot.increment_run_growth()
		
		# Can harvest when harvestable
		result = plot.harvest()
		assert_that(result).is_not_empty()
		assert_that(result.get("crop_id")).is_equal(crop.crop_id)
		
		plot.free()

## Property 5: Growth percentage is bounded [0.0, 1.0]
## **Validates: Requirements 4.3, 4.5**
func test_property_growth_percentage_bounded() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot = Plot.new()
		var crop = create_random_crop()
		
		# Empty plot: 0%
		var percentage = plot.get_growth_percentage()
		assert_float(percentage).is_equal(0.0)
		
		plot.plant(crop)
		
		# During growth: [0.0, 1.0]
		var update_count = rng.randi_range(1, 50)
		for i in range(update_count):
			if crop.growth_mode == "time":
				plot.update_growth(rng.randf_range(0.1, 1.0))
			else:
				plot.increment_run_growth()
			
			percentage = plot.get_growth_percentage()
			assert_float(percentage).is_greater_equal(0.0)
			assert_float(percentage).is_less_equal(1.0)
		
		# Complete growth: 100%
		if crop.growth_mode == "time":
			plot.update_growth(crop.growth_time * 2.0)  # Overshoot
		else:
			for i in range(int(crop.growth_time) * 2):  # Overshoot
				plot.increment_run_growth()
		
		percentage = plot.get_growth_percentage()
		assert_float(percentage).is_equal(1.0)
		
		plot.free()

## Property 6: Visual stage progresses with growth
## **Validates: Requirements 4.3, 4.5**
func test_property_visual_stage_progression() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot = Plot.new()
		var crop = create_random_crop()
		
		# Empty: stage 0
		assert_that(plot.get_visual_stage()).is_equal(0)
		
		plot.plant(crop)
		
		var prev_stage = 0
		var progress_steps = [0.2, 0.4, 0.6, 0.8, 1.0]
		
		for progress_ratio in progress_steps:
			if crop.growth_mode == "time":
				plot.growth_progress = crop.growth_time * progress_ratio
			else:
				plot.growth_progress = crop.growth_time * progress_ratio
			
			# Update state if complete
			if plot.growth_progress >= crop.growth_time:
				plot.state = Plot.PlotState.HARVESTABLE
			
			var stage = plot.get_visual_stage()
			
			# Stage should be in valid range [1, 3] for growing/harvestable
			assert_that(stage).is_greater_equal(1)
			assert_that(stage).is_less_equal(3)
			
			# Stage should not decrease
			assert_that(stage).is_greater_equal(prev_stage)
			prev_stage = stage
		
		plot.free()

## Property 7: Time-based crops ignore run updates, run-based crops ignore time updates
## **Validates: Requirements 4.5**
func test_property_growth_mode_isolation() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot_time = Plot.new()
		var plot_run = Plot.new()
		
		var time_crop = create_random_crop()
		time_crop.growth_mode = "time"
		
		var run_crop = create_random_crop()
		run_crop.growth_mode = "runs"
		
		plot_time.plant(time_crop)
		plot_run.plant(run_crop)
		
		# Time crop should not respond to run increments
		var initial_progress = plot_time.growth_progress
		for i in range(10):
			plot_time.increment_run_growth()
		assert_that(plot_time.growth_progress).is_equal(initial_progress)
		
		# Run crop should not respond to time updates
		initial_progress = plot_run.growth_progress
		plot_run.update_growth(100.0)
		assert_that(plot_run.growth_progress).is_equal(initial_progress)
		
		plot_time.free()
		plot_run.free()

## Property 8: Harvest returns correct crop data
## **Validates: Requirements 4.4**
func test_property_harvest_returns_correct_data() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot = Plot.new()
		var crop = create_random_crop()
		
		plot.plant(crop)
		
		# Complete growth
		if crop.growth_mode == "time":
			plot.update_growth(crop.growth_time)
		else:
			for i in range(int(crop.growth_time)):
				plot.increment_run_growth()
		
		var result = plot.harvest()
		
		# Result should contain correct crop_id and buff
		assert_that(result.get("crop_id")).is_equal(crop.crop_id)
		assert_that(result.get("buff")).is_equal(crop.buff_provided)
		
		plot.free()

## Property 9: Serialization round-trip preserves state
## **Validates: Requirements 4.2, 4.3, 4.4, 4.5**
func test_property_serialization_round_trip() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot1 = Plot.new()
		var crop = create_random_crop()
		
		# Set up random plot state
		if rng.randf() > 0.3:  # 70% chance to plant
			plot1.plant(crop)
			
			# Random growth progress
			if crop.growth_mode == "time":
				plot1.update_growth(rng.randf_range(0, crop.growth_time * 1.5))
			else:
				for i in range(rng.randi_range(0, int(crop.growth_time) + 2)):
					plot1.increment_run_growth()
		
		# Serialize
		var data = plot1.to_dict()
		
		# Deserialize into new plot
		var plot2 = Plot.new()
		var crop_database = {crop.crop_id: crop}
		plot2.from_dict(data, crop_database)
		
		# States should match
		assert_that(plot2.state).is_equal(plot1.state)
		assert_that(plot2.crop_type).is_equal(plot1.crop_type)
		assert_that(plot2.growth_progress).is_equal(plot1.growth_progress)
		assert_that(plot2.growth_time).is_equal(plot1.growth_time)
		
		plot1.free()
		plot2.free()

## Property 10: Growth completed signal emits exactly once per growth cycle
## **Validates: Requirements 4.3**
func test_property_growth_completed_signal_once() -> void:
	for iteration in range(PROPERTY_TEST_ITERATIONS):
		var plot = Plot.new()
		var crop = create_random_crop()
		
		plot.plant(crop)
		
		var signal_monitor = monitor_signal(plot, "growth_completed")
		
		# Complete growth (possibly with overshoot)
		if crop.growth_mode == "time":
			plot.update_growth(crop.growth_time * rng.randf_range(1.0, 2.0))
		else:
			for i in range(int(crop.growth_time) * rng.randi_range(1, 3)):
				plot.increment_run_growth()
		
		# Signal should emit exactly once
		assert_signal(signal_monitor).is_emitted(1)
		
		plot.free()
