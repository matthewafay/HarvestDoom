extends Resource
## CropData - Defines a crop type with growth and buff parameters
##
## Represents a plantable crop type that grows over time and provides buffs
## when harvested. Each crop has visual generation parameters for procedural
## sprite creation.
##
## Growth can be based on:
## - Time: Real-time seconds elapsed
## - Runs: Number of combat runs completed
##
## Visual generation uses:
## - base_color: Primary color for the crop sprite
## - shape_type: Geometric shape category ("round", "tall", "leafy")
##
## Validates: Requirements 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 12.5

class_name CropData

## Unique identifier for this crop type
## Examples: "health_berry", "ammo_grain", "weapon_flower"
@export var crop_id: String = ""

## Display name shown to the player
## Examples: "Health Berry", "Ammo Grain", "Weapon Flower"
@export var display_name: String = ""

## Time required for crop to reach harvestable state
## Interpretation depends on growth_mode:
## - If growth_mode is TIME: seconds of real time
## - If growth_mode is RUNS: number of combat runs completed
@export var growth_time: float = 30.0

## The buff provided when this crop is harvested
## Should be a Buff resource with appropriate type and value
@export var buff_provided = null

## Cost in seeds/currency to plant this crop
@export var seed_cost: int = 10

## Base color for procedural sprite generation
## Used by ProceduralArtGenerator to create crop visuals
@export var base_color: Color = Color.GREEN

## Shape type for procedural sprite generation
## Valid values: "round", "tall", "leafy"
## - "round": Circular/berry-like shapes (e.g., health crops)
## - "tall": Vertical/grain-like shapes (e.g., ammo crops)
## - "leafy": Spread/flower-like shapes (e.g., weapon mod crops)
@export var shape_type: String = "round"

## Growth mode determines how growth_time is interpreted
## Valid values: "time", "runs"
## - "time": Crop grows based on elapsed real-time seconds
## - "runs": Crop grows based on completed combat runs
@export var growth_mode: String = "time"

## Validate the crop data configuration
## Returns true if all required fields are properly set
func is_valid() -> bool:
	if crop_id.is_empty():
		push_warning("CropData.is_valid: crop_id is empty")
		return false
	
	if display_name.is_empty():
		push_warning("CropData.is_valid: display_name is empty")
		return false
	
	if growth_time <= 0:
		push_warning("CropData.is_valid: growth_time must be positive")
		return false
	
	if buff_provided == null:
		push_warning("CropData.is_valid: buff_provided is null")
		return false
	
	if seed_cost < 0:
		push_warning("CropData.is_valid: seed_cost cannot be negative")
		return false
	
	if not shape_type in ["round", "tall", "leafy"]:
		push_warning("CropData.is_valid: shape_type must be 'round', 'tall', or 'leafy'")
		return false
	
	if not growth_mode in ["time", "runs"]:
		push_warning("CropData.is_valid: growth_mode must be 'time' or 'runs'")
		return false
	
	return true

## Get a description of the crop for UI display
func get_description() -> String:
	var buff_desc = ""
	if buff_provided != null:
		# BuffType enum values: HEALTH=0, AMMO=1, WEAPON_MOD=2
		match buff_provided.buff_type:
			0:  # HEALTH
				buff_desc = "+%d Max Health" % buff_provided.value
			1:  # AMMO
				buff_desc = "+%d Ammo" % buff_provided.value
			2:  # WEAPON_MOD
				buff_desc = "Weapon Mod: %s" % buff_provided.weapon_mod_type
	
	var growth_desc = ""
	if growth_mode == "time":
		growth_desc = "%.0f seconds" % growth_time
	else:
		growth_desc = "%.0f runs" % growth_time
	
	return "%s - %s (Growth: %s)" % [display_name, buff_desc, growth_desc]
