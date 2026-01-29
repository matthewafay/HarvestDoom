extends GdUnitTestSuite

## Unit tests for ProceduralArtGenerator weapon sprite generation
## Tests task 1.4.6: Implement generate_weapon_sprite method

var generator: ProceduralArtGenerator

func before_test() -> void:
	generator = ProceduralArtGenerator.new()

func after_test() -> void:
	generator.free()

## Test that generate_weapon_sprite returns a valid texture for pistol
func test_generate_pistol_sprite() -> void:
	var texture := generator.generate_weapon_sprite("pistol", 12345)
	
	assert_that(texture).is_not_null()
	assert_that(texture).is_instanceof(Texture2D)
	assert_that(texture.get_width()).is_equal(64)
	assert_that(texture.get_height()).is_equal(64)

## Test that generate_weapon_sprite returns a valid texture for shotgun
func test_generate_shotgun_sprite() -> void:
	var texture := generator.generate_weapon_sprite("shotgun", 54321)
	
	assert_that(texture).is_not_null()
	assert_that(texture).is_instanceof(Texture2D)
	assert_that(texture.get_width()).is_equal(64)
	assert_that(texture.get_height()).is_equal(64)

## Test that generate_weapon_sprite returns a valid texture for plant_weapon
func test_generate_plant_weapon_sprite() -> void:
	var texture := generator.generate_weapon_sprite("plant_weapon", 99999)
	
	assert_that(texture).is_not_null()
	assert_that(texture).is_instanceof(Texture2D)
	assert_that(texture.get_width()).is_equal(64)
	assert_that(texture.get_height()).is_equal(64)

## Test that generate_weapon_sprite handles unknown weapon types
func test_generate_unknown_weapon_type() -> void:
	var texture := generator.generate_weapon_sprite("laser_gun", 11111)
	
	assert_that(texture).is_null()

## Test that generate_weapon_sprite is case-insensitive
func test_weapon_type_case_insensitive() -> void:
	var texture1 := generator.generate_weapon_sprite("PISTOL", 12345)
	var texture2 := generator.generate_weapon_sprite("Pistol", 12345)
	var texture3 := generator.generate_weapon_sprite("pistol", 12345)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	assert_that(texture3).is_not_null()

## Test determinism: same seed produces same output
func test_weapon_sprite_determinism() -> void:
	var texture1 := generator.generate_weapon_sprite("pistol", 42)
	var texture2 := generator.generate_weapon_sprite("pistol", 42)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	# Get images from textures
	var image1 := texture1.get_image()
	var image2 := texture2.get_image()
	
	# Compare pixel by pixel
	assert_that(image1.get_width()).is_equal(image2.get_width())
	assert_that(image1.get_height()).is_equal(image2.get_height())
	
	var pixels_match := true
	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			if image1.get_pixel(x, y) != image2.get_pixel(x, y):
				pixels_match = false
				break
		if not pixels_match:
			break
	
	assert_that(pixels_match).is_true()

## Test that different seeds produce different outputs
func test_weapon_sprite_different_seeds() -> void:
	var texture1 := generator.generate_weapon_sprite("pistol", 100)
	var texture2 := generator.generate_weapon_sprite("pistol", 200)
	
	assert_that(texture1).is_not_null()
	assert_that(texture2).is_not_null()
	
	var image1 := texture1.get_image()
	var image2 := texture2.get_image()
	
	# Check that at least some pixels are different
	var pixels_different := false
	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			if image1.get_pixel(x, y) != image2.get_pixel(x, y):
				pixels_different = true
				break
		if pixels_different:
			break
	
	assert_that(pixels_different).is_true()

## Test that different weapon types produce different outputs
func test_different_weapon_types() -> void:
	var pistol := generator.generate_weapon_sprite("pistol", 12345)
	var shotgun := generator.generate_weapon_sprite("shotgun", 12345)
	var plant := generator.generate_weapon_sprite("plant_weapon", 12345)
	
	assert_that(pistol).is_not_null()
	assert_that(shotgun).is_not_null()
	assert_that(plant).is_not_null()
	
	# All should be different from each other
	var pistol_img := pistol.get_image()
	var shotgun_img := shotgun.get_image()
	var plant_img := plant.get_image()
	
	# Compare pistol vs shotgun
	var pistol_shotgun_different := false
	for y in range(pistol_img.get_height()):
		for x in range(pistol_img.get_width()):
			if pistol_img.get_pixel(x, y) != shotgun_img.get_pixel(x, y):
				pistol_shotgun_different = true
				break
		if pistol_shotgun_different:
			break
	
	assert_that(pistol_shotgun_different).is_true()
	
	# Compare pistol vs plant
	var pistol_plant_different := false
	for y in range(pistol_img.get_height()):
		for x in range(pistol_img.get_width()):
			if pistol_img.get_pixel(x, y) != plant_img.get_pixel(x, y):
				pistol_plant_different = true
				break
		if pistol_plant_different:
			break
	
	assert_that(pistol_plant_different).is_true()

## Test that weapon sprites contain non-transparent pixels
func test_weapon_sprites_not_empty() -> void:
	var weapons := ["pistol", "shotgun", "plant_weapon"]
	
	for weapon_type in weapons:
		var texture := generator.generate_weapon_sprite(weapon_type, 12345)
		assert_that(texture).is_not_null()
		
		var image := texture.get_image()
		var has_opaque_pixels := false
		
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				var pixel := image.get_pixel(x, y)
				if pixel.a > 0.0:
					has_opaque_pixels = true
					break
			if has_opaque_pixels:
				break
		
		assert_that(has_opaque_pixels).is_true()

## Test that pistol and shotgun use combat palette
func test_combat_weapons_use_combat_palette() -> void:
	var pistol := generator.generate_weapon_sprite("pistol", 12345)
	var shotgun := generator.generate_weapon_sprite("shotgun", 12345)
	
	# Check that colors used are from combat palette
	for weapon_texture in [pistol, shotgun]:
		var image := weapon_texture.get_image()
		var uses_combat_colors := false
		
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				var pixel := image.get_pixel(x, y)
				if pixel.a > 0.0:  # Non-transparent pixel
					# Check if this color is in combat palette
					for palette_color in ProceduralArtGenerator.COMBAT_PALETTE:
						if pixel.is_equal_approx(palette_color):
							uses_combat_colors = true
							break
				if uses_combat_colors:
					break
			if uses_combat_colors:
				break
		
		assert_that(uses_combat_colors).is_true()

## Test that plant weapon uses farm palette
func test_plant_weapon_uses_farm_palette() -> void:
	var plant := generator.generate_weapon_sprite("plant_weapon", 12345)
	var image := plant.get_image()
	
	var uses_farm_colors := false
	
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a > 0.0:  # Non-transparent pixel
				# Check if this color is in farm palette
				for palette_color in ProceduralArtGenerator.FARM_PALETTE:
					if pixel.is_equal_approx(palette_color):
						uses_farm_colors = true
						break
			if uses_farm_colors:
				break
		if uses_farm_colors:
			break
	
	assert_that(uses_farm_colors).is_true()

## Test multiple generations with different seeds
func test_multiple_generations() -> void:
	var seeds := [1, 100, 1000, 10000, 99999]
	var weapon_types := ["pistol", "shotgun", "plant_weapon"]
	
	for weapon_type in weapon_types:
		for seed_value in seeds:
			var texture := generator.generate_weapon_sprite(weapon_type, seed_value)
			assert_that(texture).is_not_null()
			assert_that(texture.get_width()).is_equal(64)
			assert_that(texture.get_height()).is_equal(64)
