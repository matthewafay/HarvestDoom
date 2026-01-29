# GdUnit generated TestSuite
class_name TestBuff
extends GdUnitTestSuite

## Unit tests for Buff resource class
##
## Tests verify:
## - Buff creation and initialization
## - BuffType enum values
## - Export variable configuration
## - apply_to_player method for each buff type
## - Integration with GameManager
##
## Validates: Requirements 5.1, 5.2, 5.3

# Reference to the source being tested
const __source = 'res://resources/buffs/buff.gd'

var game_manager: GameManager

func before_test() -> void:
	"""Setup before each test - reset GameManager state."""
	game_manager = GameManager
	
	# Reset to default state
	game_manager.player_health = 100
	game_manager.player_max_health = 100
	game_manager.inventory.clear()
	game_manager.active_buffs.clear()
	game_manager.permanent_upgrades.clear()
	game_manager._initialize_inventory()

func after_test() -> void:
	"""Cleanup after each test."""
	# Reset state for next test
	game_manager.active_buffs.clear()
	game_manager.inventory.clear()
	game_manager._initialize_inventory()

# ============================================================================
# Buff Creation and Initialization Tests
# ============================================================================

func test_buff_creation() -> void:
	"""Test that a Buff can be created."""
	var buff = Buff.new()
	
	assert_object(buff).is_not_null()
	assert_object(buff).is_instanceof(Buff)
	assert_object(buff).is_instanceof(Resource)

func test_buff_default_values() -> void:
	"""Test that Buff has correct default values."""
	var buff = Buff.new()
	
	assert_int(buff.buff_type).is_equal(Buff.BuffType.HEALTH)
	assert_int(buff.value).is_equal(0)
	assert_int(buff.duration).is_equal(1)
	assert_str(buff.weapon_mod_type).is_equal("")

func test_buff_type_enum_values() -> void:
	"""Test that BuffType enum has all required values."""
	# Verify enum values exist and are distinct
	assert_int(Buff.BuffType.HEALTH).is_not_equal(Buff.BuffType.AMMO)
	assert_int(Buff.BuffType.HEALTH).is_not_equal(Buff.BuffType.WEAPON_MOD)
	assert_int(Buff.BuffType.AMMO).is_not_equal(Buff.BuffType.WEAPON_MOD)

func test_buff_export_variables_can_be_set() -> void:
	"""Test that all export variables can be set."""
	var buff = Buff.new()
	
	buff.buff_type = Buff.BuffType.AMMO
	buff.value = 50
	buff.duration = 2
	buff.weapon_mod_type = "fire_rate_boost"
	
	assert_int(buff.buff_type).is_equal(Buff.BuffType.AMMO)
	assert_int(buff.value).is_equal(50)
	assert_int(buff.duration).is_equal(2)
	assert_str(buff.weapon_mod_type).is_equal("fire_rate_boost")

# ============================================================================
# HEALTH Buff Tests
# ============================================================================

func test_health_buff_increases_max_health() -> void:
	"""Test that HEALTH buff increases player max health."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 25
	
	var original_max_health = game_manager.player_max_health
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 25)

func test_health_buff_with_zero_value() -> void:
	"""Test that HEALTH buff with zero value doesn't change max health."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 0
	
	var original_max_health = game_manager.player_max_health
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health)

func test_health_buff_with_negative_value() -> void:
	"""Test that HEALTH buff with negative value decreases max health."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = -20
	
	var original_max_health = game_manager.player_max_health
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health - 20)

func test_multiple_health_buffs_stack() -> void:
	"""Test that multiple HEALTH buffs stack additively."""
	var buff1 = Buff.new()
	buff1.buff_type = Buff.BuffType.HEALTH
	buff1.value = 15
	
	var buff2 = Buff.new()
	buff2.buff_type = Buff.BuffType.HEALTH
	buff2.value = 10
	
	var original_max_health = game_manager.player_max_health
	
	buff1.apply_to_player(null)
	buff2.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 25)

func test_health_buff_large_value() -> void:
	"""Test that HEALTH buff works with large values."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 1000
	
	var original_max_health = game_manager.player_max_health
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 1000)

# ============================================================================
# AMMO Buff Tests
# ============================================================================

func test_ammo_buff_adds_to_inventory() -> void:
	"""Test that AMMO buff adds ammunition to inventory."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.AMMO
	buff.value = 50
	
	var original_ammo = game_manager.get_inventory_amount("ammo")
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(original_ammo + 50)

func test_ammo_buff_with_zero_value() -> void:
	"""Test that AMMO buff with zero value doesn't change ammo."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.AMMO
	buff.value = 0
	
	var original_ammo = game_manager.get_inventory_amount("ammo")
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(original_ammo)

func test_ammo_buff_with_negative_value() -> void:
	"""Test that AMMO buff with negative value decreases ammo (clamped to 0)."""
	game_manager.add_to_inventory("ammo", 100)
	
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.AMMO
	buff.value = -30
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(70)

func test_multiple_ammo_buffs_stack() -> void:
	"""Test that multiple AMMO buffs stack additively."""
	var buff1 = Buff.new()
	buff1.buff_type = Buff.BuffType.AMMO
	buff1.value = 25
	
	var buff2 = Buff.new()
	buff2.buff_type = Buff.BuffType.AMMO
	buff2.value = 35
	
	var original_ammo = game_manager.get_inventory_amount("ammo")
	
	buff1.apply_to_player(null)
	buff2.apply_to_player(null)
	
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(original_ammo + 60)

func test_ammo_buff_large_value() -> void:
	"""Test that AMMO buff works with large values."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.AMMO
	buff.value = 9999
	
	var original_ammo = game_manager.get_inventory_amount("ammo")
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(original_ammo + 9999)

# ============================================================================
# WEAPON_MOD Buff Tests
# ============================================================================

func test_weapon_mod_buff_without_player() -> void:
	"""Test that WEAPON_MOD buff with null player shows warning."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.WEAPON_MOD
	buff.weapon_mod_type = "fire_rate_boost"
	
	# Should not crash, just show warning
	buff.apply_to_player(null)
	
	# Test passes if no crash occurs

func test_weapon_mod_buff_with_player_without_weapon_system() -> void:
	"""Test that WEAPON_MOD buff with player but no WeaponSystem shows warning."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.WEAPON_MOD
	buff.weapon_mod_type = "damage_increase"
	
	# Create a mock player node without WeaponSystem
	var mock_player = Node.new()
	
	# Should not crash, just show warning
	buff.apply_to_player(mock_player)
	
	mock_player.free()
	
	# Test passes if no crash occurs

func test_weapon_mod_buff_types() -> void:
	"""Test that WEAPON_MOD buff can store different mod types."""
	var buff1 = Buff.new()
	buff1.buff_type = Buff.BuffType.WEAPON_MOD
	buff1.weapon_mod_type = "fire_rate_boost"
	
	var buff2 = Buff.new()
	buff2.buff_type = Buff.BuffType.WEAPON_MOD
	buff2.weapon_mod_type = "spread_reduction"
	
	var buff3 = Buff.new()
	buff3.buff_type = Buff.BuffType.WEAPON_MOD
	buff3.weapon_mod_type = "damage_increase"
	
	assert_str(buff1.weapon_mod_type).is_equal("fire_rate_boost")
	assert_str(buff2.weapon_mod_type).is_equal("spread_reduction")
	assert_str(buff3.weapon_mod_type).is_equal("damage_increase")

# ============================================================================
# Mixed Buff Tests
# ============================================================================

func test_different_buff_types_applied_together() -> void:
	"""Test that different buff types can be applied together."""
	var health_buff = Buff.new()
	health_buff.buff_type = Buff.BuffType.HEALTH
	health_buff.value = 30
	
	var ammo_buff = Buff.new()
	ammo_buff.buff_type = Buff.BuffType.AMMO
	ammo_buff.value = 40
	
	var original_max_health = game_manager.player_max_health
	var original_ammo = game_manager.get_inventory_amount("ammo")
	
	health_buff.apply_to_player(null)
	ammo_buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 30)
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(original_ammo + 40)

func test_buff_duration_field() -> void:
	"""Test that buff duration field can be set (for future use)."""
	var buff = Buff.new()
	buff.duration = 3
	
	assert_int(buff.duration).is_equal(3)

# ============================================================================
# Integration with GameManager Tests
# ============================================================================

func test_buff_applied_through_game_manager() -> void:
	"""Test that buffs work when applied through GameManager.apply_buff."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	
	game_manager.apply_buff(buff)
	
	# Verify buff is in active_buffs
	assert_array(game_manager.active_buffs).has_size(1)
	
	# Apply the buff
	var original_max_health = game_manager.player_max_health
	buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 20)

func test_multiple_buffs_through_game_manager() -> void:
	"""Test that multiple buffs work through GameManager workflow."""
	var health_buff = Buff.new()
	health_buff.buff_type = Buff.BuffType.HEALTH
	health_buff.value = 15
	
	var ammo_buff = Buff.new()
	ammo_buff.buff_type = Buff.BuffType.AMMO
	ammo_buff.value = 25
	
	game_manager.apply_buff(health_buff)
	game_manager.apply_buff(ammo_buff)
	
	assert_array(game_manager.active_buffs).has_size(2)
	
	var original_max_health = game_manager.player_max_health
	var original_ammo = game_manager.get_inventory_amount("ammo")
	
	# Apply all buffs (simulating combat transition)
	for buff in game_manager.active_buffs:
		buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 15)
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(original_ammo + 25)

func test_buff_cleared_after_farm_transition() -> void:
	"""Test that buffs are cleared from GameManager after farm transition."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 10
	
	game_manager.apply_buff(buff)
	assert_array(game_manager.active_buffs).has_size(1)
	
	game_manager.clear_temporary_buffs()
	
	assert_array(game_manager.active_buffs).is_empty()

# ============================================================================
# Resource Serialization Tests
# ============================================================================

func test_buff_can_be_duplicated() -> void:
	"""Test that Buff resources can be duplicated."""
	var original = Buff.new()
	original.buff_type = Buff.BuffType.AMMO
	original.value = 50
	original.duration = 2
	original.weapon_mod_type = "test_mod"
	
	var duplicate = original.duplicate()
	
	assert_object(duplicate).is_not_null()
	assert_int(duplicate.buff_type).is_equal(Buff.BuffType.AMMO)
	assert_int(duplicate.value).is_equal(50)
	assert_int(duplicate.duration).is_equal(2)
	assert_str(duplicate.weapon_mod_type).is_equal("test_mod")

func test_buff_is_resource_type() -> void:
	"""Test that Buff extends Resource for serialization."""
	var buff = Buff.new()
	
	assert_object(buff).is_instanceof(Resource)

# ============================================================================
# Edge Case Tests
# ============================================================================

func test_buff_with_all_fields_set() -> void:
	"""Test buff with all fields configured."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.WEAPON_MOD
	buff.value = 100
	buff.duration = 5
	buff.weapon_mod_type = "ultimate_power"
	
	assert_int(buff.buff_type).is_equal(Buff.BuffType.WEAPON_MOD)
	assert_int(buff.value).is_equal(100)
	assert_int(buff.duration).is_equal(5)
	assert_str(buff.weapon_mod_type).is_equal("ultimate_power")

func test_buff_value_can_be_very_large() -> void:
	"""Test that buff value can handle large numbers."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 999999
	
	var original_max_health = game_manager.player_max_health
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 999999)

func test_buff_value_can_be_very_negative() -> void:
	"""Test that buff value can handle large negative numbers."""
	game_manager.set_max_health(1000000)
	
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = -500000
	
	buff.apply_to_player(null)
	
	assert_int(game_manager.player_max_health).is_equal(500000)
