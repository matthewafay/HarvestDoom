extends Node2D
## FarmGrid - Manages multiple Plot instances in a grid layout
##
## The FarmGrid is responsible for managing a collection of farming plots
## arranged in a grid pattern. It handles plot creation, positioning,
## player interaction, and crop management across all plots.
##
## Grid Layout:
## - Configurable grid_size (e.g., 3x4 = 12 plots)
## - Configurable plot_size for spacing
## - Plots are arranged in a 2D grid with consistent spacing
##
## Responsibilities:
## - Create and position Plot instances
## - Handle player interaction with plots (planting/harvesting)
## - Update crop growth across all plots
## - Manage plot state persistence
##
## Validates: Requirements 4.1, 4.2, 4.3, 4.4

class_name FarmGrid

## Grid dimensions (number of plots in x and y directions)
## Default: 3x4 = 12 plots (within 6-12 plot requirement)
@export var grid_size: Vector2i = Vector2i(3, 4)

## Size of each plot in pixels (used for spacing)
@export var plot_size: float = 64.0

## Array of all Plot instances in the grid
var plots: Array = []

## Reference to the Plot scene for instancing
## This should be set to the Plot scene resource
var plot_scene: PackedScene = null

## Emitted when a crop is planted in a plot
## @param plot: The Plot instance where the crop was planted
## @param crop_type: The crop_id of the planted crop
signal crop_planted(plot, crop_type: String)

## Emitted when a crop is harvested from a plot
## @param plot: The Plot instance where the crop was harvested
## @param resources: Dictionary containing harvest results
signal crop_harvested(plot, resources: Dictionary)

func _ready() -> void:
	_initialize_grid()

## Initialize the grid by creating and positioning all plots
func _initialize_grid() -> void:
	# Clear any existing plots
	for plot in plots:
		if is_instance_valid(plot):
			plot.queue_free()
	plots.clear()
	
	# Create plot scene if not already loaded
	if plot_scene == null:
		# Try to load the plot scene
		# For now, we'll create plots programmatically
		pass
	
	# Calculate grid offset to center the grid
	var grid_width = grid_size.x * plot_size
	var grid_height = grid_size.y * plot_size
	var offset = Vector2(-grid_width / 2.0, -grid_height / 2.0)
	
	# Create plots in grid layout
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var plot = load("res://scripts/farming/plot.gd").new()
			
			# Position the plot
			var plot_position = Vector2(
				x * plot_size + plot_size / 2.0,
				y * plot_size + plot_size / 2.0
			) + offset
			plot.position = plot_position
			
			# Add plot to scene and array
			add_child(plot)
			plots.append(plot)
			
			# Connect plot signals
			plot.growth_completed.connect(_on_plot_growth_completed.bind(plot))

## Get the plot at a given world position
## @param world_pos: World position to check
## @returns: Plot instance at that position, or null if none found
func get_plot_at_position(world_pos: Vector2):
	# Convert world position to local position
	var local_pos = to_local(world_pos)
	
	# Find the closest plot within interaction range
	var closest_plot = null
	var closest_distance: float = INF
	var interaction_range: float = plot_size / 2.0
	
	for plot in plots:
		if not is_instance_valid(plot):
			continue
		
		var distance = local_pos.distance_to(plot.position)
		if distance < interaction_range and distance < closest_distance:
			closest_plot = plot
			closest_distance = distance
	
	return closest_plot

## Plant a crop in the specified plot
## @param plot: The Plot instance to plant in
## @param crop: CropData resource defining the crop to plant
## @returns: true if planting succeeded, false otherwise
## 
## This method now checks the player's seed inventory before allowing planting.
## If the player has sufficient seeds, the seed cost is deducted from inventory.
## 
## Validates: Requirements 4.1, 4.2, 4.3, 4.4
func plant_crop(plot, crop) -> bool:
	if plot == null:
		push_warning("FarmGrid.plant_crop: plot parameter is null")
		return false
	
	if crop == null:
		push_warning("FarmGrid.plant_crop: crop parameter is null")
		return false
	
	# Verify the plot belongs to this grid
	if not plots.has(plot):
		push_warning("FarmGrid.plant_crop: plot does not belong to this grid")
		return false
	
	# Check if GameManager is available
	if not GameManager:
		push_error("FarmGrid.plant_crop: GameManager not found")
		return false
	
	# Determine the seed type from crop_id
	# Convention: crop_id like "health_berry" maps to "health_seeds" in inventory
	var seed_type = _get_seed_type_from_crop(crop.crop_id)
	
	# Check if player has enough seeds in inventory
	if not GameManager.has_inventory_amount(seed_type, crop.seed_cost):
		push_warning("FarmGrid.plant_crop: Insufficient seeds. Need %d %s, have %d" % [
			crop.seed_cost,
			seed_type,
			GameManager.get_inventory_amount(seed_type)
		])
		return false
	
	# Attempt to plant the crop
	var success = plot.plant(crop)
	
	if success:
		# Deduct seed cost from inventory
		GameManager.add_to_inventory(seed_type, -crop.seed_cost)
		crop_planted.emit(plot, crop.crop_id)
	
	return success

## Harvest a crop from the specified plot
## @param plot: The Plot instance to harvest from
## @returns: Dictionary with crop resources, or empty dict if harvest failed
##
## This method now adds harvested resources to the player's inventory via GameManager.
## The harvested buff is stored in inventory for later consumption by the player.
##
## Validates: Requirements 4.1, 4.2, 4.3, 4.4
func harvest_crop(plot) -> Dictionary:
	if plot == null:
		push_warning("FarmGrid.harvest_crop: plot parameter is null")
		return {}
	
	# Verify the plot belongs to this grid
	if not plots.has(plot):
		push_warning("FarmGrid.harvest_crop: plot does not belong to this grid")
		return {}
	
	# Check if GameManager is available
	if not GameManager:
		push_error("FarmGrid.harvest_crop: GameManager not found")
		return {}
	
	# Attempt to harvest the crop
	var resources = plot.harvest()
	
	if not resources.is_empty():
		# Add harvested crop to inventory
		var crop_id = resources.get("crop_id", "")
		if not crop_id.is_empty():
			# Increment the count of this crop type in inventory
			# Convention: crop_id like "health_berry" is stored as "health_berry" in inventory
			GameManager.add_to_inventory(crop_id, 1)
		
		# Store the buff for later application
		# Buffs are stored separately and can be consumed by the player before combat
		var buff = resources.get("buff", null)
		if buff != null:
			# Add buff to a special inventory category for harvested buffs
			# This allows the player to choose when to consume the buff
			var buff_inventory_key = crop_id + "_buff"
			GameManager.add_to_inventory(buff_inventory_key, 1)
		
		# Emit signal with harvest results
		crop_harvested.emit(plot, resources)
	
	return resources

## Update crop growth for all plots (time-based crops)
## Should be called each frame with delta time
## @param delta: Time elapsed since last update in seconds
func update_crop_growth(delta: float) -> void:
	for plot in plots:
		if is_instance_valid(plot):
			plot.update_growth(delta)

## Increment run-based growth for all plots
## Should be called when a combat run is completed
func increment_run_growth() -> void:
	for plot in plots:
		if is_instance_valid(plot):
			plot.increment_run_growth()

## Get the number of plots in the grid
## @returns: Total number of plots
func get_plot_count() -> int:
	return plots.size()

## Get all plots in the grid
## @returns: Array of all Plot instances
func get_all_plots() -> Array:
	return plots.duplicate()

## Get plots by state
## @param state: PlotState to filter by
## @returns: Array of plots matching the specified state
func get_plots_by_state(state) -> Array:
	var filtered: Array = []
	for plot in plots:
		if is_instance_valid(plot) and plot.state == state:
			filtered.append(plot)
	return filtered

## Serialize all plot states for saving
## @returns: Array of dictionaries containing plot states
func serialize_plots() -> Array[Dictionary]:
	var plot_states: Array[Dictionary] = []
	for plot in plots:
		if is_instance_valid(plot):
			plot_states.append(plot.to_dict())
	return plot_states

## Restore plot states from saved data
## @param plot_states: Array of dictionaries containing plot states
func deserialize_plots(plot_states: Array[Dictionary]) -> void:
	# Ensure we have the right number of plots
	if plot_states.size() != plots.size():
		push_warning("FarmGrid.deserialize_plots: plot count mismatch (saved: %d, current: %d)" % [plot_states.size(), plots.size()])
		# Continue anyway, restore what we can
	
	# Load all crop resources into a database
	var crop_database = _load_crop_database()
	
	var count = min(plot_states.size(), plots.size())
	for i in range(count):
		if is_instance_valid(plots[i]):
			plots[i].from_dict(plot_states[i], crop_database)

## Load all CropData resources from the resources/crops directory
## @returns: Dictionary mapping crop_id to CropData resources
func _load_crop_database() -> Dictionary:
	var database: Dictionary = {}
	
	# List of known crop resource paths
	var crop_paths = [
		"res://resources/crops/health_berry.tres",
		"res://resources/crops/vitality_herb.tres",
		"res://resources/crops/ammo_grain.tres",
		"res://resources/crops/power_root.tres",
		"res://resources/crops/weapon_flower.tres"
	]
	
	for path in crop_paths:
		if ResourceLoader.exists(path):
			var crop = load(path)
			if crop:
				database[crop.crop_id] = crop
	
	return database

## Called when a plot completes growth
func _on_plot_growth_completed(plot) -> void:
	# This can be used for visual/audio feedback in the future
	pass

## Helper method to determine seed type from crop_id
## Convention: crop_id like "health_berry" maps to "health_seeds"
## @param crop_id: The crop identifier
## @returns: The corresponding seed type for inventory lookup
func _get_seed_type_from_crop(crop_id: String) -> String:
	# Extract the prefix from crop_id (e.g., "health" from "health_berry")
	# Common patterns: "health_*", "ammo_*", "weapon_mod_*"
	
	if crop_id.begins_with("health"):
		return "health_seeds"
	elif crop_id.begins_with("ammo"):
		return "ammo_seeds"
	elif crop_id.begins_with("weapon_mod") or crop_id.begins_with("weapon"):
		return "weapon_mod_seeds"
	else:
		# Default fallback: try to extract first word and append "_seeds"
		var parts = crop_id.split("_")
		if parts.size() > 0:
			return parts[0] + "_seeds"
		else:
			return "generic_seeds"

## Process function for continuous updates
func _process(delta: float) -> void:
	update_crop_growth(delta)
