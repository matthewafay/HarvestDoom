extends GdUnitTestSuite
## Integration tests for Plot class with real CropData resources
##
## Tests verify that Plot works correctly with actual CropData resources
## from the resources/crops/ directory.
##
## Validates: Requirements 4.2, 4.3, 4.4, 4.5

# Test fixtures
var plot: Plot
var health_berry: CropData
var ammo_grain: CropData
var weapon_flower: CropData

func before_test() -> void:
	# Create a fresh plot
	plot = Plot.new()
	
	# Load real crop data resources
	health_berry = load("res://resources/crops/health_berry.tres")
	ammo_grain = load("res://resources/crops/ammo_grain.tres")
	weapon_flower = load("res://resources/crops/weapon_flower.tres")

func after_test() -> void:
	if plot != null:
		plot.free()
	plot = null
	health_berry = null
	ammo_grain = null
	weapon_flower = null

## Test: Plant and harvest health berry
func test_health_berry_lifecycle() -> void:
	# Verify crop data loaded correctly
	assert_that(health_berry).is_not_null()
	assert_that(health_berry.crop_id).is_equal("health_berry")
	
	# Plant the crop
	var plant_result = plot.plant(health_berry)
	assert_bool(plant_result).is_true()
	assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
	assert_that(plot.crop_type).is_equal("health_berry")
	
	# Complete growth (health berry is time-based, 30 seconds)
	plot.update_growth(health_berry.growth_time)
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	
	# Harvest
	var harvest_result = plot.harvest()
	assert_that(harvest_result).is_not_empty()
	assert_that(harvest_result.get("crop_id")).is_equal("health_berry")
	
	# Verify buff
	var buff = harvest_result.get("buff")
	assert_that(buff).is_not_null()
	assert_that(buff.buff_type).is_equal(Buff.BuffType.HEALTH)
	assert_that(buff.value).is_equal(20)

## Test: Plant and harvest ammo grain
func test_ammo_grain_lifecycle() -> void:
	# Verify crop data loaded correctly
	assert_that(ammo_grain).is_not_null()
	assert_that(ammo_grain.crop_id).is_equal("ammo_grain")
	
	# Plant the crop
	var plant_result = plot.plant(ammo_grain)
	assert_bool(plant_result).is_true()
	
	# Complete growth (ammo grain is run-based, 2 runs)
	if ammo_grain.growth_mode == "runs":
		for i in range(int(ammo_grain.growth_time)):
			plot.increment_run_growth()
	else:
		plot.update_growth(ammo_grain.growth_time)
	
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	
	# Harvest
	var harvest_result = plot.harvest()
	assert_that(harvest_result).is_not_empty()
	assert_that(harvest_result.get("crop_id")).is_equal("ammo_grain")
	
	# Verify buff
	var buff = harvest_result.get("buff")
	assert_that(buff).is_not_null()
	assert_that(buff.buff_type).is_equal(Buff.BuffType.AMMO)

## Test: Plant and harvest weapon flower
func test_weapon_flower_lifecycle() -> void:
	# Verify crop data loaded correctly
	assert_that(weapon_flower).is_not_null()
	assert_that(weapon_flower.crop_id).is_equal("weapon_flower")
	
	# Plant the crop
	var plant_result = plot.plant(weapon_flower)
	assert_bool(plant_result).is_true()
	
	# Complete growth
	if weapon_flower.growth_mode == "runs":
		for i in range(int(weapon_flower.growth_time)):
			plot.increment_run_growth()
	else:
		plot.update_growth(weapon_flower.growth_time)
	
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	
	# Harvest
	var harvest_result = plot.harvest()
	assert_that(harvest_result).is_not_empty()
	assert_that(harvest_result.get("crop_id")).is_equal("weapon_flower")
	
	# Verify buff
	var buff = harvest_result.get("buff")
	assert_that(buff).is_not_null()
	assert_that(buff.buff_type).is_equal(Buff.BuffType.WEAPON_MOD)

## Test: Switch between different crops
func test_multiple_crop_cycles() -> void:
	# First cycle: health berry
	plot.plant(health_berry)
	plot.update_growth(health_berry.growth_time)
	var result1 = plot.harvest()
	assert_that(result1.get("crop_id")).is_equal("health_berry")
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
	
	# Second cycle: ammo grain
	plot.plant(ammo_grain)
	if ammo_grain.growth_mode == "runs":
		for i in range(int(ammo_grain.growth_time)):
			plot.increment_run_growth()
	else:
		plot.update_growth(ammo_grain.growth_time)
	var result2 = plot.harvest()
	assert_that(result2.get("crop_id")).is_equal("ammo_grain")
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
	
	# Third cycle: weapon flower
	plot.plant(weapon_flower)
	if weapon_flower.growth_mode == "runs":
		for i in range(int(weapon_flower.growth_time)):
			plot.increment_run_growth()
	else:
		plot.update_growth(weapon_flower.growth_time)
	var result3 = plot.harvest()
	assert_that(result3.get("crop_id")).is_equal("weapon_flower")
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)

## Test: Serialization with real crop data
func test_serialization_with_real_crops() -> void:
	# Plant and partially grow health berry
	plot.plant(health_berry)
	plot.update_growth(15.0)  # 50% growth
	
	# Serialize
	var save_data = plot.to_dict()
	
	# Create crop database
	var crop_db = {
		"health_berry": health_berry,
		"ammo_grain": ammo_grain,
		"weapon_flower": weapon_flower
	}
	
	# Deserialize into new plot
	var new_plot = Plot.new()
	new_plot.from_dict(save_data, crop_db)
	
	# Verify state
	assert_that(new_plot.state).is_equal(Plot.PlotState.GROWING)
	assert_that(new_plot.crop_type).is_equal("health_berry")
	assert_that(new_plot.growth_progress).is_equal(15.0)
	assert_that(new_plot.crop_data).is_equal(health_berry)
	
	# Complete growth and harvest
	new_plot.update_growth(15.0)
	var result = new_plot.harvest()
	assert_that(result.get("crop_id")).is_equal("health_berry")
	
	new_plot.free()

## Test: Visual stages with real crop growth times
func test_visual_stages_with_real_crops() -> void:
	plot.plant(health_berry)
	
	# Early growth (0-33%)
	plot.update_growth(10.0)  # 33% of 30 seconds
	assert_that(plot.get_visual_stage()).is_equal(1)
	
	# Mid growth (33-66%)
	plot.update_growth(5.0)  # Now at 50%
	assert_that(plot.get_visual_stage()).is_equal(2)
	
	# Late growth (66-100%)
	plot.update_growth(10.0)  # Now at 83%
	assert_that(plot.get_visual_stage()).is_equal(3)
	
	# Complete
	plot.update_growth(5.0)  # Now at 100%
	assert_that(plot.get_visual_stage()).is_equal(3)
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)

## Test: Growth percentage with real crops
func test_growth_percentage_with_real_crops() -> void:
	plot.plant(health_berry)
	
	# 0%
	assert_float(plot.get_growth_percentage()).is_equal(0.0)
	
	# 25%
	plot.update_growth(7.5)
	assert_float(plot.get_growth_percentage()).is_equal_approx(0.25, 0.01)
	
	# 50%
	plot.update_growth(7.5)
	assert_float(plot.get_growth_percentage()).is_equal_approx(0.5, 0.01)
	
	# 75%
	plot.update_growth(7.5)
	assert_float(plot.get_growth_percentage()).is_equal_approx(0.75, 0.01)
	
	# 100%
	plot.update_growth(7.5)
	assert_float(plot.get_growth_percentage()).is_equal(1.0)
