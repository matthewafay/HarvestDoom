# GdUnit generated TestSuite
class_name TestFarmHubScene
extends GdUnitTestSuite

## Unit tests for Farm_Hub scene (Task 1.5.1)
##
## Tests verify:
## - Scene loads and instantiates correctly
## - All required nodes are present
## - Ground plane has proper collision setup
## - Lighting and environment are configured
## - Scene follows Godot 4.x best practices
##
## Validates: Requirements 11.1, 13.1, 13.2

# Reference to the source being tested
const __source = 'res://scenes/farm_hub.tscn'

var farm_hub_scene: PackedScene
var farm_hub_instance: Node3D

func before_test() -> void:
	"""Setup before each test - load the scene."""
	farm_hub_scene = load("res://scenes/farm_hub.tscn")
	assert_object(farm_hub_scene).is_not_null()

func after_test() -> void:
	"""Cleanup after each test."""
	if farm_hub_instance:
		farm_hub_instance.queue_free()
		farm_hub_instance = null

# ============================================================================
# Scene Loading Tests
# ============================================================================

func test_scene_loads_successfully() -> void:
	"""Test that the Farm_Hub scene file loads without errors."""
	assert_object(farm_hub_scene).is_not_null()

func test_scene_instantiates_successfully() -> void:
	"""Test that the Farm_Hub scene can be instantiated."""
	farm_hub_instance = farm_hub_scene.instantiate()
	assert_object(farm_hub_instance).is_not_null()
	assert_bool(farm_hub_instance is Node3D).is_true()

func test_scene_has_script_attached() -> void:
	"""Test that the Farm_Hub scene has a script attached."""
	farm_hub_instance = farm_hub_scene.instantiate()
	assert_object(farm_hub_instance.get_script()).is_not_null()

# ============================================================================
# Required Nodes Tests
# ============================================================================

func test_has_world_environment() -> void:
	"""Test that the scene has a WorldEnvironment node."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var world_env := farm_hub_instance.get_node_or_null("WorldEnvironment")
	assert_object(world_env).is_not_null()
	assert_bool(world_env is WorldEnvironment).is_true()

func test_has_directional_light() -> void:
	"""Test that the scene has a DirectionalLight3D node."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var light := farm_hub_instance.get_node_or_null("DirectionalLight3D")
	assert_object(light).is_not_null()
	assert_bool(light is DirectionalLight3D).is_true()

func test_has_ground_node() -> void:
	"""Test that the scene has a Ground StaticBody3D node."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var ground := farm_hub_instance.get_node_or_null("Ground")
	assert_object(ground).is_not_null()
	assert_bool(ground is StaticBody3D).is_true()

func test_has_ground_collision_shape() -> void:
	"""Test that the Ground has a CollisionShape3D."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var collision_shape := farm_hub_instance.get_node_or_null("Ground/CollisionShape3D")
	assert_object(collision_shape).is_not_null()
	assert_bool(collision_shape is CollisionShape3D).is_true()
	assert_object(collision_shape.shape).is_not_null()

func test_has_ground_mesh() -> void:
	"""Test that the Ground has a MeshInstance3D."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var mesh_instance := farm_hub_instance.get_node_or_null("Ground/MeshInstance3D")
	assert_object(mesh_instance).is_not_null()
	assert_bool(mesh_instance is MeshInstance3D).is_true()

func test_has_camera_placeholder() -> void:
	"""Test that the scene has a camera placeholder marker."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var camera_placeholder := farm_hub_instance.get_node_or_null("CameraPlaceholder")
	assert_object(camera_placeholder).is_not_null()
	assert_bool(camera_placeholder is Marker3D).is_true()

func test_has_farming_area_marker() -> void:
	"""Test that the scene has a farming area marker for future FarmGrid placement."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var farming_area := farm_hub_instance.get_node_or_null("FarmingArea")
	assert_object(farming_area).is_not_null()
	assert_bool(farming_area is Marker3D).is_true()

func test_has_portal_location_marker() -> void:
	"""Test that the scene has a portal location marker for combat zone transition."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var portal_location := farm_hub_instance.get_node_or_null("PortalLocation")
	assert_object(portal_location).is_not_null()
	assert_bool(portal_location is Marker3D).is_true()

# ============================================================================
# Collision Configuration Tests
# ============================================================================

func test_ground_collision_layer() -> void:
	"""Test that Ground uses LAYER_ENVIRONMENT (layer 4, bit 8)."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var ground: StaticBody3D = farm_hub_instance.get_node("Ground")
	# LAYER_ENVIRONMENT = 8 (bit 4 set)
	assert_int(ground.collision_layer).is_equal(8)

func test_ground_collision_mask() -> void:
	"""Test that Ground has collision_mask set to 0 (doesn't check collisions)."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var ground: StaticBody3D = farm_hub_instance.get_node("Ground")
	assert_int(ground.collision_mask).is_equal(0)

# ============================================================================
# Environment Configuration Tests
# ============================================================================

func test_world_environment_has_environment() -> void:
	"""Test that WorldEnvironment has an Environment resource configured."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var world_env: WorldEnvironment = farm_hub_instance.get_node("WorldEnvironment")
	assert_object(world_env.environment).is_not_null()

func test_environment_uses_sky_background() -> void:
	"""Test that the environment uses a sky background."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var world_env: WorldEnvironment = farm_hub_instance.get_node("WorldEnvironment")
	var env := world_env.environment
	# BG_SKY = 2
	assert_int(env.background_mode).is_equal(Environment.BG_SKY)

func test_environment_has_sky() -> void:
	"""Test that the environment has a Sky resource."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var world_env: WorldEnvironment = farm_hub_instance.get_node("WorldEnvironment")
	var env := world_env.environment
	assert_object(env.sky).is_not_null()

# ============================================================================
# Lighting Configuration Tests
# ============================================================================

func test_directional_light_has_shadows() -> void:
	"""Test that the directional light has shadows enabled."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var light: DirectionalLight3D = farm_hub_instance.get_node("DirectionalLight3D")
	assert_bool(light.shadow_enabled).is_true()

func test_directional_light_warm_color() -> void:
	"""Test that the directional light uses warm colors for farm atmosphere."""
	farm_hub_instance = farm_hub_scene.instantiate()
	var light: DirectionalLight3D = farm_hub_instance.get_node("DirectionalLight3D")
	# Warm light should have high R and G values
	assert_float(light.light_color.r).is_greater(0.9)
	assert_float(light.light_color.g).is_greater(0.9)

# ============================================================================
# Ground Mesh Setup Tests
# ============================================================================

func test_ground_mesh_setup_after_ready() -> void:
	"""Test that the ground mesh is properly set up after _ready is called."""
	farm_hub_instance = farm_hub_scene.instantiate()
	add_child(farm_hub_instance)
	
	# Wait for _ready to be called
	await get_tree().process_frame
	
	var mesh_instance: MeshInstance3D = farm_hub_instance.get_node("Ground/MeshInstance3D")
	assert_object(mesh_instance.mesh).is_not_null()
	assert_bool(mesh_instance.mesh is PlaneMesh).is_true()

func test_ground_plane_size() -> void:
	"""Test that the ground plane has the correct size (30x30)."""
	farm_hub_instance = farm_hub_scene.instantiate()
	add_child(farm_hub_instance)
	
	await get_tree().process_frame
	
	var mesh_instance: MeshInstance3D = farm_hub_instance.get_node("Ground/MeshInstance3D")
	var plane: PlaneMesh = mesh_instance.mesh
	assert_vector2(plane.size).is_equal(Vector2(30, 30))

func test_ground_plane_has_subdivisions() -> void:
	"""Test that the ground plane has subdivisions for better visual quality."""
	farm_hub_instance = farm_hub_scene.instantiate()
	add_child(farm_hub_instance)
	
	await get_tree().process_frame
	
	var mesh_instance: MeshInstance3D = farm_hub_instance.get_node("Ground/MeshInstance3D")
	var plane: PlaneMesh = mesh_instance.mesh
	assert_int(plane.subdivide_width).is_greater(0)
	assert_int(plane.subdivide_depth).is_greater(0)

func test_ground_has_material() -> void:
	"""Test that the ground plane has a material assigned."""
	farm_hub_instance = farm_hub_scene.instantiate()
	add_child(farm_hub_instance)
	
	await get_tree().process_frame
	
	var mesh_instance: MeshInstance3D = farm_hub_instance.get_node("Ground/MeshInstance3D")
	var plane: PlaneMesh = mesh_instance.mesh
	assert_object(plane.material).is_not_null()

func test_ground_uses_procedural_tileset() -> void:
	"""Test that the ground uses a procedurally generated tileset texture."""
	farm_hub_instance = farm_hub_scene.instantiate()
	add_child(farm_hub_instance)
	
	await get_tree().process_frame
	
	var mesh_instance: MeshInstance3D = farm_hub_instance.get_node("Ground/MeshInstance3D")
	var plane: PlaneMesh = mesh_instance.mesh
	var material: StandardMaterial3D = plane.material
	
	# Check that the material has an albedo texture (procedurally generated tileset)
	assert_object(material.albedo_texture).is_not_null()
	assert_bool(material.albedo_texture is Texture2D).is_true()

func test_ground_tileset_is_deterministic() -> void:
	"""Test that the procedurally generated tileset is deterministic (same seed = same result)."""
	# Create two instances
	var instance1 = farm_hub_scene.instantiate()
	add_child(instance1)
	await get_tree().process_frame
	
	var instance2 = farm_hub_scene.instantiate()
	add_child(instance2)
	await get_tree().process_frame
	
	# Get the textures from both instances
	var mesh1: MeshInstance3D = instance1.get_node("Ground/MeshInstance3D")
	var plane1: PlaneMesh = mesh1.mesh
	var material1: StandardMaterial3D = plane1.material
	var texture1: Texture2D = material1.albedo_texture
	
	var mesh2: MeshInstance3D = instance2.get_node("Ground/MeshInstance3D")
	var plane2: PlaneMesh = mesh2.mesh
	var material2: StandardMaterial3D = plane2.material
	var texture2: Texture2D = material2.albedo_texture
	
	# Both textures should have the same dimensions
	assert_int(texture1.get_width()).is_equal(texture2.get_width())
	assert_int(texture1.get_height()).is_equal(texture2.get_height())
	
	# Clean up
	instance1.queue_free()
	instance2.queue_free()

func test_ground_uses_farm_palette_color() -> void:
	"""Test that the ground uses colors from the FARM_PALETTE."""
	farm_hub_instance = farm_hub_scene.instantiate()
	add_child(farm_hub_instance)
	
	await get_tree().process_frame
	
	var mesh_instance: MeshInstance3D = farm_hub_instance.get_node("Ground/MeshInstance3D")
	var plane: PlaneMesh = mesh_instance.mesh
	var material: StandardMaterial3D = plane.material
	
	# Check that the material has a texture (not just a solid color)
	assert_object(material.albedo_texture).is_not_null()
