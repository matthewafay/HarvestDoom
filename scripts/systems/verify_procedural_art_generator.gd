extends Node

## Verification script for ProceduralArtGenerator.generate_ui_element
##
## This script tests the generate_ui_element method by generating all UI element types
## and verifying they produce valid textures.

func _ready() -> void:
	print("=== ProceduralArtGenerator UI Element Verification ===")
	print("")
	
	var generator = ProceduralArtGenerator.new()
	var all_passed = true
	
	# Test all UI element types
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
	
	print("Testing UI element generation...")
	for element_type in element_types:
		var texture = generator.generate_ui_element(element_type, 12345)
		if texture == null:
			print("  ❌ FAILED: %s - returned null" % element_type)
			all_passed = false
		elif not (texture is Texture2D):
			print("  ❌ FAILED: %s - not a Texture2D" % element_type)
			all_passed = false
		elif texture.get_width() <= 0 or texture.get_height() <= 0:
			print("  ❌ FAILED: %s - invalid dimensions (%dx%d)" % [element_type, texture.get_width(), texture.get_height()])
			all_passed = false
		else:
			print("  ✅ PASSED: %s (%dx%d)" % [element_type, texture.get_width(), texture.get_height()])
	
	print("")
	
	# Test determinism (same seed = same output)
	print("Testing determinism (same seed = same output)...")
	var texture1 = generator.generate_ui_element("button", 42)
	var texture2 = generator.generate_ui_element("button", 42)
	
	if texture1 == null or texture2 == null:
		print("  ❌ FAILED: Textures are null")
		all_passed = false
	elif texture1.get_width() != texture2.get_width() or texture1.get_height() != texture2.get_height():
		print("  ❌ FAILED: Dimensions don't match")
		all_passed = false
	else:
		var image1 = texture1.get_image()
		var image2 = texture2.get_image()
		var pixels_match = true
		
		# Sample pixels to verify they're identical
		for y in range(0, image1.get_height(), 4):
			for x in range(0, image1.get_width(), 4):
				if image1.get_pixel(x, y) != image2.get_pixel(x, y):
					pixels_match = false
					break
			if not pixels_match:
				break
		
		if pixels_match:
			print("  ✅ PASSED: Same seed produces identical output")
		else:
			print("  ❌ FAILED: Same seed produces different output")
			all_passed = false
	
	print("")
	
	# Test that different seeds produce different output
	print("Testing different seeds produce different output...")
	var texture_a = generator.generate_ui_element("button", 100)
	var texture_b = generator.generate_ui_element("button", 200)
	
	if texture_a == null or texture_b == null:
		print("  ❌ FAILED: Textures are null")
		all_passed = false
	else:
		var image_a = texture_a.get_image()
		var image_b = texture_b.get_image()
		var differences = 0
		
		# Count pixel differences
		for y in range(0, image_a.get_height(), 4):
			for x in range(0, image_a.get_width(), 4):
				if image_a.get_pixel(x, y) != image_b.get_pixel(x, y):
					differences += 1
		
		if differences > 0:
			print("  ✅ PASSED: Different seeds produce different output (%d differences)" % differences)
		else:
			print("  ❌ FAILED: Different seeds produce identical output")
			all_passed = false
	
	print("")
	
	# Test unknown element type
	print("Testing unknown element type...")
	var unknown_texture = generator.generate_ui_element("unknown_element", 12345)
	if unknown_texture == null:
		print("  ✅ PASSED: Unknown element type returns null")
	else:
		print("  ❌ FAILED: Unknown element type should return null")
		all_passed = false
	
	print("")
	print("=== Verification Complete ===")
	if all_passed:
		print("✅ ALL TESTS PASSED")
	else:
		print("❌ SOME TESTS FAILED")
	
	generator.free()
	
	# Exit after verification
	get_tree().quit()
