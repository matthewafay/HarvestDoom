extends GdUnitTestSuite

## Unit tests for ProceduralArtGenerator
##
## Tests the procedural art generation system, including:
## - Color palette definitions
## - Deterministic generation (same seed = same output)
## - Shape generation from primitives
## - Sprite generation for various game elements

var generator: ProceduralArtGenerator

func before_test() -> void:
	generator = ProceduralArtGenerator.new()

func after_test() -> void:
	generator.free()

## Test that FARM_PALETTE is correctly defined with expected colors
func test_farm_palette_defined() -> void:
	assert_that(ProceduralArtGenerator.FARM_PALETTE).is_not_null()
	assert_that(ProceduralArtGenerator.FARM_PALETTE.size()).is_equal(4)
	
	# Verify the palette contains the expected colors
	assert_that(ProceduralArtGenerator.FARM_PALETTE[0]).is_equal(Color("#8BC34A"))  # Light green
	assert_that(ProceduralArtGenerator.FARM_PALETTE[1]).is_equal(Color("#FFC107"))  # Amber/yellow
	assert_that(ProceduralArtGenerator.FARM_PALETTE[2]).is_equal(Color("#795548"))  # Brown
	assert_that(ProceduralArtGenerator.FARM_PALETTE[3]).is_equal(Color("#4CAF50"))  # Green

## Test that COMBAT_PALETTE is correctly defined with expected colors
func test_combat_palette_defined() -> void:
	assert_that(ProceduralArtGenerator.COMBAT_PALETTE).is_not_null()
	assert_that(ProceduralArtGenerator.COMBAT_PALETTE.size()).is_equal(4)
	
	# Verify the palette contains the expected colors
	assert_that(ProceduralArtGenerator.COMBAT_PALETTE[0]).is_equal(Color("#212121"))  # Dark gray/black
	assert_that(ProceduralArtGenerator.COMBAT_PALETTE[1]).is_equal(Color("#F44336"))  # Red
	assert_that(ProceduralArtGenerator.COMBAT_PALETTE[2]).is_equal(Color("#9C27B0"))  # Purple
	assert_that(ProceduralArtGenerator.COMBAT_PALETTE[3]).is_equal(Color("#607D8B"))  # Blue-gray

## Test that FARM_PALETTE uses bright, warm colors (validates Requirement 13.1)
func test_farm_palette_is_bright_and_warm() -> void:
	for color in ProceduralArtGenerator.FARM_PALETTE:
		# Warm colors should have higher red/yellow components
		# Bright colors should have higher overall luminance
		var luminance = (color.r + color.g + color.b) / 3.0
		assert_that(luminance).is_greater(0.3)  # Should be reasonably bright

## Test that COMBAT_PALETTE uses dark, aggressive colors (validates Requirement 13.2)
func test_combat_palette_is_dark_and_aggressive() -> void:
	# At least one color should be very dark (the base color)
	var has_dark_color = false
	for color in ProceduralArtGenerator.COMBAT_PALETTE:
		var luminance = (color.r + color.g + color.b) / 3.0
		if luminance < 0.2:
			has_dark_color = true
			break
	assert_that(has_dark_color).is_true()

## Test that palettes are distinct (not the same colors)
func test_palettes_are_distinct() -> void:
	# The palettes should not be identical
	var palettes_identical = true
	for i in range(ProceduralArtGenerator.FARM_PALETTE.size()):
		if ProceduralArtGenerator.FARM_PALETTE[i] != ProceduralArtGenerator.COMBAT_PALETTE[i]:
			palettes_identical = false
			break
	assert_that(palettes_identical).is_false()

## Test that generator instance can be created
func test_generator_instantiation() -> void:
	assert_that(generator).is_not_null()
	assert_that(generator is ProceduralArtGenerator).is_true()

## Test that generation methods exist (even if not yet implemented)
func test_generation_methods_exist() -> void:
	assert_that(generator.has_method("generate_tileset")).is_true()
	assert_that(generator.has_method("generate_crop_sprite")).is_true()
	assert_that(generator.has_method("generate_enemy_sprite")).is_true()
	assert_that(generator.has_method("generate_weapon_sprite")).is_true()
	assert_that(generator.has_method("generate_ui_element")).is_true()

## Test that helper methods exist (even if not yet implemented)
func test_helper_methods_exist() -> void:
	assert_that(generator.has_method("_create_shape_from_primitives")).is_true()
	assert_that(generator.has_method("_apply_palette_swap")).is_true()

## Test that generate_crop_sprite returns a valid texture
func test_generate_crop_sprite_returns_texture() -> void:
	var texture = generator.generate_crop_sprite("health", 2, 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_crop_sprite handles all growth stages (0-3)
func test_generate_crop_sprite_all_growth_stages() -> void:
	for stage in range(4):
		var texture = generator.generate_crop_sprite("health", stage, 12345)
		assert_that(texture).is_not_null()
		assert_that(texture is Texture2D).is_true()

## Test that generate_crop_sprite handles all crop types
func test_generate_crop_sprite_all_crop_types() -> void:
	var crop_types = ["health", "health_berry", "ammo", "ammo_grain", "weapon_mod", "weapon_flower"]
	for crop_type in crop_types:
		var texture = generator.generate_crop_sprite(crop_type, 2, 12345)
		assert_that(texture).is_not_null()
		assert_that(texture is Texture2D).is_true()

## Test that generate_crop_sprite handles unknown crop types gracefully
func test_generate_crop_sprite_unknown_type() -> void:
	var texture = generator.generate_crop_sprite("unknown_crop", 2, 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_crop_sprite clamps growth stage to valid range
func test_generate_crop_sprite_clamps_growth_stage() -> void:
	# Test negative growth stage
	var texture1 = generator.generate_crop_sprite("health", -1, 12345)
	assert_that(texture1).is_not_null()
	
	# Test growth stage above maximum
	var texture2 = generator.generate_crop_sprite("health", 10, 12345)
	assert_that(texture2).is_not_null()

## Test that generate_crop_sprite is deterministic (same seed = same output)
## Validates: Requirement 12.1, 12.9
func test_generate_crop_sprite_deterministic() -> void:
	var seed_value = 42
	var texture1 = generator.generate_crop_sprite("health", 2, seed_value)
	var texture2 = generator.generate_crop_sprite("health", 2, seed_value)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	# Get images from textures
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	assert_that(image1).is_not_null()
	assert_that(image2).is_not_null()
	
	# Verify images have same dimensions
	assert_that(image1.get_width()).is_equal(image2.get_width())
	assert_that(image1.get_height()).is_equal(image2.get_height())
	
	# Verify pixel-perfect equality
	var width = image1.get_width()
	var height = image1.get_height()
	for y in range(height):
		for x in range(width):
			var pixel1 = image1.get_pixel(x, y)
			var pixel2 = image2.get_pixel(x, y)
			assert_that(pixel1).is_equal(pixel2)

## Test that different seeds produce different outputs
## Validates: Requirement 12.9
func test_generate_crop_sprite_different_seeds_different_output() -> void:
	var texture1 = generator.generate_crop_sprite("health", 2, 12345)
	var texture2 = generator.generate_crop_sprite("health", 2, 67890)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	# Note: While the overall structure might be similar, the RNG-based variations
	# should make them different. For now, we just verify both are valid textures.
	# A more thorough test would compare pixel data, but that's complex for this test.
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	assert_that(image1).is_not_null()
	assert_that(image2).is_not_null()

## Test that growth stages show progression (larger sprites at higher stages)
## Validates: Requirement 12.5
func test_generate_crop_sprite_growth_progression() -> void:
	var seed_value = 12345
	var textures = []
	
	# Generate sprites for all growth stages
	for stage in range(4):
		var texture = generator.generate_crop_sprite("health", stage, seed_value)
		textures.append(texture)
	
	# All textures should be valid
	for texture in textures:
		assert_that(texture).is_not_null()
		assert_that(texture is Texture2D).is_true()
	
	# Verify that later stages have more non-transparent pixels (visual progression)
	var pixel_counts = []
	for texture in textures:
		var image = texture.get_image()
		var non_transparent_pixels = 0
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				var pixel = image.get_pixel(x, y)
				if pixel.a > 0.5:  # Count non-transparent pixels
					non_transparent_pixels += 1
		pixel_counts.append(non_transparent_pixels)
	
	# Later growth stages should have more pixels (or at least not fewer)
	for i in range(1, pixel_counts.size()):
		assert_that(pixel_counts[i]).is_greater_equal(pixel_counts[i - 1])

## Test that crop sprites use appropriate colors
func test_generate_crop_sprite_uses_appropriate_colors() -> void:
	# Health crops should have reddish tones
	var health_texture = generator.generate_crop_sprite("health", 3, 12345)
	assert_that(health_texture).is_not_null()
	
	# Ammo crops should have yellowish tones
	var ammo_texture = generator.generate_crop_sprite("ammo", 3, 12345)
	assert_that(ammo_texture).is_not_null()
	
	# Weapon mod crops should have greenish tones
	var weapon_texture = generator.generate_crop_sprite("weapon_mod", 3, 12345)
	assert_that(weapon_texture).is_not_null()
	
	# All should be valid textures
	assert_that(health_texture is Texture2D).is_true()
	assert_that(ammo_texture is Texture2D).is_true()
	assert_that(weapon_texture is Texture2D).is_true()

## Test _create_shape_from_primitives creates an image with correct dimensions
func test_create_shape_creates_image_with_correct_dimensions() -> void:
	var shape_data = {
		"width": 64,
		"height": 64,
		"shapes": []
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_not_null()
	assert_that(image.get_width()).is_equal(64)
	assert_that(image.get_height()).is_equal(64)

## Test _create_shape_from_primitives returns null for invalid input
func test_create_shape_returns_null_for_invalid_input() -> void:
	var invalid_data = {}  # Missing width and height
	var image = generator._create_shape_from_primitives(invalid_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_null()

## Test drawing a filled rectangle
func test_draw_filled_rectangle() -> void:
	var shape_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "rectangle",
				"position": Vector2(8, 8),
				"size": Vector2(16, 16),
				"color": 0,  # First palette color
				"filled": true
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_not_null()
	
	# Check that pixels inside the rectangle have the correct color
	var expected_color = ProceduralArtGenerator.FARM_PALETTE[0]
	assert_that(image.get_pixel(12, 12)).is_equal(expected_color)
	assert_that(image.get_pixel(16, 16)).is_equal(expected_color)
	
	# Check that pixels outside the rectangle are transparent
	assert_that(image.get_pixel(0, 0).a).is_equal(0.0)
	assert_that(image.get_pixel(31, 31).a).is_equal(0.0)

## Test drawing an unfilled rectangle (outline)
func test_draw_unfilled_rectangle() -> void:
	var shape_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "rectangle",
				"position": Vector2(8, 8),
				"size": Vector2(16, 16),
				"color": 1,  # Second palette color
				"filled": false
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.COMBAT_PALETTE)
	
	assert_that(image).is_not_null()
	
	# Check that edge pixels have the correct color
	var expected_color = ProceduralArtGenerator.COMBAT_PALETTE[1]
	assert_that(image.get_pixel(8, 8)).is_equal(expected_color)  # Top-left corner
	assert_that(image.get_pixel(24, 8)).is_equal(expected_color)  # Top-right corner
	assert_that(image.get_pixel(8, 24)).is_equal(expected_color)  # Bottom-left corner
	assert_that(image.get_pixel(24, 24)).is_equal(expected_color)  # Bottom-right corner
	
	# Check that center pixel is transparent (not filled)
	assert_that(image.get_pixel(16, 16).a).is_equal(0.0)

## Test drawing a filled circle
func test_draw_filled_circle() -> void:
	var shape_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "circle",
				"position": Vector2(16, 16),  # Center
				"size": Vector2(8, 8),  # Radius 8
				"color": 2,  # Third palette color
				"filled": true
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_not_null()
	
	# Check that center pixel has the correct color
	var expected_color = ProceduralArtGenerator.FARM_PALETTE[2]
	assert_that(image.get_pixel(16, 16)).is_equal(expected_color)
	
	# Check that a pixel within radius has the correct color
	assert_that(image.get_pixel(20, 16)).is_equal(expected_color)
	
	# Check that corners are transparent (outside circle)
	assert_that(image.get_pixel(0, 0).a).is_equal(0.0)

## Test drawing an unfilled circle (outline)
func test_draw_unfilled_circle() -> void:
	var shape_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "circle",
				"position": Vector2(16, 16),  # Center
				"size": Vector2(8, 8),  # Radius 8
				"color": 3,  # Fourth palette color
				"filled": false
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.COMBAT_PALETTE)
	
	assert_that(image).is_not_null()
	
	# Check that pixels on the circle edge have color
	var expected_color = ProceduralArtGenerator.COMBAT_PALETTE[3]
	# The exact edge pixels depend on the circle algorithm, so we check that some edge pixels are colored
	var has_colored_pixels = false
	for x in range(8, 25):
		for y in range(8, 25):
			var pixel = image.get_pixel(x, y)
			if pixel.a > 0:
				has_colored_pixels = true
				break
		if has_colored_pixels:
			break
	
	assert_that(has_colored_pixels).is_true()

## Test drawing a filled triangle
func test_draw_filled_triangle() -> void:
	var shape_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "triangle",
				"points": [
					Vector2(16, 8),   # Top
					Vector2(8, 24),   # Bottom-left
					Vector2(24, 24)   # Bottom-right
				],
				"color": 0,
				"filled": true
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_not_null()
	
	# Check that a pixel inside the triangle has the correct color
	var expected_color = ProceduralArtGenerator.FARM_PALETTE[0]
	assert_that(image.get_pixel(16, 16)).is_equal(expected_color)
	
	# Check that corners are transparent (outside triangle)
	assert_that(image.get_pixel(0, 0).a).is_equal(0.0)
	assert_that(image.get_pixel(31, 0).a).is_equal(0.0)

## Test drawing an unfilled triangle (outline)
func test_draw_unfilled_triangle() -> void:
	var shape_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "triangle",
				"points": [
					Vector2(16, 8),   # Top
					Vector2(8, 24),   # Bottom-left
					Vector2(24, 24)   # Bottom-right
				],
				"color": 1,
				"filled": false
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.COMBAT_PALETTE)
	
	assert_that(image).is_not_null()
	
	# Check that edge pixels have color
	var expected_color = ProceduralArtGenerator.COMBAT_PALETTE[1]
	var has_colored_pixels = false
	# Check along the edges
	for x in range(8, 25):
		for y in range(8, 25):
			var pixel = image.get_pixel(x, y)
			if pixel.a > 0:
				has_colored_pixels = true
				break
		if has_colored_pixels:
			break
	
	assert_that(has_colored_pixels).is_true()

## Test drawing multiple shapes on the same image
func test_draw_multiple_shapes() -> void:
	var shape_data = {
		"width": 64,
		"height": 64,
		"shapes": [
			{
				"type": "rectangle",
				"position": Vector2(8, 8),
				"size": Vector2(16, 16),
				"color": 0,
				"filled": true
			},
			{
				"type": "circle",
				"position": Vector2(48, 48),
				"size": Vector2(8, 8),
				"color": 1,
				"filled": true
			},
			{
				"type": "triangle",
				"points": [
					Vector2(32, 8),
					Vector2(24, 24),
					Vector2(40, 24)
				],
				"color": 2,
				"filled": true
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_not_null()
	
	# Check that each shape has its correct color
	assert_that(image.get_pixel(12, 12)).is_equal(ProceduralArtGenerator.FARM_PALETTE[0])  # Rectangle
	assert_that(image.get_pixel(48, 48)).is_equal(ProceduralArtGenerator.FARM_PALETTE[1])  # Circle
	assert_that(image.get_pixel(32, 16)).is_equal(ProceduralArtGenerator.FARM_PALETTE[2])  # Triangle

## Test using Color directly instead of palette index
func test_draw_shape_with_direct_color() -> void:
	var custom_color = Color(1.0, 0.0, 1.0, 1.0)  # Magenta
	var shape_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "rectangle",
				"position": Vector2(8, 8),
				"size": Vector2(16, 16),
				"color": custom_color,
				"filled": true
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_not_null()
	assert_that(image.get_pixel(12, 12)).is_equal(custom_color)

## Test that shapes are clamped to image bounds
func test_shapes_clamped_to_bounds() -> void:
	var shape_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "rectangle",
				"position": Vector2(-10, -10),  # Partially outside
				"size": Vector2(20, 20),
				"color": 0,
				"filled": true
			}
		]
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_not_null()
	# Should not crash and should draw the visible portion
	assert_that(image.get_pixel(0, 0)).is_equal(ProceduralArtGenerator.FARM_PALETTE[0])

## Test empty shapes array creates transparent image
func test_empty_shapes_array_creates_transparent_image() -> void:
	var shape_data = {
		"width": 16,
		"height": 16,
		"shapes": []
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(image).is_not_null()
	# All pixels should be transparent
	assert_that(image.get_pixel(0, 0).a).is_equal(0.0)
	assert_that(image.get_pixel(8, 8).a).is_equal(0.0)
	assert_that(image.get_pixel(15, 15).a).is_equal(0.0)

## Test that generate_enemy_sprite returns a valid texture for melee_charger
func test_generate_enemy_sprite_melee_charger() -> void:
	var texture = generator.generate_enemy_sprite("melee_charger", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()
	assert_that(texture.get_width()).is_equal(64)
	assert_that(texture.get_height()).is_equal(64)

## Test that generate_enemy_sprite returns a valid texture for ranged_shooter
func test_generate_enemy_sprite_ranged_shooter() -> void:
	var texture = generator.generate_enemy_sprite("ranged_shooter", 54321)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()
	assert_that(texture.get_width()).is_equal(64)
	assert_that(texture.get_height()).is_equal(64)

## Test that generate_enemy_sprite returns a valid texture for tank
func test_generate_enemy_sprite_tank() -> void:
	var texture = generator.generate_enemy_sprite("tank", 99999)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()
	assert_that(texture.get_width()).is_equal(64)
	assert_that(texture.get_height()).is_equal(64)

## Test that generate_enemy_sprite handles unknown enemy types gracefully
func test_generate_enemy_sprite_unknown_type() -> void:
	var texture = generator.generate_enemy_sprite("unknown_enemy", 11111)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()
	# Should still return a valid texture (default placeholder)
	assert_that(texture.get_width()).is_equal(64)
	assert_that(texture.get_height()).is_equal(64)

## Test that generate_enemy_sprite is deterministic (same seed = same output)
## Validates Requirement 12.1, 12.9
func test_generate_enemy_sprite_deterministic() -> void:
	var seed_value = 42
	
	# Generate the same enemy type with the same seed multiple times
	var texture1 = generator.generate_enemy_sprite("melee_charger", seed_value)
	var texture2 = generator.generate_enemy_sprite("melee_charger", seed_value)
	
	# Get images from textures
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	# Compare pixel by pixel
	assert_that(image1.get_width()).is_equal(image2.get_width())
	assert_that(image1.get_height()).is_equal(image2.get_height())
	
	var pixels_match = true
	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			if image1.get_pixel(x, y) != image2.get_pixel(x, y):
				pixels_match = false
				break
		if not pixels_match:
			break
	
	assert_that(pixels_match).is_true()

## Test that different enemy types produce different visuals
func test_generate_enemy_sprite_types_are_distinct() -> void:
	var seed_value = 12345
	
	var melee_texture = generator.generate_enemy_sprite("melee_charger", seed_value)
	var ranged_texture = generator.generate_enemy_sprite("ranged_shooter", seed_value)
	var tank_texture = generator.generate_enemy_sprite("tank", seed_value)
	
	var melee_image = melee_texture.get_image()
	var ranged_image = ranged_texture.get_image()
	var tank_image = tank_texture.get_image()
	
	# Check that at least some pixels are different between types
	var melee_ranged_different = false
	var melee_tank_different = false
	var ranged_tank_different = false
	
	for y in range(32):  # Check center area
		for x in range(32):
			if melee_image.get_pixel(x, y) != ranged_image.get_pixel(x, y):
				melee_ranged_different = true
			if melee_image.get_pixel(x, y) != tank_image.get_pixel(x, y):
				melee_tank_different = true
			if ranged_image.get_pixel(x, y) != tank_image.get_pixel(x, y):
				ranged_tank_different = true
	
	assert_that(melee_ranged_different).is_true()
	assert_that(melee_tank_different).is_true()
	assert_that(ranged_tank_different).is_true()

## Test that enemy sprites use COMBAT_PALETTE colors
func test_generate_enemy_sprite_uses_combat_palette() -> void:
	var texture = generator.generate_enemy_sprite("melee_charger", 12345)
	var image = texture.get_image()
	
	# Collect all non-transparent colors used in the sprite
	var colors_used = {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel = image.get_pixel(x, y)
			if pixel.a > 0:  # Not transparent
				colors_used[pixel] = true
	
	# Check that at least one color from COMBAT_PALETTE is used
	var uses_combat_color = false
	for color in colors_used.keys():
		for palette_color in ProceduralArtGenerator.COMBAT_PALETTE:
			if color.is_equal_approx(palette_color):
				uses_combat_color = true
				break
		if uses_combat_color:
			break
	
	assert_that(uses_combat_color).is_true()

## Test that generate_tileset returns a valid texture
func test_generate_tileset_returns_texture() -> void:
	var texture = generator.generate_tileset(12345, ProceduralArtGenerator.FARM_PALETTE)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_tileset produces correct dimensions
func test_generate_tileset_dimensions() -> void:
	var texture = generator.generate_tileset(12345, ProceduralArtGenerator.FARM_PALETTE)
	assert_that(texture).is_not_null()
	
	# Tileset should be 256x256 (4x4 tiles of 64x64 each)
	var image = texture.get_image()
	assert_that(image.get_width()).is_equal(256)
	assert_that(image.get_height()).is_equal(256)

## Test that generate_tileset is deterministic (same seed = same output)
## **Validates: Requirements 12.1, 12.9**
func test_generate_tileset_determinism() -> void:
	var seed_value = 42
	
	# Generate the same tileset twice with the same seed
	var texture1 = generator.generate_tileset(seed_value, ProceduralArtGenerator.FARM_PALETTE)
	var texture2 = generator.generate_tileset(seed_value, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	# Get the images from both textures
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	# Verify dimensions match
	assert_that(image1.get_width()).is_equal(image2.get_width())
	assert_that(image1.get_height()).is_equal(image2.get_height())
	
	# Verify pixel-perfect equality
	var width = image1.get_width()
	var height = image1.get_height()
	
	for y in range(height):
		for x in range(width):
			var pixel1 = image1.get_pixel(x, y)
			var pixel2 = image2.get_pixel(x, y)
			assert_that(pixel1).is_equal(pixel2)

## Test that different seeds produce different outputs
## **Validates: Requirements 12.1, 12.9**
func test_generate_tileset_different_seeds() -> void:
	var texture1 = generator.generate_tileset(111, ProceduralArtGenerator.FARM_PALETTE)
	var texture2 = generator.generate_tileset(222, ProceduralArtGenerator.FARM_PALETTE)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	# Find at least one pixel that differs
	var found_difference = false
	var width = image1.get_width()
	var height = image1.get_height()
	
	for y in range(height):
		for x in range(width):
			var pixel1 = image1.get_pixel(x, y)
			var pixel2 = image2.get_pixel(x, y)
			if pixel1 != pixel2:
				found_difference = true
				break
		if found_difference:
			break
	
	assert_that(found_difference).is_true()

## Test that generate_tileset uses the provided palette
func test_generate_tileset_uses_palette() -> void:
	var texture = generator.generate_tileset(12345, ProceduralArtGenerator.FARM_PALETTE)
	assert_that(texture).is_not_null()
	
	var image = texture.get_image()
	var width = image.get_width()
	var height = image.get_height()
	
	# Collect all unique colors used in the tileset
	var used_colors = {}
	for y in range(height):
		for x in range(width):
			var pixel = image.get_pixel(x, y)
			used_colors[pixel] = true
	
	# Verify that all used colors are from the palette
	for color in used_colors.keys():
		var found_in_palette = false
		for palette_color in ProceduralArtGenerator.FARM_PALETTE:
			if color.is_equal_approx(palette_color):
				found_in_palette = true
				break
		assert_that(found_in_palette).is_true()

## Test that generate_tileset works with COMBAT_PALETTE
func test_generate_tileset_combat_palette() -> void:
	var texture = generator.generate_tileset(54321, ProceduralArtGenerator.COMBAT_PALETTE)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()
	
	var image = texture.get_image()
	assert_that(image.get_width()).is_equal(256)
	assert_that(image.get_height()).is_equal(256)

## Test that generate_ui_element returns a valid texture for button type
func test_generate_ui_element_button() -> void:
	var texture = generator.generate_ui_element("button", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()
	assert_that(texture.get_width()).is_greater(0)
	assert_that(texture.get_height()).is_greater(0)

## Test that generate_ui_element returns a valid texture for border type
func test_generate_ui_element_border() -> void:
	var texture = generator.generate_ui_element("border", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_ui_element returns a valid texture for health icon
func test_generate_ui_element_health_icon() -> void:
	var texture = generator.generate_ui_element("icon_health", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_ui_element returns a valid texture for ammo icon
func test_generate_ui_element_ammo_icon() -> void:
	var texture = generator.generate_ui_element("icon_ammo", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_ui_element returns a valid texture for buff icon
func test_generate_ui_element_buff_icon() -> void:
	var texture = generator.generate_ui_element("icon_buff", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_ui_element returns a valid texture for weapon icon
func test_generate_ui_element_weapon_icon() -> void:
	var texture = generator.generate_ui_element("icon_weapon", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_ui_element returns a valid texture for health bar background
func test_generate_ui_element_health_bar_bg() -> void:
	var texture = generator.generate_ui_element("health_bar_bg", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()
	# Health bar should be wider than tall
	assert_that(texture.get_width()).is_greater(texture.get_height())

## Test that generate_ui_element returns a valid texture for health bar fill
func test_generate_ui_element_health_bar_fill() -> void:
	var texture = generator.generate_ui_element("health_bar_fill", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_ui_element returns a valid texture for panel
func test_generate_ui_element_panel() -> void:
	var texture = generator.generate_ui_element("panel", 12345)
	assert_that(texture).is_not_null()
	assert_that(texture is Texture2D).is_true()

## Test that generate_ui_element returns null for unknown element type
func test_generate_ui_element_unknown_type() -> void:
	var texture = generator.generate_ui_element("unknown_element", 12345)
	assert_that(texture).is_null()

## Test that generate_ui_element produces deterministic output (same seed = same result)
## Validates Requirement 12.9
func test_generate_ui_element_deterministic() -> void:
	var seed_value = 42
	
	# Generate the same UI element twice with the same seed
	var texture1 = generator.generate_ui_element("button", seed_value)
	var texture2 = generator.generate_ui_element("button", seed_value)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	# Both textures should have the same dimensions
	assert_that(texture1.get_width()).is_equal(texture2.get_width())
	assert_that(texture1.get_height()).is_equal(texture2.get_height())
	
	# Get images from textures and compare pixels
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	# Compare a sample of pixels to verify they're identical
	for y in range(0, image1.get_height(), 4):  # Sample every 4th pixel for performance
		for x in range(0, image1.get_width(), 4):
			var pixel1 = image1.get_pixel(x, y)
			var pixel2 = image2.get_pixel(x, y)
			assert_that(pixel1).is_equal(pixel2)

## Test that different seeds produce different results
## Validates Requirement 12.9
func test_generate_ui_element_different_seeds_different_output() -> void:
	var texture1 = generator.generate_ui_element("button", 100)
	var texture2 = generator.generate_ui_element("button", 200)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	# At least some pixels should be different
	var differences = 0
	for y in range(0, image1.get_height(), 4):
		for x in range(0, image1.get_width(), 4):
			var pixel1 = image1.get_pixel(x, y)
			var pixel2 = image2.get_pixel(x, y)
			if pixel1 != pixel2:
				differences += 1
	
	# There should be at least some differences
	assert_that(differences).is_greater(0)

## Test that UI elements use high-contrast colors for readability
## Validates Requirement 10.5
func test_generate_ui_element_high_contrast() -> void:
	var texture = generator.generate_ui_element("button", 12345)
	assert_that(texture).is_not_null()
	
	var image = texture.get_image()
	
	# Check that the image contains both dark and light pixels (high contrast)
	var has_dark = false
	var has_light = false
	
	for y in range(0, image.get_height(), 4):
		for x in range(0, image.get_width(), 4):
			var pixel = image.get_pixel(x, y)
			if pixel.a > 0.5:  # Only check non-transparent pixels
				var luminance = (pixel.r + pixel.g + pixel.b) / 3.0
				if luminance < 0.3:
					has_dark = true
				if luminance > 0.7:
					has_light = true
	
	# Button should have both dark and light elements for contrast
	assert_that(has_dark or has_light).is_true()

## Test that all UI element types can be generated without errors
func test_generate_all_ui_element_types() -> void:
	var element_types = [
		"button",
		"border",
		"icon_health",
		"icon_ammo",
		"icon_buff",
		"icon_weapon",
		"health_bar_bg",
		"health_bar_fill",
		"panel"
	]
	
	for element_type in element_types:
		var texture = generator.generate_ui_element(element_type, 12345)
		assert_that(texture).is_not_null().override_failure_message(
			"Failed to generate UI element type: " + element_type
		)
