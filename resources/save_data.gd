extends Resource
## SaveData - Game state serialization resource
##
## Represents the complete saveable game state including progression,
## inventory, and farming state. Used by ProgressionManager for save/load
## functionality.
##
## Serialization:
## - to_dict(): Converts SaveData to Dictionary for JSON serialization
## - from_dict(): Static method to reconstruct SaveData from Dictionary
##
## Saved data includes:
## - unlocked_upgrades: Array of upgrade IDs that have been purchased
## - inventory: Dictionary of resource types to quantities
## - plot_states: Array of plot state dictionaries for farming persistence
## - total_runs_completed: Counter for completed combat runs
## - timestamp: Unix timestamp of when save was created
##
## Validates: Requirements 16.1, 16.2, 16.3

class_name SaveData

## Array of unlocked upgrade IDs
## Example: ["max_health_1", "dash_cooldown_1", "fire_rate_1"]
@export var unlocked_upgrades: Array[String] = []

## Dictionary mapping resource types to quantities
## Example: {"credits": 500, "seeds": 20, "ammo": 50}
@export var inventory: Dictionary = {}

## Array of plot state dictionaries for farming persistence
## Each dictionary contains: {crop_id: String, growth_progress: float, state: int}
## Empty plots are represented as empty dictionaries or null entries
@export var plot_states: Array[Dictionary] = []

## Total number of combat runs completed across all sessions
## Used for statistics and run-based crop growth
@export var total_runs_completed: int = 0

## Unix timestamp (seconds since epoch) when this save was created
## Used for time-based crop growth and save file management
@export var timestamp: int = 0

## Convert SaveData to Dictionary for JSON serialization
##
## Returns a Dictionary containing all save data fields that can be
## serialized to JSON and written to disk.
##
## Returns:
##   Dictionary with keys: unlocked_upgrades, inventory, plot_states,
##   total_runs_completed, timestamp
func to_dict() -> Dictionary:
	return {
		"unlocked_upgrades": unlocked_upgrades,
		"inventory": inventory,
		"plot_states": plot_states,
		"total_runs_completed": total_runs_completed,
		"timestamp": timestamp
	}

## Create SaveData from Dictionary (deserialization)
##
## Static method to reconstruct a SaveData resource from a Dictionary
## loaded from JSON. Uses get() with default values to handle missing
## or corrupted data gracefully.
##
## Args:
##   data: Dictionary containing save data fields
##
## Returns:
##   SaveData resource populated with data from the dictionary
static func from_dict(data: Dictionary) -> SaveData:
	var save = SaveData.new()
	save.unlocked_upgrades = data.get("unlocked_upgrades", [])
	save.inventory = data.get("inventory", {})
	save.plot_states = data.get("plot_states", [])
	save.total_runs_completed = data.get("total_runs_completed", 0)
	save.timestamp = data.get("timestamp", 0)
	return save

## Validate the save data structure
##
## Checks that all fields are properly typed and contain valid data.
## Used to detect corrupted save files.
##
## Returns:
##   true if save data is valid, false otherwise
func is_valid() -> bool:
	# Check unlocked_upgrades is an array
	if not unlocked_upgrades is Array:
		push_warning("SaveData.is_valid: unlocked_upgrades is not an Array")
		return false
	
	# Check inventory is a dictionary
	if not inventory is Dictionary:
		push_warning("SaveData.is_valid: inventory is not a Dictionary")
		return false
	
	# Check plot_states is an array
	if not plot_states is Array:
		push_warning("SaveData.is_valid: plot_states is not an Array")
		return false
	
	# Check numeric fields are non-negative
	if total_runs_completed < 0:
		push_warning("SaveData.is_valid: total_runs_completed cannot be negative")
		return false
	
	if timestamp < 0:
		push_warning("SaveData.is_valid: timestamp cannot be negative")
		return false
	
	return true

## Get a human-readable summary of the save data
##
## Returns a formatted string describing the save state, useful for
## debugging and save file selection UI.
##
## Returns:
##   String describing the save state
func get_summary() -> String:
	var time_str = Time.get_datetime_string_from_unix_time(timestamp)
	var upgrade_count = unlocked_upgrades.size()
	var resource_count = inventory.size()
	
	return "Save from %s - %d upgrades, %d resources, %d runs completed" % [
		time_str,
		upgrade_count,
		resource_count,
		total_runs_completed
	]
