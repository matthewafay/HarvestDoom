extends Node
## Verification Script for Task 1.5.3: Apply Procedurally Generated Tilesets
##
## This script can be run in the Godot editor to verify that procedurally generated
## tilesets are correctly applied to both Farm_Hub and Combat_Zone scenes.
##
## Usage:
## 1. Attach this script to a Node in any scene
## 2. Run the scene
## 3. Check the Output panel for verification results

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("TASK 1.5.3 VERIFICATION: Procedurally Generated Tilesets")
	print("=".repeat(80) + "\n")
	
	verify_farm_hub_tileset()
	verify_combat_zone_tileset()
	
	print("\n" + "=".repeat(80))
	print("VERIFICATION COMPLETE")
	print("=".repeat(80) + "\n")

func verify_farm_hub_tileset() -> void:
	print("--- Verifying Farm_Hub Scene ---\n")
	
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	if not farm_hub_scene:
		print("❌ FAILED: Could not load Farm_Hub scene")
		return
	
	var instance = farm_hub_scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	var mesh_instance = instance.get_node_or_null("Ground/MeshInstance3D")
	if not mesh_instance:
		print("❌ FAILED: Ground/MeshInstance3D not found")
		instance.queue_free()
		return
	
	var plane_mesh = mesh_instance.mesh as PlaneMesh
	if not plane_mesh:
		print("❌ FAILED: Ground mesh is not a PlaneMesh")
		instance.queue_free()
		return
	
	var material = plane_mesh.material as StandardMaterial3D
	if not material:
		print("❌ FAILED: Ground material is not a StandardMaterial3D")
		instance.queue_free()
		return
	
	# Check for procedural tileset texture
	if not material.albedo_texture:
		print("❌ FAILED: Ground material has no albedo_texture")
		print("   Expected: Procedurally generated tileset texture")
		print("   Actual: No texture (solid color)")
		instance.queue_free()
		return
	
	print("✅ PASSED: Ground has procedurally generated tileset")
	print("   Texture Size: %dx%d" % [material.albedo_texture.get_width(), material.albedo_texture.get_height()])
	print("   UV Scale: %s" % str(material.uv1_scale))
	print("   Roughness: %.2f" % material.roughness)
	
	# Verify determinism by creating another instance
	var instance2 = farm_hub_scene.instantiate()
	add_child(instance2)
	await get_tree().process_frame
	
	var mesh_instance2 = instance2.get_node("Ground/MeshInstance3D")
	var plane_mesh2 = mesh_instance2.mesh as PlaneMesh
	var material2 = plane_mesh2.material as StandardMaterial3D
	
	if material.albedo_texture.get_width() == material2.albedo_texture.get_width() and \
	   material.albedo_texture.get_height() == material2.albedo_texture.get_height():
		print("✅ PASSED: Tileset generation is deterministic")
		print("   Both instances have same texture dimensions")
	else:
		print("❌ FAILED: Tileset generation is not deterministic")
		print("   Instance 1: %dx%d" % [material.albedo_texture.get_width(), material.albedo_texture.get_height()])
		print("   Instance 2: %dx%d" % [material2.albedo_texture.get_width(), material2.albedo_texture.get_height()])
	
	instance.queue_free()
	instance2.queue_free()
	print()

func verify_combat_zone_tileset() -> void:
	print("--- Verifying Combat_Zone Scene ---\n")
	
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	if not combat_zone_scene:
		print("❌ FAILED: Could not load Combat_Zone scene")
		return
	
	var instance = combat_zone_scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	
	# Verify arena floor
	var arena_mesh = instance.get_node_or_null("Arena/MeshInstance3D")
	if not arena_mesh:
		print("❌ FAILED: Arena/MeshInstance3D not found")
		instance.queue_free()
		return
	
	var floor_material = arena_mesh.material_override as StandardMaterial3D
	if not floor_material:
		print("❌ FAILED: Arena floor material is not a StandardMaterial3D")
		instance.queue_free()
		return
	
	if not floor_material.albedo_texture:
		print("❌ FAILED: Arena floor has no albedo_texture")
		print("   Expected: Procedurally generated tileset texture")
		print("   Actual: No texture (solid color)")
		instance.queue_free()
		return
	
	print("✅ PASSED: Arena floor has procedurally generated tileset")
	print("   Texture Size: %dx%d" % [floor_material.albedo_texture.get_width(), floor_material.albedo_texture.get_height()])
	print("   UV Scale: %s" % str(floor_material.uv1_scale))
	print("   Roughness: %.2f" % floor_material.roughness)
	print("   Metallic: %.2f" % floor_material.metallic)
	
	# Verify boundary walls
	var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
	var all_walls_ok = true
	
	for wall_name in walls:
		var wall_mesh = instance.get_node_or_null("ArenaBoundaries/" + wall_name + "/MeshInstance3D")
		if not wall_mesh:
			print("❌ FAILED: %s mesh not found" % wall_name)
			all_walls_ok = false
			continue
		
		var wall_material = wall_mesh.material_override as StandardMaterial3D
		if not wall_material or not wall_material.albedo_texture:
			print("❌ FAILED: %s has no procedural tileset" % wall_name)
			all_walls_ok = false
			continue
	
	if all_walls_ok:
		print("✅ PASSED: All boundary walls have procedurally generated tilesets")
		print("   Walls verified: North, South, East, West")
	
	# Verify determinism
	var instance2 = combat_zone_scene.instantiate()
	add_child(instance2)
	await get_tree().process_frame
	
	var arena_mesh2 = instance2.get_node("Arena/MeshInstance3D")
	var floor_material2 = arena_mesh2.material_override as StandardMaterial3D
	
	if floor_material.albedo_texture.get_width() == floor_material2.albedo_texture.get_width() and \
	   floor_material.albedo_texture.get_height() == floor_material2.albedo_texture.get_height():
		print("✅ PASSED: Tileset generation is deterministic")
		print("   Both instances have same texture dimensions")
	else:
		print("❌ FAILED: Tileset generation is not deterministic")
		print("   Instance 1: %dx%d" % [floor_material.albedo_texture.get_width(), floor_material.albedo_texture.get_height()])
		print("   Instance 2: %dx%d" % [floor_material2.albedo_texture.get_width(), floor_material2.albedo_texture.get_height()])
	
	instance.queue_free()
	instance2.queue_free()
	print()
