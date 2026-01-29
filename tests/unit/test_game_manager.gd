# GdUnit generated TestSuite
class_name TestGameManager
extends GdUnitTestSuite

## Unit tests for GameManager singleton
##
## Tests verify:
## - State variable initialization
## - Buff management (apply, clear)
## - Upgrade management (unlock, level up)
## - Health management (set, modify, bounds)
## - Inventory management (add, get, check)
## - Signal emissions
##
## Validates: Requirements 7.5, 11.2

# Reference to the source being tested
const __source = 'res://scripts/autoload/game_manager.gd'

# Test instance (we'll use the autoload singleton)
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
	game_manager.permanent_upgrades.clear()

# ============================================================================
# Initialization Tests
# ============================================================================

func test_initial_health_values() -> void:
	"""Test that player health is initialized correctly."""
	assert_int(game_manager.player_health).is_equal(100)
	assert_int(game_manager.player_max_health).is_equal(100)

func test_inventory_initialization() -> void:
	"""Test that inventory is initialized with default values."""
	assert_dict(game_manager.inventory).is_not_empty()
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(0)
	assert_int(game_manager.get_inventory_amount("health_seeds")).is_equal(0)
	assert_int(game_manager.get_inventory_amount("ammo_seeds")).is_equal(0)
	assert_int(game_manager.get_inventory_amount("weapon_mod_seeds")).is_equal(0)

func test_buffs_start_empty() -> void:
	"""Test that active buffs array starts empty."""
	assert_array(game_manager.active_buffs).is_empty()

func test_upgrades_start_empty() -> void:
	"""Test that permanent upgrades dictionary starts empty."""
	assert_dict(game_manager.permanent_upgrades).is_empty()

# ============================================================================
# Buff Management Tests
# ============================================================================

func test_apply_buff_adds_to_array() -> void:
	"""Test that applying a buff adds it to the active_buffs array."""
	var buff = Buff.new()
	buff.buff_type = Buff.BuffType.HEALTH
	buff.value = 20
	
	game_manager.apply_buff(buff)
	
	assert_array(game_manager.active_buffs).has_size(1)
	assert_object(game_manager.active_buffs[0]).is_same(buff)

func test_apply_buff_emits_signal() -> void:
	"""Test that applying a buff emits the buff_applied signal."""
	var buff = Buff.new()
	var signal_monitor = monitor_signals(game_manager)
	
	game_manager.apply_buff(buff)
	
	assert_signal(signal_monitor).is_emitted("buff_applied", [buff])

func test_apply_null_buff_shows_error() -> void:
	"""Test that applying a null buff shows an error and doesn't add to array."""
	game_manager.apply_buff(null)
	
	assert_array(game_manager.active_buffs).is_empty()

func test_apply_multiple_buffs() -> void:
	"""Test that multiple buffs can be applied."""
	var buff1 = Buff.new()
	var buff2 = Buff.new()
	var buff3 = Buff.new()
	
	game_manager.apply_buff(buff1)
	game_manager.apply_buff(buff2)
	game_manager.apply_buff(buff3)
	
	assert_array(game_manager.active_buffs).has_size(3)

func test_clear_temporary_buffs() -> void:
	"""Test that clearing buffs removes all active buffs."""
	var buff1 = Buff.new()
	var buff2 = Buff.new()
	
	game_manager.apply_buff(buff1)
	game_manager.apply_buff(buff2)
	assert_array(game_manager.active_buffs).has_size(2)
	
	game_manager.clear_temporary_buffs()
	
	assert_array(game_manager.active_buffs).is_empty()

func test_clear_buffs_emits_signal() -> void:
	"""Test that clearing buffs emits the buff_cleared signal."""
	var signal_monitor = monitor_signals(game_manager)
	
	game_manager.clear_temporary_buffs()
	
	assert_signal(signal_monitor).is_emitted("buff_cleared")

# ============================================================================
# Upgrade Management Tests
# ============================================================================

func test_unlock_upgrade_adds_to_dictionary() -> void:
	"""Test that unlocking an upgrade adds it to permanent_upgrades."""
	game_manager.unlock_upgrade("max_health_1")
	
	assert_dict(game_manager.permanent_upgrades).contains_keys(["max_health_1"])
	assert_int(game_manager.permanent_upgrades["max_health_1"]).is_equal(1)

func test_unlock_upgrade_emits_signal() -> void:
	"""Test that unlocking an upgrade emits the upgrade_unlocked signal."""
	var signal_monitor = monitor_signals(game_manager)
	
	game_manager.unlock_upgrade("dash_cooldown_1")
	
	assert_signal(signal_monitor).is_emitted("upgrade_unlocked", ["dash_cooldown_1"])

func test_unlock_same_upgrade_increments_level() -> void:
	"""Test that unlocking the same upgrade multiple times increments its level."""
	game_manager.unlock_upgrade("fire_rate_1")
	game_manager.unlock_upgrade("fire_rate_1")
	game_manager.unlock_upgrade("fire_rate_1")
	
	assert_int(game_manager.permanent_upgrades["fire_rate_1"]).is_equal(3)

func test_unlock_empty_upgrade_id_shows_error() -> void:
	"""Test that unlocking with empty ID shows error and doesn't add to dictionary."""
	game_manager.unlock_upgrade("")
	
	assert_dict(game_manager.permanent_upgrades).is_empty()

func test_unlock_multiple_different_upgrades() -> void:
	"""Test that multiple different upgrades can be unlocked."""
	game_manager.unlock_upgrade("max_health_1")
	game_manager.unlock_upgrade("dash_cooldown_1")
	game_manager.unlock_upgrade("fire_rate_1")
	
	assert_dict(game_manager.permanent_upgrades).has_size(3)
	assert_int(game_manager.permanent_upgrades["max_health_1"]).is_equal(1)
	assert_int(game_manager.permanent_upgrades["dash_cooldown_1"]).is_equal(1)
	assert_int(game_manager.permanent_upgrades["fire_rate_1"]).is_equal(1)

# ============================================================================
# Health Management Tests
# ============================================================================

func test_set_player_health() -> void:
	"""Test that setting player health updates the value."""
	game_manager.set_player_health(75)
	
	assert_int(game_manager.player_health).is_equal(75)

func test_set_player_health_emits_signal() -> void:
	"""Test that setting health emits the health_changed signal."""
	var signal_monitor = monitor_signals(game_manager)
	
	game_manager.set_player_health(50)
	
	assert_signal(signal_monitor).is_emitted("health_changed", [50, 100])

func test_set_player_health_clamps_to_max() -> void:
	"""Test that setting health above max clamps to max_health."""
	game_manager.set_player_health(150)
	
	assert_int(game_manager.player_health).is_equal(100)

func test_set_player_health_clamps_to_zero() -> void:
	"""Test that setting health below zero clamps to 0."""
	game_manager.set_player_health(-50)
	
	assert_int(game_manager.player_health).is_equal(0)

func test_modify_player_health_positive() -> void:
	"""Test that modifying health with positive delta increases health."""
	game_manager.player_health = 50
	game_manager.modify_player_health(25)
	
	assert_int(game_manager.player_health).is_equal(75)

func test_modify_player_health_negative() -> void:
	"""Test that modifying health with negative delta decreases health."""
	game_manager.player_health = 50
	game_manager.modify_player_health(-20)
	
	assert_int(game_manager.player_health).is_equal(30)

func test_modify_player_health_respects_bounds() -> void:
	"""Test that modifying health respects min/max bounds."""
	game_manager.player_health = 90
	game_manager.modify_player_health(50)  # Would go to 140
	assert_int(game_manager.player_health).is_equal(100)
	
	game_manager.modify_player_health(-150)  # Would go to -50
	assert_int(game_manager.player_health).is_equal(0)

func test_set_max_health() -> void:
	"""Test that setting max health updates the value."""
	game_manager.set_max_health(150)
	
	assert_int(game_manager.player_max_health).is_equal(150)

func test_set_max_health_emits_signal() -> void:
	"""Test that setting max health emits the health_changed signal."""
	var signal_monitor = monitor_signals(game_manager)
	
	game_manager.set_max_health(120)
	
	assert_signal(signal_monitor).is_emitted("health_changed")

func test_set_max_health_clamps_current_health() -> void:
	"""Test that reducing max health clamps current health if needed."""
	game_manager.player_health = 100
	game_manager.player_max_health = 100
	
	game_manager.set_max_health(80)
	
	assert_int(game_manager.player_health).is_equal(80)
	assert_int(game_manager.player_max_health).is_equal(80)

func test_set_max_health_zero_shows_error() -> void:
	"""Test that setting max health to zero or negative shows error."""
	var original_max = game_manager.player_max_health
	
	game_manager.set_max_health(0)
	assert_int(game_manager.player_max_health).is_equal(original_max)
	
	game_manager.set_max_health(-10)
	assert_int(game_manager.player_max_health).is_equal(original_max)

# ============================================================================
# Inventory Management Tests
# ============================================================================

func test_add_to_inventory_new_resource() -> void:
	"""Test that adding a new resource type creates it in inventory."""
	game_manager.add_to_inventory("new_resource", 10)
	
	assert_int(game_manager.get_inventory_amount("new_resource")).is_equal(10)

func test_add_to_inventory_existing_resource() -> void:
	"""Test that adding to existing resource increments the amount."""
	game_manager.add_to_inventory("credits", 50)
	game_manager.add_to_inventory("credits", 30)
	
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(80)

func test_add_negative_amount_to_inventory() -> void:
	"""Test that adding negative amount subtracts from inventory."""
	game_manager.add_to_inventory("credits", 100)
	game_manager.add_to_inventory("credits", -30)
	
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(70)

func test_inventory_cannot_go_negative() -> void:
	"""Test that inventory amounts cannot go below zero."""
	game_manager.add_to_inventory("credits", 50)
	game_manager.add_to_inventory("credits", -100)
	
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(0)

func test_get_inventory_amount_nonexistent() -> void:
	"""Test that getting amount of nonexistent resource returns 0."""
	var amount = game_manager.get_inventory_amount("nonexistent_resource")
	
	assert_int(amount).is_equal(0)

func test_has_inventory_amount_true() -> void:
	"""Test that has_inventory_amount returns true when sufficient resources exist."""
	game_manager.add_to_inventory("credits", 100)
	
	assert_bool(game_manager.has_inventory_amount("credits", 50)).is_true()
	assert_bool(game_manager.has_inventory_amount("credits", 100)).is_true()

func test_has_inventory_amount_false() -> void:
	"""Test that has_inventory_amount returns false when insufficient resources."""
	game_manager.add_to_inventory("credits", 50)
	
	assert_bool(game_manager.has_inventory_amount("credits", 100)).is_false()

func test_has_inventory_amount_nonexistent() -> void:
	"""Test that has_inventory_amount returns false for nonexistent resources."""
	assert_bool(game_manager.has_inventory_amount("nonexistent", 1)).is_false()

# ============================================================================
# Integration Tests
# ============================================================================

func test_buff_and_upgrade_independence() -> void:
	"""Test that buffs and upgrades are independent systems."""
	var buff = Buff.new()
	game_manager.apply_buff(buff)
	game_manager.unlock_upgrade("max_health_1")
	
	game_manager.clear_temporary_buffs()
	
	# Buffs should be cleared but upgrades should remain
	assert_array(game_manager.active_buffs).is_empty()
	assert_dict(game_manager.permanent_upgrades).has_size(1)

func test_health_and_inventory_independence() -> void:
	"""Test that health and inventory are independent systems."""
	game_manager.set_player_health(50)
	game_manager.add_to_inventory("credits", 100)
	
	game_manager.set_player_health(100)
	
	# Changing health shouldn't affect inventory
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(100)

func test_multiple_systems_state_preservation() -> void:
	"""Test that all systems maintain their state independently."""
	# Set up state in all systems
	game_manager.set_player_health(75)
	game_manager.set_max_health(120)
	game_manager.add_to_inventory("credits", 50)
	game_manager.unlock_upgrade("max_health_1")
	var buff = Buff.new()
	game_manager.apply_buff(buff)
	
	# Verify all state is preserved
	assert_int(game_manager.player_health).is_equal(75)
	assert_int(game_manager.player_max_health).is_equal(120)
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(50)
	assert_dict(game_manager.permanent_upgrades).has_size(1)
	assert_array(game_manager.active_buffs).has_size(1)

# ============================================================================
# Scene Transition Tests
# ============================================================================

func test_transition_to_combat_applies_buffs() -> void:
	"""Test that transition_to_combat applies all active buffs."""
	# Create health buff
	var health_buff = Buff.new()
	health_buff.buff_type = Buff.BuffType.HEALTH
	health_buff.value = 20
	
	# Create ammo buff
	var ammo_buff = Buff.new()
	ammo_buff.buff_type = Buff.BuffType.AMMO
	ammo_buff.value = 50
	
	# Apply buffs
	game_manager.apply_buff(health_buff)
	game_manager.apply_buff(ammo_buff)
	
	var original_max_health = game_manager.player_max_health
	var original_ammo = game_manager.get_inventory_amount("ammo")
	
	# Note: We can't actually test scene transition without mocking the scene tree
	# Instead, we test that buffs are applied correctly by calling apply_to_player directly
	for buff in game_manager.active_buffs:
		buff.apply_to_player(null)
	
	# Verify buffs were applied
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 20)
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(original_ammo + 50)

func test_transition_to_farm_clears_buffs() -> void:
	"""Test that transition_to_farm clears all temporary buffs."""
	# Add some buffs
	var buff1 = Buff.new()
	var buff2 = Buff.new()
	game_manager.apply_buff(buff1)
	game_manager.apply_buff(buff2)
	
	assert_array(game_manager.active_buffs).has_size(2)
	
	# Call clear_temporary_buffs (which is called by transition_to_farm)
	game_manager.clear_temporary_buffs()
	
	# Verify buffs were cleared
	assert_array(game_manager.active_buffs).is_empty()

func test_transition_preserves_inventory() -> void:
	"""Test that scene transitions preserve inventory state."""
	# Set up inventory
	game_manager.add_to_inventory("credits", 100)
	game_manager.add_to_inventory("health_seeds", 5)
	
	# Simulate transition by clearing buffs (part of transition_to_farm)
	game_manager.clear_temporary_buffs()
	
	# Verify inventory is preserved
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(100)
	assert_int(game_manager.get_inventory_amount("health_seeds")).is_equal(5)

func test_transition_preserves_permanent_upgrades() -> void:
	"""Test that scene transitions preserve permanent upgrades."""
	# Unlock some upgrades
	game_manager.unlock_upgrade("max_health_1")
	game_manager.unlock_upgrade("dash_cooldown_1")
	
	# Simulate transition by clearing buffs (part of transition_to_farm)
	game_manager.clear_temporary_buffs()
	
	# Verify upgrades are preserved
	assert_dict(game_manager.permanent_upgrades).has_size(2)
	assert_int(game_manager.permanent_upgrades["max_health_1"]).is_equal(1)
	assert_int(game_manager.permanent_upgrades["dash_cooldown_1"]).is_equal(1)

func test_buffs_cleared_but_not_inventory_on_farm_transition() -> void:
	"""Test that transition_to_farm clears buffs but preserves inventory."""
	# Set up state
	var buff = Buff.new()
	game_manager.apply_buff(buff)
	game_manager.add_to_inventory("credits", 50)
	
	# Simulate farm transition
	game_manager.clear_temporary_buffs()
	
	# Buffs should be cleared, inventory should remain
	assert_array(game_manager.active_buffs).is_empty()
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(50)

func test_multiple_buffs_applied_on_combat_transition() -> void:
	"""Test that multiple buffs are all applied when transitioning to combat."""
	# Create multiple buffs
	var health_buff1 = Buff.new()
	health_buff1.buff_type = Buff.BuffType.HEALTH
	health_buff1.value = 10
	
	var health_buff2 = Buff.new()
	health_buff2.buff_type = Buff.BuffType.HEALTH
	health_buff2.value = 15
	
	var ammo_buff = Buff.new()
	ammo_buff.buff_type = Buff.BuffType.AMMO
	ammo_buff.value = 30
	
	game_manager.apply_buff(health_buff1)
	game_manager.apply_buff(health_buff2)
	game_manager.apply_buff(ammo_buff)
	
	var original_max_health = game_manager.player_max_health
	var original_ammo = game_manager.get_inventory_amount("ammo")
	
	# Apply all buffs (simulating combat transition)
	for buff in game_manager.active_buffs:
		buff.apply_to_player(null)
	
	# Verify all buffs were applied
	assert_int(game_manager.player_max_health).is_equal(original_max_health + 25)  # 10 + 15
	assert_int(game_manager.get_inventory_amount("ammo")).is_equal(original_ammo + 30)



# ============================================================================
# Run Loot Management Tests (Task 5.2.3)
# ============================================================================

func test_add_to_run_loot_adds_resource() -> void:
	"""Test that add_to_run_loot adds resources to run_loot dictionary."""
	game_manager.run_loot.clear()
	
	game_manager.add_to_run_loot("credits", 50)
	
	assert_int(game_manager.get_run_loot_amount("credits")).is_equal(50)

func test_add_to_run_loot_accumulates() -> void:
	"""Test that multiple calls to add_to_run_loot accumulate."""
	game_manager.run_loot.clear()
	
	game_manager.add_to_run_loot("credits", 10)
	game_manager.add_to_run_loot("credits", 20)
	game_manager.add_to_run_loot("credits", 30)
	
	assert_int(game_manager.get_run_loot_amount("credits")).is_equal(60)

func test_add_to_run_loot_multiple_resource_types() -> void:
	"""Test that different resource types can be tracked separately."""
	game_manager.run_loot.clear()
	
	game_manager.add_to_run_loot("credits", 100)
	game_manager.add_to_run_loot("health_seeds", 5)
	game_manager.add_to_run_loot("ammo_seeds", 3)
	
	assert_int(game_manager.get_run_loot_amount("credits")).is_equal(100)
	assert_int(game_manager.get_run_loot_amount("health_seeds")).is_equal(5)
	assert_int(game_manager.get_run_loot_amount("ammo_seeds")).is_equal(3)

func test_get_run_loot_amount_returns_zero_for_missing() -> void:
	"""Test that get_run_loot_amount returns 0 for non-existent resources."""
	game_manager.run_loot.clear()
	
	var amount = game_manager.get_run_loot_amount("non_existent")
	
	assert_int(amount).is_equal(0)

func test_finalize_run_loot_transfers_to_inventory() -> void:
	"""Test that finalize_run_loot transfers loot to permanent inventory."""
	game_manager.run_loot.clear()
	game_manager.inventory["credits"] = 50
	
	game_manager.add_to_run_loot("credits", 100)
	game_manager.finalize_run_loot()
	
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(150)

func test_finalize_run_loot_clears_run_loot() -> void:
	"""Test that finalize_run_loot clears the run_loot dictionary."""
	game_manager.run_loot.clear()
	
	game_manager.add_to_run_loot("credits", 100)
	game_manager.finalize_run_loot()
	
	assert_int(game_manager.get_run_loot_amount("credits")).is_equal(0)
	assert_dict(game_manager.run_loot).is_empty()

func test_finalize_run_loot_handles_multiple_resources() -> void:
	"""Test that finalize_run_loot handles multiple resource types."""
	game_manager.run_loot.clear()
	game_manager.inventory["credits"] = 10
	game_manager.inventory["health_seeds"] = 2
	
	game_manager.add_to_run_loot("credits", 50)
	game_manager.add_to_run_loot("health_seeds", 3)
	game_manager.add_to_run_loot("ammo_seeds", 5)
	
	game_manager.finalize_run_loot()
	
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(60)
	assert_int(game_manager.get_inventory_amount("health_seeds")).is_equal(5)
	assert_int(game_manager.get_inventory_amount("ammo_seeds")).is_equal(5)

func test_clear_run_loot_removes_all_loot() -> void:
	"""Test that clear_run_loot removes all run loot without adding to inventory."""
	game_manager.run_loot.clear()
	game_manager.inventory["credits"] = 50
	
	game_manager.add_to_run_loot("credits", 100)
	game_manager.clear_run_loot()
	
	assert_int(game_manager.get_run_loot_amount("credits")).is_equal(0)
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(50)  # Unchanged
	assert_dict(game_manager.run_loot).is_empty()

func test_clear_run_loot_on_death_scenario() -> void:
	"""Test that run loot is lost on death (Requirement 9.4)."""
	game_manager.run_loot.clear()
	var initial_credits = 100
	game_manager.inventory["credits"] = initial_credits
	
	# Collect loot during run
	game_manager.add_to_run_loot("credits", 200)
	
	# Player dies - loot is cleared
	game_manager.clear_run_loot()
	
	# Inventory should be unchanged (loot lost)
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(initial_credits)

func test_get_total_run_loot_sums_all_resources() -> void:
	"""Test that get_total_run_loot returns sum of all loot values."""
	game_manager.run_loot.clear()
	
	game_manager.add_to_run_loot("credits", 100)
	game_manager.add_to_run_loot("health_seeds", 5)
	game_manager.add_to_run_loot("ammo_seeds", 10)
	
	var total = game_manager.get_total_run_loot()
	
	assert_int(total).is_equal(115)

func test_get_total_run_loot_returns_zero_when_empty() -> void:
	"""Test that get_total_run_loot returns 0 when no loot collected."""
	game_manager.run_loot.clear()
	
	var total = game_manager.get_total_run_loot()
	
	assert_int(total).is_equal(0)

func test_run_loot_separate_from_inventory() -> void:
	"""Test that run loot is tracked separately from permanent inventory."""
	game_manager.run_loot.clear()
	game_manager.inventory["credits"] = 50
	
	game_manager.add_to_run_loot("credits", 100)
	
	# Run loot and inventory should be separate
	assert_int(game_manager.get_run_loot_amount("credits")).is_equal(100)
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(50)

func test_finalize_run_loot_with_empty_run_loot() -> void:
	"""Test that finalize_run_loot handles empty run_loot gracefully."""
	game_manager.run_loot.clear()
	game_manager.inventory["credits"] = 50
	
	game_manager.finalize_run_loot()
	
	# Inventory should be unchanged
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(50)

func test_add_to_run_loot_prevents_negative_values() -> void:
	"""Test that run loot values cannot go negative."""
	game_manager.run_loot.clear()
	
	game_manager.add_to_run_loot("credits", 50)
	game_manager.add_to_run_loot("credits", -100)  # Try to make negative
	
	# Should be clamped to 0
	assert_int(game_manager.get_run_loot_amount("credits")).is_equal(0)
