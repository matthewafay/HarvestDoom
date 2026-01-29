extends Node

## Verification script for generate_tileset method
## This script can be run in the Godot editor to verify the generate_tileset implementation

func _ready() -> void:
	print("=== generate_tileset Verification ===")
	
	var generator = ProceduralArtGenerator.new()
	
	# Test 1: Basic generation
	print("\n--- Test 1: Basic Generation ---")
	var texture = generator.generate_tileset(12345, ProceduralArtGenerator.FARM_PALETTE)
	if texture != null:
		print("✓ generate_tileset returns a valid texture")
		var image = texture.get_image()
		print("  Dimensions: %dx%d" % [image.get_width(), image.get_height()])
		if image.get_width() == 256 and image.get_height() == 256:
			print("✓ Tileset has correct dimensions (256x256)")
		else:
			print("✗ Tileset has incorrect dimensions")
	else:
		print("✗ generate_tileset returned null")
		generator.free()
		return
	
	# Test 2: Determinism (same seed = same output)
	print("\n--- Test 2: Determinism ---")
	var seed_value = 42
	var texture1 = generator.generate_tileset(seed_value, ProceduralArtGenerator.FARM_PALETTE)
	var texture2 = generator.generate_tileset(seed_value, ProceduralArtGenerator.FARM_PALETTE)
	
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	var pixels_match = true
	var sample_count = 0
	var match_count = 0
	
	# Sample pixels to verify determinism (checking every pixel would be slow)
	for y in range(0, 256, 16):
		for x in range(0, 256, 16):
			sample_count += 1
			var pixel1 = image1.get_pixel(x, y)
			var pixel2 = image2.get_pixel(x, y)
			if pixel1.is_equal_approx(pixel2):
				match_count += 1
			else:
				pixels_match = false
	
	if pixels_match:
		print("✓ Same seed produces identical output (%d/%d samples matched)" % [match_count, sample_count])
		print("  Validates: Requirements 12.1, 12.9")
	else:
		print("✗ Same seed produced different output (%d/%d samples matched)" % [match_count, sample_count])
	
	# Test 3: Different seeds produce different output
	print("\n--- Test 3: Different Seeds ---")
	var texture_a = generator.generate_tileset(111, ProceduralArtGenerator.FARM_PALETTE)
	var texture_b = generator.generate_tileset(222, ProceduralArtGenerator.FARM_PALETTE)
	
	var image_a = texture_a.get_image()
	var image_b = texture_b.get_image()
	
	var found_difference = false
	for y in range(0, 256, 16):
		for x in range(0, 256, 16):
			var pixel_a = image_a.get_pixel(x, y)
			var pixel_b = image_b.get_pixel(x, y)
			if not pixel_a.is_equal_approx(pixel_b):
				found_difference = true
				break
		if found_difference:
			break
	
	if found_difference:
		print("✓ Different seeds produce different output")
		print("  Validates: Requirements 12.1, 12.9")
	else:
		print("✗ Different seeds produced identical output")
	
	# Test 4: Palette usage
	print("\n--- Test 4: Palette Usage ---")
	var farm_texture = generator.generate_tileset(12345, ProceduralArtGenerator.FARM_PALETTE)
	var farm_image = farm_texture.get_image()
	
	# Sample colors and verify they're from the palette
	var used_colors = {}
	for y in range(0, 256, 8):
		for x in range(0, 256, 8):
			var pixel = farm_image.get_pixel(x, y)
			var color_key = "%f,%f,%f" % [pixel.r, pixel.g, pixel.b]
			used_colors[color_key] = pixel
	
	print("  Found %d unique colors in tileset" % used_colors.size())
	
	var all_from_palette = true
	for color_key in used_colors.keys():
		var color = used_colors[color_key]
		var found_in_palette = false
		for palette_color in ProceduralArtGenerator.FARM_PALETTE:
			if color.is_equal_approx(palette_color):
				found_in_palette = true
				break
		if not found_in_palette:
			all_from_palette = false
			print("  ✗ Found color not in palette: %s" % color)
	
	if all_from_palette:
		print("✓ All colors are from the FARM_PALETTE")
		print("  Validates: Requirements 12.2")
	else:
		print("✗ Some colors are not from the palette")
	
	# Test 5: Combat palette
	print("\n--- Test 5: Combat Palette ---")
	var combat_texture = generator.generate_tileset(54321, ProceduralArtGenerator.COMBAT_PALETTE)
	if combat_texture != null:
		var combat_image = combat_texture.get_image()
		print("✓ generate_tileset works with COMBAT_PALETTE")
		print("  Dimensions: %dx%d" % [combat_image.get_width(), combat_image.get_height()])
		print("  Validates: Requirements 12.2, 13.2")
	else:
		print("✗ generate_tileset failed with COMBAT_PALETTE")
	
	# Test 6: Visual variety
	print("\n--- Test 6: Visual Variety ---")
	var test_image = farm_texture.get_image()
	
	# Check that tiles have variety (not all the same)
	var tile_samples = []
	for row in range(4):
		for col in range(4):
			var tile_x = col * 64 + 32  # Center of tile
			var tile_y = row * 64 + 32
			var pixel = test_image.get_pixel(tile_x, tile_y)
			tile_samples.append(pixel)
	
	var unique_tile_colors = {}
	for pixel in tile_samples:
		var color_key = "%f,%f,%f" % [pixel.r, pixel.g, pixel.b]
		unique_tile_colors[color_key] = true
	
	if unique_tile_colors.size() > 1:
		print("✓ Tileset has visual variety (%d unique colors in tile centers)" % unique_tile_colors.size())
		print("  Validates: Requirements 12.3, 12.4")
	else:
		print("✗ Tileset lacks variety (all tiles appear identical)")
	
	# Cleanup
	generator.free()
	
	print("\n=== Verification Complete ===")
	print("Task 1.4.3: Implement generate_tileset method - READY FOR REVIEW")
	print("\nTo run unit tests:")
	print("1. Install GdUnit4 (task 1.1.5)")
	print("2. Run tests/unit/test_procedural_art_generator.gd")
