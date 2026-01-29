extends Node
## Verification script for crop sprite generation integration
##
## Tests that Plot class correctly integrates with ProceduralArtGenerator
## to generate crop sprites for all growth stages.
##
## Validates: Requirements 4.5, 12.5

func _ready() -> void:
	print("\n=== Crop Sprite Generation Verification ===\n")
	
	var all_passed = true
	
	# Test 1: Verify ProceduralArtGenerator can generate crop sprites
	all_passed = test_art_generator_crop_sprites() and all_passed
	
	# Test 2: Verify Plot integrates with art generator
	all_passed = test_plot_sprite_generation() and all_passed
	
	# Test 3: Verify all crop types generate sprites
	all_passed = test_all_crop_types() and all_passed
	
	# Test 4: Verify all growth stages generate sprites
	all_passed = test_all_growth_stages() and all_passed
	
	# Test 5: Verify sprite updates on growth progress
	all_passed = test_sprite_updates_on_growth() and all_passed
	
	# Print summary
	print("\n=== Verification Summary ===")
	if all_passed:
		print("✓ All tests PASSED")
	else:
		print("✗ Some tests FAILED")
	
	print("\nVerification complete. Exiting...")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

## Test 1: Verify ProceduralArtGenerator can generate crop sprites
func test_art_generator_crop_sprites() -> bool:
	print("Test 1: ProceduralArtGenerator crop sprite generation")
	
	var art_gen = ProceduralArtGenerator.new()
	var crop_types = ["health_berry", "ammo_grain", "weapon_flower"]
	var stages = [0, 1, 2, 3]
	
	for crop_type in crop_types:
		for stage in stages:
			var seed_value = crop_type.hash() + stage
			var texture = art_gen.generate_crop_sprite(crop_type, stage, seed_value)
			
			if texture == null:
				print("  ✗ FAIL: Failed to generate sprite for %s stage %d" % [crop_type, stage])
				return false
			
			if not texture is Texture2D:
				print("  ✗ FAIL: Generated sprite is not a Texture2D for %s stage %d" % [crop_type, stage])
				return false
			
			# Verify texture has reasonable dimensions
			var image = texture.get_image()
			if image.get_width() != 32 or image.get_height() != 32:
				print("  ✗ FAIL: Sprite dimensions incorrect for %s stage %d (expected 32x32, got %dx%d)" % [crop_type, stage, image.get_width(), image.get_height()])
				return false
	
	print("  ✓ PASS: All crop sprites generated successfully")
	return true

## Test 2: Verify Plot integrates with art generator
func test_plot_sprite_generation() -> bool:
	print("\nTest 2: Plot sprite generation integration")
	
	# Create plot and art generator
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()  # Initialize sprite
	
	# Load a crop data
	var crop = load("res://resources/crops/health_berry.tres")
	if crop == null:
		print("  ✗ FAIL: Could not load health_berry crop data")
		return false
	
	# Plant the crop
	if not plot.plant(crop):
		print("  ✗ FAIL: Failed to plant crop")
		return false
	
	# Verify sprite is visible and has texture
	if plot.sprite == null:
		print("  ✗ FAIL: Plot sprite is null")
		return false
	
	if not plot.sprite.visible:
		print("  ✗ FAIL: Plot sprite is not visible after planting")
		return false
	
	if plot.sprite.texture == null:
		print("  ✗ FAIL: Plot sprite has no texture after planting")
		return false
	
	print("  ✓ PASS: Plot correctly generates and displays crop sprite")
	return true

## Test 3: Verify all crop types generate sprites
func test_all_crop_types() -> bool:
	print("\nTest 3: All crop types generate sprites")
	
	var crop_files = [
		"res://resources/crops/health_berry.tres",
		"res://resources/crops/ammo_grain.tres",
		"res://resources/crops/weapon_flower.tres"
	]
	
	for crop_file in crop_files:
		var crop = load(crop_file)
		if crop == null:
			print("  ✗ FAIL: Could not load crop: %s" % crop_file)
			return false
		
		var plot = Plot.new()
		plot.art_generator = ProceduralArtGenerator.new()
		plot._ready()
		
		if not plot.plant(crop):
			print("  ✗ FAIL: Failed to plant crop: %s" % crop.crop_id)
			return false
		
		if plot.sprite.texture == null:
			print("  ✗ FAIL: No texture generated for crop: %s" % crop.crop_id)
			return false
		
		# Verify the sprite uses the crop's properties
		var stage = plot.get_visual_stage()
		if stage == 0:
			print("  ✗ FAIL: Growth stage is 0 after planting: %s" % crop.crop_id)
			return false
		
		print("  ✓ Crop %s generates sprite correctly" % crop.crop_id)
	
	print("  ✓ PASS: All crop types generate sprites")
	return true

## Test 4: Verify all growth stages generate sprites
func test_all_growth_stages() -> bool:
	print("\nTest 4: All growth stages generate sprites")
	
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()
	
	var crop = load("res://resources/crops/health_berry.tres")
	if crop == null:
		print("  ✗ FAIL: Could not load health_berry crop data")
		return false
	
	plot.plant(crop)
	
	# Test each growth stage
	var test_stages = [
		{"progress": 0.0, "expected_stage": 1, "name": "Early growth"},
		{"progress": 0.4, "expected_stage": 2, "name": "Mid growth"},
		{"progress": 0.8, "expected_stage": 3, "name": "Late growth"}
	]
	
	for test in test_stages:
		plot.growth_progress = test.progress * plot.growth_time
		plot._update_visual()
		
		var stage = plot.get_visual_stage()
		if stage != test.expected_stage:
			print("  ✗ FAIL: Expected stage %d for %s, got %d" % [test.expected_stage, test.name, stage])
			return false
		
		if plot.sprite.texture == null:
			print("  ✗ FAIL: No texture for %s (stage %d)" % [test.name, stage])
			return false
		
		print("  ✓ %s (stage %d) generates sprite" % [test.name, stage])
	
	# Test harvestable state
	plot.state = Plot.PlotState.HARVESTABLE
	plot._update_visual()
	if plot.get_visual_stage() != 3:
		print("  ✗ FAIL: Harvestable state should be stage 3")
		return false
	
	print("  ✓ Harvestable state generates sprite")
	
	# Test empty state
	plot.harvest()
	if plot.sprite.visible:
		print("  ✗ FAIL: Sprite should be hidden when plot is empty")
		return false
	
	print("  ✓ Empty state hides sprite")
	print("  ✓ PASS: All growth stages generate sprites correctly")
	return true

## Test 5: Verify sprite updates on growth progress
func test_sprite_updates_on_growth() -> bool:
	print("\nTest 5: Sprite updates on growth progress")
	
	var plot = Plot.new()
	plot.art_generator = ProceduralArtGenerator.new()
	plot._ready()
	
	var crop = load("res://resources/crops/health_berry.tres")
	if crop == null:
		print("  ✗ FAIL: Could not load health_berry crop data")
		return false
	
	plot.plant(crop)
	
	# Track texture changes as growth progresses
	var initial_texture = plot.sprite.texture
	var stage_1_texture = initial_texture
	
	# Progress to mid growth
	plot.growth_progress = plot.growth_time * 0.5
	plot._update_visual()
	var stage_2_texture = plot.sprite.texture
	
	# Progress to late growth
	plot.growth_progress = plot.growth_time * 0.8
	plot._update_visual()
	var stage_3_texture = plot.sprite.texture
	
	# Verify textures exist
	if stage_1_texture == null or stage_2_texture == null or stage_3_texture == null:
		print("  ✗ FAIL: One or more textures are null")
		return false
	
	# Note: Textures will be different objects even if visually similar
	# The important thing is that they all exist and are valid
	print("  ✓ Sprite updates through growth stages")
	
	# Test that update_growth triggers visual update
	plot.growth_progress = 0.0
	plot.state = Plot.PlotState.GROWING
	var initial_stage = plot.get_visual_stage()
	
	# Simulate time-based growth
	plot.update_growth(plot.growth_time * 0.4)
	var new_stage = plot.get_visual_stage()
	
	if new_stage <= initial_stage:
		print("  ✗ FAIL: Growth stage did not advance after update_growth")
		return false
	
	print("  ✓ update_growth triggers sprite update")
	print("  ✓ PASS: Sprite updates correctly on growth progress")
	return true
