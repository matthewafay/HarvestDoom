extends GdUnitTestSuite
## Integration tests for FarmInteractionManager
##
## Tests the interaction between player, plots, and interaction prompts.
##
## Validates: Requirements 4.5, 10.3, 12.5

var farm_grid: FarmGrid
var interaction_prompt: InteractionPrompt
var farm_interaction_manager: FarmInteractionManager
var player: Node3D

func before_test() -> void:
	# Create test components
	farm_grid = FarmGrid.new()
	farm_grid.grid_size = Vector2i(2, 2)  # Small grid for testing
	farm_grid.plot_size = 2.0
	add_child(farm_grid)
	
	# Load interaction prompt scene
	var prompt_scene = load("res://scenes/interaction_prompt.tscn")
	interaction_prompt = prompt_scene.instantiate()
	add_child(interaction_prompt)
	
	# Create player node
	player = Node3D.new()
	player.position = Vector3(0, 0, 0)
	add_child(player)
	
	# Create interaction manager
	farm_interaction_manager = FarmInteractionManager.new()
	add_child(farm_interaction_manager)
	
	# Initialize manager
	farm_interaction_manager.initialize(farm_grid, interaction_prompt, player)
	
	# Give player some seeds
	GameManager.add_to_inventory("health_seeds", 5)

func after_test() -> void:
	# Cleanup
	if is_instance_valid(farm_grid):
		farm_grid.queue_free()
	if is_instance_valid(interaction_prompt):
		interaction_prompt.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	if is_instance_valid(farm_interaction_manager):
		farm_interaction_manager.queue_free()
	
	# Clear inventory
	GameManager.inventory.clear()

func test_prompt_shows_when_player_near_empty_plot() -> void:
	# Arrange
	await get_tree().process_frame
	var plots = farm_grid.get_all_plots()
	assert_int(plots.size()).is_greater(0)
	
	var plot = plots[0]
	var plot_world_pos = farm_grid.to_global(plot.position)
	
	# Move player near plot
	player.position = Vector3(plot_world_pos.x, 0, plot_world_pos.y)
	
	# Act - process to detect nearby plot
	await get_tree().process_frame
	farm_interaction_manager._process(0.016)
	
	# Assert - prompt should show for empty plot with seeds
	assert_bool(interaction_prompt.is_showing()).is_true()
	if interaction_prompt.prompt_label:
		var prompt_text = interaction_prompt.prompt_label.text
		assert_bool(prompt_text.contains("Plant") or prompt_text.contains("seeds")).is_true()

func test_prompt_hides_when_player_moves_away() -> void:
	# Arrange
	await get_tree().process_frame
	var plots = farm_grid.get_all_plots()
	var plot = plots[0]
	var plot_world_pos = farm_grid.to_global(plot.position)
	
	# Move player near plot
	player.position = Vector3(plot_world_pos.x, 0, plot_world_pos.y)
	await get_tree().process_frame
	farm_interaction_manager._process(0.016)
	
	# Act - move player far away
	player.position = Vector3(100, 0, 100)
	await get_tree().process_frame
	farm_interaction_manager._process(0.016)
	
	# Assert - prompt should be hidden
	assert_bool(interaction_prompt.is_showing()).is_false()

func test_prompt_shows_harvest_for_harvestable_plot() -> void:
	# Arrange
	await get_tree().process_frame
	var plots = farm_grid.get_all_plots()
	var plot = plots[0]
	
	# Create a test crop
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.growth_time = 1.0
	crop.seed_cost = 1
	crop.base_color = Color.RED
	crop.shape_type = "round"
	
	# Plant and make harvestable
	plot.plant(crop)
	plot.state = Plot.PlotState.HARVESTABLE
	
	# Move player near plot
	var plot_world_pos = farm_grid.to_global(plot.position)
	player.position = Vector3(plot_world_pos.x, 0, plot_world_pos.y)
	
	# Act
	await get_tree().process_frame
	farm_interaction_manager._process(0.016)
	
	# Assert - prompt should show harvest message
	assert_bool(interaction_prompt.is_showing()).is_true()
	if interaction_prompt.prompt_label:
		var prompt_text = interaction_prompt.prompt_label.text
		assert_bool(prompt_text.contains("Harvest")).is_true()

func test_prompt_shows_growing_progress() -> void:
	# Arrange
	await get_tree().process_frame
	var plots = farm_grid.get_all_plots()
	var plot = plots[0]
	
	# Create a test crop
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.growth_time = 10.0
	crop.seed_cost = 1
	crop.base_color = Color.RED
	crop.shape_type = "round"
	
	# Plant crop
	plot.plant(crop)
	plot.growth_progress = 0.5  # 50% grown
	
	# Move player near plot
	var plot_world_pos = farm_grid.to_global(plot.position)
	player.position = Vector3(plot_world_pos.x, 0, plot_world_pos.y)
	
	# Act
	await get_tree().process_frame
	farm_interaction_manager._process(0.016)
	
	# Assert - prompt should show growing status
	assert_bool(interaction_prompt.is_showing()).is_true()
	if interaction_prompt.prompt_label:
		var prompt_text = interaction_prompt.prompt_label.text
		assert_bool(prompt_text.contains("Growing")).is_true()

func test_no_prompt_when_no_seeds() -> void:
	# Arrange
	await get_tree().process_frame
	
	# Clear all seeds from inventory
	GameManager.inventory.clear()
	
	var plots = farm_grid.get_all_plots()
	var plot = plots[0]
	var plot_world_pos = farm_grid.to_global(plot.position)
	
	# Move player near empty plot
	player.position = Vector3(plot_world_pos.x, 0, plot_world_pos.y)
	
	# Act
	await get_tree().process_frame
	farm_interaction_manager._process(0.016)
	
	# Assert - prompt should show but indicate no seeds
	assert_bool(interaction_prompt.is_showing()).is_true()
	if interaction_prompt.prompt_label:
		var prompt_text = interaction_prompt.prompt_label.text
		assert_bool(prompt_text.contains("No seeds") or prompt_text.contains("available")).is_true()
