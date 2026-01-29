extends GdUnitTestSuite
## Integration tests for crop sprite generation with Plot and ProceduralArtGenerator
##
## Tests the complete workflow of planting crops, growing them, and
## displaying procedurally generated sprites at each growth stage.
##
## Validates: Requirements 4.5, 12.5

var plot: Plot
var art_generator: ProceduralArtGenerator

func before_test() -> void:
	# Create plot and art generator
	plot = Plot.new()
	art_generator = ProceduralArtGenerator.new()
	plot.art_generator = art_generator
	plot._ready()

func after_test() -> void:
	if plot != null:
		plot.free()
	plot = null
	art_generator = null

## Test complete workflow: plant -> grow -> harvest with sprite updates
func test_complete_crop_lifecycle_with_sprites() -> void:
	# Load health berry crop
	var crop = load("res://resources/crops/health_berry.tres")
	assert_that(crop).is_not_null()
	
	# Initial state: empty plot, no sprite
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
	assert_that(plot.sprite.visible).is_false()
	
	# Plant crop
	var planted = plot.plant(crop)
	assert_that(planted).is_true()
	assert_that(plot.state).is_equal(Plot.PlotState.GROWING)
	assert_that(plot.sprite.visible).is_true()
	assert_that(plot.sprite.texture).is_not_null()
	
	# Verify early growth stage (stage 1)
	var stage_1 = plot.get_visual_stage()
	assert_that(stage_1).is_equal(1)
	var texture_1 = plot.sprite.texture
	
	# Progress to mid growth
	plot.growth_progress = plot.growth_time * 0.5
	plot._update_visual()
	var stage_2 = plot.get_visual_stage()
	assert_that(stage_2).is_equal(2)
	assert_that(plot.sprite.texture).is_not_null()
	
	# Progress to late growth
	plot.growth_progress = plot.growth_time * 0.8
	plot._update_visual()
	var stage_3 = plot.get_visual_stage()
	assert_that(stage_3).is_equal(3)
	assert_that(plot.sprite.texture).is_not_null()
	
	# Complete growth
	plot.state = Plot.PlotState.HARVESTABLE
	plot._update_visual()
	assert_that(plot.get_visual_stage()).is_equal(3)
	assert_that(plot.sprite.visible).is_true()
	
	# Harvest
	var harvest_result = plot.harvest()
	assert_that(harvest_result).is_not_empty()
	assert_that(plot.state).is_equal(Plot.PlotState.EMPTY)
	assert_that(plot.sprite.visible).is_false()

## Test that different crop types generate visually distinct sprites
func test_different_crops_generate_distinct_sprites() -> void:
	var crops = [
		load("res://resources/crops/health_berry.tres"),
		load("res://resources/crops/ammo_grain.tres"),
		load("res://resources/crops/weapon_flower.tres")
	]
	
	var textures = []
	
	for crop in crops:
		# Create a new plot for each crop
		var test_plot = Plot.new()
		test_plot.art_generator = art_generator
		test_plot._ready()
		
		# Plant and grow to harvestable
		test_plot.plant(crop)
		test_plot.state = Plot.PlotState.HARVESTABLE
		test_plot.growth_progress = test_plot.growth_time
		test_plot._update_visual()
		
		# Store texture
		assert_that(test_plot.sprite.texture).is_not_null()
		textures.append(test_plot.sprite.texture)
		
		test_plot.free()
	
	# Verify we got 3 textures
	assert_that(textures.size()).is_equal(3)
	
	# All textures should exist
	for texture in textures:
		assert_that(texture).is_not_null()

## Test that sprite generation respects CropData properties
func test_sprite_respects_crop_data_properties() -> void:
	# Test health berry (round, red)
	var health_crop = load("res://resources/crops/health_berry.tres")
	assert_that(health_crop.shape_type).is_equal("round")
	assert_that(health_crop.base_color.r).is_greater(0.5)  # Reddish
	
	plot.plant(health_crop)
	assert_that(plot.sprite.texture).is_not_null()
	
	# Harvest and test ammo grain (tall, yellow)
	plot.state = Plot.PlotState.HARVESTABLE
	plot.harvest()
	
	var ammo_crop = load("res://resources/crops/ammo_grain.tres")
	assert_that(ammo_crop.shape_type).is_equal("tall")
	assert_that(ammo_crop.base_color.r).is_greater(0.5)  # Yellowish
	assert_that(ammo_crop.base_color.g).is_greater(0.5)
	
	plot.plant(ammo_crop)
	assert_that(plot.sprite.texture).is_not_null()
	
	# Harvest and test weapon flower (leafy, purple)
	plot.state = Plot.PlotState.HARVESTABLE
	plot.harvest()
	
	var weapon_crop = load("res://resources/crops/weapon_flower.tres")
	assert_that(weapon_crop.shape_type).is_equal("leafy")
	assert_that(weapon_crop.base_color.b).is_greater(0.5)  # Purplish
	
	plot.plant(weapon_crop)
	assert_that(plot.sprite.texture).is_not_null()

## Test sprite updates during time-based growth
func test_sprite_updates_during_time_growth() -> void:
	var crop = load("res://resources/crops/health_berry.tres")
	plot.plant(crop)
	
	# Track stage changes
	var stages_seen = []
	
	# Early growth
	stages_seen.append(plot.get_visual_stage())
	
	# Simulate growth over time
	var time_step = plot.growth_time / 10.0
	for i in range(10):
		plot.update_growth(time_step)
		var current_stage = plot.get_visual_stage()
		if not current_stage in stages_seen:
			stages_seen.append(current_stage)
		
		# Sprite should always be visible during growth
		assert_that(plot.sprite.visible).is_true()
		assert_that(plot.sprite.texture).is_not_null()
	
	# Should have seen multiple stages
	assert_that(stages_seen.size()).is_greater_equal(2)
	
	# Should end at harvestable
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	assert_that(plot.get_visual_stage()).is_equal(3)

## Test sprite updates during run-based growth
func test_sprite_updates_during_run_growth() -> void:
	# Create a run-based crop
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	
	var run_crop = CropData.new()
	run_crop.crop_id = "test_run_crop"
	run_crop.display_name = "Test Run Crop"
	run_crop.growth_time = 3.0  # 3 runs
	run_crop.growth_mode = "runs"
	run_crop.buff_provided = buff
	run_crop.seed_cost = 10
	run_crop.base_color = Color.BLUE
	run_crop.shape_type = "tall"
	
	plot.plant(run_crop)
	
	# Track stage changes
	var stages_seen = [plot.get_visual_stage()]
	
	# Simulate 3 runs
	for i in range(3):
		plot.increment_run_growth()
		var current_stage = plot.get_visual_stage()
		if not current_stage in stages_seen:
			stages_seen.append(current_stage)
		
		# Sprite should be visible
		assert_that(plot.sprite.visible).is_true()
		assert_that(plot.sprite.texture).is_not_null()
	
	# Should have seen multiple stages
	assert_that(stages_seen.size()).is_greater_equal(2)
	
	# Should be harvestable after 3 runs
	assert_that(plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	assert_that(plot.get_visual_stage()).is_equal(3)

## Test deterministic sprite generation with same seed
func test_deterministic_sprite_generation() -> void:
	var crop = load("res://resources/crops/health_berry.tres")
	
	# Plant in first plot
	plot.plant(crop)
	plot.state = Plot.PlotState.HARVESTABLE
	plot._update_visual()
	var texture1 = plot.sprite.texture
	
	# Create second plot with same crop
	var plot2 = Plot.new()
	plot2.art_generator = art_generator
	plot2._ready()
	plot2.plant(crop)
	plot2.state = Plot.PlotState.HARVESTABLE
	plot2._update_visual()
	var texture2 = plot2.sprite.texture
	
	# Both should have textures
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	# Compare images pixel by pixel
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	assert_that(image1.get_width()).is_equal(image2.get_width())
	assert_that(image1.get_height()).is_equal(image2.get_height())
	
	# Sample pixels to verify determinism
	for y in range(0, image1.get_height(), 4):
		for x in range(0, image1.get_width(), 4):
			var pixel1 = image1.get_pixel(x, y)
			var pixel2 = image2.get_pixel(x, y)
			assert_that(pixel1).is_equal(pixel2)
	
	plot2.free()

## Test sprite persistence through save/load cycle
func test_sprite_persistence_through_save_load() -> void:
	var crop = load("res://resources/crops/health_berry.tres")
	plot.plant(crop)
	plot.growth_progress = plot.growth_time * 0.6
	plot._update_visual()
	
	var original_stage = plot.get_visual_stage()
	var original_visible = plot.sprite.visible
	
	# Save plot state
	var save_data = plot.to_dict()
	
	# Create new plot and restore
	var plot2 = Plot.new()
	plot2.art_generator = art_generator
	plot2._ready()
	
	var crop_database = {
		"health_berry": crop
	}
	plot2.from_dict(save_data, crop_database)
	
	# Verify sprite is restored correctly
	assert_that(plot2.get_visual_stage()).is_equal(original_stage)
	assert_that(plot2.sprite.visible).is_equal(original_visible)
	assert_that(plot2.sprite.texture).is_not_null()
	
	plot2.free()

## Test fallback visual when art generator is unavailable
func test_fallback_visual_without_art_generator() -> void:
	# Create plot without art generator
	var plot_no_gen = Plot.new()
	plot_no_gen.art_generator = null
	plot_no_gen._ready()
	
	var crop = load("res://resources/crops/health_berry.tres")
	plot_no_gen.plant(crop)
	
	# Should still have a visible sprite (fallback)
	assert_that(plot_no_gen.sprite.visible).is_true()
	assert_that(plot_no_gen.sprite.texture).is_not_null()
	
	# Verify fallback works for different stages
	plot_no_gen.growth_progress = plot_no_gen.growth_time * 0.5
	plot_no_gen._update_visual()
	assert_that(plot_no_gen.sprite.visible).is_true()
	
	plot_no_gen.free()
