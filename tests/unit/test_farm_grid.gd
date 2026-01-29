extends GdUnitTestSuite
## Unit tests for FarmGrid class
##
## Tests the FarmGrid's ability to manage multiple Plot instances,
## handle grid layout, player interaction, and crop management.
##
## Test Coverage:
## - Grid initialization and configuration
## - Plot positioning and layout
## - Plot retrieval by position
## - Crop planting and harvesting
## - Seed inventory checks and deduction
## - Growth updates (time-based and run-based)
## - State queries and filtering
## - Serialization and deserialization
##
## Validates: Requirements 4.1, 4.2, 4.3, 4.4

# Setup before each test
func before_test() -> void:
	# Reset GameManager inventory to a clean state
	GameManager.inventory.clear()
	GameManager._initialize_inventory()

# Test helper to create a mock CropData
func create_test_crop(crop_id: String, growth_time: float = 10.0, growth_mode: String = "time") -> CropData:
	var crop = CropData.new()
	crop.crop_id = crop_id
	crop.display_name = "Test " + crop_id
	crop.growth_time = growth_time
	crop.growth_mode = growth_mode
	crop.seed_cost = 10
	crop.base_color = Color.GREEN
	crop.shape_type = "round"
	
	# Create a simple buff
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	crop.buff_provided = buff
	
	return crop

func test_farm_grid_initialization() -> void:
	# Test that FarmGrid initializes with default configuration
	var grid = FarmGrid.new()
	add_child(grid)
	
	# Wait for _ready to be called
	await get_tree().process_frame
	
	# Verify default grid size (3x4 = 12 plots)
	assert_int(grid.get_plot_count()).is_equal(12)
	assert_object(grid.grid_size).is_equal(Vector2i(3, 4))
	assert_float(grid.plot_size).is_equal(64.0)
	
	# Verify all plots are valid
	var all_plots = grid.get_all_plots()
	assert_int(all_plots.size()).is_equal(12)
	for plot in all_plots:
		assert_object(plot).is_not_null()
		assert_bool(is_instance_valid(plot)).is_true()
	
	grid.queue_free()

func test_farm_grid_custom_size() -> void:
	# Test FarmGrid with custom grid size
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 3)  # 6 plots
	grid.plot_size = 100.0
	add_child(grid)
	
	await get_tree().process_frame
	
	# Verify custom configuration
	assert_int(grid.get_plot_count()).is_equal(6)
	assert_float(grid.plot_size).is_equal(100.0)
	
	grid.queue_free()

func test_plot_positioning() -> void:
	# Test that plots are positioned correctly in a grid
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)  # 2x2 grid
	grid.plot_size = 100.0
	add_child(grid)
	
	await get_tree().process_frame
	
	var plots = grid.get_all_plots()
	assert_int(plots.size()).is_equal(4)
	
	# Grid should be centered, so positions should be symmetric
	# Expected positions (centered around origin):
	# (-50, -50), (50, -50), (-50, 50), (50, 50)
	var expected_positions = [
		Vector2(-50, -50),
		Vector2(50, -50),
		Vector2(-50, 50),
		Vector2(50, 50)
	]
	
	for i in range(4):
		var actual_pos = plots[i].position
		var expected_pos = expected_positions[i]
		assert_float(actual_pos.x).is_equal_approx(expected_pos.x, 0.1)
		assert_float(actual_pos.y).is_equal_approx(expected_pos.y, 0.1)
	
	grid.queue_free()

func test_get_plot_at_position() -> void:
	# Test retrieving plots by world position
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)
	grid.plot_size = 100.0
	add_child(grid)
	
	await get_tree().process_frame
	
	# Get plot at specific position (should find the plot at -50, -50)
	var plot = grid.get_plot_at_position(Vector2(-50, -50))
	assert_object(plot).is_not_null()
	assert_float(plot.position.x).is_equal_approx(-50, 0.1)
	assert_float(plot.position.y).is_equal_approx(-50, 0.1)
	
	# Get plot at nearby position (should still find the same plot)
	plot = grid.get_plot_at_position(Vector2(-40, -40))
	assert_object(plot).is_not_null()
	
	# Get plot at far away position (should return null)
	plot = grid.get_plot_at_position(Vector2(1000, 1000))
	assert_object(plot).is_null()
	
	grid.queue_free()

func test_plant_crop() -> void:
	# Test planting a crop in a plot with sufficient seeds
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("tomato", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Verify plot is initially empty
	assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
	
	# Add seeds to inventory (crop.seed_cost = 10)
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# Plant the crop
	var success = grid.plant_crop(target_plot, crop)
	assert_bool(success).is_true()
	
	# Verify plot state changed
	assert_int(target_plot.state).is_equal(Plot.PlotState.GROWING)
	assert_str(target_plot.crop_type).is_equal("tomato")
	
	# Verify seeds were deducted
	assert_int(GameManager.get_inventory_amount("generic_seeds")).is_equal(10)
	
	grid.queue_free()

func test_plant_crop_signal() -> void:
	# Test that crop_planted signal is emitted
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("carrot", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# Monitor the signal
	var signal_monitor = monitor_signal(grid, "crop_planted")
	
	# Plant the crop
	grid.plant_crop(target_plot, crop)
	
	# Verify signal was emitted
	assert_int(signal_monitor.get_count()).is_equal(1)
	var signal_args = signal_monitor.get_args(0)
	assert_object(signal_args[0]).is_equal(target_plot)
	assert_str(signal_args[1]).is_equal("carrot")
	
	grid.queue_free()

func test_plant_crop_insufficient_seeds() -> void:
	# Test that planting fails when player has insufficient seeds
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("wheat", 10.0)
	crop.seed_cost = 15
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add insufficient seeds to inventory (need 15, have 10)
	GameManager.add_to_inventory("generic_seeds", 10)
	
	# Attempt to plant the crop
	var success = grid.plant_crop(target_plot, crop)
	assert_bool(success).is_false()
	
	# Verify plot is still empty
	assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
	
	# Verify seeds were not deducted
	assert_int(GameManager.get_inventory_amount("generic_seeds")).is_equal(10)
	
	grid.queue_free()

func test_plant_crop_no_seeds() -> void:
	# Test that planting fails when player has no seeds
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("corn", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Don't add any seeds to inventory
	
	# Attempt to plant the crop
	var success = grid.plant_crop(target_plot, crop)
	assert_bool(success).is_false()
	
	# Verify plot is still empty
	assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
	
	grid.queue_free()

func test_plant_crop_health_seeds() -> void:
	# Test planting a health crop with health_seeds
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("health_berry", 10.0)
	crop.seed_cost = 5
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add health_seeds to inventory
	GameManager.add_to_inventory("health_seeds", 10)
	
	# Plant the crop
	var success = grid.plant_crop(target_plot, crop)
	assert_bool(success).is_true()
	
	# Verify health_seeds were deducted
	assert_int(GameManager.get_inventory_amount("health_seeds")).is_equal(5)
	
	grid.queue_free()

func test_plant_crop_ammo_seeds() -> void:
	# Test planting an ammo crop with ammo_seeds
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("ammo_grain", 10.0)
	crop.seed_cost = 8
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add ammo_seeds to inventory
	GameManager.add_to_inventory("ammo_seeds", 20)
	
	# Plant the crop
	var success = grid.plant_crop(target_plot, crop)
	assert_bool(success).is_true()
	
	# Verify ammo_seeds were deducted
	assert_int(GameManager.get_inventory_amount("ammo_seeds")).is_equal(12)
	
	grid.queue_free()

func test_plant_crop_weapon_mod_seeds() -> void:
	# Test planting a weapon mod crop with weapon_mod_seeds
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("weapon_mod_flower", 10.0)
	crop.seed_cost = 12
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add weapon_mod_seeds to inventory
	GameManager.add_to_inventory("weapon_mod_seeds", 15)
	
	# Plant the crop
	var success = grid.plant_crop(target_plot, crop)
	assert_bool(success).is_true()
	
	# Verify weapon_mod_seeds were deducted
	assert_int(GameManager.get_inventory_amount("weapon_mod_seeds")).is_equal(3)
	
	grid.queue_free()

func test_plant_multiple_crops_inventory_tracking() -> void:
	# Test that inventory is correctly tracked across multiple plantings
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("potato", 10.0)
	crop.seed_cost = 5
	var plots = grid.get_all_plots()
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# Plant in first plot
	var success1 = grid.plant_crop(plots[0], crop)
	assert_bool(success1).is_true()
	assert_int(GameManager.get_inventory_amount("generic_seeds")).is_equal(15)
	
	# Plant in second plot
	var success2 = grid.plant_crop(plots[1], crop)
	assert_bool(success2).is_true()
	assert_int(GameManager.get_inventory_amount("generic_seeds")).is_equal(10)
	
	# Plant in third plot
	var success3 = grid.plant_crop(plots[2], crop)
	assert_bool(success3).is_true()
	assert_int(GameManager.get_inventory_amount("generic_seeds")).is_equal(5)
	
	# Attempt to plant in fourth plot (insufficient seeds)
	var success4 = grid.plant_crop(plots[3], crop)
	assert_bool(success4).is_false()
	assert_int(GameManager.get_inventory_amount("generic_seeds")).is_equal(5)
	
	grid.queue_free()

func test_plant_crop_invalid_plot() -> void:
	# Test planting with invalid plot reference
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("wheat", 10.0)
	
	# Try to plant with null plot
	var success = grid.plant_crop(null, crop)
	assert_bool(success).is_false()
	
	# Try to plant with plot not in grid
	var external_plot = Plot.new()
	success = grid.plant_crop(external_plot, crop)
	assert_bool(success).is_false()
	
	external_plot.queue_free()
	grid.queue_free()

func test_harvest_crop() -> void:
	# Test harvesting a crop from a plot with inventory addition
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("potato", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# Plant and grow the crop to harvestable state
	grid.plant_crop(target_plot, crop)
	target_plot.growth_progress = 10.0  # Complete growth
	target_plot.state = Plot.PlotState.HARVESTABLE
	
	# Record initial inventory state
	var initial_potato_count = GameManager.get_inventory_amount("potato")
	var initial_buff_count = GameManager.get_inventory_amount("potato_buff")
	
	# Harvest the crop
	var resources = grid.harvest_crop(target_plot)
	
	# Verify harvest succeeded
	assert_bool(resources.is_empty()).is_false()
	assert_str(resources.get("crop_id", "")).is_equal("potato")
	assert_object(resources.get("buff", null)).is_not_null()
	
	# Verify plot is now empty
	assert_int(target_plot.state).is_equal(Plot.PlotState.EMPTY)
	
	# Verify crop was added to inventory
	assert_int(GameManager.get_inventory_amount("potato")).is_equal(initial_potato_count + 1)
	
	# Verify buff was added to inventory
	assert_int(GameManager.get_inventory_amount("potato_buff")).is_equal(initial_buff_count + 1)
	
	grid.queue_free()

func test_harvest_crop_signal() -> void:
	# Test that crop_harvested signal is emitted
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("corn", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# Plant and grow the crop
	grid.plant_crop(target_plot, crop)
	target_plot.growth_progress = 10.0
	target_plot.state = Plot.PlotState.HARVESTABLE
	
	# Monitor the signal
	var signal_monitor = monitor_signal(grid, "crop_harvested")
	
	# Harvest the crop
	grid.harvest_crop(target_plot)
	
	# Verify signal was emitted
	assert_int(signal_monitor.get_count()).is_equal(1)
	var signal_args = signal_monitor.get_args(0)
	assert_object(signal_args[0]).is_equal(target_plot)
	assert_bool(signal_args[1].is_empty()).is_false()
	
	grid.queue_free()

func test_update_crop_growth_time_based() -> void:
	# Test time-based crop growth updates
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("lettuce", 10.0, "time")
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# Plant the crop
	grid.plant_crop(target_plot, crop)
	
	# Update growth
	grid.update_crop_growth(5.0)  # 5 seconds
	
	# Verify growth progress
	assert_float(target_plot.growth_progress).is_equal(5.0)
	assert_int(target_plot.state).is_equal(Plot.PlotState.GROWING)
	
	# Update to completion
	grid.update_crop_growth(5.0)  # Another 5 seconds (total 10)
	
	# Verify crop is now harvestable
	assert_int(target_plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	
	grid.queue_free()

func test_increment_run_growth() -> void:
	# Test run-based crop growth updates
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("pumpkin", 3.0, "runs")
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# Plant the crop
	grid.plant_crop(target_plot, crop)
	
	# Increment run growth
	grid.increment_run_growth()
	assert_float(target_plot.growth_progress).is_equal(1.0)
	
	grid.increment_run_growth()
	assert_float(target_plot.growth_progress).is_equal(2.0)
	
	grid.increment_run_growth()
	assert_float(target_plot.growth_progress).is_equal(3.0)
	
	# Verify crop is now harvestable
	assert_int(target_plot.state).is_equal(Plot.PlotState.HARVESTABLE)
	
	grid.queue_free()

func test_get_plots_by_state() -> void:
	# Test filtering plots by state
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)  # 4 plots
	add_child(grid)
	await get_tree().process_frame
	
	var plots = grid.get_all_plots()
	
	# Initially all plots should be empty
	var empty_plots = grid.get_plots_by_state(Plot.PlotState.EMPTY)
	assert_int(empty_plots.size()).is_equal(4)
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 50)
	
	# Plant crops in 2 plots
	var crop1 = create_test_crop("bean", 10.0)
	var crop2 = create_test_crop("pea", 10.0)
	grid.plant_crop(plots[0], crop1)
	grid.plant_crop(plots[1], crop2)
	
	# Check state distribution
	empty_plots = grid.get_plots_by_state(Plot.PlotState.EMPTY)
	var growing_plots = grid.get_plots_by_state(Plot.PlotState.GROWING)
	assert_int(empty_plots.size()).is_equal(2)
	assert_int(growing_plots.size()).is_equal(2)
	
	# Make one plot harvestable
	plots[0].growth_progress = 10.0
	plots[0].state = Plot.PlotState.HARVESTABLE
	
	var harvestable_plots = grid.get_plots_by_state(Plot.PlotState.HARVESTABLE)
	growing_plots = grid.get_plots_by_state(Plot.PlotState.GROWING)
	assert_int(harvestable_plots.size()).is_equal(1)
	assert_int(growing_plots.size()).is_equal(1)
	
	grid.queue_free()

func test_serialize_and_deserialize() -> void:
	# Test saving and loading plot states
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)
	add_child(grid)
	await get_tree().process_frame
	
	# Create crop database
	var crop_database = {
		"radish": create_test_crop("radish", 15.0),
		"onion": create_test_crop("onion", 20.0)
	}
	
	var plots = grid.get_all_plots()
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 50)
	
	# Plant crops and set various states
	grid.plant_crop(plots[0], crop_database["radish"])
	plots[0].growth_progress = 7.5
	
	grid.plant_crop(plots[1], crop_database["onion"])
	plots[1].growth_progress = 20.0
	plots[1].state = Plot.PlotState.HARVESTABLE
	
	# Serialize
	var plot_states = grid.serialize_plots()
	assert_int(plot_states.size()).is_equal(4)
	
	# Create a new grid and deserialize
	var grid2 = FarmGrid.new()
	grid2.grid_size = Vector2i(2, 2)
	add_child(grid2)
	await get_tree().process_frame
	
	grid2.deserialize_plots(plot_states, crop_database)
	
	# Verify states were restored
	var plots2 = grid2.get_all_plots()
	
	# Plot 0 should be growing radish at 7.5 progress
	assert_int(plots2[0].state).is_equal(Plot.PlotState.GROWING)
	assert_str(plots2[0].crop_type).is_equal("radish")
	assert_float(plots2[0].growth_progress).is_equal(7.5)
	
	# Plot 1 should be harvestable onion
	assert_int(plots2[1].state).is_equal(Plot.PlotState.HARVESTABLE)
	assert_str(plots2[1].crop_type).is_equal("onion")
	
	# Plots 2 and 3 should be empty
	assert_int(plots2[2].state).is_equal(Plot.PlotState.EMPTY)
	assert_int(plots2[3].state).is_equal(Plot.PlotState.EMPTY)
	
	grid.queue_free()
	grid2.queue_free()

func test_multiple_plots_growth_update() -> void:
	# Test that update_crop_growth affects all growing plots
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("spinach", 10.0, "time")
	var plots = grid.get_all_plots()
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 50)
	
	# Plant crops in all plots
	for plot in plots:
		grid.plant_crop(plot, crop)
	
	# Update growth for all plots
	grid.update_crop_growth(5.0)
	
	# Verify all plots have updated growth
	for plot in plots:
		assert_float(plot.growth_progress).is_equal(5.0)
		assert_int(plot.state).is_equal(Plot.PlotState.GROWING)
	
	grid.queue_free()

func test_grid_size_validation() -> void:
	# Test that grid size is within requirements (6-12 plots)
	# Requirement 4.1: Farm_Hub SHALL contain a grid of 6 to 12 Plot tiles
	
	# Test minimum valid size (2x3 = 6 plots)
	var grid1 = FarmGrid.new()
	grid1.grid_size = Vector2i(2, 3)
	add_child(grid1)
	await get_tree().process_frame
	assert_int(grid1.get_plot_count()).is_equal(6)
	grid1.queue_free()
	
	# Test maximum valid size (3x4 = 12 plots)
	var grid2 = FarmGrid.new()
	grid2.grid_size = Vector2i(3, 4)
	add_child(grid2)
	await get_tree().process_frame
	assert_int(grid2.get_plot_count()).is_equal(12)
	grid2.queue_free()
	
	# Test another valid size (2x4 = 8 plots)
	var grid3 = FarmGrid.new()
	grid3.grid_size = Vector2i(2, 4)
	add_child(grid3)
	await get_tree().process_frame
	assert_int(grid3.get_plot_count()).is_equal(8)
	grid3.queue_free()

func test_harvest_crop_health_berry() -> void:
	# Test harvesting a health crop adds correct items to inventory
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("health_berry", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("health_seeds", 20)
	
	# Plant and grow the crop
	grid.plant_crop(target_plot, crop)
	target_plot.growth_progress = 10.0
	target_plot.state = Plot.PlotState.HARVESTABLE
	
	# Harvest the crop
	var resources = grid.harvest_crop(target_plot)
	
	# Verify inventory additions
	assert_int(GameManager.get_inventory_amount("health_berry")).is_equal(1)
	assert_int(GameManager.get_inventory_amount("health_berry_buff")).is_equal(1)
	
	grid.queue_free()

func test_harvest_crop_ammo_grain() -> void:
	# Test harvesting an ammo crop adds correct items to inventory
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("ammo_grain", 15.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("ammo_seeds", 20)
	
	# Plant and grow the crop
	grid.plant_crop(target_plot, crop)
	target_plot.growth_progress = 15.0
	target_plot.state = Plot.PlotState.HARVESTABLE
	
	# Harvest the crop
	var resources = grid.harvest_crop(target_plot)
	
	# Verify inventory additions
	assert_int(GameManager.get_inventory_amount("ammo_grain")).is_equal(1)
	assert_int(GameManager.get_inventory_amount("ammo_grain_buff")).is_equal(1)
	
	grid.queue_free()

func test_harvest_multiple_crops_inventory_accumulation() -> void:
	# Test that harvesting multiple crops accumulates in inventory
	var grid = FarmGrid.new()
	grid.grid_size = Vector2i(2, 2)
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("tomato", 10.0)
	var plots = grid.get_all_plots()
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 50)
	
	# Plant crops in all plots
	for plot in plots:
		grid.plant_crop(plot, crop)
		plot.growth_progress = 10.0
		plot.state = Plot.PlotState.HARVESTABLE
	
	# Harvest all crops
	for plot in plots:
		grid.harvest_crop(plot)
	
	# Verify inventory accumulated correctly
	assert_int(GameManager.get_inventory_amount("tomato")).is_equal(4)
	assert_int(GameManager.get_inventory_amount("tomato_buff")).is_equal(4)
	
	grid.queue_free()

func test_harvest_crop_invalid_plot_no_inventory_change() -> void:
	# Test that failed harvest doesn't modify inventory
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	# Record initial inventory state
	var initial_inventory = GameManager.inventory.duplicate()
	
	# Try to harvest with null plot
	var resources = grid.harvest_crop(null)
	assert_bool(resources.is_empty()).is_true()
	
	# Verify inventory unchanged
	assert_object(GameManager.inventory).is_equal(initial_inventory)
	
	# Try to harvest with external plot
	var external_plot = Plot.new()
	resources = grid.harvest_crop(external_plot)
	assert_bool(resources.is_empty()).is_true()
	
	# Verify inventory still unchanged
	assert_object(GameManager.inventory).is_equal(initial_inventory)
	
	external_plot.queue_free()
	grid.queue_free()

func test_harvest_crop_not_harvestable_no_inventory_change() -> void:
	# Test that harvesting non-harvestable plot doesn't modify inventory
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("carrot", 10.0)
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# Plant the crop but don't complete growth
	grid.plant_crop(target_plot, crop)
	target_plot.growth_progress = 5.0  # Only halfway
	
	# Record initial inventory state (after planting)
	var initial_carrot_count = GameManager.get_inventory_amount("carrot")
	var initial_buff_count = GameManager.get_inventory_amount("carrot_buff")
	
	# Try to harvest (should fail)
	var resources = grid.harvest_crop(target_plot)
	assert_bool(resources.is_empty()).is_true()
	
	# Verify inventory unchanged
	assert_int(GameManager.get_inventory_amount("carrot")).is_equal(initial_carrot_count)
	assert_int(GameManager.get_inventory_amount("carrot_buff")).is_equal(initial_buff_count)
	
	grid.queue_free()

func test_harvest_and_replant_cycle() -> void:
	# Test complete plant-harvest-replant cycle with inventory tracking
	var grid = FarmGrid.new()
	add_child(grid)
	await get_tree().process_frame
	
	var crop = create_test_crop("wheat", 10.0)
	crop.seed_cost = 5
	var plots = grid.get_all_plots()
	var target_plot = plots[0]
	
	# Add seeds to inventory
	GameManager.add_to_inventory("generic_seeds", 20)
	
	# First cycle: plant and harvest
	grid.plant_crop(target_plot, crop)
	assert_int(GameManager.get_inventory_amount("generic_seeds")).is_equal(15)
	
	target_plot.growth_progress = 10.0
	target_plot.state = Plot.PlotState.HARVESTABLE
	
	grid.harvest_crop(target_plot)
	assert_int(GameManager.get_inventory_amount("wheat")).is_equal(1)
	assert_int(GameManager.get_inventory_amount("wheat_buff")).is_equal(1)
	
	# Second cycle: replant and harvest
	grid.plant_crop(target_plot, crop)
	assert_int(GameManager.get_inventory_amount("generic_seeds")).is_equal(10)
	
	target_plot.growth_progress = 10.0
	target_plot.state = Plot.PlotState.HARVESTABLE
	
	grid.harvest_crop(target_plot)
	assert_int(GameManager.get_inventory_amount("wheat")).is_equal(2)
	assert_int(GameManager.get_inventory_amount("wheat_buff")).is_equal(2)
	
	grid.queue_free()
