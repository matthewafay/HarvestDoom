extends GdUnitTestSuite
## Property-Based Tests for Buff System
##
## Tests correctness properties for buff application and clearing:
## - Property 5.1: Buffs applied before combat are active during combat
## - Property 5.2: Buffs are cleared when returning to farm (unless multi-run)
## - Property 5.3: Buff durations decrement correctly after each run
## - Property 5.4: Expired buffs are removed automatically
##
## Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5, 7.3, 7.4

# Test constants
const ITERATIONS = 100
const MAX_BUFFS = 10
const MAX_DURATION = 5

# Buff resources for testing
const HEALTH_BUFF_20 = preload("res://resources/buffs/health_buff_20.tres")
const AMMO_BUFF_50 = preload("res://resources/buffs/ammo_buff_50.tres")
const WEAPON_MOD_DAMAGE = preload("res://resources/buffs/weapon_mod_damage.tres")

var test_buffs: Array = []

func before() -> void:
	# Initialize test buffs array
	test_buffs = [HEALTH_BUFF_20, AMMO_BUFF_50, WEAPON_MOD_DAMAGE]

func before_test() -> void:
	# Reset GameManager state before each test
	GameManager.active_buffs.clear()
	GameManager.buff_durations.clear()
	GameManager.player_health = 100
	GameManager.player_max_health = 100
	GameManager.inventory.clear()

func after_test() -> void:
	# Clean up after each test
	GameManager.active_buffs.clear()
	GameManager.buff_durations.clear()

## **Validates: Requirements 5.1, 5.4**
##
## Property 5.1: Applied buffs are tracked in active_buffs
##
## For any buff B:
## - After apply_buff(B), B is in active_buffs
## - active_buffs.size() increases by 1
func test_property_5_1_applied_buffs_are_tracked() -> void:
	for i in range(ITERATIONS):
		# Arrange - reset state
		GameManager.active_buffs.clear()
		GameManager.buff_durations.clear()
		
		# Generate random number of buffs to apply
		var num_buffs = randi() % MAX_BUFFS + 1
		
		# Act - apply buffs
		for j in range(num_buffs):
			var buff = test_buffs[randi() % test_buffs.size()]
			GameManager.apply_buff(buff)
		
		# Assert - all buffs are tracked
		assert_int(GameManager.active_buffs.size()).is_equal(num_buffs)
		assert_int(GameManager.buff_durations.size()).is_equal(num_buffs)
		
		# Assert - all buffs have valid durations
		for buff_index in GameManager.buff_durations.keys():
			var duration = GameManager.buff_durations[buff_index]
			assert_int(duration).is_greater(0)

## **Validates: Requirements 5.5, 7.4**
##
## Property 5.2: clear_temporary_buffs removes all buffs
##
## For any set of buffs:
## - After clear_temporary_buffs(), active_buffs is empty
## - buff_durations is empty
func test_property_5_2_clear_removes_all_buffs() -> void:
	for i in range(ITERATIONS):
		# Arrange - apply random buffs
		GameManager.active_buffs.clear()
		GameManager.buff_durations.clear()
		
		var num_buffs = randi() % MAX_BUFFS + 1
		for j in range(num_buffs):
			var buff = test_buffs[randi() % test_buffs.size()]
			GameManager.apply_buff(buff)
		
		# Verify buffs were applied
		assert_int(GameManager.active_buffs.size()).is_greater(0)
		
		# Act - clear buffs
		GameManager.clear_temporary_buffs()
		
		# Assert - all buffs are cleared
		assert_int(GameManager.active_buffs.size()).is_equal(0)
		assert_int(GameManager.buff_durations.size()).is_equal(0)

## **Validates: Requirement 5.4**
##
## Property 5.3: Buff durations decrement correctly
##
## For any buff with duration D:
## - After decrement_buff_durations(), duration is D-1
## - If D-1 > 0, buff remains in active_buffs
## - If D-1 <= 0, buff is removed from active_buffs
func test_property_5_3_durations_decrement_correctly() -> void:
	for i in range(ITERATIONS):
		# Arrange - apply buffs with random durations
		GameManager.active_buffs.clear()
		GameManager.buff_durations.clear()
		
		var num_buffs = randi() % MAX_BUFFS + 1
		var initial_durations: Array[int] = []
		
		for j in range(num_buffs):
			var buff = test_buffs[randi() % test_buffs.size()].duplicate()
			var duration = randi() % MAX_DURATION + 1
			buff.duration = duration
			initial_durations.append(duration)
			GameManager.apply_buff(buff)
		
		# Act - decrement durations
		GameManager.decrement_buff_durations()
		
		# Assert - durations decremented correctly
		var expected_remaining = 0
		for j in range(num_buffs):
			if initial_durations[j] > 1:
				expected_remaining += 1
		
		assert_int(GameManager.active_buffs.size()).is_equal(expected_remaining)

## **Validates: Requirement 5.4**
##
## Property 5.4: Expired buffs are removed
##
## For any buff with duration 1:
## - After decrement_buff_durations(), buff is not in active_buffs
func test_property_5_4_expired_buffs_removed() -> void:
	for i in range(ITERATIONS):
		# Arrange - apply buffs with duration 1
		GameManager.active_buffs.clear()
		GameManager.buff_durations.clear()
		
		var num_buffs = randi() % MAX_BUFFS + 1
		for j in range(num_buffs):
			var buff = test_buffs[randi() % test_buffs.size()].duplicate()
			buff.duration = 1  # All buffs expire after 1 run
			GameManager.apply_buff(buff)
		
		# Verify buffs were applied
		assert_int(GameManager.active_buffs.size()).is_equal(num_buffs)
		
		# Act - decrement durations
		GameManager.decrement_buff_durations()
		
		# Assert - all buffs expired and removed
		assert_int(GameManager.active_buffs.size()).is_equal(0)
		assert_int(GameManager.buff_durations.size()).is_equal(0)

## **Validates: Requirements 5.1, 5.2**
##
## Property 5.5: Health buffs increase max health
##
## For any health buff with value V:
## - After apply_to_player(), max_health increases by V
func test_property_5_5_health_buffs_increase_max_health() -> void:
	for i in range(ITERATIONS):
		# Arrange - reset health
		GameManager.player_max_health = 100
		
		# Generate random health buff value
		var buff_value = (randi() % 10 + 1) * 10  # 10-100
		var health_buff = HEALTH_BUFF_20.duplicate()
		health_buff.value = buff_value
		
		var initial_max_health = GameManager.player_max_health
		
		# Act - apply health buff
		health_buff.apply_to_player(null)
		
		# Assert - max health increased
		assert_int(GameManager.player_max_health).is_equal(initial_max_health + buff_value)

## **Validates: Requirements 5.1, 5.2**
##
## Property 5.6: Ammo buffs add to inventory
##
## For any ammo buff with value V:
## - After apply_to_player(), inventory["ammo"] increases by V
func test_property_5_6_ammo_buffs_add_to_inventory() -> void:
	for i in range(ITERATIONS):
		# Arrange - reset inventory
		GameManager.inventory.clear()
		GameManager.inventory["ammo"] = 0
		
		# Generate random ammo buff value
		var buff_value = (randi() % 10 + 1) * 10  # 10-100
		var ammo_buff = AMMO_BUFF_50.duplicate()
		ammo_buff.value = buff_value
		
		var initial_ammo = GameManager.get_inventory_amount("ammo")
		
		# Act - apply ammo buff
		ammo_buff.apply_to_player(null)
		
		# Assert - ammo increased
		var final_ammo = GameManager.get_inventory_amount("ammo")
		assert_int(final_ammo).is_equal(initial_ammo + buff_value)

## **Validates: Requirement 5.4**
##
## Property 5.7: Multiple runs decrement durations correctly
##
## For any buff with duration D:
## - After D calls to decrement_buff_durations(), buff is removed
## - After D-1 calls, buff is still active
func test_property_5_7_multiple_runs_decrement_correctly() -> void:
	for i in range(ITERATIONS):
		# Arrange - apply buff with random duration
		GameManager.active_buffs.clear()
		GameManager.buff_durations.clear()
		
		var duration = randi() % MAX_DURATION + 2  # 2-6 runs
		var buff = test_buffs[randi() % test_buffs.size()].duplicate()
		buff.duration = duration
		GameManager.apply_buff(buff)
		
		# Act & Assert - decrement duration-1 times
		for j in range(duration - 1):
			GameManager.decrement_buff_durations()
			assert_int(GameManager.active_buffs.size()).is_equal(1)
		
		# Act - final decrement
		GameManager.decrement_buff_durations()
		
		# Assert - buff removed
		assert_int(GameManager.active_buffs.size()).is_equal(0)

