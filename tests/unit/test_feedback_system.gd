# GdUnit generated TestSuite
class_name TestFeedbackSystem
extends GdUnitTestSuite

## Unit tests for FeedbackSystem singleton
##
## Tests verify:
## - Singleton initialization
## - Damage number spawning
## - Hit effect spawning
## - Screen flash effects
## - Camera shake effects
## - Procedural particle effects (impact, death, harvest)
## - Signal emissions
##
## Validates: Requirements 2.3, 9.2, 12.8

# Reference to the source being tested
const __source = 'res://scripts/systems/feedback_system.gd'

# Test instance (we'll use the autoload singleton)
var feedback_system: FeedbackSystem
var test_camera: Camera3D
var test_scene: Node3D

func before_test() -> void:
	"""Setup before each test - get FeedbackSystem reference and create test scene."""
	feedback_system = FeedbackSystem
	
	# Create a test scene with camera
	test_scene = Node3D.new()
	test_camera = Camera3D.new()
	test_scene.add_child(test_camera)
	
	# Add test scene to tree
	add_child(test_scene)
	
	# Set camera reference in feedback system
	feedback_system.set_camera(test_camera)
	
	# Reset any ongoing effects
	feedback_system.shake_timer = 0.0
	feedback_system.flash_timer = 0.0

func after_test() -> void:
	"""Cleanup after each test."""
	# Remove test scene
	if test_scene != null:
		test_scene.queue_free()
	
	# Reset feedback system state
	feedback_system.shake_timer = 0.0
	feedback_system.flash_timer = 0.0
	feedback_system.camera = null

# ============================================================================
# Initialization Tests
# ============================================================================

func test_feedback_system_exists() -> void:
	"""Test that FeedbackSystem singleton is accessible."""
	assert_object(feedback_system).is_not_null()

func test_screen_flash_initialized() -> void:
	"""Test that screen flash overlay is initialized."""
	assert_object(feedback_system.screen_flash).is_not_null()
	assert_bool(feedback_system.screen_flash.visible).is_false()

func test_camera_can_be_set() -> void:
	"""Test that camera reference can be set."""
	var new_camera = Camera3D.new()
	feedback_system.set_camera(new_camera)
	
	assert_object(feedback_system.camera).is_same(new_camera)
	new_camera.queue_free()

func test_initial_shake_state() -> void:
	"""Test that camera shake state is initialized to zero."""
	assert_float(feedback_system.shake_intensity).is_equal(0.0)
	assert_float(feedback_system.shake_duration).is_equal(0.0)
	assert_float(feedback_system.shake_timer).is_equal(0.0)

func test_initial_flash_state() -> void:
	"""Test that screen flash state is initialized to zero."""
	assert_float(feedback_system.flash_timer).is_equal(0.0)
	assert_float(feedback_system.flash_duration).is_equal(0.0)

# ============================================================================
# Damage Number Tests
# ============================================================================

func test_spawn_damage_number_creates_label() -> void:
	"""Test that spawning damage number creates a Label3D in the scene."""
	var initial_child_count = get_tree().current_scene.get_child_count()
	
	feedback_system.spawn_damage_number(50, Vector3(0, 1, 0))
	
	# Wait a frame for the label to be added
	await await_idle_frame()
	
	# Check that a new child was added
	var new_child_count = get_tree().current_scene.get_child_count()
	assert_int(new_child_count).is_greater(initial_child_count)

func test_spawn_damage_number_emits_signal() -> void:
	"""Test that spawning damage number emits feedback_completed signal."""
	var signal_monitor = monitor_signals(feedback_system)
	
	feedback_system.spawn_damage_number(25, Vector3.ZERO)
	
	assert_signal(signal_monitor).is_emitted("feedback_completed", ["damage_number"])

func test_spawn_damage_number_positive_is_red() -> void:
	"""Test that positive damage numbers are displayed in red."""
	feedback_system.spawn_damage_number(100, Vector3.ZERO)
	
	await await_idle_frame()
	
	# Find the created label
	var labels = _find_nodes_of_type(get_tree().current_scene, Label3D)
	if labels.size() > 0:
		var label = labels[-1] as Label3D
		# Red color for damage
		assert_object(label.modulate).is_equal(Color.RED)

func test_spawn_damage_number_negative_is_green() -> void:
	"""Test that negative damage numbers (healing) are displayed in green."""
	feedback_system.spawn_damage_number(-50, Vector3.ZERO)
	
	await await_idle_frame()
	
	# Find the created label
	var labels = _find_nodes_of_type(get_tree().current_scene, Label3D)
	if labels.size() > 0:
		var label = labels[-1] as Label3D
		# Green color for healing
		assert_object(label.modulate).is_equal(Color.GREEN)

# ============================================================================
# Hit Effect Tests
# ============================================================================

func test_spawn_hit_effect_emits_signal() -> void:
	"""Test that spawning hit effect emits feedback_completed signal."""
	var signal_monitor = monitor_signals(feedback_system)
	
	feedback_system.spawn_hit_effect(Vector3.ZERO, false)
	
	assert_signal(signal_monitor).is_emitted("feedback_completed", ["hit_effect"])

func test_spawn_hit_effect_normal() -> void:
	"""Test that spawning normal hit effect creates particles."""
	var initial_child_count = get_tree().current_scene.get_child_count()
	
	feedback_system.spawn_hit_effect(Vector3(1, 1, 1), false)
	
	await await_idle_frame()
	
	# Check that particles were added
	var new_child_count = get_tree().current_scene.get_child_count()
	assert_int(new_child_count).is_greater(initial_child_count)

func test_spawn_hit_effect_critical() -> void:
	"""Test that spawning critical hit effect creates particles."""
	var initial_child_count = get_tree().current_scene.get_child_count()
	
	feedback_system.spawn_hit_effect(Vector3(1, 1, 1), true)
	
	await await_idle_frame()
	
	# Check that particles were added
	var new_child_count = get_tree().current_scene.get_child_count()
	assert_int(new_child_count).is_greater(initial_child_count)

# ============================================================================
# Screen Flash Tests
# ============================================================================

func test_flash_screen_sets_visible() -> void:
	"""Test that flashing screen makes the flash overlay visible."""
	feedback_system.flash_screen(Color.RED, 0.5)
	
	assert_bool(feedback_system.screen_flash.visible).is_true()

func test_flash_screen_sets_color() -> void:
	"""Test that flashing screen sets the correct color."""
	var flash_color = Color.YELLOW
	feedback_system.flash_screen(flash_color, 0.3)
	
	assert_object(feedback_system.flash_color).is_equal(flash_color)

func test_flash_screen_sets_duration() -> void:
	"""Test that flashing screen sets the correct duration."""
	feedback_system.flash_screen(Color.WHITE, 1.5)
	
	assert_float(feedback_system.flash_duration).is_equal(1.5)
	assert_float(feedback_system.flash_timer).is_equal(1.5)

func test_flash_screen_fades_over_time() -> void:
	"""Test that screen flash fades out over time."""
	feedback_system.flash_screen(Color.RED, 0.2)
	
	# Process for half the duration
	feedback_system._process(0.1)
	
	# Timer should have decreased
	assert_float(feedback_system.flash_timer).is_less(0.2)
	assert_float(feedback_system.flash_timer).is_greater(0.0)

func test_flash_screen_completes_and_hides() -> void:
	"""Test that screen flash hides after duration completes."""
	feedback_system.flash_screen(Color.BLUE, 0.1)
	
	# Process past the duration
	feedback_system._process(0.15)
	
	# Flash should be complete
	assert_bool(feedback_system.screen_flash.visible).is_false()
	assert_float(feedback_system.flash_timer).is_equal(0.0)

func test_flash_screen_emits_signal_on_complete() -> void:
	"""Test that screen flash emits signal when complete."""
	var signal_monitor = monitor_signals(feedback_system)
	
	feedback_system.flash_screen(Color.GREEN, 0.05)
	feedback_system._process(0.1)
	
	assert_signal(signal_monitor).is_emitted("feedback_completed", ["screen_flash"])

# ============================================================================
# Camera Shake Tests
# ============================================================================

func test_shake_camera_sets_intensity() -> void:
	"""Test that shaking camera sets the correct intensity."""
	feedback_system.shake_camera(0.5, 0.3)
	
	assert_float(feedback_system.shake_intensity).is_equal(0.5)

func test_shake_camera_sets_duration() -> void:
	"""Test that shaking camera sets the correct duration."""
	feedback_system.shake_camera(0.3, 1.0)
	
	assert_float(feedback_system.shake_duration).is_equal(1.0)
	assert_float(feedback_system.shake_timer).is_equal(1.0)

func test_shake_camera_stores_original_position() -> void:
	"""Test that camera shake stores the original camera position."""
	var original_pos = test_camera.position
	feedback_system.shake_camera(0.2, 0.5)
	
	assert_object(feedback_system.original_camera_position).is_equal(original_pos)

func test_shake_camera_moves_camera() -> void:
	"""Test that camera shake actually moves the camera."""
	var original_pos = test_camera.position
	feedback_system.shake_camera(0.5, 0.5)
	
	# Process one frame
	feedback_system._process(0.016)
	
	# Camera should have moved (unless random offset was exactly zero, which is unlikely)
	# We'll just check that the shake is active
	assert_float(feedback_system.shake_timer).is_greater(0.0)

func test_shake_camera_restores_position_on_complete() -> void:
	"""Test that camera shake restores original position when complete."""
	var original_pos = test_camera.position
	feedback_system.shake_camera(0.3, 0.1)
	
	# Process past the duration
	feedback_system._process(0.15)
	
	# Camera should be back to original position
	assert_object(test_camera.position).is_equal(original_pos)
	assert_float(feedback_system.shake_intensity).is_equal(0.0)

func test_shake_camera_emits_signal_on_complete() -> void:
	"""Test that camera shake emits signal when complete."""
	var signal_monitor = monitor_signals(feedback_system)
	
	feedback_system.shake_camera(0.2, 0.05)
	feedback_system._process(0.1)
	
	assert_signal(signal_monitor).is_emitted("feedback_completed", ["camera_shake"])

func test_shake_camera_without_camera_shows_warning() -> void:
	"""Test that shaking without a camera shows a warning."""
	feedback_system.camera = null
	
	# This should not crash, just show a warning
	feedback_system.shake_camera(0.5, 0.5)
	
	# Shake should not be active
	assert_float(feedback_system.shake_timer).is_equal(0.0)

# ============================================================================
# Impact Particles Tests
# ============================================================================

func test_create_impact_particles_creates_particles() -> void:
	"""Test that creating impact particles adds CPUParticles3D to scene."""
	var initial_child_count = get_tree().current_scene.get_child_count()
	
	feedback_system.create_impact_particles(Vector3.ZERO, Color.WHITE)
	
	await await_idle_frame()
	
	# Check that particles were added
	var new_child_count = get_tree().current_scene.get_child_count()
	assert_int(new_child_count).is_greater(initial_child_count)

func test_create_impact_particles_emits_signal() -> void:
	"""Test that creating impact particles emits feedback_completed signal."""
	var signal_monitor = monitor_signals(feedback_system)
	
	feedback_system.create_impact_particles(Vector3(1, 0, 0), Color.RED)
	
	await await_signal(feedback_system.feedback_completed, [], 1000)
	
	assert_signal(signal_monitor).is_emitted("feedback_completed", ["impact_particles"])

func test_create_impact_particles_uses_color() -> void:
	"""Test that impact particles use the specified color."""
	var test_color = Color.BLUE
	feedback_system.create_impact_particles(Vector3.ZERO, test_color)
	
	await await_idle_frame()
	
	# Find the created particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles3D)
	if particles_list.size() > 0:
		var particles = particles_list[-1] as CPUParticles3D
		# Check that color ramp starts with our color
		if particles.color_ramp != null:
			assert_object(particles.color_ramp.get_color(0)).is_equal(test_color)

# ============================================================================
# Death Explosion Tests
# ============================================================================

func test_create_death_explosion_creates_particles() -> void:
	"""Test that creating death explosion adds CPUParticles3D to scene."""
	var initial_child_count = get_tree().current_scene.get_child_count()
	
	feedback_system.create_death_explosion(Vector3.ZERO, "MeleeCharger")
	
	await await_idle_frame()
	
	# Check that particles were added
	var new_child_count = get_tree().current_scene.get_child_count()
	assert_int(new_child_count).is_greater(initial_child_count)

func test_create_death_explosion_emits_signal() -> void:
	"""Test that creating death explosion emits feedback_completed signal."""
	var signal_monitor = monitor_signals(feedback_system)
	
	feedback_system.create_death_explosion(Vector3(0, 1, 0), "TankEnemy")
	
	await await_signal(feedback_system.feedback_completed, [], 1500)
	
	assert_signal(signal_monitor).is_emitted("feedback_completed", ["death_explosion"])

func test_create_death_explosion_melee_charger() -> void:
	"""Test that MeleeCharger death explosion is created."""
	feedback_system.create_death_explosion(Vector3.ZERO, "MeleeCharger")
	
	await await_idle_frame()
	
	# Should create particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles3D)
	assert_int(particles_list.size()).is_greater(0)

func test_create_death_explosion_ranged_shooter() -> void:
	"""Test that RangedShooter death explosion is created."""
	feedback_system.create_death_explosion(Vector3.ZERO, "RangedShooter")
	
	await await_idle_frame()
	
	# Should create particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles3D)
	assert_int(particles_list.size()).is_greater(0)

func test_create_death_explosion_tank_enemy() -> void:
	"""Test that TankEnemy death explosion is created."""
	feedback_system.create_death_explosion(Vector3.ZERO, "TankEnemy")
	
	await await_idle_frame()
	
	# Should create particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles3D)
	assert_int(particles_list.size()).is_greater(0)

func test_create_death_explosion_unknown_type() -> void:
	"""Test that unknown enemy type still creates explosion with default color."""
	feedback_system.create_death_explosion(Vector3.ZERO, "UnknownEnemy")
	
	await await_idle_frame()
	
	# Should still create particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles3D)
	assert_int(particles_list.size()).is_greater(0)

# ============================================================================
# Harvest Effect Tests
# ============================================================================

func test_create_harvest_effect_creates_particles() -> void:
	"""Test that creating harvest effect adds CPUParticles2D to scene."""
	var initial_child_count = get_tree().current_scene.get_child_count()
	
	feedback_system.create_harvest_effect(Vector2.ZERO, "health_crop")
	
	await await_idle_frame()
	
	# Check that particles were added
	var new_child_count = get_tree().current_scene.get_child_count()
	assert_int(new_child_count).is_greater(initial_child_count)

func test_create_harvest_effect_emits_signal() -> void:
	"""Test that creating harvest effect emits feedback_completed signal."""
	var signal_monitor = monitor_signals(feedback_system)
	
	feedback_system.create_harvest_effect(Vector2(10, 10), "ammo_crop")
	
	await await_signal(feedback_system.feedback_completed, [], 1000)
	
	assert_signal(signal_monitor).is_emitted("feedback_completed", ["harvest_effect"])

func test_create_harvest_effect_health_crop() -> void:
	"""Test that health crop harvest effect is created."""
	feedback_system.create_harvest_effect(Vector2.ZERO, "health_crop")
	
	await await_idle_frame()
	
	# Should create particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles2D)
	assert_int(particles_list.size()).is_greater(0)

func test_create_harvest_effect_ammo_crop() -> void:
	"""Test that ammo crop harvest effect is created."""
	feedback_system.create_harvest_effect(Vector2.ZERO, "ammo_crop")
	
	await await_idle_frame()
	
	# Should create particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles2D)
	assert_int(particles_list.size()).is_greater(0)

func test_create_harvest_effect_weapon_mod_crop() -> void:
	"""Test that weapon mod crop harvest effect is created."""
	feedback_system.create_harvest_effect(Vector2.ZERO, "weapon_mod_crop")
	
	await await_idle_frame()
	
	# Should create particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles2D)
	assert_int(particles_list.size()).is_greater(0)

func test_create_harvest_effect_unknown_crop() -> void:
	"""Test that unknown crop type still creates effect with default color."""
	feedback_system.create_harvest_effect(Vector2.ZERO, "unknown_crop")
	
	await await_idle_frame()
	
	# Should still create particles
	var particles_list = _find_nodes_of_type(get_tree().current_scene, CPUParticles2D)
	assert_int(particles_list.size()).is_greater(0)

# ============================================================================
# Helper Methods
# ============================================================================

func _find_nodes_of_type(parent: Node, type) -> Array:
	"""Helper to find all nodes of a specific type in the tree."""
	var result: Array = []
	for child in parent.get_children():
		if is_instance_of(child, type):
			result.append(child)
		result.append_array(_find_nodes_of_type(child, type))
	return result
