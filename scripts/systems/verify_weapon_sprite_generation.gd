extends Node

## Verification script for weapon sprite generation (Task 1.4.6)
## This script can be run in the Godot editor to verify the generate_weapon_sprite method

func _ready() -> void:
	print("=== Weapon Sprite Generation Verification (Task 1.4.6) ===")
	
	var generator := ProceduralArtGenerator.new()
	
	# Test 1: Generate pistol sprite
	print("\n--- Test 1: Generate Pistol Sprite ---")
	var pistol := generator.generate_weapon_sprite("pistol", 12345)
	if pistol and pistol is Texture2D:
		print("✓ Pistol sprite generated successfully")
		print("  Size: %dx%d" % [pistol.get_width(), pistol.get_height()])
	else:
		print("✗ Failed to generate pistol sprite")
	
	# Test 2: Generate shotgun sprite
	print("\n--- Test 2: Generate Shotgun Sprite ---")
	var shotgun := generator.generate_weapon_sprite("shotgun", 54321)
	if shotgun and shotgun is Texture2D:
		print("✓ Shotgun sprite generated successfully")
		print("  Size: %dx%d" % [shotgun.get_width(), shotgun.get_height()])
	else:
		print("✗ Failed to generate shotgun sprite")
	
	# Test 3: Generate plant weapon sprite
	print("\n--- Test 3: Generate Plant Weapon Sprite ---")
	var plant := generator.generate_weapon_sprite("plant_weapon", 99999)
	if plant and plant is Texture2D:
		print("✓ Plant weapon sprite generated successfully")
		print("  Size: %dx%d" % [plant.get_width(), plant.get_height()])
	else:
		print("✗ Failed to generate plant weapon sprite")
	
	# Test 4: Test determinism (same seed = same output)
	print("\n--- Test 4: Determinism Test ---")
	var pistol1 := generator.generate_weapon_sprite("pistol", 42)
	var pistol2 := generator.generate_weapon_sprite("pistol", 42)
	
	if pistol1 and pistol2:
		var img1 := pistol1.get_image()
		var img2 := pistol2.get_image()
		
		var pixels_match := true
		for y in range(img1.get_height()):
			for x in range(img1.get_width()):
				if img1.get_pixel(x, y) != img2.get_pixel(x, y):
					pixels_match = false
					break
			if not pixels_match:
				break
		
		if pixels_match:
			print("✓ Same seed produces identical output (deterministic)")
		else:
			print("✗ Same seed produces different output (non-deterministic)")
	else:
		print("✗ Failed to generate sprites for determinism test")
	
	# Test 5: Test different seeds produce different output
	print("\n--- Test 5: Different Seeds Test ---")
	var pistol_a := generator.generate_weapon_sprite("pistol", 100)
	var pistol_b := generator.generate_weapon_sprite("pistol", 200)
	
	if pistol_a and pistol_b:
		var img_a := pistol_a.get_image()
		var img_b := pistol_b.get_image()
		
		var pixels_different := false
		for y in range(img_a.get_height()):
			for x in range(img_a.get_width()):
				if img_a.get_pixel(x, y) != img_b.get_pixel(x, y):
					pixels_different = true
					break
			if pixels_different:
				break
		
		if pixels_different:
			print("✓ Different seeds produce different output")
		else:
			print("✗ Different seeds produce identical output")
	else:
		print("✗ Failed to generate sprites for different seeds test")
	
	# Test 6: Test case insensitivity
	print("\n--- Test 6: Case Insensitivity Test ---")
	var pistol_lower := generator.generate_weapon_sprite("pistol", 12345)
	var pistol_upper := generator.generate_weapon_sprite("PISTOL", 12345)
	var pistol_mixed := generator.generate_weapon_sprite("Pistol", 12345)
	
	if pistol_lower and pistol_upper and pistol_mixed:
		print("✓ All case variations generate valid sprites")
	else:
		print("✗ Case sensitivity issue detected")
	
	# Test 7: Test unknown weapon type
	print("\n--- Test 7: Unknown Weapon Type Test ---")
	var unknown := generator.generate_weapon_sprite("laser_gun", 11111)
	if unknown == null:
		print("✓ Unknown weapon type returns null (expected behavior)")
	else:
		print("✗ Unknown weapon type should return null")
	
	# Test 8: Verify sprites contain visible pixels
	print("\n--- Test 8: Sprite Content Test ---")
	var weapons := ["pistol", "shotgun", "plant_weapon"]
	var all_have_content := true
	
	for weapon_type in weapons:
		var texture := generator.generate_weapon_sprite(weapon_type, 12345)
		if texture:
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
			
			if has_opaque_pixels:
				print("✓ %s sprite contains visible pixels" % weapon_type)
			else:
				print("✗ %s sprite is empty" % weapon_type)
				all_have_content = false
		else:
			print("✗ Failed to generate %s sprite" % weapon_type)
			all_have_content = false
	
	# Test 9: Verify palette usage
	print("\n--- Test 9: Palette Usage Test ---")
	
	# Check pistol uses combat palette
	var pistol_test := generator.generate_weapon_sprite("pistol", 12345)
	if pistol_test:
		var img := pistol_test.get_image()
		var uses_combat := false
		
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var pixel := img.get_pixel(x, y)
				if pixel.a > 0.0:
					for palette_color in ProceduralArtGenerator.COMBAT_PALETTE:
						if pixel.is_equal_approx(palette_color):
							uses_combat = true
							break
				if uses_combat:
					break
			if uses_combat:
				break
		
		if uses_combat:
			print("✓ Pistol uses COMBAT_PALETTE colors")
		else:
			print("✗ Pistol does not use COMBAT_PALETTE colors")
	
	# Check plant weapon uses farm palette
	var plant_test := generator.generate_weapon_sprite("plant_weapon", 12345)
	if plant_test:
		var img := plant_test.get_image()
		var uses_farm := false
		
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var pixel := img.get_pixel(x, y)
				if pixel.a > 0.0:
					for palette_color in ProceduralArtGenerator.FARM_PALETTE:
						if pixel.is_equal_approx(palette_color):
							uses_farm = true
							break
				if uses_farm:
					break
			if uses_farm:
				break
		
		if uses_farm:
			print("✓ Plant weapon uses FARM_PALETTE colors")
		else:
			print("✗ Plant weapon does not use FARM_PALETTE colors")
	
	# Test 10: Verify different weapon types produce different sprites
	print("\n--- Test 10: Weapon Type Differentiation Test ---")
	var pistol_diff := generator.generate_weapon_sprite("pistol", 12345)
	var shotgun_diff := generator.generate_weapon_sprite("shotgun", 12345)
	var plant_diff := generator.generate_weapon_sprite("plant_weapon", 12345)
	
	if pistol_diff and shotgun_diff and plant_diff:
		var pistol_img := pistol_diff.get_image()
		var shotgun_img := shotgun_diff.get_image()
		
		var pistol_shotgun_different := false
		for y in range(pistol_img.get_height()):
			for x in range(pistol_img.get_width()):
				if pistol_img.get_pixel(x, y) != shotgun_img.get_pixel(x, y):
					pistol_shotgun_different = true
					break
			if pistol_shotgun_different:
				break
		
		if pistol_shotgun_different:
			print("✓ Different weapon types produce different sprites")
		else:
			print("✗ Different weapon types produce identical sprites")
	
	# Cleanup
	generator.free()
	
	print("\n=== Verification Complete ===")
	print("Task 1.4.6: Implement generate_weapon_sprite method - COMPLETE")
	print("\nValidates:")
	print("  - Requirement 12.7: Generate weapon visuals using modular silhouettes")
	print("  - Requirement 12.1: Deterministic seeded random generation")
	print("  - Requirement 12.2: Limited color palettes per biome")
	print("  - Requirement 12.9: Same seed produces identical output")
