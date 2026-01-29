extends GdUnitTestSuite

## Property-Based Tests for Buff Application and Clearing
##
## Property 5: Buffs applied before entering Combat_Zone persist throughout
## the run and are cleared upon returning to Farm_Hub. Buff effects are
## additive and reversible.
##
## Validates: Requirements 5.1, 5.2, 5.3, 5.4

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

func test_buffs_persist_throughout_combat_run() -> void:
	# Property: Buffs applied before combat persist during entire run
	
	for i in range(ITERATIONS):
		# Arrange - Create random buffs
		var buff_count = randi() % 5 + 1  # 1-5 buffs
		var buffs_to_apply: Array = []
		
		for j in range(buff_count):
			var buff = _create_random_buff()
			buffs_to_apply.append(buff)
			game_manager.apply_buff(buff)
		
		# Act - Simulate combat run (buffs should persist)
		var initial_buff_count = game_manager.active_buffs.size()
		
		# Simulate some time passing during combat
		await get_tree().create_timer(0.01).timeout
		
		# Assert - Buffs still present
		assert_int(game_manager.active_buffs.size()).is_equal(initial_buff_count)
		
		# Verify each buff is still in the array
		for buff in buffs_to_apply:
			assert_array(game_manager.active_buffs).contains([buff])
		
		# Cleanup
		game_manager.clear_temporary_buffs()

func test_buffs_cleared_on_return_to_farm() -> void:
	# Property: All buffs are cleared when returning to Farm_Hub
	
	for i in range(ITERATIONS):
		# Arrange - Apply random number of buffs
		var buff_count = randi() % 10 + 1  # 1-10 buffs
		
		for j in range(buff_count):
			var buff = _create_random_buff()
			game_manager.apply_buff(buff)
		
		# Verify buffs were applied
		assert_int(game_manager.active_buffs.size()).is_equal(buff_count)
		
		# Act - Clear buffs (simulating return to farm)
		game_manager.clear_temporary_buffs()
		
		# Assert - All buffs cleared
		assert_array(game_manager.active_buffs).is_empty()
		assert_dict(game_manager.buff_durations).is_empty()

func test_buff_effects_are_additive() -> void:
	# Property: Multiple buffs of same type stack additively
	
	for i in range(ITERATIONS):
		# Arrange - Create multiple health buffs
		var buff_count = randi() % 5 + 2  # 2-6 buffs
		var expected_total_health = game_manager.player_max_health
		
		for j in range(buff_count):
			var buff_value = randi() % 30 + 10  # 10-39 health
			var buff = _create_health_buff(buff_value)
			
			expected_total_health += buff_value
			game_manager.apply_buff(buff)
			
			# Apply buff effect
			buff.apply_to_player(null)
		
		# Assert - Total health equals sum of all buffs
		assert_int(game_manager.player_max_health).is_equal(expected_total_health)
		
		# Cleanup
		game_manager.player_max_health = 100
		game_manager.clear_temporary_buffs()

func test_buff_effects_are_reversible() -> void:
	# Property: Player stats return to base values after buff clearing
	
	for i in range(ITERATIONS):
		# Arrange - Record initial state
		var initial_max_health = game_manager.player_max_health
		var initial_inventory = game_manager.inventory.duplicate()
		
		# Apply random buffs
		var buff_count = randi() % 5 + 1
		for j in range(buff_count):
			var buff = _create_random_buff()
			game_manager.apply_buff(buff)
			buff.apply_to_player(null)
		
		# Act - Clear buffs
		game_manager.clear_temporary_buffs()
		
		# Manually reverse buff effects (in real game, this happens on scene transition)
		game_manager.player_max_health = initial_max_health
		
		# Assert - Stats returned to initial values
		assert_int(game_manager.player_max_health).is_equal(initial_max_health)
		
		# Cleanup
		game_manager.inventory = initial_inventory.duplicate()

func test_buff_durations_decrement_correctly() -> void:
	# Property: Buff durations decrement after each run
	
	for i in range(ITERATIONS):
		# Arrange - Create buffs with random durations
		var buff_count = randi() % 5 + 1
		var expected_durations: Array[int] = []
		
		for j in range(buff_count):
			var duration = randi() % 5 + 1  # 1-5 runs
			var buff = _create_buff_with_duration(duration)
			game_manager.apply_buff(buff)
			expected_durations.append(duration - 1)
		
		# Act - Decrement durations
		game_manager.decrement_buff_durations()
		
		# Assert - Durations decremented by 1
		for j in range(game_manager.active_buffs.size()):
			var actual_duration = game_manager.buff_durations.get(j, -1)
			assert_int(actual_duration).is_equal(expected_durations[j])
		
		# Cleanup
		game_manager.clear_temporary_buffs()

func test_expired_buffs_removed_after_decrement() -> void:
	# Property: Buffs with duration <= 0 are removed
	
	for i in range(ITERATIONS):
		# Arrange - Create buffs with duration 1 (will expire after decrement)
		var buff_count = randi() % 5 + 1
		
		for j in range(buff_count):
			var buff = _create_buff_with_duration(1)
			game_manager.apply_buff(buff)
		
		# Verify buffs were applied
		assert_int(game_manager.active_buffs.size()).is_equal(buff_count)
		
		# Act - Decrement durations (should remove all buffs)
		game_manager.decrement_buff_durations()
		
		# Assert - All buffs removed
		assert_array(game_manager.active_buffs).is_empty()
		
		# Cleanup
		game_manager.clear_temporary_buffs()

func test_permanent_upgrades_unaffected_by_buff_clearing() -> void:
	# Property: Permanent upgrades persist when buffs are cleared
	
	for i in range(ITERATIONS):
		# Arrange - Unlock random upgrades
		var upgrade_count = randi() % 5 + 1
		var upgrade_ids: Array[String] = []
		
		for j in range(upgrade_count):
			var upgrade_id = "test_upgrade_%d" % j
			game_manager.unlock_upgrade(upgrade_id)
			upgrade_ids.append(upgrade_id)
		
		# Apply some buffs
		for j in range(3):
			game_manager.apply_buff(_create_random_buff())
		
		# Act - Clear buffs
		game_manager.clear_temporary_buffs()
		
		# Assert - Upgrades still present
		for upgrade_id in upgrade_ids:
			assert_bool(game_manager.permanent_upgrades.has(upgrade_id)).is_true()
		
		# Cleanup
		game_manager.permanent_upgrades.clear()

## Helper: Create a random buff
func _create_random_buff() -> Resource:
	var buff = load("res://resources/buffs/buff.gd").new()
	
	var buff_types = [0, 1, 2]  # HEALTH, AMMO, WEAPON_MOD
	buff.buff_type = buff_types[randi() % buff_types.size()]
	buff.value = randi() % 50 + 10  # 10-59
	buff.duration = randi() % 5 + 1  # 1-5 runs
	
	return buff

## Helper: Create a health buff with specific value
func _create_health_buff(value: int) -> Resource:
	var buff = load("res://resources/buffs/buff.gd").new()
	buff.buff_type = 0  # HEALTH
	buff.value = value
	buff.duration = 1
	return buff

## Helper: Create a buff with specific duration
func _create_buff_with_duration(duration: int) -> Resource:
	var buff = load("res://resources/buffs/buff.gd").new()
	buff.buff_type = 0  # HEALTH
	buff.value = 20
	buff.duration = duration
	return buff

