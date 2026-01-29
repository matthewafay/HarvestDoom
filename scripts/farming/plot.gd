extends Node2D
## Plot - Individual farming plot with crop state management
##
## Represents a single tile in the farming grid where crops can be planted,
## grown, and harvested. Manages crop state transitions and growth progress
## with support for both time-based and run-based growth modes.
##
## State Transitions:
## EMPTY -> GROWING (via plant())
## GROWING -> HARVESTABLE (when growth_progress >= growth_time)
## HARVESTABLE -> EMPTY (via harvest())
##
## Growth Modes:
## - Time-based: Growth progresses based on elapsed real-time seconds
## - Run-based: Growth progresses based on completed combat runs
##
## Visual Generation:
## - Uses ProceduralArtGenerator to create crop sprites for each growth stage
## - Sprites are generated based on CropData.base_color and CropData.shape_type
## - Growth stages: 0 (empty), 1 (early), 2 (mid), 3 (harvestable)
##
## Validates: Requirements 4.2, 4.3, 4.4, 4.5, 12.5

class_name Plot

## Plot state enumeration
enum PlotState {
	EMPTY,       ## No crop planted, ready for planting
	GROWING,     ## Crop is planted and growing
	HARVESTABLE  ## Crop is fully grown and ready to harvest
}

## Current state of the plot
var state: PlotState = PlotState.EMPTY

## Type of crop currently planted (empty string if no crop)
## Should match a CropData.crop_id value
var crop_type: String = ""

## Current growth progress
## For time-based: seconds elapsed
## For run-based: number of runs completed
var growth_progress: float = 0.0

## Time required to reach harvestable state
## Copied from CropData.growth_time when crop is planted
var growth_time: float = 30.0

## Reference to the CropData for the currently planted crop
## Null when plot is empty
var crop_data = null

## Sprite node for displaying crop visuals
## Created in _ready() if not already present
var sprite: Sprite2D = null

## Reference to ProceduralArtGenerator for sprite generation
## Set automatically from GameManager autoload
## Note: Using untyped to avoid class loading order issues
var art_generator = null

## Emitted when crop completes growth and becomes harvestable
signal growth_completed()

## Plant a crop in this plot
## @param crop: CropData resource defining the crop to plant
## @returns: true if planting succeeded, false if plot is not empty
func plant(crop) -> bool:
	if state != PlotState.EMPTY:
		push_warning("Plot.plant: Cannot plant in non-empty plot (state: %d)" % state)
		return false
	
	if crop == null:
		push_error("Plot.plant: crop parameter is null")
		return false
	
	if not crop.is_valid():
		push_error("Plot.plant: crop data is invalid")
		return false
	
	# Store crop data and initialize growth
	crop_data = crop
	crop_type = crop.crop_id
	growth_time = crop.growth_time
	growth_progress = 0.0
	state = PlotState.GROWING
	
	# Update visual representation
	_update_visual()
	
	return true

## Update growth progress for time-based crops
## Should be called each frame with delta time
## @param delta: Time elapsed since last update in seconds
func update_growth(delta: float) -> void:
	if state != PlotState.GROWING:
		return
	
	if crop_data == null:
		push_error("Plot.update_growth: crop_data is null in GROWING state")
		return
	
	# Only update if this is a time-based crop
	if crop_data.growth_mode != "time":
		return
	
	# Increment growth progress
	growth_progress += delta
	
	# Check if growth is complete
	if growth_progress >= growth_time:
		_complete_growth()
	else:
		# Update visual for intermediate growth stages
		_update_visual()

## Increment growth progress for run-based crops
## Should be called when a combat run is completed
func increment_run_growth() -> void:
	if state != PlotState.GROWING:
		return
	
	if crop_data == null:
		push_error("Plot.increment_run_growth: crop_data is null in GROWING state")
		return
	
	# Only update if this is a run-based crop
	if crop_data.growth_mode != "runs":
		return
	
	# Increment growth progress by 1 run
	growth_progress += 1.0
	
	# Check if growth is complete
	if growth_progress >= growth_time:
		_complete_growth()
	else:
		# Update visual for intermediate growth stages
		_update_visual()

## Complete the growth process and transition to HARVESTABLE state
func _complete_growth() -> void:
	state = PlotState.HARVESTABLE
	growth_progress = growth_time  # Clamp to exact growth time
	_update_visual()
	growth_completed.emit()

## Harvest the crop from this plot
## @returns: Dictionary with crop resources, or empty dict if harvest failed
## Dictionary format: {"crop_id": String, "buff": Buff}
func harvest() -> Dictionary:
	if state != PlotState.HARVESTABLE:
		push_warning("Plot.harvest: Cannot harvest non-harvestable plot (state: %d)" % state)
		return {}
	
	if crop_data == null:
		push_error("Plot.harvest: crop_data is null in HARVESTABLE state")
		return {}
	
	# Prepare harvest result
	var result = {
		"crop_id": crop_type,
		"buff": crop_data.buff_provided
	}
	
	# Clear plot state
	state = PlotState.EMPTY
	crop_type = ""
	crop_data = null
	growth_progress = 0.0
	growth_time = 30.0
	
	# Update visual
	_update_visual()
	
	return result

## Get the current visual stage for sprite generation
## @returns: Integer from 0-3 representing growth stage
## - 0: Empty plot
## - 1: Early growth (0-33% progress)
## - 2: Mid growth (33-66% progress)
## - 3: Late growth / Harvestable (66-100% progress)
func get_visual_stage() -> int:
	match state:
		PlotState.EMPTY:
			return 0
		PlotState.GROWING:
			var progress_ratio = growth_progress / growth_time if growth_time > 0 else 0.0
			if progress_ratio < 0.33:
				return 1
			elif progress_ratio < 0.66:
				return 2
			else:
				return 3
		PlotState.HARVESTABLE:
			return 3
		_:
			return 0

## Get the growth progress as a percentage (0.0 to 1.0)
## @returns: Float representing completion percentage
func get_growth_percentage() -> float:
	if state == PlotState.EMPTY:
		return 0.0
	elif state == PlotState.HARVESTABLE:
		return 1.0
	else:
		return growth_progress / growth_time if growth_time > 0 else 0.0

## Initialize the plot
func _ready() -> void:
	# Create sprite node if it doesn't exist
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.centered = true
		add_child(sprite)
	
	# Get reference to ProceduralArtGenerator from GameManager
	if art_generator == null and has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		if game_manager.has_node("ProceduralArtGenerator"):
			art_generator = game_manager.get_node("ProceduralArtGenerator")
	
	# Initialize visual
	_update_visual()

## Update the visual representation of the plot
## Generates crop sprite based on current growth stage using ProceduralArtGenerator
func _update_visual() -> void:
	# Ensure sprite node exists
	if sprite == null:
		return
	
	# Get current growth stage
	var stage = get_visual_stage()
	
	# If empty, hide sprite
	if stage == 0 or crop_data == null:
		sprite.visible = false
		return
	
	# Generate sprite for current growth stage
	if art_generator != null:
		# Use crop_type as base for seed, combined with stage for variation
		var seed_value = crop_type.hash() + stage
		var texture = art_generator.generate_crop_sprite(crop_type, stage, seed_value)
		
		if texture != null:
			sprite.texture = texture
			sprite.visible = true
		else:
			push_warning("Plot._update_visual: Failed to generate sprite for crop '%s' stage %d" % [crop_type, stage])
			sprite.visible = false
	else:
		# Fallback: show a colored square if art generator is not available
		_create_fallback_visual(stage)

## Serialize plot state for saving
## @returns: Dictionary containing all plot state
func to_dict() -> Dictionary:
	return {
		"state": state,
		"crop_type": crop_type,
		"growth_progress": growth_progress,
		"growth_time": growth_time
	}

## Restore plot state from saved data
## @param data: Dictionary containing plot state
## @param crop_database: Dictionary mapping crop_id to CropData resources
func from_dict(data: Dictionary, crop_database: Dictionary) -> void:
	state = data.get("state", PlotState.EMPTY)
	crop_type = data.get("crop_type", "")
	growth_progress = data.get("growth_progress", 0.0)
	growth_time = data.get("growth_time", 30.0)
	
	# Restore crop_data reference if crop is planted
	if not crop_type.is_empty() and crop_database.has(crop_type):
		crop_data = crop_database[crop_type]
	else:
		crop_data = null
	
	_update_visual()

## Create a fallback visual when ProceduralArtGenerator is not available
## Used for testing or when art generator is not initialized
func _create_fallback_visual(stage: int) -> void:
	if sprite == null:
		return
	
	# Create a simple colored square as fallback
	var size = 32
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	# Color based on growth stage
	var color: Color
	match stage:
		1:
			color = Color(0.3, 0.6, 0.3, 1.0)  # Light green for early growth
		2:
			color = Color(0.4, 0.7, 0.4, 1.0)  # Medium green for mid growth
		3:
			color = Color(0.5, 0.8, 0.5, 1.0)  # Bright green for harvestable
		_:
			color = Color(0.2, 0.4, 0.2, 1.0)  # Dark green default
	
	image.fill(color)
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.visible = true
