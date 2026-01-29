extends Node2D
## Verification script for FarmGrid implementation
##
## This script creates a FarmGrid instance and verifies basic functionality
## Can be run in the Godot editor to visually verify the implementation

@onready var farm_grid: FarmGrid = $FarmGrid

func _ready() -> void:
	print("=== FarmGrid Verification ===")
	
	# Wait a frame for grid initialization
	await get_tree().process_frame
	
	verify_grid_initialization()
	verify_plot_positioning()
	verify_crop_operations()
	verify_growth_updates()
	verify_serialization()
	
	print("=== Verification Complete ===")

func verify_grid_initialization() -> void:
	print("\n1. Testing Grid Initialization...")
	
	var plot_count = farm_grid.get_plot_count()
	print("  - Plot count: %d" % plot_count)
	
	if plot_count >= 6 and plot_count <= 12:
		print("  ✓ Plot count within valid range (6-12)")
	else:
		print("  ✗ Plot count outside valid range!")
	
	var plots = farm_grid.get_all_plots()
	var all_valid = true
	for plot in plots:
		if not is_instance_valid(plot):
			all_valid = false
			break
	
	if all_valid:
		print("  ✓ All plots are valid instances")
	else:
		print("  ✗ Some plots are invalid!")

func verify_plot_positioning() -> void:
	print("\n2. Testing Plot Positioning...")
	
	var plots = farm_grid.get_all_plots()
	
	# Check that plots have different positions
	var positions = []
	for plot in plots:
		positions.append(plot.position)
	
	var unique_positions = []
	for pos in positions:
		var is_unique = true
		for unique_pos in unique_positions:
			if pos.distance_to(unique_pos) < 0.1:
				is_unique = false
				break
		if is_unique:
			unique_positions.append(pos)
	
	if unique_positions.size() == plots.size():
		print("  ✓ All plots have unique positions")
	else:
		print("  ✗ Some plots have duplicate positions!")
	
	# Test get_plot_at_position
	var test_plot = plots[0]
	var found_plot = farm_grid.get_plot_at_position(test_plot.position)
	
	if found_plot == test_plot:
		print("  ✓ get_plot_at_position works correctly")
	else:
		print("  ✗ get_plot_at_position failed!")

func verify_crop_operations() -> void:
	print("\n3. Testing Crop Operations...")
	
	# Create a test crop
	var crop = CropData.new()
	crop.crop_id = "test_tomato"
	crop.display_name = "Test Tomato"
	crop.growth_time = 10.0
	crop.growth_mode = "time"
	crop.seed_cost = 10
	crop.base_color = Color.RED
	crop.shape_type = "round"
	
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	crop.buff_provided = buff
	
	var plots = farm_grid.get_all_plots()
	var test_plot = plots[0]
	
	# Test planting
	var plant_success = farm_grid.plant_crop(test_plot, crop)
	
	if plant_success:
		print("  ✓ Crop planted successfully")
	else:
		print("  ✗ Crop planting failed!")
	
	if test_plot.state == Plot.PlotState.GROWING:
		print("  ✓ Plot state changed to GROWING")
	else:
		print("  ✗ Plot state incorrect after planting!")
	
	# Grow to harvestable
	test_plot.growth_progress = 10.0
	test_plot.state = Plot.PlotState.HARVESTABLE
	
	# Test harvesting
	var resources = farm_grid.harvest_crop(test_plot)
	
	if not resources.is_empty():
		print("  ✓ Crop harvested successfully")
	else:
		print("  ✗ Crop harvesting failed!")
	
	if test_plot.state == Plot.PlotState.EMPTY:
		print("  ✓ Plot state reset to EMPTY after harvest")
	else:
		print("  ✗ Plot state incorrect after harvesting!")

func verify_growth_updates() -> void:
	print("\n4. Testing Growth Updates...")
	
	# Create test crops
	var time_crop = CropData.new()
	time_crop.crop_id = "time_crop"
	time_crop.display_name = "Time Crop"
	time_crop.growth_time = 10.0
	time_crop.growth_mode = "time"
	time_crop.seed_cost = 10
	time_crop.base_color = Color.GREEN
	time_crop.shape_type = "round"
	
	var buff1 = Buff.new()
	buff1.buff_type = Buff.BuffType.HEALTH
	buff1.value = 20
	time_crop.buff_provided = buff1
	
	var run_crop = CropData.new()
	run_crop.crop_id = "run_crop"
	run_crop.display_name = "Run Crop"
	run_crop.growth_time = 3.0
	run_crop.growth_mode = "runs"
	run_crop.seed_cost = 10
	run_crop.base_color = Color.BLUE
	run_crop.shape_type = "tall"
	
	var buff2 = Buff.new()
	buff2.buff_type = Buff.BuffType.AMMO
	buff2.value = 30
	run_crop.buff_provided = buff2
	
	var plots = farm_grid.get_all_plots()
	
	# Plant time-based crop
	farm_grid.plant_crop(plots[0], time_crop)
	
	# Plant run-based crop
	farm_grid.plant_crop(plots[1], run_crop)
	
	# Test time-based growth
	farm_grid.update_crop_growth(5.0)
	
	if abs(plots[0].growth_progress - 5.0) < 0.01:
		print("  ✓ Time-based growth update works")
	else:
		print("  ✗ Time-based growth update failed! Progress: %f" % plots[0].growth_progress)
	
	# Test run-based growth
	farm_grid.increment_run_growth()
	
	if abs(plots[1].growth_progress - 1.0) < 0.01:
		print("  ✓ Run-based growth update works")
	else:
		print("  ✗ Run-based growth update failed! Progress: %f" % plots[1].growth_progress)

func verify_serialization() -> void:
	print("\n5. Testing Serialization...")
	
	# Create crop database
	var crop_database = {}
	
	var crop = CropData.new()
	crop.crop_id = "serialize_test"
	crop.display_name = "Serialize Test"
	crop.growth_time = 15.0
	crop.growth_mode = "time"
	crop.seed_cost = 10
	crop.base_color = Color.YELLOW
	crop.shape_type = "leafy"
	
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.WEAPON_MOD
	buff.value = 1
	crop.buff_provided = buff
	
	crop_database["serialize_test"] = crop
	
	var plots = farm_grid.get_all_plots()
	
	# Plant a crop and set some growth
	farm_grid.plant_crop(plots[2], crop)
	plots[2].growth_progress = 7.5
	
	# Serialize
	var plot_states = farm_grid.serialize_plots()
	
	if plot_states.size() == plots.size():
		print("  ✓ Serialization produced correct number of states")
	else:
		print("  ✗ Serialization state count mismatch!")
	
	# Create a new grid and deserialize
	var new_grid = FarmGrid.new()
	new_grid.grid_size = farm_grid.grid_size
	new_grid.plot_size = farm_grid.plot_size
	add_child(new_grid)
	
	await get_tree().process_frame
	
	new_grid.deserialize_plots(plot_states, crop_database)
	
	var new_plots = new_grid.get_all_plots()
	
	# Verify state was restored
	if new_plots[2].state == Plot.PlotState.GROWING:
		print("  ✓ Plot state restored correctly")
	else:
		print("  ✗ Plot state restoration failed!")
	
	if new_plots[2].crop_type == "serialize_test":
		print("  ✓ Crop type restored correctly")
	else:
		print("  ✗ Crop type restoration failed!")
	
	if abs(new_plots[2].growth_progress - 7.5) < 0.01:
		print("  ✓ Growth progress restored correctly")
	else:
		print("  ✗ Growth progress restoration failed!")
	
	new_grid.queue_free()
