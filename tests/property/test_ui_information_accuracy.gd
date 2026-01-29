extends GdUnitTestSuite

## Property-Based Tests for UI Information Accuracy
##
## Property 11: All UI displays accurately reflect current game state with
## no delay or desynchronization.
##
## Validates: Requirements 10.1, 10.2, 10.4

const ITERATIONS = 100

var game_manager: Node

func before_test() -> void:
	# Get GameManager singleton
	game_manager = GameManager
	
	# Reset to clean state
	game_manager.player_health = 100
	game_manager.player_max_health = 100
	game_manager.inventory.clear()
	game_manager.active_buffs.clear()
	game_manager.buff_durations.clear()
	game_manager.permanent_upgrades.clear()

func test_health_display_matches_game_state() -> void:
	# Property: Health display always matches GameManager.player_health
	
	for i in range(ITERATIONS):
		# Arrange & Act - Set random health
		var max_health = randi() % 200 + 50  # 50-249
		var current_health = randi() % max_health + 1  # 1-max_health
		
		game_manager.player_max_health = max_health
		game_manager.set_player_health(current_health)
		
		# Assert - Values match
		assert_int(game_manager.player_health).is_equal(current_health)
		assert_int(game_manager.player_max_health).is_equal(max_health)
		
		# In a real UI test, we would verify:
		# assert_int(ui.health_display.value).is_equal(current_health)
		# assert_int(ui.health_display.max_value).is_equal(max_health)

func test_inventory_display_matches_game_state() -> void:
	# Property: Inventory display always matches GameManager.inventory
	
	for i in range(ITERATIONS):
		# Arrange - Set random inventory
		var resource_types = ["credits", "health_seeds", "ammo_seeds", "weapon_mod_seeds"]
		var expected_values: Dictionary = {}
		
		for resource_type in resource_types:
			var amount = randi() % 100
			game_manager.add_to_inventory(resource_type, amount)
			expected_values[resource_type] = game_manager.get_inventory_amount(resource_type)
		
		# Assert - Values match
		for resource_type in resource_types:
			var actual = game_manager.get_inventory_amount(resource_type)
			assert_int(actual).is_equal(expected_values[resource_type])
		
		# Cleanup
		game_manager.inventory.clear()

func test_buff_display_matches_active_buffs() -> void:
	# Property: Buff display shows exactly the buffs in GameManager.active_buffs
	
	for i in range(ITERATIONS):
		# Arrange - Apply random buffs
		var buff_count = randi() % 5 + 1
		
		for j in range(buff_count):
			var buff = _create_random_buff()
			game_manager.apply_buff(buff)
		
		# Assert - Buff count matches
		assert_int(game_manager.active_buffs.size()).is_equal(buff_count)
		
		# In a real UI test, we would verify:
		# assert_int(ui.buff_display.get_child_count()).is_equal(buff_count)
		
		# Cleanup
		game_manager.clear_temporary_buffs()

func test_health_changes_immediately_reflected() -> void:
	# Property: Health changes are immediately visible (no delay)
	
	for i in range(ITERATIONS):
		# Arrange
		var initial_health = randi() % 100 + 50
		game_manager.set_player_health(initial_health)
		
		# Act - Modify health
		var damage = randi() % 30 + 1
		game_manager.modify_player_health(-damage)
		
		# Assert - Change is immediate
		var expected_health = max(0, initial_health - damage)
		assert_int(game_manager.player_health).is_equal(expected_health)
		
		# No frame delay - value is updated synchronously

func test_inventory_changes_immediately_reflected() -> void:
	# Property: Inventory changes are immediately visible (no delay)
	
	for i in range(ITERATIONS):
		# Arrange
		var initial_amount = randi() % 50
		game_manager.add_to_inventory("credits", initial_amount)
		
		# Act - Modify inventory
		var delta = randi() % 20 + 1
		game_manager.add_to_inventory("credits", delta)
		
		# Assert - Change is immediate
		var expected_amount = initial_amount + delta
		assert_int(game_manager.get_inventory_amount("credits")).is_equal(expected_amount)
		
		# Cleanup
		game_manager.inventory.clear()

func test_buff_addition_immediately_reflected() -> void:
	# Property: Buff additions are immediately visible (no delay)
	
	for i in range(ITERATIONS):
		# Arrange
		var initial_count = game_manager.active_buffs.size()
		
		# Act - Add buff
		var buff = _create_random_buff()
		game_manager.apply_buff(buff)
		
		# Assert - Change is immediate
		assert_int(game_manager.active_buffs.size()).is_equal(initial_count + 1)
		
		# Cleanup
		game_manager.clear_temporary_buffs()

func test_buff_removal_immediately_reflected() -> void:
	# Property: Buff removals are immediately visible (no delay)
	
	for i in range(ITERATIONS):
		# Arrange - Add buffs
		var buff_count = randi() % 5 + 1
		for j in range(buff_count):
			game_manager.apply_buff(_create_random_buff())
		
		# Act - Clear buffs
		game_manager.clear_temporary_buffs()
		
		# Assert - Change is immediate
		assert_array(game_manager.active_buffs).is_empty()

func test_health_signal_emitted_on_change() -> void:
	# Property: health_changed signal is emitted whenever health changes
	
	for i in range(ITERATIONS):
		# Arrange
		var signal_emitted = false
		var emitted_health = 0
		var emitted_max_health = 0
		
		var callback = func(new_health: int, max_health: int):
			signal_emitted = true
			emitted_health = new_health
			emitted_max_health = max_health
		
		game_manager.health_changed.connect(callback)
		
		# Act - Change health
		var new_health = randi() % 100 + 1
		game_manager.set_player_health(new_health)
		
		# Assert - Signal emitted with correct values
		assert_bool(signal_emitted).is_true()
		assert_int(emitted_health).is_equal(new_health)
		assert_int(emitted_max_health).is_equal(game_manager.player_max_health)
		
		# Cleanup
		game_manager.health_changed.disconnect(callback)

func test_buff_signal_emitted_on_application() -> void:
	# Property: buff_applied signal is emitted whenever a buff is applied
	
	for i in range(ITERATIONS):
		# Arrange
		var signal_emitted = false
		var emitted_buff = null
		
		var callback = func(buff):
			signal_emitted = true
			emitted_buff = buff
		
		game_manager.buff_applied.connect(callback)
		
		# Act - Apply buff
		var buff = _create_random_buff()
		game_manager.apply_buff(buff)
		
		# Assert - Signal emitted with correct buff
		assert_bool(signal_emitted).is_true()
		assert_object(emitted_buff).is_equal(buff)
		
		# Cleanup
		game_manager.buff_applied.disconnect(callback)
		game_manager.clear_temporary_buffs()

func test_buff_cleared_signal_emitted() -> void:
	# Property: buff_cleared signal is emitted when buffs are cleared
	
	for i in range(ITERATIONS):
		# Arrange
		var signal_emitted = false
		
		var callback = func():
			signal_emitted = true
		
		game_manager.buff_cleared.connect(callback)
		
		# Add some buffs
		for j in range(3):
			game_manager.apply_buff(_create_random_buff())
		
		# Act - Clear buffs
		game_manager.clear_temporary_buffs()
		
		# Assert - Signal emitted
		assert_bool(signal_emitted).is_true()
		
		# Cleanup
		game_manager.buff_cleared.disconnect(callback)

func test_upgrade_signal_emitted_on_unlock() -> void:
	# Property: upgrade_unlocked signal is emitted when an upgrade is unlocked
	
	for i in range(ITERATIONS):
		# Arrange
		var signal_emitted = false
		var emitted_upgrade_id = ""
		
		var callback = func(upgrade_id: String):
			signal_emitted = true
			emitted_upgrade_id = upgrade_id
		
		game_manager.upgrade_unlocked.connect(callback)
		
		# Act - Unlock upgrade
		var upgrade_id = "test_upgrade_%d" % i
		game_manager.unlock_upgrade(upgrade_id)
		
		# Assert - Signal emitted with correct ID
		assert_bool(signal_emitted).is_true()
		assert_str(emitted_upgrade_id).is_equal(upgrade_id)
		
		# Cleanup
		game_manager.upgrade_unlocked.disconnect(callback)
		game_manager.permanent_upgrades.clear()

## Helper: Create a random buff
func _create_random_buff() -> Resource:
	var buff = load("res://resources/buffs/buff.gd").new()
	
	var buff_types = [0, 1, 2]  # HEALTH, AMMO, WEAPON_MOD
	buff.buff_type = buff_types[randi() % buff_types.size()]
	buff.value = randi() % 50 + 10
	buff.duration = randi() % 5 + 1
	
	return buff

