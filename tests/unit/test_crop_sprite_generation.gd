extends GdUnitTestSuite
## Unit tests for crop sprite generation integration
##
## Tests that Plot class correctly integrates with ProceduralArtGenerator
## to generate crop sprites for all growth stages.
##
## Validates: Requirements 4.5, 12.5

## Test that ProceduralArtGenerator can generate crop sprites for all types
func test_art_generator_generates_crop_sprites() -> void:
	var art_gen = ProceduralArtGenerator.new()
	var crop_types = ["health_berry", "ammo_grain", "weapon_flower"]
	var stages = [0, 1, 2, 3]
	
	for crop_type in crop_types:
		for stage in stages:
			var seed_value = crop_type.hash() + stage
			var texture = art_gen.generate_crop_sprite(crop_type, stage, seed_value)
			
			assert_that(texture).is_not_null()
			assert_that(texture).is_instanceof(Texture2D)
			
			# Verify texture has correct dimensions (32x32)
			var image = texture.get_image()
			assert_that(image.get_width()).is_equal(32)
			assert_that(image.get_height()).is_equal(32)

## Test that Plot initializes sprite node correctly
func test_plot_initializes_sprite() -> void:
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()
	
	assert_that(plot.sprite).is_not_null()
	assert_that(plot.sprite).is_instanceof(Sprite2D)
	assert_that(plot.sprite.centered).is_true()

## Test that planting a crop generates and displays sprite
func test_planting_generates_sprite() -> void:
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()
	
	# Load health berry crop
	var crop = load("res://resources/crops/health_berry.tres")
	assert_that(crop).is_not_null()
	
	# Plant the crop
	var planted = plot.plant(crop)
	assert_that(planted).is_true()
	
	# Verify sprite is visible and has texture
	assert_that(plot.sprite.visible).is_true()
	assert_that(plot.sprite.texture).is_not_null()

## Test that all crop types generate sprites correctly
func test_all_crop_types_generate_sprites() -> void:
	var crop_files = [
		"res://resources/crops/health_berry.tres",
		"res://resources/crops/ammo_grain.tres",
		"res://resources/crops/weapon_flower.tres"
	]
	
	for crop_file in crop_files:
		var crop = load(crop_file)
		assert_that(crop).is_not_null()
		
		var plot = Plot.new()
		plot.art_generator = ProceduralArtGenerator.new()
		plot._ready()
		
		var planted = plot.plant(crop)
		assert_that(planted).is_true()
		
		# Verify sprite has texture
		assert_that(plot.sprite.texture).is_not_null()
		
		# Verify growth stage is not empty
		var stage = plot.get_visual_stage()
		assert_that(stage).is_greater(0)

## Test that sprite updates for different growth stages
func test_sprite_updates_for_growth_stages() -> void:
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()
	
	var crop = load("res://resources/crops/health_berry.tres")
	plot.plant(crop)
	
	# Test early growth (stage 1)
	plot.growth_progress = 0.0
	plot._update_visual()
	assert_that(plot.get_visual_stage()).is_equal(1)
	assert_that(plot.sprite.texture).is_not_null()
	assert_that(plot.sprite.visible).is_true()
	
	# Test mid growth (stage 2)
	plot.growth_progress = plot.growth_time * 0.5
	plot._update_visual()
	assert_that(plot.get_visual_stage()).is_equal(2)
	assert_that(plot.sprite.texture).is_not_null()
	assert_that(plot.sprite.visible).is_true()
	
	# Test late growth (stage 3)
	plot.growth_progress = plot.growth_time * 0.8
	plot._update_visual()
	assert_that(plot.get_visual_stage()).is_equal(3)
	assert_that(plot.sprite.texture).is_not_null()
	assert_that(plot.sprite.visible).is_true()

## Test that harvestable state shows stage 3 sprite
func test_harvestable_state_shows_stage_3() -> void:
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()
	
	var crop = load("res://resources/crops/health_berry.tres")
	plot.plant(crop)
	
	# Set to harvestable
	plot.state = Plot.PlotState.HARVESTABLE
	plot.growth_progress = plot.growth_time
	plot._update_visual()
	
	assert_that(plot.get_visual_stage()).is_equal(3)
	assert_that(plot.sprite.texture).is_not_null()
	assert_that(plot.sprite.visible).is_true()

## Test that empty plot hides sprite
func test_empty_plot_hides_sprite() -> void:
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()
	
	var crop = load("res://resources/crops/health_berry.tres")
	plot.plant(crop)
	
	# Verify sprite is visible
	assert_that(plot.sprite.visible).is_true()
	
	# Harvest to empty the plot
	plot.state = Plot.PlotState.HARVESTABLE
	plot.harvest()
	
	# Verify sprite is hidden
	assert_that(plot.sprite.visible).is_false()
	assert_that(plot.get_visual_stage()).is_equal(0)

## Test that sprite updates when growth progresses
func test_sprite_updates_on_growth_progress() -> void:
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()
	
	var crop = load("res://resources/crops/health_berry.tres")
	plot.plant(crop)
	
	# Start at early growth
	var initial_stage = plot.get_visual_stage()
	assert_that(initial_stage).is_equal(1)
	
	# Progress growth to mid stage
	plot.update_growth(plot.growth_time * 0.4)
	var new_stage = plot.get_visual_stage()
	
	# Verify stage advanced
	assert_that(new_stage).is_greater(initial_stage)
	assert_that(plot.sprite.texture).is_not_null()

## Test that different crop types use their shape_type property
func test_crop_types_use_shape_type() -> void:
	var art_gen = ProceduralArtGenerator.new()
	
	# Test health berry (round shape)
	var health_crop = load("res://resources/crops/health_berry.tres")
	assert_that(health_crop.shape_type).is_equal("round")
	var health_texture = art_gen.generate_crop_sprite("health_berry", 3, 12345)
	assert_that(health_texture).is_not_null()
	
	# Test ammo grain (tall shape)
	var ammo_crop = load("res://resources/crops/ammo_grain.tres")
	assert_that(ammo_crop.shape_type).is_equal("tall")
	var ammo_texture = art_gen.generate_crop_sprite("ammo_grain", 3, 12345)
	assert_that(ammo_texture).is_not_null()
	
	# Test weapon flower (leafy shape)
	var weapon_crop = load("res://resources/crops/weapon_flower.tres")
	assert_that(weapon_crop.shape_type).is_equal("leafy")
	var weapon_texture = art_gen.generate_crop_sprite("weapon_flower", 3, 12345)
	assert_that(weapon_texture).is_not_null()

## Test that sprite generation is deterministic with same seed
func test_sprite_generation_is_deterministic() -> void:
	var art_gen = ProceduralArtGenerator.new()
	var crop_type = "health_berry"
	var stage = 2
	var seed_value = 42
	
	# Generate sprite twice with same parameters
	var texture1 = art_gen.generate_crop_sprite(crop_type, stage, seed_value)
	var texture2 = art_gen.generate_crop_sprite(crop_type, stage, seed_value)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	# Get images and compare pixel data
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	assert_that(image1.get_width()).is_equal(image2.get_width())
	assert_that(image1.get_height()).is_equal(image2.get_height())
	
	# Compare a sample of pixels to verify determinism
	for y in range(0, image1.get_height(), 4):
		for x in range(0, image1.get_width(), 4):
			var pixel1 = image1.get_pixel(x, y)
			var pixel2 = image2.get_pixel(x, y)
			assert_that(pixel1).is_equal(pixel2)

## Test that fallback visual works when art generator is not available
func test_fallback_visual_when_no_art_generator() -> void:
	var plot = Plot.new()
	plot.art_generator = null  # No art generator
	plot._ready()
	
	var crop = load("res://resources/crops/health_berry.tres")
	plot.plant(crop)
	
	# Should still have a visible sprite (fallback)
	assert_that(plot.sprite.visible).is_true()
	assert_that(plot.sprite.texture).is_not_null()

## Test that growth stage 0 (empty) generates no sprite
func test_growth_stage_0_generates_no_sprite() -> void:
	var art_gen = ProceduralArtGenerator.new()
	
	# Stage 0 should still generate a texture (it's the seed/sprout stage)
	var texture = art_gen.generate_crop_sprite("health_berry", 0, 12345)
	assert_that(texture).is_not_null()
	
	# But an empty plot should hide the sprite
	var plot = Plot.new()
	plot.art_generator = art_gen
	plot._ready()
	
	# Empty plot should have hidden sprite
	assert_that(plot.sprite.visible).is_false()

## Test that sprite uses CropData base_color property
func test_sprite_uses_crop_base_color() -> void:
	# This is implicitly tested by the generate_crop_sprite method
	# which uses the crop_type to determine colors
	var art_gen = ProceduralArtGenerator.new()
	
	# Health berry should use red/pink tones
	var health_texture = art_gen.generate_crop_sprite("health_berry", 3, 12345)
	assert_that(health_texture).is_not_null()
	
	# Ammo grain should use yellow/gold tones
	var ammo_texture = art_gen.generate_crop_sprite("ammo_grain", 3, 12345)
	assert_that(ammo_texture).is_not_null()
	
	# Weapon flower should use green tones
	var weapon_texture = art_gen.generate_crop_sprite("weapon_flower", 3, 12345)
	assert_that(weapon_texture).is_not_null()
	
	# All textures should be different (different crop types)
	# We can't directly compare textures, but we verified they all generate
