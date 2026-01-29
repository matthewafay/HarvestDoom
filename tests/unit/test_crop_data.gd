extends GdUnitTestSuite
## Unit tests for CropData resource class
##
## Tests the CropData resource class which defines crop types with growth
## parameters and visual generation data.
##
## Test Coverage:
## - Field initialization and default values
## - Validation logic for required fields
## - Shape type validation
## - Growth mode validation
## - Description generation
## - Integration with Buff resources
##
## Validates: Requirements 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3

# Test that a new CropData instance has expected default values
func test_default_values() -> void:
	var crop = CropData.new()
	
	assert_str(crop.crop_id).is_empty()
	assert_str(crop.display_name).is_empty()
	assert_float(crop.growth_time).is_equal(30.0)
	assert_object(crop.buff_provided).is_null()
	assert_int(crop.seed_cost).is_equal(10)
	assert_object(crop.base_color).is_equal(Color.GREEN)
	assert_str(crop.shape_type).is_equal("round")
	assert_str(crop.growth_mode).is_equal("time")

# Test that is_valid returns false when crop_id is empty
func test_is_valid_requires_crop_id() -> void:
	var crop = CropData.new()
	crop.display_name = "Test Crop"
	crop.buff_provided = Buff.new()
	
	assert_bool(crop.is_valid()).is_false()

# Test that is_valid returns false when display_name is empty
func test_is_valid_requires_display_name() -> void:
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.buff_provided = Buff.new()
	
	assert_bool(crop.is_valid()).is_false()

# Test that is_valid returns false when buff_provided is null
func test_is_valid_requires_buff() -> void:
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.buff_provided = null
	
	assert_bool(crop.is_valid()).is_false()

# Test that is_valid returns false when growth_time is zero or negative
func test_is_valid_requires_positive_growth_time() -> void:
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.buff_provided = Buff.new()
	
	crop.growth_time = 0
	assert_bool(crop.is_valid()).is_false()
	
	crop.growth_time = -10
	assert_bool(crop.is_valid()).is_false()

# Test that is_valid returns false when seed_cost is negative
func test_is_valid_rejects_negative_seed_cost() -> void:
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.buff_provided = Buff.new()
	crop.seed_cost = -5
	
	assert_bool(crop.is_valid()).is_false()

# Test that is_valid returns false for invalid shape_type
func test_is_valid_requires_valid_shape_type() -> void:
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.buff_provided = Buff.new()
	
	crop.shape_type = "invalid"
	assert_bool(crop.is_valid()).is_false()
	
	crop.shape_type = "square"
	assert_bool(crop.is_valid()).is_false()

# Test that is_valid returns true for all valid shape_types
func test_is_valid_accepts_all_valid_shape_types() -> void:
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.buff_provided = Buff.new()
	
	crop.shape_type = "round"
	assert_bool(crop.is_valid()).is_true()
	
	crop.shape_type = "tall"
	assert_bool(crop.is_valid()).is_true()
	
	crop.shape_type = "leafy"
	assert_bool(crop.is_valid()).is_true()

# Test that is_valid returns false for invalid growth_mode
func test_is_valid_requires_valid_growth_mode() -> void:
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.buff_provided = Buff.new()
	
	crop.growth_mode = "invalid"
	assert_bool(crop.is_valid()).is_false()
	
	crop.growth_mode = "instant"
	assert_bool(crop.is_valid()).is_false()

# Test that is_valid returns true for all valid growth_modes
func test_is_valid_accepts_all_valid_growth_modes() -> void:
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.buff_provided = Buff.new()
	
	crop.growth_mode = "time"
	assert_bool(crop.is_valid()).is_true()
	
	crop.growth_mode = "runs"
	assert_bool(crop.is_valid()).is_true()

# Test that is_valid returns true when all fields are properly set
func test_is_valid_returns_true_for_complete_crop() -> void:
	var crop = CropData.new()
	crop.crop_id = "health_berry"
	crop.display_name = "Health Berry"
	crop.growth_time = 30.0
	crop.buff_provided = Buff.new()
	crop.seed_cost = 10
	crop.base_color = Color.RED
	crop.shape_type = "round"
	crop.growth_mode = "time"
	
	assert_bool(crop.is_valid()).is_true()

# Test get_description with health buff
func test_get_description_with_health_buff() -> void:
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	
	var crop = CropData.new()
	crop.crop_id = "health_berry"
	crop.display_name = "Health Berry"
	crop.growth_time = 30.0
	crop.buff_provided = buff
	crop.growth_mode = "time"
	
	var desc = crop.get_description()
	assert_str(desc).contains("Health Berry")
	assert_str(desc).contains("+20 Max Health")
	assert_str(desc).contains("30 seconds")

# Test get_description with ammo buff
func test_get_description_with_ammo_buff() -> void:
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.AMMO
	buff.value = 50
	
	var crop = CropData.new()
	crop.crop_id = "ammo_grain"
	crop.display_name = "Ammo Grain"
	crop.growth_time = 45.0
	crop.buff_provided = buff
	crop.growth_mode = "time"
	
	var desc = crop.get_description()
	assert_str(desc).contains("Ammo Grain")
	assert_str(desc).contains("+50 Ammo")
	assert_str(desc).contains("45 seconds")

# Test get_description with weapon mod buff
func test_get_description_with_weapon_mod_buff() -> void:
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.WEAPON_MOD
	buff.weapon_mod_type = "fire_rate_boost"
	
	var crop = CropData.new()
	crop.crop_id = "weapon_flower"
	crop.display_name = "Weapon Flower"
	crop.growth_time = 60.0
	crop.buff_provided = buff
	crop.growth_mode = "time"
	
	var desc = crop.get_description()
	assert_str(desc).contains("Weapon Flower")
	assert_str(desc).contains("Weapon Mod: fire_rate_boost")
	assert_str(desc).contains("60 seconds")

# Test get_description with runs-based growth
func test_get_description_with_runs_growth_mode() -> void:
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 30
	
	var crop = CropData.new()
	crop.crop_id = "rare_berry"
	crop.display_name = "Rare Berry"
	crop.growth_time = 3.0
	crop.buff_provided = buff
	crop.growth_mode = "runs"
	
	var desc = crop.get_description()
	assert_str(desc).contains("Rare Berry")
	assert_str(desc).contains("+30 Max Health")
	assert_str(desc).contains("3 runs")

# Test that CropData can be created with all field types
func test_field_types() -> void:
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 25
	
	var crop = CropData.new()
	crop.crop_id = "test_crop"
	crop.display_name = "Test Crop"
	crop.growth_time = 42.5
	crop.buff_provided = buff
	crop.seed_cost = 15
	crop.base_color = Color(0.8, 0.2, 0.3)
	crop.shape_type = "tall"
	crop.growth_mode = "runs"
	
	assert_str(crop.crop_id).is_equal("test_crop")
	assert_str(crop.display_name).is_equal("Test Crop")
	assert_float(crop.growth_time).is_equal(42.5)
	assert_object(crop.buff_provided).is_equal(buff)
	assert_int(crop.seed_cost).is_equal(15)
	assert_object(crop.base_color).is_equal(Color(0.8, 0.2, 0.3))
	assert_str(crop.shape_type).is_equal("tall")
	assert_str(crop.growth_mode).is_equal("runs")

# Test that seed_cost can be zero (free crops)
func test_seed_cost_can_be_zero() -> void:
	var crop = CropData.new()
	crop.crop_id = "free_crop"
	crop.display_name = "Free Crop"
	crop.buff_provided = Buff.new()
	crop.seed_cost = 0
	
	assert_bool(crop.is_valid()).is_true()
	assert_int(crop.seed_cost).is_equal(0)

# Test that multiple CropData instances are independent
func test_multiple_instances_are_independent() -> void:
	var crop1 = CropData.new()
	crop1.crop_id = "crop1"
	crop1.display_name = "Crop One"
	crop1.base_color = Color.RED
	
	var crop2 = CropData.new()
	crop2.crop_id = "crop2"
	crop2.display_name = "Crop Two"
	crop2.base_color = Color.BLUE
	
	assert_str(crop1.crop_id).is_equal("crop1")
	assert_str(crop2.crop_id).is_equal("crop2")
	assert_object(crop1.base_color).is_equal(Color.RED)
	assert_object(crop2.base_color).is_equal(Color.BLUE)

# ============================================================================
# Resource Serialization Tests
# ============================================================================

# Test that CropData extends Resource for serialization
func test_crop_data_is_resource_type() -> void:
	var crop = CropData.new()
	
	assert_object(crop).is_instanceof(Resource)

# Test that CropData can be duplicated (Godot Resource serialization)
func test_crop_data_can_be_duplicated() -> void:
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 25
	
	var original = CropData.new()
	original.crop_id = "health_berry"
	original.display_name = "Health Berry"
	original.growth_time = 45.0
	original.buff_provided = buff
	original.seed_cost = 15
	original.base_color = Color(0.8, 0.2, 0.3)
	original.shape_type = "round"
	original.growth_mode = "time"
	
	var duplicate = original.duplicate()
	
	assert_object(duplicate).is_not_null()
	assert_str(duplicate.crop_id).is_equal("health_berry")
	assert_str(duplicate.display_name).is_equal("Health Berry")
	assert_float(duplicate.growth_time).is_equal(45.0)
	assert_object(duplicate.buff_provided).is_not_null()
	assert_int(duplicate.seed_cost).is_equal(15)
	assert_object(duplicate.base_color).is_equal(Color(0.8, 0.2, 0.3))
	assert_str(duplicate.shape_type).is_equal("round")
	assert_str(duplicate.growth_mode).is_equal("time")

# Test that duplicated CropData has independent buff
func test_duplicated_crop_has_independent_buff() -> void:
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	
	var original = CropData.new()
	original.crop_id = "test_crop"
	original.display_name = "Test Crop"
	original.buff_provided = buff
	
	var duplicate = original.duplicate(true)  # Deep duplicate
	
	# Modify original buff
	original.buff_provided.value = 50
	
	# Duplicate should have independent buff with original value
	assert_int(duplicate.buff_provided.value).is_equal(20)
	assert_int(original.buff_provided.value).is_equal(50)

# Test that CropData serialization preserves all field types
func test_serialization_preserves_all_field_types() -> void:
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.AMMO
	buff.value = 100
	
	var original = CropData.new()
	original.crop_id = "ammo_grain"
	original.display_name = "Ammo Grain"
	original.growth_time = 60.5
	original.buff_provided = buff
	original.seed_cost = 25
	original.base_color = Color(0.9, 0.7, 0.1, 1.0)
	original.shape_type = "tall"
	original.growth_mode = "runs"
	
	var duplicate = original.duplicate()
	
	# Verify all fields are preserved with correct types
	assert_object(duplicate.crop_id).is_instanceof(String)
	assert_object(duplicate.display_name).is_instanceof(String)
	assert_object(duplicate.growth_time).is_instanceof(float)
	assert_object(duplicate.buff_provided).is_instanceof(Buff)
	assert_object(duplicate.seed_cost).is_instanceof(int)
	assert_object(duplicate.base_color).is_instanceof(Color)
	assert_object(duplicate.shape_type).is_instanceof(String)
	assert_object(duplicate.growth_mode).is_instanceof(String)

# Test that CropData with null buff can be duplicated
func test_crop_with_null_buff_can_be_duplicated() -> void:
	var original = CropData.new()
	original.crop_id = "incomplete_crop"
	original.display_name = "Incomplete Crop"
	original.buff_provided = null
	
	var duplicate = original.duplicate()
	
	assert_object(duplicate).is_not_null()
	assert_str(duplicate.crop_id).is_equal("incomplete_crop")
	assert_object(duplicate.buff_provided).is_null()
