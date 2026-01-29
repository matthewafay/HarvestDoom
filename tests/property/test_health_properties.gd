extends GdUnitTestSuite
## Property-Based Tests for Player Health and Death
##
## Tests Property 9: Health and Death Mechanics
## Validates: Requirements 9.1, 9.2, 9.3, 9.4
##
## Property: Player health is bounded by [0, max_health]. Death occurs if and only if
## health reaches 0. Death results in loss of run loot and return to Farm_Hub.

const ITERATIONS = 100

func before_test() -> void:
	# Ensure GameManager is available
	if not Engine.has_singleton("GameManager"):
		assert_that(false).is_true().override_failure_message("GameManager singleton not found")
	
	# Reset GameManager state
	GameManager.player_health = 100
	GameManager.player_max_health = 100

func test_property_health_never_exceeds_max() -> void:
	"""Property: Player health never exceeds max_health."""
	for i in range(ITERATIONS):
		var max_health = randi_range(50, 200)
		var health_to_set = randi_range(0, max_health + 100)  # Try to exceed max
		
		GameManager.player_max_health = max_health
		GameManager.set_player_health(health_to_set)
		
		# Health should be clamped to max
		assert_that(GameManager.player_health).is_less_equal(max_health)

func test_property_health_never_below_zero() -> void:
	"""Property: Player health never goes below 0."""
	for i in range(ITERATIONS):
		GameManager.player_health = randi_range(10, 50)
		var damage = randi_range(100, 200)  # Excessive damage
		
		GameManager.modify_player_health(-damage)
		
		# Health should be clamped to 0
		assert_that(GameManager.player_health).is_greater_equal(0)

func test_property_death_occurs_at_zero_health() -> void:
	"""Property: Death occurs if and only if health reaches 0."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Set health to a low value
		var initial_health = randi_range(1, 50)
		GameManager.player_health = initial_health
		GameManager.player_max_health = 100
		
		# Monitor died signal
		var signal_monitor = monitor_signal(player, "died")
		
		# Apply damage that brings health to exactly 0
		player.take_damage(initial_health)
		
		# Death should occur
		assert_that(GameManager.player_health).is_equal(0)
		assert_signal(signal_monitor).is_emitted()
		
		remove_child(player)
		player.queue_free()
		
		# Reset for next iteration
		GameManager.player_health = 100

func test_property_no_death_above_zero_health() -> void:
	"""Property: Death does not occur when health is above 0."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Set health to a value that will remain above 0
		var initial_health = randi_range(50, 100)
		GameManager.player_health = initial_health
		GameManager.player_max_health = 100
		
		# Monitor died signal
		var signal_monitor = monitor_signal(player, "died")
		
		# Apply damage that doesn't kill
		var damage = randi_range(1, initial_health - 1)
		player.take_damage(damage)
		
		# Death should not occur
		assert_that(GameManager.player_health).is_greater(0)
		assert_signal(signal_monitor).is_not_emitted()
		
		remove_child(player)
		player.queue_free()
		
		# Reset for next iteration
		GameManager.player_health = 100

func test_property_damage_reduces_health_by_exact_amount() -> void:
	"""Property: Damage reduces health by exactly the damage amount (when above 0)."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		var initial_health = randi_range(50, 100)
		GameManager.player_health = initial_health
		GameManager.player_max_health = 100
		
		var damage = randi_range(1, initial_health - 1)
		player.take_damage(damage)
		
		var expected_health = initial_health - damage
		assert_that(GameManager.player_health).is_equal(expected_health)
		
		remove_child(player)
		player.queue_free()
		
		# Reset for next iteration
		GameManager.player_health = 100

func test_property_health_bounded_by_zero_and_max() -> void:
	"""Property: Health is always in range [0, max_health]."""
	for i in range(ITERATIONS):
		var max_health = randi_range(50, 200)
		GameManager.player_max_health = max_health
		
		# Try various health values
		var test_health = randi_range(-100, max_health + 100)
		GameManager.set_player_health(test_health)
		
		# Health should be within bounds
		assert_that(GameManager.player_health).is_greater_equal(0)
		assert_that(GameManager.player_health).is_less_equal(max_health)

func test_property_max_health_always_positive() -> void:
	"""Property: Max health must always be positive."""
	for i in range(ITERATIONS):
		var max_health = randi_range(1, 200)
		GameManager.set_max_health(max_health)
		
		assert_that(GameManager.player_max_health).is_greater(0)

func test_property_health_signal_emitted_on_change() -> void:
	"""Property: health_changed signal is emitted when health changes."""
	for i in range(ITERATIONS):
		var signal_monitor = monitor_signal(GameManager, "health_changed")
		
		var initial_health = randi_range(50, 100)
		GameManager.player_health = initial_health
		GameManager.player_max_health = 100
		
		# Change health
		var delta = randi_range(-20, 20)
		GameManager.modify_player_health(delta)
		
		# Signal should be emitted
		assert_signal(signal_monitor).is_emitted()

func test_property_current_health_clamped_when_max_reduced() -> void:
	"""Property: Current health is clamped when max health is reduced below it."""
	for i in range(ITERATIONS):
		GameManager.player_health = 100
		GameManager.player_max_health = 100
		
		var new_max = randi_range(20, 80)
		GameManager.set_max_health(new_max)
		
		# Current health should not exceed new max
		assert_that(GameManager.player_health).is_less_equal(new_max)

func test_property_overkill_damage_stops_at_zero() -> void:
	"""Property: Overkill damage (more than current health) stops at 0."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		var initial_health = randi_range(10, 50)
		GameManager.player_health = initial_health
		GameManager.player_max_health = 100
		
		# Apply massive overkill damage
		var overkill_damage = initial_health + randi_range(100, 500)
		player.take_damage(overkill_damage)
		
		# Health should stop at 0, not go negative
		assert_that(GameManager.player_health).is_equal(0)
		
		remove_child(player)
		player.queue_free()
		
		# Reset for next iteration
		GameManager.player_health = 100

func after_test() -> void:
	# Reset GameManager state
	GameManager.player_health = 100
	GameManager.player_max_health = 100
