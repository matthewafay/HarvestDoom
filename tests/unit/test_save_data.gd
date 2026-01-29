# GdUnit generated TestSuite
class_name TestSaveData
extends GdUnitTestSuite

## Unit tests for SaveData resource class
##
## Tests verify:
## - SaveData creation and initialization
## - to_dict() serialization method
## - from_dict() deserialization method
## - is_valid() validation method
## - get_summary() display method
## - Round-trip serialization/deserialization
## - Edge cases and error handling
##
## Validates: Requirements 16.1, 16.2, 16.3

# Reference to the source being tested
const __source = 'res://resources/save_data.gd'

# ============================================================================
# SaveData Creation and Initialization Tests
# ============================================================================

func test_save_data_creation() -> void:
	"""Test that a SaveData can be created."""
	var save_data = SaveData.new()
	
	assert_object(save_data).is_not_null()
	assert_object(save_data).is_instanceof(SaveData)
	assert_object(save_data).is_instanceof(Resource)

func test_save_data_default_values() -> void:
	"""Test that SaveData has correct default values."""
	var save_data = SaveData.new()
	
	assert_array(save_data.unlocked_upgrades).is_empty()
	assert_dict(save_data.inventory).is_empty()
	assert_array(save_data.plot_states).is_empty()
	assert_int(save_data.total_runs_completed).is_equal(0)
	assert_int(save_data.timestamp).is_equal(0)

func test_save_data_fields_can_be_set() -> void:
	"""Test that all SaveData fields can be set."""
	var save_data = SaveData.new()
	
	save_data.unlocked_upgrades = ["max_health_1", "dash_cooldown_1"]
	save_data.inventory = {"credits": 500, "seeds": 20}
	save_data.plot_states = [{"crop_id": "health_berry", "growth_progress": 0.5}]
	save_data.total_runs_completed = 10
	save_data.timestamp = 1234567890
	
	assert_array(save_data.unlocked_upgrades).has_size(2)
	assert_dict(save_data.inventory).has_size(2)
	assert_array(save_data.plot_states).has_size(1)
	assert_int(save_data.total_runs_completed).is_equal(10)
	assert_int(save_data.timestamp).is_equal(1234567890)

# ============================================================================
# to_dict() Serialization Tests
# ============================================================================

func test_to_dict_returns_dictionary() -> void:
	"""Test that to_dict() returns a Dictionary."""
	var save_data = SaveData.new()
	var dict = save_data.to_dict()
	
	assert_object(dict).is_instanceof(Dictionary)

func test_to_dict_contains_all_fields() -> void:
	"""Test that to_dict() includes all required fields."""
	var save_data = SaveData.new()
	var dict = save_data.to_dict()
	
	assert_bool(dict.has("unlocked_upgrades")).is_true()
	assert_bool(dict.has("inventory")).is_true()
	assert_bool(dict.has("plot_states")).is_true()
	assert_bool(dict.has("total_runs_completed")).is_true()
	assert_bool(dict.has("timestamp")).is_true()

func test_to_dict_with_empty_data() -> void:
	"""Test that to_dict() works with default/empty data."""
	var save_data = SaveData.new()
	var dict = save_data.to_dict()
	
	assert_array(dict["unlocked_upgrades"]).is_empty()
	assert_dict(dict["inventory"]).is_empty()
	assert_array(dict["plot_states"]).is_empty()
	assert_int(dict["total_runs_completed"]).is_equal(0)
	assert_int(dict["timestamp"]).is_equal(0)

func test_to_dict_with_populated_data() -> void:
	"""Test that to_dict() correctly serializes populated data."""
	var save_data = SaveData.new()
	save_data.unlocked_upgrades = ["max_health_1", "fire_rate_1"]
	save_data.inventory = {"credits": 1000, "seeds": 50, "ammo": 200}
	save_data.plot_states = [
		{"crop_id": "health_berry", "growth_progress": 0.75, "state": 1},
		{"crop_id": "ammo_grain", "growth_progress": 1.0, "state": 2}
	]
	save_data.total_runs_completed = 25
	save_data.timestamp = 1700000000
	
	var dict = save_data.to_dict()
	
	assert_array(dict["unlocked_upgrades"]).contains_exactly(["max_health_1", "fire_rate_1"])
	assert_int(dict["inventory"]["credits"]).is_equal(1000)
	assert_int(dict["inventory"]["seeds"]).is_equal(50)
	assert_int(dict["inventory"]["ammo"]).is_equal(200)
	assert_array(dict["plot_states"]).has_size(2)
	assert_str(dict["plot_states"][0]["crop_id"]).is_equal("health_berry")
	assert_float(dict["plot_states"][0]["growth_progress"]).is_equal(0.75)
	assert_int(dict["total_runs_completed"]).is_equal(25)
	assert_int(dict["timestamp"]).is_equal(1700000000)

func test_to_dict_with_many_upgrades() -> void:
	"""Test that to_dict() handles many unlocked upgrades."""
	var save_data = SaveData.new()
	save_data.unlocked_upgrades = [
		"max_health_1", "max_health_2", "max_health_3",
		"dash_cooldown_1", "dash_cooldown_2",
		"fire_rate_1", "fire_rate_2", "fire_rate_3"
	]
	
	var dict = save_data.to_dict()
	
	assert_array(dict["unlocked_upgrades"]).has_size(8)
	assert_array(dict["unlocked_upgrades"]).contains("max_health_1")
	assert_array(dict["unlocked_upgrades"]).contains("fire_rate_3")

func test_to_dict_with_complex_inventory() -> void:
	"""Test that to_dict() handles complex inventory data."""
	var save_data = SaveData.new()
	save_data.inventory = {
		"credits": 5000,
		"seeds": 100,
		"ammo": 500,
		"health_berry": 10,
		"ammo_grain": 5,
		"weapon_flower": 3
	}
	
	var dict = save_data.to_dict()
	
	assert_dict(dict["inventory"]).has_size(6)
	assert_int(dict["inventory"]["credits"]).is_equal(5000)
	assert_int(dict["inventory"]["weapon_flower"]).is_equal(3)

func test_to_dict_with_many_plots() -> void:
	"""Test that to_dict() handles many plot states."""
	var save_data = SaveData.new()
	save_data.plot_states = []
	
	# Create 12 plot states (typical farm grid size)
	for i in range(12):
		save_data.plot_states.append({
			"crop_id": "crop_%d" % i,
			"growth_progress": i * 0.1,
			"state": i % 3
		})
	
	var dict = save_data.to_dict()
	
	assert_array(dict["plot_states"]).has_size(12)
	assert_str(dict["plot_states"][5]["crop_id"]).is_equal("crop_5")
	assert_float(dict["plot_states"][5]["growth_progress"]).is_equal(0.5)

# ============================================================================
# from_dict() Deserialization Tests
# ============================================================================

func test_from_dict_creates_save_data() -> void:
	"""Test that from_dict() creates a SaveData instance."""
	var dict = {
		"unlocked_upgrades": [],
		"inventory": {},
		"plot_states": [],
		"total_runs_completed": 0,
		"timestamp": 0
	}
	
	var save_data = SaveData.from_dict(dict)
	
	assert_object(save_data).is_not_null()
	assert_object(save_data).is_instanceof(SaveData)

func test_from_dict_with_empty_dictionary() -> void:
	"""Test that from_dict() handles empty dictionary with defaults."""
	var dict = {}
	
	var save_data = SaveData.from_dict(dict)
	
	assert_array(save_data.unlocked_upgrades).is_empty()
	assert_dict(save_data.inventory).is_empty()
	assert_array(save_data.plot_states).is_empty()
	assert_int(save_data.total_runs_completed).is_equal(0)
	assert_int(save_data.timestamp).is_equal(0)

func test_from_dict_with_populated_data() -> void:
	"""Test that from_dict() correctly deserializes populated data."""
	var dict = {
		"unlocked_upgrades": ["max_health_1", "dash_cooldown_1"],
		"inventory": {"credits": 750, "seeds": 30},
		"plot_states": [{"crop_id": "health_berry", "growth_progress": 0.5}],
		"total_runs_completed": 15,
		"timestamp": 1600000000
	}
	
	var save_data = SaveData.from_dict(dict)
	
	assert_array(save_data.unlocked_upgrades).contains_exactly(["max_health_1", "dash_cooldown_1"])
	assert_int(save_data.inventory["credits"]).is_equal(750)
	assert_int(save_data.inventory["seeds"]).is_equal(30)
	assert_array(save_data.plot_states).has_size(1)
	assert_str(save_data.plot_states[0]["crop_id"]).is_equal("health_berry")
	assert_int(save_data.total_runs_completed).is_equal(15)
	assert_int(save_data.timestamp).is_equal(1600000000)

func test_from_dict_with_missing_fields() -> void:
	"""Test that from_dict() uses defaults for missing fields."""
	var dict = {
		"unlocked_upgrades": ["max_health_1"],
		"total_runs_completed": 5
		# Missing: inventory, plot_states, timestamp
	}
	
	var save_data = SaveData.from_dict(dict)
	
	assert_array(save_data.unlocked_upgrades).has_size(1)
	assert_dict(save_data.inventory).is_empty()  # Default
	assert_array(save_data.plot_states).is_empty()  # Default
	assert_int(save_data.total_runs_completed).is_equal(5)
	assert_int(save_data.timestamp).is_equal(0)  # Default

func test_from_dict_with_extra_fields() -> void:
	"""Test that from_dict() ignores extra fields."""
	var dict = {
		"unlocked_upgrades": ["fire_rate_1"],
		"inventory": {"credits": 100},
		"plot_states": [],
		"total_runs_completed": 3,
		"timestamp": 1500000000,
		"extra_field": "should_be_ignored",
		"another_extra": 999
	}
	
	var save_data = SaveData.from_dict(dict)
	
	# Should only have the expected fields
	assert_array(save_data.unlocked_upgrades).has_size(1)
	assert_int(save_data.inventory["credits"]).is_equal(100)
	assert_int(save_data.total_runs_completed).is_equal(3)

func test_from_dict_with_null_values() -> void:
	"""Test that from_dict() handles null values gracefully."""
	var dict = {
		"unlocked_upgrades": null,
		"inventory": null,
		"plot_states": null,
		"total_runs_completed": null,
		"timestamp": null
	}
	
	var save_data = SaveData.from_dict(dict)
	
	# Should use defaults for null values
	assert_array(save_data.unlocked_upgrades).is_empty()
	assert_dict(save_data.inventory).is_empty()
	assert_array(save_data.plot_states).is_empty()
	assert_int(save_data.total_runs_completed).is_equal(0)
	assert_int(save_data.timestamp).is_equal(0)

# ============================================================================
# Round-Trip Serialization Tests
# ============================================================================

func test_round_trip_serialization_empty_data() -> void:
	"""Test that empty data survives round-trip serialization."""
	var original = SaveData.new()
	
	var dict = original.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_array(restored.unlocked_upgrades).is_empty()
	assert_dict(restored.inventory).is_empty()
	assert_array(restored.plot_states).is_empty()
	assert_int(restored.total_runs_completed).is_equal(0)
	assert_int(restored.timestamp).is_equal(0)

func test_round_trip_serialization_populated_data() -> void:
	"""Test that populated data survives round-trip serialization."""
	var original = SaveData.new()
	original.unlocked_upgrades = ["max_health_1", "fire_rate_1", "dash_cooldown_1"]
	original.inventory = {"credits": 2500, "seeds": 75, "ammo": 300}
	original.plot_states = [
		{"crop_id": "health_berry", "growth_progress": 0.8, "state": 1},
		{"crop_id": "ammo_grain", "growth_progress": 0.3, "state": 1}
	]
	original.total_runs_completed = 42
	original.timestamp = 1700000000
	
	var dict = original.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_array(restored.unlocked_upgrades).contains_exactly(original.unlocked_upgrades)
	assert_int(restored.inventory["credits"]).is_equal(2500)
	assert_int(restored.inventory["seeds"]).is_equal(75)
	assert_int(restored.inventory["ammo"]).is_equal(300)
	assert_array(restored.plot_states).has_size(2)
	assert_str(restored.plot_states[0]["crop_id"]).is_equal("health_berry")
	assert_float(restored.plot_states[0]["growth_progress"]).is_equal(0.8)
	assert_int(restored.total_runs_completed).is_equal(42)
	assert_int(restored.timestamp).is_equal(1700000000)

func test_round_trip_serialization_complex_data() -> void:
	"""Test that complex data survives round-trip serialization."""
	var original = SaveData.new()
	original.unlocked_upgrades = [
		"max_health_1", "max_health_2", "max_health_3",
		"dash_cooldown_1", "dash_cooldown_2",
		"fire_rate_1", "fire_rate_2"
	]
	original.inventory = {
		"credits": 10000,
		"seeds": 200,
		"ammo": 1000,
		"health_berry": 25,
		"ammo_grain": 15,
		"weapon_flower": 8
	}
	original.plot_states = []
	for i in range(12):
		original.plot_states.append({
			"crop_id": "crop_%d" % i,
			"growth_progress": randf(),
			"state": i % 3
		})
	original.total_runs_completed = 100
	original.timestamp = 1750000000
	
	var dict = original.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_array(restored.unlocked_upgrades).has_size(7)
	assert_dict(restored.inventory).has_size(6)
	assert_array(restored.plot_states).has_size(12)
	assert_int(restored.total_runs_completed).is_equal(100)
	assert_int(restored.timestamp).is_equal(1750000000)

# ============================================================================
# is_valid() Validation Tests
# ============================================================================

func test_is_valid_with_default_data() -> void:
	"""Test that default SaveData is valid."""
	var save_data = SaveData.new()
	
	assert_bool(save_data.is_valid()).is_true()

func test_is_valid_with_populated_data() -> void:
	"""Test that populated SaveData is valid."""
	var save_data = SaveData.new()
	save_data.unlocked_upgrades = ["max_health_1"]
	save_data.inventory = {"credits": 100}
	save_data.plot_states = [{"crop_id": "test"}]
	save_data.total_runs_completed = 5
	save_data.timestamp = 1600000000
	
	assert_bool(save_data.is_valid()).is_true()

func test_is_valid_with_negative_runs() -> void:
	"""Test that negative total_runs_completed is invalid."""
	var save_data = SaveData.new()
	save_data.total_runs_completed = -1
	
	assert_bool(save_data.is_valid()).is_false()

func test_is_valid_with_negative_timestamp() -> void:
	"""Test that negative timestamp is invalid."""
	var save_data = SaveData.new()
	save_data.timestamp = -1
	
	assert_bool(save_data.is_valid()).is_false()

func test_is_valid_with_large_values() -> void:
	"""Test that large valid values are accepted."""
	var save_data = SaveData.new()
	save_data.total_runs_completed = 999999
	save_data.timestamp = 2147483647  # Max 32-bit int
	
	assert_bool(save_data.is_valid()).is_true()

# ============================================================================
# get_summary() Display Tests
# ============================================================================

func test_get_summary_returns_string() -> void:
	"""Test that get_summary() returns a String."""
	var save_data = SaveData.new()
	var summary = save_data.get_summary()
	
	assert_object(summary).is_instanceof(String)

func test_get_summary_contains_key_information() -> void:
	"""Test that get_summary() includes key save data information."""
	var save_data = SaveData.new()
	save_data.unlocked_upgrades = ["max_health_1", "fire_rate_1"]
	save_data.inventory = {"credits": 500, "seeds": 20}
	save_data.total_runs_completed = 10
	save_data.timestamp = 1700000000
	
	var summary = save_data.get_summary()
	
	# Should mention upgrades, resources, and runs
	assert_bool(summary.contains("2 upgrades")).is_true()
	assert_bool(summary.contains("2 resources")).is_true()
	assert_bool(summary.contains("10 runs")).is_true()

func test_get_summary_with_empty_data() -> void:
	"""Test that get_summary() works with empty data."""
	var save_data = SaveData.new()
	save_data.timestamp = 1600000000
	
	var summary = save_data.get_summary()
	
	assert_bool(summary.contains("0 upgrades")).is_true()
	assert_bool(summary.contains("0 resources")).is_true()
	assert_bool(summary.contains("0 runs")).is_true()

func test_get_summary_with_many_items() -> void:
	"""Test that get_summary() handles many items."""
	var save_data = SaveData.new()
	save_data.unlocked_upgrades = ["u1", "u2", "u3", "u4", "u5"]
	save_data.inventory = {"r1": 1, "r2": 2, "r3": 3, "r4": 4}
	save_data.total_runs_completed = 100
	save_data.timestamp = 1700000000
	
	var summary = save_data.get_summary()
	
	assert_bool(summary.contains("5 upgrades")).is_true()
	assert_bool(summary.contains("4 resources")).is_true()
	assert_bool(summary.contains("100 runs")).is_true()

# ============================================================================
# Resource Type Tests
# ============================================================================

func test_save_data_is_resource_type() -> void:
	"""Test that SaveData extends Resource for serialization."""
	var save_data = SaveData.new()
	
	assert_object(save_data).is_instanceof(Resource)

func test_save_data_can_be_duplicated() -> void:
	"""Test that SaveData resources can be duplicated."""
	var original = SaveData.new()
	original.unlocked_upgrades = ["max_health_1"]
	original.inventory = {"credits": 100}
	original.total_runs_completed = 5
	original.timestamp = 1600000000
	
	var duplicate = original.duplicate()
	
	assert_object(duplicate).is_not_null()
	assert_array(duplicate.unlocked_upgrades).has_size(1)
	assert_int(duplicate.inventory["credits"]).is_equal(100)
	assert_int(duplicate.total_runs_completed).is_equal(5)
	assert_int(duplicate.timestamp).is_equal(1600000000)

# ============================================================================
# Edge Case Tests
# ============================================================================

func test_save_data_with_empty_plot_states() -> void:
	"""Test that empty plot_states array is handled correctly."""
	var save_data = SaveData.new()
	save_data.plot_states = []
	
	var dict = save_data.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_array(restored.plot_states).is_empty()

func test_save_data_with_zero_timestamp() -> void:
	"""Test that zero timestamp is valid (epoch time)."""
	var save_data = SaveData.new()
	save_data.timestamp = 0
	
	assert_bool(save_data.is_valid()).is_true()

func test_save_data_with_very_large_timestamp() -> void:
	"""Test that large future timestamps are valid."""
	var save_data = SaveData.new()
	save_data.timestamp = 2147483647  # Year 2038
	
	assert_bool(save_data.is_valid()).is_true()

func test_save_data_with_empty_strings_in_upgrades() -> void:
	"""Test that empty strings in unlocked_upgrades are preserved."""
	var save_data = SaveData.new()
	save_data.unlocked_upgrades = ["max_health_1", "", "fire_rate_1"]
	
	var dict = save_data.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_array(restored.unlocked_upgrades).has_size(3)
	assert_str(restored.unlocked_upgrades[1]).is_equal("")

func test_save_data_with_zero_values_in_inventory() -> void:
	"""Test that zero values in inventory are preserved."""
	var save_data = SaveData.new()
	save_data.inventory = {"credits": 0, "seeds": 100, "ammo": 0}
	
	var dict = save_data.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_int(restored.inventory["credits"]).is_equal(0)
	assert_int(restored.inventory["seeds"]).is_equal(100)
	assert_int(restored.inventory["ammo"]).is_equal(0)

func test_save_data_with_negative_inventory_values() -> void:
	"""Test that negative inventory values are preserved (for debt/penalties)."""
	var save_data = SaveData.new()
	save_data.inventory = {"credits": -50}
	
	var dict = save_data.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_int(restored.inventory["credits"]).is_equal(-50)

func test_save_data_with_duplicate_upgrades() -> void:
	"""Test that duplicate upgrades in array are preserved."""
	var save_data = SaveData.new()
	save_data.unlocked_upgrades = ["max_health_1", "max_health_1", "fire_rate_1"]
	
	var dict = save_data.to_dict()
	var restored = SaveData.from_dict(dict)
	
	# Duplicates should be preserved (validation is ProgressionManager's job)
	assert_array(restored.unlocked_upgrades).has_size(3)

func test_save_data_with_special_characters_in_keys() -> void:
	"""Test that special characters in dictionary keys are preserved."""
	var save_data = SaveData.new()
	save_data.inventory = {
		"item_with_underscore": 10,
		"item-with-dash": 20,
		"item.with.dot": 30
	}
	
	var dict = save_data.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_int(restored.inventory["item_with_underscore"]).is_equal(10)
	assert_int(restored.inventory["item-with-dash"]).is_equal(20)
	assert_int(restored.inventory["item.with.dot"]).is_equal(30)

func test_save_data_with_nested_plot_state_data() -> void:
	"""Test that complex nested plot state data is preserved."""
	var save_data = SaveData.new()
	save_data.plot_states = [
		{
			"crop_id": "health_berry",
			"growth_progress": 0.75,
			"state": 1,
			"extra_data": {"planted_at": 1600000000, "fertilized": true}
		}
	]
	
	var dict = save_data.to_dict()
	var restored = SaveData.from_dict(dict)
	
	assert_array(restored.plot_states).has_size(1)
	assert_str(restored.plot_states[0]["crop_id"]).is_equal("health_berry")
	assert_object(restored.plot_states[0]["extra_data"]).is_instanceof(Dictionary)
	assert_int(restored.plot_states[0]["extra_data"]["planted_at"]).is_equal(1600000000)
	assert_bool(restored.plot_states[0]["extra_data"]["fertilized"]).is_true()
