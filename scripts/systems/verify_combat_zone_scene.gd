extends SceneTree

## Verification script for Combat_Zone scene
## Run with: godot --headless --script scripts/systems/verify_combat_zone_scene.gd

const COMBAT_ZONE_SCENE_PATH = "res://scenes/combat_zone.tscn"
const LAYER_ENVIRONMENT = 8

var passed_checks = 0
var failed_checks = 0

func _init():
	print("\n=== Combat Zone Scene Verification ===\n")
	
	# Load and instantiate scene
	var scene = load(COMBAT_ZONE_SCENE_PATH)
	if not scene:
		print("❌ FAILED: Could not load scene")
		quit(1)
		return
	
	var instance = scene.instantiate()
	if not instance:
		print("❌ FAILED: Could not instantiate scene")
		quit(1)
		return
	
	root.add_child(instance)
	
	# Run all checks
	check_scene_structure(instance)
	check_collision_configuration(instance)
	check_environment_setup(instance)
	check_lighting_setup(instance)
	check_spawn_points(instance)
	
	# Wait for _ready to be called
	await get_tree().process_frame
	
	check_arena_floor_setup(instance)
	check_boundary_walls_setup(instance)
	
	# Print summary
	print("\n=== Verification Summary ===")
	print("Passed: %d" % passed_checks)
	print("Failed: %d" % failed_checks)
	
	if failed_checks == 0:
		print("\n✅ All checks passed!")
		quit(0)
	else:
		print("\n❌ Some checks failed")
		quit(1)

func check_scene_structure(instance: Node) -> void:
	print("Checking scene structure...")
	
	check("Scene has script", instance.get_script() != null)
	check("Has WorldEnvironment", instance.has_node("WorldEnvironment"))
	check("Has DirectionalLight3D", instance.has_node("DirectionalLight3D"))
	check("Has Arena", instance.has_node("Arena"))
	check("Has Arena/CollisionShape3D", instance.has_node("Arena/CollisionShape3D"))
	check("Has Arena/MeshInstance3D", instance.has_node("Arena/MeshInstance3D"))
	check("Has ArenaBoundaries", instance.has_node("ArenaBoundaries"))
	check("Has SpawnPoints", instance.has_node("SpawnPoints"))
	check("Has CameraPlaceholder", instance.has_node("CameraPlaceholder"))
	check("Has PlayerSpawnPoint", instance.has_node("PlayerSpawnPoint"))
	
	# Check all boundary walls
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	for wall_name in walls:
		check("Has " + wall_name, instance.has_node("ArenaBoundaries/" + wall_name))
	
	# Check all spawn points
	for i in range(1, 7):
		check("Has SpawnPoint" + str(i), instance.has_node("SpawnPoints/SpawnPoint" + str(i)))
	
	print()

func check_collision_configuration(instance: Node) -> void:
	print("Checking collision configuration...")
	
	var arena = instance.get_node("Arena")
	check("Arena uses LAYER_ENVIRONMENT", arena.collision_layer == LAYER_ENVIRONMENT)
	check("Arena collision mask is 0", arena.collision_mask == 0)
	
	# Check boundary walls
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	for wall_name in walls:
		var wall = instance.get_node("ArenaBoundaries/" + wall_name)
		check(wall_name + " uses LAYER_ENVIRONMENT", wall.collision_layer == LAYER_ENVIRONMENT)
		check(wall_name + " collision mask is 0", wall.collision_mask == 0)
	
	print()

func check_environment_setup(instance: Node) -> void:
	print("Checking environment setup...")
	
	var world_env = instance.get_node("WorldEnvironment")
	var environment = world_env.environment
	
	check("Environment resource exists", environment != null)
	check("Uses sky background", environment.background_mode == Environment.BG_SKY)
	check("Sky resource exists", environment.sky != null)
	check("Ambient light energy is low", environment.ambient_light_energy <= 0.6)
	check("Glow enabled", environment.glow_enabled)
	
	print()

func check_lighting_setup(instance: Node) -> void:
	print("Checking lighting setup...")
	
	var light = instance.get_node("DirectionalLight3D")
	
	check("Shadows enabled", light.shadow_enabled)
	check("Light energy < 1.0", light.light_energy < 1.0)
	check("Light has reddish tint", light.light_color.r > light.light_color.g)
	
	print()

func check_spawn_points(instance: Node) -> void:
	print("Checking spawn points...")
	
	var spawn_points_node = instance.get_node("SpawnPoints")
	var positions = []
	
	for i in range(1, 7):
		var spawn_point = spawn_points_node.get_node("SpawnPoint" + str(i))
		positions.append(spawn_point.position)
	
	# Check that spawn points have unique positions
	var unique_positions = {}
	for pos in positions:
		unique_positions[str(pos)] = true
	
	check("All spawn points have unique positions", unique_positions.size() == 6)
	
	var player_spawn = instance.get_node("PlayerSpawnPoint")
	check("Player spawn at center", player_spawn.position == Vector3.ZERO)
	
	print()

func check_arena_floor_setup(instance: Node) -> void:
	print("Checking arena floor setup (after _ready)...")
	
	var mesh_instance = instance.get_node("Arena/MeshInstance3D")
	var mesh = mesh_instance.mesh
	
	check("Arena floor mesh created", mesh != null)
	check("Arena floor is PlaneMesh", mesh is PlaneMesh)
	
	if mesh is PlaneMesh:
		var plane_mesh = mesh as PlaneMesh
		check("Arena floor size is 25x25", plane_mesh.size == Vector2(25, 25))
		check("Arena floor has subdivisions", plane_mesh.subdivide_width > 0 and plane_mesh.subdivide_depth > 0)
	
	var material = mesh_instance.material_override
	check("Arena floor has material", material != null)
	
	if material is StandardMaterial3D:
		var std_material = material as StandardMaterial3D
		var expected_color = Color("#212121")
		check("Arena floor uses COMBAT_PALETTE color", std_material.albedo_color == expected_color)
	
	print()

func check_boundary_walls_setup(instance: Node) -> void:
	print("Checking boundary walls setup (after _ready)...")
	
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	var expected_color = Color("#F44336")
	
	for wall_name in walls:
		var collision = instance.get_node("ArenaBoundaries/" + wall_name + "/CollisionShape3D")
		check(wall_name + " has collision shape", collision.shape != null)
		check(wall_name + " collision is BoxShape3D", collision.shape is BoxShape3D)
		
		var mesh_instance = instance.get_node("ArenaBoundaries/" + wall_name + "/MeshInstance3D")
		check(wall_name + " has mesh", mesh_instance.mesh != null)
		check(wall_name + " mesh is BoxMesh", mesh_instance.mesh is BoxMesh)
		
		var material = mesh_instance.material_override
		if material is StandardMaterial3D:
			var std_material = material as StandardMaterial3D
			check(wall_name + " uses red color", std_material.albedo_color == expected_color)
	
	print()

func check(description: String, condition: bool) -> void:
	if condition:
		print("  ✅ " + description)
		passed_checks += 1
	else:
		print("  ❌ " + description)
		failed_checks += 1
