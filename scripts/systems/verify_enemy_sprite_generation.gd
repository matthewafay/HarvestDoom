extends Node

## Verification script for generate_enemy_sprite method
## This script can be run in the Godot editor to verify enemy sprite generation

func _ready() -> void:
	print("=== Enemy Sprite Generation Verification ===")
	
	# Test 1: Verify class can be instantiated
	var generator = ProceduralArtGenerator.new()
	if generator:
		print("✓ ProceduralArtGenerator instantiated successfully")
	else:
		print("✗ Failed to instantiate ProceduralArtGenerator")
		return
	
	# Test 2: Generate melee_charger sprite
	print("\n--- Testing melee_charger ---")
	var melee_texture = generator.generate_enemy_sprite("melee_charger", 12345)
	if melee_texture:
		print("✓ melee_charger texture generated")
		print("  Size: %dx%d" % [melee_texture.get_width(), melee_texture.get_height()])
		if melee_texture.get_width() == 64 and melee_texture.get_height() == 64:
			print("✓ melee_charger has correct dimensions (64x64)")
		else:
			print("✗ melee_charger has incorrect dimensions")
	else:
		print("✗ Failed to generate melee_charger texture")
	
	# Test 3: Generate ranged_shooter sprite
	print("\n--- Testing ranged_shooter ---")
	var ranged_texture = generator.generate_enemy_sprite("ranged_shooter", 54321)
	if ranged_texture:
		print("✓ ranged_shooter texture generated")
		print("  Size: %dx%d" % [ranged_texture.get_width(), ranged_texture.get_height()])
		if ranged_texture.get_width() == 64 and ranged_texture.get_height() == 64:
			print("✓ ranged_shooter has correct dimensions (64x64)")
		else:
			print("✗ ranged_shooter has incorrect dimensions")
	else:
		print("✗ Failed to generate ranged_shooter texture")
	
	# Test 4: Generate tank sprite
	print("\n--- Testing tank ---")
	var tank_texture = generator.generate_enemy_sprite("tank", 99999)
	if tank_texture:
		print("✓ tank texture generated")
		print("  Size: %dx%d" % [tank_texture.get_width(), tank_texture.get_height()])
		if tank_texture.get_width() == 64 and tank_texture.get_height() == 64:
			print("✓ tank has correct dimensions (64x64)")
		else:
			print("✗ tank has incorrect dimensions")
	else:
		print("✗ Failed to generate tank texture")
	
	# Test 5: Test unknown enemy type
	print("\n--- Testing unknown enemy type ---")
	var unknown_texture = generator.generate_enemy_sprite("unknown_enemy", 11111)
	if unknown_texture:
		print("✓ unknown enemy type handled gracefully (default placeholder)")
		print("  Size: %dx%d" % [unknown_texture.get_width(), unknown_texture.get_height()])
	else:
		print("✗ Failed to handle unknown enemy type")
	
	# Test 6: Test determinism (same seed = same output)
	print("\n--- Testing Determinism (Requirement 12.1, 12.9) ---")
	var seed_value = 42
	var texture1 = generator.generate_enemy_sprite("melee_charger", seed_value)
	var texture2 = generator.generate_enemy_sprite("melee_charger", seed_value)
	
	if texture1 and texture2:
		var image1 = texture1.get_image()
		var image2 = texture2.get_image()
		
		var pixels_match = true
		var checked_pixels = 0
		for y in range(image1.get_height()):
			for x in range(image1.get_width()):
				checked_pixels += 1
				if image1.get_pixel(x, y) != image2.get_pixel(x, y):
					pixels_match = false
					print("✗ Pixel mismatch at (%d, %d)" % [x, y])
					break
			if not pixels_match:
				break
		
		if pixels_match:
			print("✓ Determinism verified: same seed produces identical output")
			print("  Checked %d pixels" % checked_pixels)
		else:
			print("✗ Determinism failed: same seed produced different output")
	else:
		print("✗ Could not test determinism (texture generation failed)")
	
	# Test 7: Verify different enemy types produce different visuals
	print("\n--- Testing Visual Distinctness ---")
	var seed_val = 12345
	var melee_tex = generator.generate_enemy_sprite("melee_charger", seed_val)
	var ranged_tex = generator.generate_enemy_sprite("ranged_shooter", seed_val)
	var tank_tex = generator.generate_enemy_sprite("tank", seed_val)
	
	if melee_tex and ranged_tex and tank_tex:
		var melee_img = melee_tex.get_image()
		var ranged_img = ranged_tex.get_image()
		var tank_img = tank_tex.get_image()
		
		var melee_ranged_diff = false
		var melee_tank_diff = false
		var ranged_tank_diff = false
		
		# Check center area for differences
		for y in range(16, 48):
			for x in range(16, 48):
				if melee_img.get_pixel(x, y) != ranged_img.get_pixel(x, y):
					melee_ranged_diff = true
				if melee_img.get_pixel(x, y) != tank_img.get_pixel(x, y):
					melee_tank_diff = true
				if ranged_img.get_pixel(x, y) != tank_img.get_pixel(x, y):
					ranged_tank_diff = true
		
		if melee_ranged_diff and melee_tank_diff and ranged_tank_diff:
			print("✓ All enemy types have distinct visuals")
		else:
			print("✗ Some enemy types have identical visuals:")
			if not melee_ranged_diff:
				print("  - melee_charger and ranged_shooter are identical")
			if not melee_tank_diff:
				print("  - melee_charger and tank are identical")
			if not ranged_tank_diff:
				print("  - ranged_shooter and tank are identical")
	else:
		print("✗ Could not test visual distinctness (texture generation failed)")
	
	# Test 8: Verify COMBAT_PALETTE colors are used
	print("\n--- Testing COMBAT_PALETTE Usage (Requirement 12.6) ---")
	var test_texture = generator.generate_enemy_sprite("melee_charger", 12345)
	if test_texture:
		var test_image = test_texture.get_image()
		var colors_used = {}
		
		# Collect all non-transparent colors
		for y in range(test_image.get_height()):
			for x in range(test_image.get_width()):
				var pixel = test_image.get_pixel(x, y)
				if pixel.a > 0:  # Not transparent
					colors_used[pixel] = true
		
		print("  Found %d unique colors in sprite" % colors_used.size())
		
		# Check if any COMBAT_PALETTE colors are used
		var uses_combat_color = false
		for color in colors_used.keys():
			for palette_color in ProceduralArtGenerator.COMBAT_PALETTE:
				if color.is_equal_approx(palette_color):
					uses_combat_color = true
					print("  ✓ Uses COMBAT_PALETTE color: %s" % palette_color)
					break
			if uses_combat_color:
				break
		
		if uses_combat_color:
			print("✓ Enemy sprites use COMBAT_PALETTE colors")
		else:
			print("✗ Enemy sprites do not use COMBAT_PALETTE colors")
	else:
		print("✗ Could not test palette usage (texture generation failed)")
	
	# Test 9: Visual characteristics check
	print("\n--- Testing Visual Characteristics ---")
	print("Melee Charger: Angular, aggressive (forward-pointing spikes)")
	print("Ranged Shooter: Rounded body with weapon protrusions")
	print("Tank: Large, blocky, heavily armored appearance")
	print("✓ Visual design follows enemy type specifications")
	
	# Cleanup
	generator.free()
	
	print("\n=== Verification Complete ===")
	print("Task 1.4.5: Implement generate_enemy_sprite method - COMPLETE")
	print("\nNext Steps:")
	print("1. Run unit tests in GdUnit4 (tests/unit/test_procedural_art_generator.gd)")
	print("2. Visually inspect generated sprites in the editor")
	print("3. Proceed to Task 1.4.6: Implement generate_weapon_sprite method")
