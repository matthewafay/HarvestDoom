extends GdUnitTestSuite
## Unit tests for Plot class
##
## Tests plot state management, crop planting, growth progression,
## and harvesting mechanics for both time-based and run-based growth modes.
##
## Validates: Requirements 4.2, 4.3, 4.4, 4.5

# Test fixtures
var plot: Plot
var time_crop: CropData
var run_crop: CropData
var health_buff: Buff

func before_test() -> void:
	# Create a fresh plot for each test
	plot = Plot.new()
	
	# Create a health buff for testing
	health_buff = Buff.new()
	health_buff.buff_type = Buff.BuffType.HEALTH
	health_buff.value = 20
	
	# Create a time-based crop
	time_crop = CropData.new()
	time_crop.crop_id = "test_time_crop"
	time_crop.display_name = "Test Time Crop"
	time_crop.growth_time = 10.0  # 10 seconds
	time_crop.growth_mode = "time"
	time_crop.buff_provided = health_buff
	time_crop.seed_cost = 5
	time_crop.base_color = Color.GREEN
	time_crop.shape_type = "round"
	
	# Create a run-based crop
	run_crop = CropData.new()
	run_crop.crop_id = "test_run_crop"
	run_crop.display_name = "Test Run Crop"
	run_crop.growth_time = 3.0  # 3 runs
	run_crop.growth_mode = "runs"
	run_crop.buff_provided = health_buff
	run_crop.seed_cost = 10
	run_crop.base_color = Color.BLUE
	run_crop.shape_type = "tall"

func after_test() -> void:
	if plot != null:
		plot.free()
	plot = null
	time_crop = null
	run_crop = null
	health_buff = null

## Test: Plot starts in EMPTY state
func test_initial_state() -> void:
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
	assert_that(plot.crop_type).is_equal("")
	assert_that(plot.growth_progress).is_equal(0.0)
	assert_that(plot.crop_data).is_null()

## Test: Planting a crop transitions to GROWING state
func test_plant_crop_success() -> void:
	var result = plot.plant(time_crop)
	
	assert_bool(result).is_true()
	assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
	assert_that(plot.crop_type).is_equal("test_time_crop")
	assert_that(plot.growth_time).is_equal(10.0)
	assert_that(plot.growth_progress).is_equal(0.0)
	assert_that(plot.crop_data).is_equal(time_crop)

## Test: Cannot plant in non-empty plot
func test_plant_crop_already_planted() -> void:
	plot.plant(time_crop)
	var result = plot.plant(run_crop)
	
	assert_bool(result).is_false()
	assert_that(plot.crop_type).is_equal("test_time_crop")  # Original crop unchanged

## Test: Cannot plant null crop
func test_plant_null_crop() -> void:
	var result = plot.plant(null)
	
	assert_bool(result).is_false()
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)

## Test: Time-based crop growth progresses with delta time
func test_time_based_growth_progression() -> void:
	plot.plant(time_crop)
	
	# Simulate 5 seconds of growth (50% progress)
	plot.update_growth(5.0)
	
	assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
	assert_that(plot.growth_progress).is_equal(5.0)
	assert_float(plot.get_growth_percentage()).is_equal_approx(0.5, 0.01)

## Test: Time-based crop completes growth and transitions to HARVESTABLE
func test_time_based_growth_completion() -> void:
	plot.plant(time_crop)
	
	# Monitor growth_completed signal
	var signal_monitor = monitor_signal(plot, "growth_completed")
	
	# Simulate full growth time
	plot.update_growth(10.0)
	
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	assert_that(plot.growth_progress).is_equal(10.0)
	assert_float(plot.get_growth_percentage()).is_equal(1.0)
	assert_signal(signal_monitor).is_emitted()

## Test: Time-based crop growth beyond completion time is clamped
func test_time_based_growth_overcomplete() -> void:
	plot.plant(time_crop)
	
	# Simulate more than full growth time
	plot.update_growth(15.0)
	
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	assert_that(plot.growth_progress).is_equal(10.0)  # Clamped to growth_time

## Test: Run-based crop growth progresses with run increments
func test_run_based_growth_progression() -> void:
	plot.plant(run_crop)
	
	# Complete 2 runs (66% progress)
	plot.increment_run_growth()
	plot.increment_run_growth()
	
	assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
	assert_that(plot.growth_progress).is_equal(2.0)
	assert_float(plot.get_growth_percentage()).is_equal_approx(0.666, 0.01)

## Test: Run-based crop completes growth after required runs
func test_run_based_growth_completion() -> void:
	plot.plant(run_crop)
	
	# Monitor growth_completed signal
	var signal_monitor = monitor_signal(plot, "growth_completed")
	
	# Complete 3 runs
	plot.increment_run_growth()
	plot.increment_run_growth()
	plot.increment_run_growth()
	
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	assert_that(plot.growth_progress).is_equal(3.0)
	assert_signal(signal_monitor).is_emitted()

## Test: Time-based crop does not progress with run increments
func test_time_crop_ignores_run_increments() -> void:
	plot.plant(time_crop)
	
	plot.increment_run_growth()
	
	assert_that(plot.growth_progress).is_equal(0.0)  # No change

## Test: Run-based crop does not progress with time updates
func test_run_crop_ignores_time_updates() -> void:
	plot.plant(run_crop)
	
	plot.update_growth(5.0)
	
	assert_that(plot.growth_progress).is_equal(0.0)  # No change

## Test: Harvesting harvestable crop returns resources
func test_harvest_success() -> void:
	plot.plant(time_crop)
	plot.update_growth(10.0)  # Complete growth
	
	var result = plot.harvest()
	
	assert_that(result).is_not_empty()
	assert_that(result.get("crop_id")).is_equal("test_time_crop")
	assert_that(result.get("buff")).is_equal(health_buff)

## Test: Harvesting clears plot to EMPTY state
func test_harvest_clears_plot() -> void:
	plot.plant(time_crop)
	plot.update_growth(10.0)
	plot.harvest()
	
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
	assert_that(plot.crop_type).is_equal("")
	assert_that(plot.crop_data).is_null()
	assert_that(plot.growth_progress).is_equal(0.0)

## Test: Cannot harvest empty plot
func test_harvest_empty_plot() -> void:
	var result = plot.harvest()
	
	assert_that(result).is_empty()
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)

## Test: Cannot harvest growing plot
func test_harvest_growing_plot() -> void:
	plot.plant(time_crop)
	plot.update_growth(5.0)  # Partial growth
	
	var result = plot.harvest()
	
	assert_that(result).is_empty()
	assert_that(plot.state).is_equal(Plot.PlotState.GROWING)  # State unchanged

## Test: Visual stage for empty plot is 0
func test_visual_stage_empty() -> void:
	assert_that(plot.get_visual_stage()).is_equal(0)

## Test: Visual stage for early growth is 1
func test_visual_stage_early_growth() -> void:
	plot.plant(time_crop)
	plot.update_growth(2.0)  # 20% progress
	
	assert_that(plot.get_visual_stage()).is_equal(1)

## Test: Visual stage for mid growth is 2
func test_visual_stage_mid_growth() -> void:
	plot.plant(time_crop)
	plot.update_growth(5.0)  # 50% progress
	
	assert_that(plot.get_visual_stage()).is_equal(2)

## Test: Visual stage for late growth is 3
func test_visual_stage_late_growth() -> void:
	plot.plant(time_crop)
	plot.update_growth(7.0)  # 70% progress
	
	assert_that(plot.get_visual_stage()).is_equal(3)

## Test: Visual stage for harvestable is 3
func test_visual_stage_harvestable() -> void:
	plot.plant(time_crop)
	plot.update_growth(10.0)  # Complete
	
	assert_that(plot.get_visual_stage()).is_equal(3)

## Test: Growth percentage calculation for empty plot
func test_growth_percentage_empty() -> void:
	assert_float(plot.get_growth_percentage()).is_equal(0.0)

## Test: Growth percentage calculation for partial growth
func test_growth_percentage_partial() -> void:
	plot.plant(time_crop)
	plot.update_growth(3.0)  # 30% progress
	
	assert_float(plot.get_growth_percentage()).is_equal_approx(0.3, 0.01)

## Test: Growth percentage calculation for harvestable
func test_growth_percentage_harvestable() -> void:
	plot.plant(time_crop)
	plot.update_growth(10.0)
	
	assert_float(plot.get_growth_percentage()).is_equal(1.0)

## Test: Serialization to dictionary
func test_to_dict() -> void:
	plot.plant(time_crop)
	plot.update_growth(5.0)
	
	var data = plot.to_dict()
	
	assert_that(data.get("state")).is_equal(Plot.PlotState.GROWING)
	assert_that(data.get("crop_type")).is_equal("test_time_crop")
	assert_that(data.get("growth_progress")).is_equal(5.0)
	assert_that(data.get("growth_time")).is_equal(10.0)

## Test: Deserialization from dictionary
func test_from_dict() -> void:
	var crop_database = {
		"test_time_crop": time_crop
	}
	
	var data = {
		"state": Plot.PlotState.GROWING,
		"crop_type": "test_time_crop",
		"growth_progress": 7.5,
		"growth_time": 10.0
	}
	
	plot.from_dict(data, crop_database)
	
	assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
	assert_that(plot.crop_type).is_equal("test_time_crop")
	assert_that(plot.growth_progress).is_equal(7.5)
	assert_that(plot.growth_time).is_equal(10.0)
	assert_that(plot.crop_data).is_equal(time_crop)

## Test: State transition sequence EMPTY -> GROWING -> HARVESTABLE -> EMPTY
func test_full_lifecycle() -> void:
	# Start empty
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
	
	# Plant crop
	plot.plant(time_crop)
	assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
	
	# Complete growth
	plot.update_growth(10.0)
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	
	# Harvest
	plot.harvest()
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)

## Test: Growth progress is monotonically increasing
func test_growth_progress_monotonic() -> void:
	plot.plant(time_crop)
	
	var prev_progress = plot.growth_progress
	for i in range(10):
		plot.update_growth(1.0)
		assert_that(plot.growth_progress).is_greater_equal(prev_progress)
		prev_progress = plot.growth_progress
