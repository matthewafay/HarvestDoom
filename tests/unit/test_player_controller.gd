extends GdUnitTestSuite
## Unit tests for PlayerController
##
## Tests player movement, camera control, dashing, and health management.
## Validates Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 9.1, 9.2, 9.3

func before_test() -> void:
	# Ensure GameManager is available
	if not Engine.has_singleton("GameManager"):
		assert_that(false).is_true().override_failure_message("GameManager singleton not found")

func test_player_controller_exists() -> void:
	var player_scene = load("res://scenes/player.tscn")
	assert_that(player_scene).is_not_null()
	
	var player = player_scene.instantiate()
	assert_that(player).is_not_null()
	assert_that(player).is_instanceof(CharacterBody3D)
	player.queue_free()

func test_player_has_camera() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	var camera = player.get_node_or_null("Camera3D")
	assert_that(camera).is_not_null()
	assert_that(camera).is_instanceof(Camera3D)
	
	player.queue_free()

func test_player_has_collision_shape() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	var collision = player.get_node_or_null("CollisionShape3D")
	assert_that(collision).is_not_null()
	assert_that(collision.shape).is_not_null()
	
	player.queue_free()

func test_player_movement_parameters() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	# Check default movement parameters
	assert_that(player.move_speed).is_equal(5.0)
	assert_that(player.dash_speed).is_equal(15.0)
	assert_that(player.dash_duration).is_equal(0.2)
	assert_that(player.dash_cooldown).is_equal(1.0)
	
	player.queue_free()

func test_player_collision_layers() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	# Player should be on layer 1 (LAYER_PLAYER)
	assert_that(player.collision_layer).is_equal(1)
	
	# Player should collide with layers 2 (LAYER_ENEMY) and 8 (LAYER_ENVIRONMENT)
	# collision_mask = 10 (binary 1010 = layers 2 and 8)
	assert_that(player.collision_mask).is_equal(10)
	
	player.queue_free()

func test_dash_state_initialization() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	# Dash should not be active initially
	assert_that(player.is_dashing).is_false()
	assert_that(player.dash_timer).is_equal(0.0)
	assert_that(player.cooldown_timer).is_equal(0.0)
	
	player.queue_free()

func test_take_damage_reduces_health() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	
	# Set initial health
	GameManager.player_health = 100
	GameManager.player_max_health = 100
	
	# Apply damage
	player.take_damage(30)
	
	# Health should be reduced
	assert_that(GameManager.player_health).is_equal(70)
	
	remove_child(player)
	player.queue_free()

func test_take_damage_triggers_death_at_zero_health() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	
	# Set low health
	GameManager.player_health = 10
	GameManager.player_max_health = 100
	
	# Monitor died signal
	var signal_monitor = monitor_signal(player, "died")
	
	# Apply fatal damage
	player.take_damage(15)
	
	# Death signal should be emitted
	assert_signal(signal_monitor).is_emitted()
	
	remove_child(player)
	player.queue_free()

func test_camera_position() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	var camera = player.get_node("Camera3D")
	
	# Camera should be at eye level (approximately 1.6m high)
	assert_that(camera.position.y).is_equal_approx(1.6, 0.1)
	
	player.queue_free()

func test_mouse_sensitivity() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	# Check default mouse sensitivity
	assert_that(player.mouse_sensitivity).is_equal(0.002)
	
	player.queue_free()

func test_player_signals_exist() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	# Check that required signals exist
	assert_that(player.has_signal("died")).is_true()
	assert_that(player.has_signal("dash_performed")).is_true()
	
	player.queue_free()

func test_movement_speed_consistency() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	
	# Movement speed should be consistent (not affected by scene)
	var initial_speed = player.move_speed
	assert_that(initial_speed).is_equal(5.0)
	
	# Speed should remain constant
	assert_that(player.move_speed).is_equal(initial_speed)
	
	player.queue_free()

func after_test() -> void:
	# Reset GameManager state
	GameManager.player_health = 100
	GameManager.player_max_health = 100
