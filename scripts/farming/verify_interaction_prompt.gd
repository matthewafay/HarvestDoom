extends Node
## Verification script for interaction prompt system
##
## This script tests the interaction prompt display functionality
## by simulating player movement near plots and checking prompt behavior.
##
## Run this script in the Godot editor to verify the implementation.
##
## Validates: Requirements 4.5, 10.3, 12.5

func _ready() -> void:
	print("=== Interaction Prompt Verification ===")
	print()
	
	await get_tree().process_frame
	
	# Test 1: Create interaction prompt
	print("Test 1: Creating InteractionPrompt...")
	var prompt_scene = load("res://scenes/interaction_prompt.tscn")
	if prompt_scene == null:
		print("  ❌ FAILED: Could not load interaction_prompt.tscn")
		return
	
	var prompt = prompt_scene.instantiate()
	add_child(prompt)
	await get_tree().process_frame
	
	if prompt.is_showing():
		print("  ❌ FAILED: Prompt should start hidden")
		return
	print("  ✓ PASSED: Prompt starts hidden")
	
	# Test 2: Show prompt with text
	print()
	print("Test 2: Showing prompt with text...")
	prompt.show_prompt("Press E to Plant")
	await get_tree().process_frame
	
	if not prompt.is_showing():
		print("  ❌ FAILED: Prompt should be visible after show_prompt()")
		return
	
	if prompt.prompt_label and prompt.prompt_label.text != "Press E to Plant":
		print("  ❌ FAILED: Prompt text incorrect. Expected 'Press E to Plant', got '%s'" % prompt.prompt_label.text)
		return
	print("  ✓ PASSED: Prompt shows correct text")
	
	# Test 3: Hide prompt
	print()
	print("Test 3: Hiding prompt...")
	prompt.hide_prompt()
	await get_tree().process_frame
	
	if prompt.is_showing():
		print("  ❌ FAILED: Prompt should be hidden after hide_prompt()")
		return
	print("  ✓ PASSED: Prompt hides correctly")
	
	# Test 4: Create FarmGrid and test proximity detection
	print()
	print("Test 4: Testing FarmGrid integration...")
	var farm_grid = FarmGrid.new()
	farm_grid.grid_size = Vector2i(2, 2)
	farm_grid.plot_size = 2.0
	add_child(farm_grid)
	await get_tree().process_frame
	
	var plots = farm_grid.get_all_plots()
	if plots.size() != 4:
		print("  ❌ FAILED: Expected 4 plots, got %d" % plots.size())
		return
	print("  ✓ PASSED: FarmGrid created with correct number of plots")
	
	# Test 5: Create player and interaction manager
	print()
	print("Test 5: Testing FarmInteractionManager...")
	var player = Node3D.new()
	player.position = Vector3(0, 0, 0)
	add_child(player)
	
	var manager = FarmInteractionManager.new()
	add_child(manager)
	manager.initialize(farm_grid, prompt, player)
	await get_tree().process_frame
	
	# Give player some seeds
	GameManager.add_to_inventory("health_seeds", 5)
	
	# Move player near first plot
	var plot = plots[0]
	var plot_world_pos = farm_grid.to_global(plot.position)
	player.position = Vector3(plot_world_pos.x, 0, plot_world_pos.y)
	
	# Process to detect nearby plot
	manager._process(0.016)
	await get_tree().process_frame
	
	if not prompt.is_showing():
		print("  ❌ FAILED: Prompt should show when player near empty plot with seeds")
		return
	
	var prompt_text = prompt.prompt_label.text if prompt.prompt_label else ""
	if not ("Plant" in prompt_text or "seeds" in prompt_text):
		print("  ❌ FAILED: Prompt should mention planting. Got: '%s'" % prompt_text)
		return
	print("  ✓ PASSED: Prompt shows 'Press E to Plant' when near empty plot")
	
	# Test 6: Move player away
	print()
	print("Test 6: Testing prompt hides when player moves away...")
	player.position = Vector3(100, 0, 100)
	manager._process(0.016)
	await get_tree().process_frame
	
	if prompt.is_showing():
		print("  ❌ FAILED: Prompt should hide when player moves away")
		return
	print("  ✓ PASSED: Prompt hides when player moves away")
	
	# Test 7: Test harvestable plot
	print()
	print("Test 7: Testing prompt for harvestable plot...")
	
	# Create a test crop
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.growth_time = 1.0
	crop.seed_cost = 1
	crop.base_color = Color.RED
	crop.shape_type = "round"
	
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 10
	crop.buff_provided = buff
	
	# Plant and make harvestable
	plot.plant(crop)
	plot.state = Plot.PlotState.HARVESTABLE
	
	# Move player near plot again
	player.position = Vector3(plot_world_pos.x, 0, plot_world_pos.y)
	manager._process(0.016)
	await get_tree().process_frame
	
	if not prompt.is_showing():
		print("  ❌ FAILED: Prompt should show when player near harvestable plot")
		return
	
	prompt_text = prompt.prompt_label.text if prompt.prompt_label else ""
	if not "Harvest" in prompt_text:
		print("  ❌ FAILED: Prompt should mention harvesting. Got: '%s'" % prompt_text)
		return
	print("  ✓ PASSED: Prompt shows 'Press E to Harvest' when near harvestable plot")
	
	# Test 8: Test growing plot
	print()
	print("Test 8: Testing prompt for growing plot...")
	plot.state = Plot.PlotState.GROWING
	plot.growth_progress = 0.5
	
	manager._process(0.016)
	await get_tree().process_frame
	
	if not prompt.is_showing():
		print("  ❌ FAILED: Prompt should show when player near growing plot")
		return
	
	prompt_text = prompt.prompt_label.text if prompt.prompt_label else ""
	if not "Growing" in prompt_text:
		print("  ❌ FAILED: Prompt should mention growing. Got: '%s'" % prompt_text)
		return
	print("  ✓ PASSED: Prompt shows growth progress for growing plot")
	
	# All tests passed!
	print()
	print("=== All Tests Passed! ===")
	print()
	print("Summary:")
	print("  ✓ InteractionPrompt shows and hides correctly")
	print("  ✓ Prompt displays appropriate text based on plot state")
	print("  ✓ Prompt shows 'Press E to Plant' for empty plots with seeds")
	print("  ✓ Prompt shows 'Press E to Harvest' for harvestable plots")
	print("  ✓ Prompt shows growth progress for growing plots")
	print("  ✓ Prompt hides when player moves away from plots")
	print()
	print("Task 6.3.3 implementation verified successfully!")
	
	# Quit after verification
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
