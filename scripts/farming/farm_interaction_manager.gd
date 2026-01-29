extends Node
## FarmInteractionManager - Manages player interaction with farm plots
##
## This manager detects when the player is near a plot and displays
## appropriate interaction prompts based on plot state and player inventory.
##
## Responsibilities:
## - Detect player proximity to plots
## - Determine appropriate prompt text based on context
## - Show/hide interaction prompts
## - Handle interaction input (E key)
##
## Validates: Requirements 4.5, 10.3, 12.5

class_name FarmInteractionManager

## Reference to the FarmGrid
var farm_grid = null

## Reference to the InteractionPrompt UI
var interaction_prompt = null

## Reference to the player (for position checking)
var player = null

## Maximum distance for interaction (in world units)
@export var interaction_distance: float = 2.0

## Currently nearby plot (if any)
var nearby_plot = null

## Crop data database (mapping crop_id to CropData resources)
var crop_database: Dictionary = {}

## Currently selected crop for planting (if any)
var selected_crop = null

func _ready() -> void:
	# Initialize crop database with default crops
	_initialize_crop_database()

## Initialize the manager with required references
## @param grid: The FarmGrid to monitor
## @param prompt: The InteractionPrompt UI element
## @param player_node: The player node (for position checking)
func initialize(grid, prompt, player_node) -> void:
	farm_grid = grid
	interaction_prompt = prompt
	player = player_node
	
	if farm_grid == null:
		push_error("FarmInteractionManager.initialize: farm_grid is null")
	if interaction_prompt == null:
		push_error("FarmInteractionManager.initialize: interaction_prompt is null")
	if player == null:
		push_error("FarmInteractionManager.initialize: player is null")

## Process function to check for nearby plots and update prompts
func _process(_delta: float) -> void:
	if not _is_initialized():
		return
	
	# Check for nearby plot
	var plot = _find_nearby_plot()
	
	if plot != null and plot != nearby_plot:
		# New plot detected
		nearby_plot = plot
		_update_prompt_for_plot(plot)
	elif plot == null and nearby_plot != null:
		# Player moved away from plot
		nearby_plot = null
		interaction_prompt.hide_prompt()
	elif plot != null and plot == nearby_plot:
		# Still near same plot, update prompt in case state changed
		_update_prompt_for_plot(plot)

## Handle input for interaction
func _input(event: InputEvent) -> void:
	if not _is_initialized():
		return
	
	# Check for interaction key (E)
	if event.is_action_pressed("interact") and nearby_plot != null:
		_handle_interaction()

## Find the nearest plot within interaction distance
## @returns: Plot instance if found, null otherwise
func _find_nearby_plot():
	if farm_grid == null or player == null:
		return null
	
	# Get player position (convert from 3D to 2D for farm grid)
	var player_pos_3d = player.global_position
	var player_pos_2d = Vector2(player_pos_3d.x, player_pos_3d.z)
	
	# Convert to farm grid's local space
	var grid_pos = farm_grid.to_local(player_pos_2d)
	
	# Get plot at position
	var plot = farm_grid.get_plot_at_position(grid_pos)
	
	if plot != null:
		# Check distance
		var plot_world_pos = farm_grid.to_global(plot.position)
		var distance = player_pos_2d.distance_to(plot_world_pos)
		
		if distance <= interaction_distance:
			return plot
	
	return null

## Update the interaction prompt based on plot state
## @param plot: The plot to check
func _update_prompt_for_plot(plot) -> void:
	if plot == null or interaction_prompt == null:
		return
	
	var prompt_text = ""
	
	# PlotState enum values: EMPTY=0, GROWING=1, HARVESTABLE=2
	match plot.state:
		0:  # EMPTY
			# Check if player has seeds
			if _player_has_seeds():
				prompt_text = "Press E to Plant"
			else:
				prompt_text = "No seeds available"
		
		1:  # GROWING
			# Show growth progress
			var progress_percent = int(plot.get_growth_progress() * 100)
			prompt_text = "Growing... %d%%" % progress_percent
		
		2:  # HARVESTABLE
			prompt_text = "Press E to Harvest"
	
	if not prompt_text.is_empty():
		interaction_prompt.show_prompt(prompt_text)
	else:
		interaction_prompt.hide_prompt()

## Handle interaction with the nearby plot
func _handle_interaction() -> void:
	if nearby_plot == null or farm_grid == null:
		return
	
	# PlotState enum values: EMPTY=0, GROWING=1, HARVESTABLE=2
	match nearby_plot.state:
		0:  # EMPTY
			# Attempt to plant
			if selected_crop != null:
				var success = farm_grid.plant_crop(nearby_plot, selected_crop)
				if success:
					print("Planted %s" % selected_crop.crop_id)
				else:
					print("Failed to plant - insufficient seeds")
			else:
				# Auto-select first available crop
				_auto_select_crop()
				if selected_crop != null:
					var success = farm_grid.plant_crop(nearby_plot, selected_crop)
					if success:
						print("Planted %s" % selected_crop.crop_id)
		
		2:  # HARVESTABLE
			# Attempt to harvest
			var resources = farm_grid.harvest_crop(nearby_plot)
			if not resources.is_empty():
				print("Harvested: %s" % str(resources))

## Check if player has any seeds in inventory
## @returns: true if player has at least one type of seed
func _player_has_seeds() -> bool:
	if not GameManager:
		return false
	
	# Check for any seed type
	var seed_types = ["health_seeds", "ammo_seeds", "weapon_mod_seeds"]
	for seed_type in seed_types:
		if GameManager.get_inventory_amount(seed_type) > 0:
			return true
	
	return false

## Auto-select the first crop type for which the player has seeds
func _auto_select_crop() -> void:
	if not GameManager:
		return
	
	# Try to find a crop the player can afford
	for crop_id in crop_database.keys():
		var crop = crop_database[crop_id]
		var seed_type = _get_seed_type_from_crop(crop.crop_id)
		
		if GameManager.has_inventory_amount(seed_type, crop.seed_cost):
			selected_crop = crop
			return
	
	selected_crop = null

## Helper method to determine seed type from crop_id
## @param crop_id: The crop identifier
## @returns: The corresponding seed type for inventory lookup
func _get_seed_type_from_crop(crop_id: String) -> String:
	if crop_id.begins_with("health"):
		return "health_seeds"
	elif crop_id.begins_with("ammo"):
		return "ammo_seeds"
	elif crop_id.begins_with("weapon_mod") or crop_id.begins_with("weapon"):
		return "weapon_mod_seeds"
	else:
		var parts = crop_id.split("_")
		if parts.size() > 0:
			return parts[0] + "_seeds"
		else:
			return "generic_seeds"

## Check if the manager is properly initialized
## @returns: true if all required references are set
func _is_initialized() -> bool:
	return farm_grid != null and interaction_prompt != null and player != null

## Initialize the crop database with default crops
## This is a placeholder - actual crops will be created in task 6.3.1
func _initialize_crop_database() -> void:
	# For now, create a simple default crop for testing
	# This will be replaced with proper CropData resources in task 6.3.1
	var default_crop = load("res://resources/crops/crop_data.gd").new()
	default_crop.crop_id = "health_berry"
	default_crop.display_name = "Health Berry"
	default_crop.growth_time = 10.0
	default_crop.seed_cost = 1
	default_crop.base_color = Color(1.0, 0.2, 0.2)
	default_crop.shape_type = "round"
	
	crop_database["health_berry"] = default_crop

## Set the crop database from external source
## @param database: Dictionary mapping crop_id to CropData resources
func set_crop_database(database: Dictionary) -> void:
	crop_database = database

## Set the currently selected crop for planting
## @param crop: CropData resource to select
func set_selected_crop(crop) -> void:
	selected_crop = crop

## Get the currently selected crop
## @returns: Currently selected CropData, or null
func get_selected_crop():
	return selected_crop
