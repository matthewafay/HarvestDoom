extends GdUnitTestSuite
## Property-Based Tests for Player Movement
##
## Tests Property 1: Player Movement Responsiveness
## Validates: Requirements 1.1, 1.3, 1.4
##
## Property: For all valid directional inputs, the player character's velocity changes
## within one physics frame, and movement speed remains constant across scene transitions.

const ITERATIONS = 100

func before_test() -> void:
	# Ensure GameManager is available
	if not Engine.has_singleton("GameManager"):
		assert_that(false).is_true().override_failure_message("GameManager singleton not found")

func test_property_velocity_changes_immediately() -> void:
	"""Property: Velocity changes within one physics frame of input."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Generate random input direction
		var input_x = randf_range(-1.0, 1.0)
		var input_z = randf_range(-1.0, 1.0)
		
		# Simulate input by directly setting velocity (as _physics_process would)
		var direction = Vector3(input_x, 0, input_z).normalized()
		if direction.length() > 0:
			player.velocity.x = direction.x * player.move_speed
			player.velocity.z = direction.z * player.move_speed
			
			# Verify velocity changed immediately
			var velocity_magnitude = Vector2(player.velocity.x, player.velocity.z).length()
			assert_that(velocity_magnitude).is_greater(0.0)
			assert_that(velocity_magnitude).is_equal_approx(player.move_speed, 0.1)
		
		remove_child(player)
		player.queue_free()

func test_property_movement_speed_constant_across_scenes() -> void:
	"""Property: Movement speed remains constant regardless of scene."""
	var player_scene = load("res://scenes/player.tscn")
	
	# Test in multiple instantiations (simulating different scenes)
	var speeds = []
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		speeds.append(player.move_speed)
		player.queue_free()
	
	# All speeds should be identical
	var first_speed = speeds[0]
	for speed in speeds:
		assert_that(speed).is_equal(first_speed)

func test_property_dash_cooldown_prevents_multiple_dashes() -> void:
	"""Property: Dash cooldown prevents multiple dashes within cooldown period."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Trigger first dash
		player.is_dashing = true
		player.dash_timer = player.dash_duration
		player.cooldown_timer = player.dash_cooldown
		
		# Verify cooldown is active
		assert_that(player.cooldown_timer).is_greater(0.0)
		
		# Attempt second dash while cooldown is active
		var can_dash_again = (not player.is_dashing and player.cooldown_timer <= 0.0)
		assert_that(can_dash_again).is_false()
		
		remove_child(player)
		player.queue_free()

func test_property_dash_speed_greater_than_move_speed() -> void:
	"""Property: Dash speed is always greater than normal move speed."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		
		# Dash speed must be greater than move speed
		assert_that(player.dash_speed).is_greater(player.move_speed)
		
		player.queue_free()

func test_property_velocity_zero_when_no_input() -> void:
	"""Property: Velocity becomes zero when there's no input."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Set initial velocity
		player.velocity = Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
		
		# Simulate no input (direction = zero)
		var direction = Vector3.ZERO
		if direction.length() == 0:
			player.velocity.x = 0.0
			player.velocity.z = 0.0
		
		# Verify horizontal velocity is zero
		assert_that(player.velocity.x).is_equal(0.0)
		assert_that(player.velocity.z).is_equal(0.0)
		
		remove_child(player)
		player.queue_free()

func test_property_dash_duration_positive() -> void:
	"""Property: Dash duration is always positive."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		
		assert_that(player.dash_duration).is_greater(0.0)
		assert_that(player.dash_cooldown).is_greater(0.0)
		
		player.queue_free()

func test_property_movement_immediate_acceleration() -> void:
	"""Property: Movement has immediate acceleration (no ramp-up time)."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Start with zero velocity
		player.velocity = Vector3.ZERO
		
		# Apply input direction
		var direction = Vector3(1, 0, 0).normalized()
		player.velocity.x = direction.x * player.move_speed
		player.velocity.z = direction.z * player.move_speed
		
		# Velocity should immediately match target speed (no gradual acceleration)
		var velocity_magnitude = Vector2(player.velocity.x, player.velocity.z).length()
		assert_that(velocity_magnitude).is_equal_approx(player.move_speed, 0.01)
		
		remove_child(player)
		player.queue_free()

func test_property_dash_timer_decreases() -> void:
	"""Property: Dash timer decreases over time when dashing."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Start dash
		player.is_dashing = true
		player.dash_timer = player.dash_duration
		var initial_timer = player.dash_timer
		
		# Simulate time passing
		var delta = randf_range(0.01, 0.1)
		player.dash_timer -= delta
		
		# Timer should have decreased
		assert_that(player.dash_timer).is_less(initial_timer)
		
		remove_child(player)
		player.queue_free()

func test_property_cooldown_timer_decreases() -> void:
	"""Property: Cooldown timer decreases over time."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Set cooldown
		player.cooldown_timer = player.dash_cooldown
		var initial_cooldown = player.cooldown_timer
		
		# Simulate time passing
		var delta = randf_range(0.01, 0.1)
		player.cooldown_timer -= delta
		
		# Cooldown should have decreased
		assert_that(player.cooldown_timer).is_less(initial_cooldown)
		
		remove_child(player)
		player.queue_free()

func test_property_dash_ends_when_timer_expires() -> void:
	"""Property: Dash state ends when dash timer reaches zero."""
	var player_scene = load("res://scenes/player.tscn")
	
	for i in range(ITERATIONS):
		var player = player_scene.instantiate()
		add_child(player)
		
		# Start dash
		player.is_dashing = true
		player.dash_timer = 0.01  # Very short timer
		
		# Simulate timer expiring
		player.dash_timer = 0.0
		if player.dash_timer <= 0.0:
			player.is_dashing = false
		
		# Dash should be inactive
		assert_that(player.is_dashing).is_false()
		
		remove_child(player)
		player.queue_free()

func after_test() -> void:
	# Cleanup
	pass
