extends GdUnitTestSuite

## Integration tests for wave completion and scene transitions
## Tests the connection between ArenaGenerator signals and GameManager scene transitions
## Validates: Requirements 7.2, 7.4, 8.4, 9.4

const COMBAT_ZONE_SCENE_PATH = "res://scenes/combat_zone.tscn"

# Mock classes for testing
class MockArenaGenerator extends ArenaGenerator:
	func trigger_arena_completed() -> void:
		arena_completed.emit()
	
	func trigger_wave_completed(wave_num: int) -> void:
		wave_completed.emit(wave_num)

class MockPlayer extends Node:
	signal died()
	
	func trigger_death() -> void:
		died.emit()

func before_test() -> void:
	# Reset GameManager state before each test
	GameManager.run_loot.clear()
	GameManager.inventory.clear()
	GameManager.player_health = 100
	GameManager.player_max_health = 100

func after_test() -> void:
	# Clean up after each test
	GameManager.run_loot.clear()
	GameManager.inventory.clear()

## Test that arena_completed signal triggers loot finalization
## Validates: Requirement 8.4
func test_arena_completed_finalizes_loot() -> void:
	# Setup: Add some run loot
	GameManager.add_to_run_loot("credits", 100)
	GameManager.add_to_run_loot("health_seeds", 5)
	
	# Verify run loot is tracked
	assert_that(GameManager.get_run_loot_amount("credits")).is_equal(100)
	assert_that(GameManager.get_run_loot_amount("health_seeds")).is_equal(5)
	
	# Create a mock arena generator
	var mock_arena = MockArenaGenerator.new()
	
	# Create a combat zone scene instance
	var combat_zone = Node3D.new()
	combat_zone.set_script(load("res://scenes/combat_zone.gd"))
	add_child(combat_zone)
	
	# Manually set the arena_generator reference
	combat_zone.arena_generator = mock_arena
	add_child(mock_arena)
	
	# Connect the signal
	mock_arena.arena_completed.connect(combat_zone._on_arena_completed)
	
	# Trigger arena completion
	mock_arena.trigger_arena_completed()
	
	# Wait for deferred call
	await get_tree().process_frame
	
	# Verify loot was finalized (transferred to inventory)
	assert_that(GameManager.get_inventory_amount("credits")).is_equal(100)
	assert_that(GameManager.get_inventory_amount("health_seeds")).is_equal(5)
	
	# Verify run loot was cleared
	assert_that(GameManager.get_run_loot_amount("credits")).is_equal(0)
	assert_that(GameManager.get_run_loot_amount("health_seeds")).is_equal(0)
	
	# Cleanup
	combat_zone.queue_free()
	mock_arena.queue_free()

## Test that player death clears loot without adding to inventory
## Validates: Requirement 9.4
func test_player_death_clears_loot() -> void:
	# Setup: Add some run loot
	GameManager.add_to_run_loot("credits", 100)
	GameManager.add_to_run_loot("health_seeds", 5)
	
	# Record initial inventory (should be empty)
	var initial_credits = GameManager.get_inventory_amount("credits")
	var initial_seeds = GameManager.get_inventory_amount("health_seeds")
	
	# Create a mock player
	var mock_player = MockPlayer.new()
	
	# Create a combat zone scene instance
	var combat_zone = Node3D.new()
	combat_zone.set_script(load("res://scenes/combat_zone.gd"))
	add_child(combat_zone)
	
	# Manually set the player reference
	combat_zone.player = mock_player
	add_child(mock_player)
	
	# Connect the signal
	mock_player.died.connect(combat_zone._on_player_died)
	
	# Trigger player death
	mock_player.trigger_death()
	
	# Wait for deferred call
	await get_tree().process_frame
	
	# Verify loot was NOT added to inventory
	assert_that(GameManager.get_inventory_amount("credits")).is_equal(initial_credits)
	assert_that(GameManager.get_inventory_amount("health_seeds")).is_equal(initial_seeds)
	
	# Verify run loot was cleared
	assert_that(GameManager.get_run_loot_amount("credits")).is_equal(0)
	assert_that(GameManager.get_run_loot_amount("health_seeds")).is_equal(0)
	
	# Cleanup
	combat_zone.queue_free()
	mock_player.queue_free()

## Test that wave_completed signal is handled
## Validates: Requirement 8.4
func test_wave_completed_signal_handled() -> void:
	# Create a mock arena generator
	var mock_arena = MockArenaGenerator.new()
	
	# Create a combat zone scene instance
	var combat_zone = Node3D.new()
	combat_zone.set_script(load("res://scenes/combat_zone.gd"))
	add_child(combat_zone)
	
	# Manually set the arena_generator reference
	combat_zone.arena_generator = mock_arena
	add_child(mock_arena)
	
	# Connect the signal
	mock_arena.wave_completed.connect(combat_zone._on_wave_completed)
	
	# Trigger wave completion (should not crash or error)
	mock_arena.trigger_wave_completed(1)
	mock_arena.trigger_wave_completed(2)
	mock_arena.trigger_wave_completed(3)
	
	# Wait for processing
	await get_tree().process_frame
	
	# Test passes if no errors occurred
	assert_bool(true).is_true()
	
	# Cleanup
	combat_zone.queue_free()
	mock_arena.queue_free()

## Test that arena completion with no loot works correctly
## Validates: Requirement 8.4
func test_arena_completed_with_no_loot() -> void:
	# Setup: Ensure no run loot
	GameManager.run_loot.clear()
	
	# Create a mock arena generator
	var mock_arena = MockArenaGenerator.new()
	
	# Create a combat zone scene instance
	var combat_zone = Node3D.new()
	combat_zone.set_script(load("res://scenes/combat_zone.gd"))
	add_child(combat_zone)
	
	# Manually set the arena_generator reference
	combat_zone.arena_generator = mock_arena
	add_child(mock_arena)
	
	# Connect the signal
	mock_arena.arena_completed.connect(combat_zone._on_arena_completed)
	
	# Trigger arena completion
	mock_arena.trigger_arena_completed()
	
	# Wait for deferred call
	await get_tree().process_frame
	
	# Verify no errors occurred and run loot is still empty
	assert_that(GameManager.get_total_run_loot()).is_equal(0)
	
	# Cleanup
	combat_zone.queue_free()
	mock_arena.queue_free()

## Test that multiple loot types are handled correctly on completion
## Validates: Requirement 8.4
func test_arena_completed_with_multiple_loot_types() -> void:
	# Setup: Add various loot types
	GameManager.add_to_run_loot("credits", 150)
	GameManager.add_to_run_loot("health_seeds", 3)
	GameManager.add_to_run_loot("ammo_seeds", 7)
	GameManager.add_to_run_loot("weapon_mod_seeds", 2)
	
	# Create a mock arena generator
	var mock_arena = MockArenaGenerator.new()
	
	# Create a combat zone scene instance
	var combat_zone = Node3D.new()
	combat_zone.set_script(load("res://scenes/combat_zone.gd"))
	add_child(combat_zone)
	
	# Manually set the arena_generator reference
	combat_zone.arena_generator = mock_arena
	add_child(mock_arena)
	
	# Connect the signal
	mock_arena.arena_completed.connect(combat_zone._on_arena_completed)
	
	# Trigger arena completion
	mock_arena.trigger_arena_completed()
	
	# Wait for deferred call
	await get_tree().process_frame
	
	# Verify all loot types were finalized
	assert_that(GameManager.get_inventory_amount("credits")).is_equal(150)
	assert_that(GameManager.get_inventory_amount("health_seeds")).is_equal(3)
	assert_that(GameManager.get_inventory_amount("ammo_seeds")).is_equal(7)
	assert_that(GameManager.get_inventory_amount("weapon_mod_seeds")).is_equal(2)
	
	# Verify run loot was cleared
	assert_that(GameManager.get_total_run_loot()).is_equal(0)
	
	# Cleanup
	combat_zone.queue_free()
	mock_arena.queue_free()

## Test that player death with multiple loot types clears all loot
## Validates: Requirement 9.4
func test_player_death_clears_all_loot_types() -> void:
	# Setup: Add various loot types
	GameManager.add_to_run_loot("credits", 150)
	GameManager.add_to_run_loot("health_seeds", 3)
	GameManager.add_to_run_loot("ammo_seeds", 7)
	GameManager.add_to_run_loot("weapon_mod_seeds", 2)
	
	# Record initial inventory
	var initial_inventory = GameManager.inventory.duplicate()
	
	# Create a mock player
	var mock_player = MockPlayer.new()
	
	# Create a combat zone scene instance
	var combat_zone = Node3D.new()
	combat_zone.set_script(load("res://scenes/combat_zone.gd"))
	add_child(combat_zone)
	
	# Manually set the player reference
	combat_zone.player = mock_player
	add_child(mock_player)
	
	# Connect the signal
	mock_player.died.connect(combat_zone._on_player_died)
	
	# Trigger player death
	mock_player.trigger_death()
	
	# Wait for deferred call
	await get_tree().process_frame
	
	# Verify NO loot was added to inventory
	for resource_type in initial_inventory.keys():
		assert_that(GameManager.get_inventory_amount(resource_type)).is_equal(initial_inventory[resource_type])
	
	# Verify all run loot was cleared
	assert_that(GameManager.get_total_run_loot()).is_equal(0)
	assert_that(GameManager.run_loot.size()).is_equal(0)
	
	# Cleanup
	combat_zone.queue_free()
	mock_player.queue_free()
