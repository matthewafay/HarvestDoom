extends GdUnitTestSuite
## Unit tests for scene lighting and camera positioning
## Validates Requirements 11.1, 13.1, 13.2

func test_farm_hub_has_main_directional_light() -> void:
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	var farm_hub = farm_hub_scene.instantiate()
	add_child(farm_hub)
	
	var main_light = farm_hub.get_node_or_null("DirectionalLight3D")
	assert_object(main_light).is_not_null()
	assert_bool(main_light.shadow_enabled).is_true()
	
	# Verify bright atmosphere (light energy >= 1.2)
	assert_float(main_light.light_energy).is_greater_equal(1.2)
	
	farm_hub.queue_free()

func test_farm_hub_has_fill_light() -> void:
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	var farm_hub = farm_hub_scene.instantiate()
	add_child(farm_hub)
	
	var fill_light = farm_hub.get_node_or_null("FillLight")
	assert_object(fill_light).is_not_null()
	
	# Fill light should be lower energy than main light
	assert_float(fill_light.light_energy).is_less(1.0)
	
	farm_hub.queue_free()

func test_farm_hub_environment_bright_atmosphere() -> void:
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	var farm_hub = farm_hub_scene.instantiate()
	add_child(farm_hub)
	
	var world_env = farm_hub.get_node_or_null("WorldEnvironment")
	assert_object(world_env).is_not_null()
	
	var env = world_env.environment
	assert_object(env).is_not_null()
	
	# Verify bright, cozy atmosphere settings
	assert_float(env.ambient_light_energy).is_greater_equal(0.8)
	assert_bool(env.glow_enabled).is_true()
	
	farm_hub.queue_free()

func test_farm_hub_camera_placeholder_positioned() -> void:
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	var farm_hub = farm_hub_scene.instantiate()
	add_child(farm_hub)
	
	var camera_placeholder = farm_hub.get_node_or_null("CameraPlaceholder")
	assert_object(camera_placeholder).is_not_null()
	
	# Camera should be elevated for good overview
	assert_float(camera_placeholder.position.y).is_greater(2.0)
	
	farm_hub.queue_free()

func test_combat_zone_has_main_directional_light() -> void:
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	var combat_zone = combat_zone_scene.instantiate()
	add_child(combat_zone)
	
	var main_light = combat_zone.get_node_or_null("DirectionalLight3D")
	assert_object(main_light).is_not_null()
	assert_bool(main_light.shadow_enabled).is_true()
	
	# Verify dark atmosphere (light energy <= 1.0)
	assert_float(main_light.light_energy).is_less_equal(1.0)
	
	combat_zone.queue_free()

func test_combat_zone_has_rim_light() -> void:
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	var combat_zone = combat_zone_scene.instantiate()
	add_child(combat_zone)
	
	var rim_light = combat_zone.get_node_or_null("RimLight")
	assert_object(rim_light).is_not_null()
	
	# Rim light should be subtle
	assert_float(rim_light.light_energy).is_less(0.5)
	
	combat_zone.queue_free()

func test_combat_zone_environment_dark_atmosphere() -> void:
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	var combat_zone = combat_zone_scene.instantiate()
	add_child(combat_zone)
	
	var world_env = combat_zone.get_node_or_null("WorldEnvironment")
	assert_object(world_env).is_not_null()
	
	var env = world_env.environment
	assert_object(env).is_not_null()
	
	# Verify dark, tense atmosphere settings
	assert_float(env.ambient_light_energy).is_less_equal(0.6)
	assert_bool(env.glow_enabled).is_true()
	
	combat_zone.queue_free()

func test_combat_zone_ssao_enabled() -> void:
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	var combat_zone = combat_zone_scene.instantiate()
	add_child(combat_zone)
	
	var world_env = combat_zone.get_node_or_null("WorldEnvironment")
	var env = world_env.environment
	
	# SSAO adds depth to dark scenes
	assert_bool(env.ssao_enabled).is_true()
	
	combat_zone.queue_free()

func test_combat_zone_camera_placeholder_positioned() -> void:
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	var combat_zone = combat_zone_scene.instantiate()
	add_child(combat_zone)
	
	var camera_placeholder = combat_zone.get_node_or_null("CameraPlaceholder")
	assert_object(camera_placeholder).is_not_null()
	
	# Camera should be at appropriate height for FPS combat
	assert_float(camera_placeholder.position.y).is_greater(1.5)
	
	combat_zone.queue_free()

func test_farm_hub_shadow_settings_optimized() -> void:
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	var farm_hub = farm_hub_scene.instantiate()
	add_child(farm_hub)
	
	var main_light = farm_hub.get_node_or_null("DirectionalLight3D")
	
	# Verify shadow optimization settings
	assert_int(main_light.directional_shadow_mode).is_equal(1)  # PARALLEL_2_SPLITS
	assert_float(main_light.shadow_bias).is_less_equal(0.05)
	
	farm_hub.queue_free()

func test_combat_zone_shadow_settings_optimized() -> void:
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	var combat_zone = combat_zone_scene.instantiate()
	add_child(combat_zone)
	
	var main_light = combat_zone.get_node_or_null("DirectionalLight3D")
	
	# Verify shadow optimization settings
	assert_int(main_light.directional_shadow_mode).is_equal(1)  # PARALLEL_2_SPLITS
	assert_float(main_light.shadow_bias).is_less_equal(0.05)
	
	combat_zone.queue_free()

func test_lighting_complements_procedural_tilesets() -> void:
	# Test that lighting works well with procedurally generated tilesets
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	var farm_hub = farm_hub_scene.instantiate()
	add_child(farm_hub)
	
	# Verify ground mesh exists (will have procedural tileset applied)
	var ground_mesh = farm_hub.get_node_or_null("Ground/MeshInstance3D")
	assert_object(ground_mesh).is_not_null()
	
	# Verify lighting is set up to illuminate the ground
	var main_light = farm_hub.get_node_or_null("DirectionalLight3D")
	assert_object(main_light).is_not_null()
	
	# Light should be angled to show tileset details
	var light_rotation = main_light.rotation_degrees
	assert_float(abs(light_rotation.x)).is_greater(20.0)  # Not directly overhead
	
	farm_hub.queue_free()

func test_atmosphere_contrast_between_scenes() -> void:
	# Verify that Farm Hub is brighter than Combat Zone
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	var farm_hub = farm_hub_scene.instantiate()
	add_child(farm_hub)
	
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	var combat_zone = combat_zone_scene.instantiate()
	add_child(combat_zone)
	
	var farm_light = farm_hub.get_node("DirectionalLight3D")
	var combat_light = combat_zone.get_node("DirectionalLight3D")
	
	var farm_env = farm_hub.get_node("WorldEnvironment").environment
	var combat_env = combat_zone.get_node("WorldEnvironment").environment
	
	# Farm Hub should be brighter
	assert_float(farm_light.light_energy).is_greater(combat_light.light_energy)
	assert_float(farm_env.ambient_light_energy).is_greater(combat_env.ambient_light_energy)
	
	farm_hub.queue_free()
	combat_zone.queue_free()
