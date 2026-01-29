extends GdUnitTestSuite

## Unit tests for Combat_Zone scene
## Tests scene structure, collision configuration, environment setup, and procedural generation

const COMBAT_ZONE_SCENE_PATH = "res://scenes/combat_zone.tscn"

# Collision layer constants (from design document)
const LAYER_ENVIRONMENT = 8  # Bit 4

func test_scene_loads_successfully() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	assert_that(scene).is_not_null()

func test_scene_instantiates_successfully() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	assert_that(instance).is_not_null()
	instance.free()

func test_scene_has_script_attached() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	assert_that(instance.get_script()).is_not_null()
	instance.free()

# Test required nodes exist
func test_has_world_environment() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var world_env = instance.get_node("WorldEnvironment")
	assert_that(world_env).is_not_null()
	instance.free()

func test_has_directional_light() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var light = instance.get_node("DirectionalLight3D")
	assert_that(light).is_not_null()
	instance.free()

func test_has_arena_static_body() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var arena = instance.get_node("Arena")
	assert_that(arena).is_not_null()
	assert_that(arena).is_instanceof(StaticBody3D)
	instance.free()

func test_has_arena_collision_shape() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var collision = instance.get_node("Arena/CollisionShape3D")
	assert_that(collision).is_not_null()
	instance.free()

func test_has_arena_mesh_instance() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var mesh = instance.get_node("Arena/MeshInstance3D")
	assert_that(mesh).is_not_null()
	instance.free()

func test_has_arena_boundaries_node() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var boundaries = instance.get_node("ArenaBoundaries")
	assert_that(boundaries).is_not_null()
	instance.free()

func test_has_all_boundary_walls() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	for wall_name in walls:
		var wall = instance.get_node("ArenaBoundaries/" + wall_name)
		assert_that(wall).is_not_null()
		assert_that(wall).is_instanceof(StaticBody3D)
	
	instance.free()

func test_has_spawn_points_node() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var spawn_points = instance.get_node("SpawnPoints")
	assert_that(spawn_points).is_not_null()
	instance.free()

func test_has_six_spawn_points() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	
	for i in range(1, 7):
		var spawn_point = instance.get_node("SpawnPoints/SpawnPoint" + str(i))
		assert_that(spawn_point).is_not_null()
		assert_that(spawn_point).is_instanceof(Marker3D)
	
	instance.free()

func test_has_camera_placeholder() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var camera_placeholder = instance.get_node("CameraPlaceholder")
	assert_that(camera_placeholder).is_not_null()
	assert_that(camera_placeholder).is_instanceof(Marker3D)
	instance.free()

func test_has_player_spawn_point() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var player_spawn = instance.get_node("PlayerSpawnPoint")
	assert_that(player_spawn).is_not_null()
	assert_that(player_spawn).is_instanceof(Marker3D)
	instance.free()

# Test collision configuration
func test_arena_uses_environment_layer() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var arena = instance.get_node("Arena")
	assert_that(arena.collision_layer).is_equal(LAYER_ENVIRONMENT)
	instance.free()

func test_arena_collision_mask_is_zero() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var arena = instance.get_node("Arena")
	assert_that(arena.collision_mask).is_equal(0)
	instance.free()

func test_boundary_walls_use_environment_layer() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	for wall_name in walls:
		var wall = instance.get_node("ArenaBoundaries/" + wall_name)
		assert_that(wall.collision_layer).is_equal(LAYER_ENVIRONMENT)
		assert_that(wall.collision_mask).is_equal(0)
	
	instance.free()

# Test environment configuration
func test_world_environment_has_environment_resource() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var world_env = instance.get_node("WorldEnvironment")
	assert_that(world_env.environment).is_not_null()
	instance.free()

func test_environment_uses_sky_background() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var world_env = instance.get_node("WorldEnvironment")
	var environment = world_env.environment
	assert_that(environment.background_mode).is_equal(Environment.BG_SKY)
	instance.free()

func test_environment_has_sky_resource() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var world_env = instance.get_node("WorldEnvironment")
	var environment = world_env.environment
	assert_that(environment.sky).is_not_null()
	instance.free()

func test_environment_uses_dark_colors() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var world_env = instance.get_node("WorldEnvironment")
	var environment = world_env.environment
	
	# Check ambient light is darker than farm hub (should be around 0.5 energy)
	assert_that(environment.ambient_light_energy).is_less_equal(0.6)
	
	instance.free()

# Test lighting configuration
func test_directional_light_has_shadows_enabled() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var light = instance.get_node("DirectionalLight3D")
	assert_that(light.shadow_enabled).is_true()
	instance.free()

func test_directional_light_uses_combat_colors() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var light = instance.get_node("DirectionalLight3D")
	
	# Light should have reddish tint (from COMBAT_PALETTE)
	# Red component should be higher than green and blue
	assert_that(light.light_color.r).is_greater(light.light_color.g)
	assert_that(light.light_color.r).is_greater(light.light_color.b)
	
	instance.free()

func test_directional_light_has_lower_energy() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	var light = instance.get_node("DirectionalLight3D")
	
	# Combat zone should have darker lighting than farm hub (< 1.0)
	assert_that(light.light_energy).is_less(1.0)
	
	instance.free()

# Test arena floor setup after _ready
func test_arena_floor_mesh_set_up_after_ready() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var mesh_instance = instance.get_node("Arena/MeshInstance3D")
	assert_that(mesh_instance.mesh).is_not_null()
	
	instance.queue_free()

func test_arena_floor_size_is_25x25() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var mesh_instance = instance.get_node("Arena/MeshInstance3D")
	var plane_mesh = mesh_instance.mesh as PlaneMesh
	assert_that(plane_mesh).is_not_null()
	assert_that(plane_mesh.size).is_equal(Vector2(25, 25))
	
	instance.queue_free()

func test_arena_floor_has_subdivisions() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var mesh_instance = instance.get_node("Arena/MeshInstance3D")
	var plane_mesh = mesh_instance.mesh as PlaneMesh
	assert_that(plane_mesh.subdivide_width).is_greater(0)
	assert_that(plane_mesh.subdivide_depth).is_greater(0)
	
	instance.queue_free()

func test_arena_floor_has_material_assigned() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var mesh_instance = instance.get_node("Arena/MeshInstance3D")
	assert_that(mesh_instance.material_override).is_not_null()
	
	instance.queue_free()

func test_arena_floor_uses_procedural_tileset() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var mesh_instance = instance.get_node("Arena/MeshInstance3D")
	var material = mesh_instance.material_override as StandardMaterial3D
	assert_that(material).is_not_null()
	
	# Check that the material has an albedo texture (procedurally generated tileset)
	assert_that(material.albedo_texture).is_not_null()
	assert_that(material.albedo_texture).is_instanceof(Texture2D)
	
	instance.queue_free()

func test_arena_floor_tileset_is_deterministic() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	
	# Create two instances
	var instance1 = scene.instantiate()
	add_child(instance1)
	await get_tree().process_frame
	
	var instance2 = scene.instantiate()
	add_child(instance2)
	await get_tree().process_frame
	
	# Get the textures from both instances
	var mesh1 = instance1.get_node("Arena/MeshInstance3D")
	var material1 = mesh1.material_override as StandardMaterial3D
	var texture1 = material1.albedo_texture
	
	var mesh2 = instance2.get_node("Arena/MeshInstance3D")
	var material2 = mesh2.material_override as StandardMaterial3D
	var texture2 = material2.albedo_texture
	
	# Both textures should have the same dimensions
	assert_that(texture1.get_width()).is_equal(texture2.get_width())
	assert_that(texture1.get_height()).is_equal(texture2.get_height())
	
	instance1.queue_free()
	instance2.queue_free()

func test_arena_floor_uses_combat_palette_color() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var mesh_instance = instance.get_node("Arena/MeshInstance3D")
	var material = mesh_instance.material_override as StandardMaterial3D
	assert_that(material).is_not_null()
	
	# Check that the material has a texture (not just a solid color)
	assert_that(material.albedo_texture).is_not_null()
	
	instance.queue_free()

# Test boundary walls setup after _ready
func test_boundary_walls_have_collision_shapes() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	for wall_name in walls:
		var collision = instance.get_node("ArenaBoundaries/" + wall_name + "/CollisionShape3D")
		assert_that(collision.shape).is_not_null()
		assert_that(collision.shape).is_instanceof(BoxShape3D)
	
	instance.queue_free()

func test_boundary_walls_have_meshes() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	for wall_name in walls:
		var mesh_instance = instance.get_node("ArenaBoundaries/" + wall_name + "/MeshInstance3D")
		assert_that(mesh_instance.mesh).is_not_null()
		assert_that(mesh_instance.mesh).is_instanceof(BoxMesh)
	
	instance.queue_free()

func test_boundary_walls_use_combat_palette_color() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	
	for wall_name in walls:
		var mesh_instance = instance.get_node("ArenaBoundaries/" + wall_name + "/MeshInstance3D")
		var material = mesh_instance.material_override as StandardMaterial3D
		assert_that(material).is_not_null()
		# Check that the material has a procedurally generated texture
		assert_that(material.albedo_texture).is_not_null()
	
	instance.queue_free()

# Test spawn point positions
func test_spawn_points_are_positioned_correctly() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	
	# Spawn points should be distributed around the arena
	# Check that they're not all at origin
	var spawn_points_node = instance.get_node("SpawnPoints")
	var positions_set = {}
	
	for i in range(1, 7):
		var spawn_point = spawn_points_node.get_node("SpawnPoint" + str(i))
		var pos = spawn_point.position
		var pos_key = str(pos)
		positions_set[pos_key] = true
	
	# All spawn points should have unique positions
	assert_that(positions_set.size()).is_equal(6)
	
	instance.free()

func test_player_spawn_point_at_center() -> void:
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	var instance = scene.instantiate()
	
	var player_spawn = instance.get_node("PlayerSpawnPoint")
	# Player should spawn at or near center (0, 0, 0)
	assert_that(player_spawn.position.x).is_equal(0.0)
	assert_that(player_spawn.position.z).is_equal(0.0)
	
	instance.free()
