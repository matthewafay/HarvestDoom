extends Node

## Verification script for _create_shape_from_primitives
## This script can be run in the Godot editor to verify the shape drawing functionality

func _ready() -> void:
	print("=== _create_shape_from_primitives Verification ===")
	
	var generator = ProceduralArtGenerator.new()
	if not generator:
		print("✗ Failed to instantiate ProceduralArtGenerator")
		return
	
	print("✓ ProceduralArtGenerator instantiated successfully")
	
	# Test 1: Basic image creation
	print("\n--- Test 1: Basic Image Creation ---")
	var shape_data = {
		"width": 64,
		"height": 64,
		"shapes": []
	}
	var image = generator._create_shape_from_primitives(shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if image and image.get_width() == 64 and image.get_height() == 64:
		print("✓ Creates image with correct dimensions (64x64)")
	else:
		print("✗ Failed to create image with correct dimensions")
	
	# Test 2: Invalid input handling
	print("\n--- Test 2: Invalid Input Handling ---")
	var invalid_data = {}
	var invalid_image = generator._create_shape_from_primitives(invalid_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if invalid_image == null:
		print("✓ Returns null for invalid input (missing width/height)")
	else:
		print("✗ Should return null for invalid input")
	
	# Test 3: Filled rectangle
	print("\n--- Test 3: Filled Rectangle ---")
	var rect_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "rectangle",
				"position": Vector2(8, 8),
				"size": Vector2(16, 16),
				"color": 0,
				"filled": true
			}
		]
	}
	var rect_image = generator._create_shape_from_primitives(rect_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if rect_image:
		var center_color = rect_image.get_pixel(16, 16)
		var corner_color = rect_image.get_pixel(0, 0)
		var expected_color = ProceduralArtGenerator.FARM_PALETTE[0]
		
		if center_color == expected_color:
			print("✓ Rectangle center has correct color")
		else:
			print("✗ Rectangle center color mismatch")
		
		if corner_color.a == 0.0:
			print("✓ Outside rectangle is transparent")
		else:
			print("✗ Outside rectangle should be transparent")
	else:
		print("✗ Failed to create rectangle image")
	
	# Test 4: Unfilled rectangle (outline)
	print("\n--- Test 4: Unfilled Rectangle (Outline) ---")
	var outline_rect_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "rectangle",
				"position": Vector2(8, 8),
				"size": Vector2(16, 16),
				"color": 1,
				"filled": false
			}
		]
	}
	var outline_rect_image = generator._create_shape_from_primitives(outline_rect_data, ProceduralArtGenerator.COMBAT_PALETTE)
	
	if outline_rect_image:
		var edge_color = outline_rect_image.get_pixel(8, 8)
		var center_color = outline_rect_image.get_pixel(16, 16)
		var expected_color = ProceduralArtGenerator.COMBAT_PALETTE[1]
		
		if edge_color == expected_color:
			print("✓ Rectangle edge has correct color")
		else:
			print("✗ Rectangle edge color mismatch")
		
		if center_color.a == 0.0:
			print("✓ Rectangle center is transparent (outline only)")
		else:
			print("✗ Rectangle center should be transparent for outline")
	else:
		print("✗ Failed to create outline rectangle image")
	
	# Test 5: Filled circle
	print("\n--- Test 5: Filled Circle ---")
	var circle_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "circle",
				"position": Vector2(16, 16),
				"size": Vector2(8, 8),
				"color": 2,
				"filled": true
			}
		]
	}
	var circle_image = generator._create_shape_from_primitives(circle_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if circle_image:
		var center_color = circle_image.get_pixel(16, 16)
		var corner_color = circle_image.get_pixel(0, 0)
		var expected_color = ProceduralArtGenerator.FARM_PALETTE[2]
		
		if center_color == expected_color:
			print("✓ Circle center has correct color")
		else:
			print("✗ Circle center color mismatch")
		
		if corner_color.a == 0.0:
			print("✓ Outside circle is transparent")
		else:
			print("✗ Outside circle should be transparent")
	else:
		print("✗ Failed to create circle image")
	
	# Test 6: Unfilled circle (outline)
	print("\n--- Test 6: Unfilled Circle (Outline) ---")
	var outline_circle_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "circle",
				"position": Vector2(16, 16),
				"size": Vector2(8, 8),
				"color": 3,
				"filled": false
			}
		]
	}
	var outline_circle_image = generator._create_shape_from_primitives(outline_circle_data, ProceduralArtGenerator.COMBAT_PALETTE)
	
	if outline_circle_image:
		# Check that some pixels on the edge are colored
		var has_colored_pixels = false
		for x in range(8, 25):
			for y in range(8, 25):
				var pixel = outline_circle_image.get_pixel(x, y)
				if pixel.a > 0:
					has_colored_pixels = true
					break
			if has_colored_pixels:
				break
		
		if has_colored_pixels:
			print("✓ Circle outline has colored pixels")
		else:
			print("✗ Circle outline should have colored pixels")
	else:
		print("✗ Failed to create outline circle image")
	
	# Test 7: Filled triangle
	print("\n--- Test 7: Filled Triangle ---")
	var triangle_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "triangle",
				"points": [
					Vector2(16, 8),
					Vector2(8, 24),
					Vector2(24, 24)
				],
				"color": 0,
				"filled": true
			}
		]
	}
	var triangle_image = generator._create_shape_from_primitives(triangle_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if triangle_image:
		var center_color = triangle_image.get_pixel(16, 16)
		var corner_color = triangle_image.get_pixel(0, 0)
		var expected_color = ProceduralArtGenerator.FARM_PALETTE[0]
		
		if center_color == expected_color:
			print("✓ Triangle center has correct color")
		else:
			print("✗ Triangle center color mismatch")
		
		if corner_color.a == 0.0:
			print("✓ Outside triangle is transparent")
		else:
			print("✗ Outside triangle should be transparent")
	else:
		print("✗ Failed to create triangle image")
	
	# Test 8: Unfilled triangle (outline)
	print("\n--- Test 8: Unfilled Triangle (Outline) ---")
	var outline_triangle_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "triangle",
				"points": [
					Vector2(16, 8),
					Vector2(8, 24),
					Vector2(24, 24)
				],
				"color": 1,
				"filled": false
			}
		]
	}
	var outline_triangle_image = generator._create_shape_from_primitives(outline_triangle_data, ProceduralArtGenerator.COMBAT_PALETTE)
	
	if outline_triangle_image:
		# Check that some edge pixels are colored
		var has_colored_pixels = false
		for x in range(8, 25):
			for y in range(8, 25):
				var pixel = outline_triangle_image.get_pixel(x, y)
				if pixel.a > 0:
					has_colored_pixels = true
					break
			if has_colored_pixels:
				break
		
		if has_colored_pixels:
			print("✓ Triangle outline has colored pixels")
		else:
			print("✗ Triangle outline should have colored pixels")
	else:
		print("✗ Failed to create outline triangle image")
	
	# Test 9: Multiple shapes
	print("\n--- Test 9: Multiple Shapes ---")
	var multi_shape_data = {
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
	var multi_image = generator._create_shape_from_primitives(multi_shape_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if multi_image:
		var rect_color = multi_image.get_pixel(12, 12)
		var circle_color = multi_image.get_pixel(48, 48)
		var triangle_color = multi_image.get_pixel(32, 16)
		
		var all_correct = true
		if rect_color != ProceduralArtGenerator.FARM_PALETTE[0]:
			print("✗ Rectangle color incorrect in multi-shape")
			all_correct = false
		if circle_color != ProceduralArtGenerator.FARM_PALETTE[1]:
			print("✗ Circle color incorrect in multi-shape")
			all_correct = false
		if triangle_color != ProceduralArtGenerator.FARM_PALETTE[2]:
			print("✗ Triangle color incorrect in multi-shape")
			all_correct = false
		
		if all_correct:
			print("✓ All shapes rendered correctly in multi-shape image")
	else:
		print("✗ Failed to create multi-shape image")
	
	# Test 10: Direct color (not palette index)
	print("\n--- Test 10: Direct Color ---")
	var custom_color = Color(1.0, 0.0, 1.0, 1.0)  # Magenta
	var direct_color_data = {
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
	var direct_color_image = generator._create_shape_from_primitives(direct_color_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if direct_color_image:
		var pixel_color = direct_color_image.get_pixel(12, 12)
		if pixel_color == custom_color:
			print("✓ Direct color (non-palette) works correctly")
		else:
			print("✗ Direct color mismatch")
	else:
		print("✗ Failed to create direct color image")
	
	# Test 11: Bounds clamping
	print("\n--- Test 11: Bounds Clamping ---")
	var bounds_data = {
		"width": 32,
		"height": 32,
		"shapes": [
			{
				"type": "rectangle",
				"position": Vector2(-10, -10),
				"size": Vector2(20, 20),
				"color": 0,
				"filled": true
			}
		]
	}
	var bounds_image = generator._create_shape_from_primitives(bounds_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if bounds_image:
		var corner_color = bounds_image.get_pixel(0, 0)
		var expected_color = ProceduralArtGenerator.FARM_PALETTE[0]
		if corner_color == expected_color:
			print("✓ Shapes are clamped to image bounds correctly")
		else:
			print("✗ Bounds clamping issue")
	else:
		print("✗ Failed to create bounds test image")
	
	# Test 12: Empty shapes array
	print("\n--- Test 12: Empty Shapes Array ---")
	var empty_data = {
		"width": 16,
		"height": 16,
		"shapes": []
	}
	var empty_image = generator._create_shape_from_primitives(empty_data, ProceduralArtGenerator.FARM_PALETTE)
	
	if empty_image:
		var all_transparent = true
		for y in range(16):
			for x in range(16):
				if empty_image.get_pixel(x, y).a > 0:
					all_transparent = false
					break
			if not all_transparent:
				break
		
		if all_transparent:
			print("✓ Empty shapes array creates transparent image")
		else:
			print("✗ Empty shapes array should create transparent image")
	else:
		print("✗ Failed to create empty shapes image")
	
	# Cleanup
	generator.free()
	
	print("\n=== Verification Complete ===")
	print("Task 1.4.2: Implement _create_shape_from_primitives - READY FOR TESTING")
	print("\nNext steps:")
	print("1. Run unit tests in tests/unit/test_procedural_art_generator.gd")
	print("2. Proceed to task 1.4.3: Implement generate_tileset method")
