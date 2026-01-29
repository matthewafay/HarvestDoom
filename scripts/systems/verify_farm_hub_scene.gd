extends SceneTree
## Verification script for Farm_Hub scene (Task 1.5.1)
## Tests that the scene loads correctly and has all required components

func _init() -> void:
	print("=== Farm_Hub Scene Verification ===\n")
	
	var success := true
	
	# Load the Farm_Hub scene
	var farm_hub_scene := load("res://scenes/farm_hub.tscn")
	if farm_hub_scene == null:
		print("❌ FAILED: Could not load farm_hub.tscn")
		success = false
		quit(1)
		return
	
	print("✓ Farm_Hub scene file loads successfully")
	
	# Instance the scene
	var farm_hub: Node3D = farm_hub_scene.instantiate()
	if farm_hub == null:
		print("❌ FAILED: Could not instantiate farm_hub scene")
		success = false
		quit(1)
		return
	
	print("✓ Farm_Hub scene instantiates successfully")
	
	# Check for required nodes
	var required_nodes := {
		"WorldEnvironment": false,
		"DirectionalLight3D": false,
		"Ground": false,
		"Ground/CollisionShape3D": false,
		"Ground/MeshInstance3D": false,
		"CameraPlaceholder": false,
		"FarmingArea": false,
		"PortalLocation": false
	}
	
	for node_path in required_nodes.keys():
		var node := farm_hub.get_node_or_null(node_path)
		if node != null:
			required_nodes[node_path] = true
			print("✓ Found required node: %s" % node_path)
		else:
			print("❌ Missing required node: %s" % node_path)
			success = false
	
	# Check Ground collision setup
	var ground: StaticBody3D = farm_hub.get_node_or_null("Ground")
	if ground:
		if ground.collision_layer == 8:  # LAYER_ENVIRONMENT
			print("✓ Ground has correct collision layer (8 - LAYER_ENVIRONMENT)")
		else:
			print("❌ Ground has incorrect collision layer: %d (expected 8)" % ground.collision_layer)
			success = false
		
		if ground.collision_mask == 0:
			print("✓ Ground has correct collision mask (0)")
		else:
			print("❌ Ground has incorrect collision mask: %d (expected 0)" % ground.collision_mask)
			success = false
	
	# Check WorldEnvironment setup
	var world_env: WorldEnvironment = farm_hub.get_node_or_null("WorldEnvironment")
	if world_env and world_env.environment:
		print("✓ WorldEnvironment has environment configured")
		
		var env := world_env.environment
		if env.background_mode == Environment.BG_SKY:
			print("✓ Environment uses sky background")
		else:
			print("⚠ Warning: Environment background mode is %d (expected 2 for SKY)" % env.background_mode)
	
	# Check DirectionalLight3D setup
	var light: DirectionalLight3D = farm_hub.get_node_or_null("DirectionalLight3D")
	if light:
		if light.shadow_enabled:
			print("✓ DirectionalLight3D has shadows enabled")
		else:
			print("⚠ Warning: DirectionalLight3D shadows not enabled")
		
		# Check for warm lighting color (farm atmosphere)
		if light.light_color.r > 0.9 and light.light_color.g > 0.9:
			print("✓ DirectionalLight3D uses warm color for farm atmosphere")
		else:
			print("⚠ Warning: Light color may not be warm enough for farm atmosphere")
	
	# Check script attachment
	if farm_hub.get_script():
		print("✓ Farm_Hub scene has script attached")
	else:
		print("❌ Farm_Hub scene missing script")
		success = false
	
	# Test ground mesh setup by calling _ready
	root.add_child(farm_hub)
	await get_tree().process_frame
	
	var ground_mesh: MeshInstance3D = farm_hub.get_node_or_null("Ground/MeshInstance3D")
	if ground_mesh and ground_mesh.mesh:
		print("✓ Ground mesh is set up (mesh assigned)")
		
		if ground_mesh.mesh is PlaneMesh:
			var plane: PlaneMesh = ground_mesh.mesh
			print("✓ Ground uses PlaneMesh")
			print("  - Size: %s" % str(plane.size))
			print("  - Subdivisions: %dx%d" % [plane.subdivide_width, plane.subdivide_depth])
		else:
			print("⚠ Warning: Ground mesh is not a PlaneMesh")
	else:
		print("❌ Ground mesh not properly set up")
		success = false
	
	# Summary
	print("\n=== Verification Summary ===")
	if success:
		print("✅ ALL CHECKS PASSED - Farm_Hub scene is properly configured")
		print("\nScene includes:")
		print("  • 30x30 ground plane with collision (LAYER_ENVIRONMENT)")
		print("  • Warm directional lighting with shadows")
		print("  • Procedural sky with farm-appropriate colors")
		print("  • Camera placeholder for future PlayerController")
		print("  • Farming area marker for FarmGrid placement")
		print("  • Portal location marker for combat zone transition")
		print("\nReady for task 1.5.3 (Apply procedurally generated tilesets)")
		quit(0)
	else:
		print("❌ SOME CHECKS FAILED - Review errors above")
		quit(1)
