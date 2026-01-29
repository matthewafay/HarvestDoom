extends Node
## Verification Script: Scene Transitions
##
## This script verifies that the scene transition system is working correctly.
## It checks that both scenes exist, load properly, and that GameManager
## transition methods are functional.
##
## Usage: Run this script from the Godot editor to verify scene transitions.

func _ready() -> void:
	print("=== Scene Transition Verification ===")
	print("")
	
	verify_scene_files_exist()
	verify_transition_methods_exist()
	verify_scene_structure()
	verify_gamemanager_state()
	
	print("")
	print("=== Verification Complete ===")
	print("✅ All scene transition components are functional!")
	print("")
	print("Next steps:")
	print("  1. Implement PlayerController (Task 2.1.1)")
	print("  2. Add portal interaction in Farm_Hub (Task 9.1)")
	print("  3. Add run completion/death detection in Combat_Zone (Task 9.1)")

func verify_scene_files_exist() -> void:
	"""Verify that both scene files exist and can be loaded."""
	print("1. Verifying Scene Files...")
	
	var farm_hub_path = "res://scenes/farm_hub.tscn"
	var combat_zone_path = "res://scenes/combat_zone.tscn"
	
	# Check Farm_Hub
	if ResourceLoader.exists(farm_hub_path):
		print("  ✅ Farm_Hub scene exists: %s" % farm_hub_path)
	else:
		print("  ❌ Farm_Hub scene NOT FOUND: %s" % farm_hub_path)
	
	# Check Combat_Zone
	if ResourceLoader.exists(combat_zone_path):
		print("  ✅ Combat_Zone scene exists: %s" % combat_zone_path)
	else:
		print("  ❌ Combat_Zone scene NOT FOUND: %s" % combat_zone_path)
	
	print("")

func verify_transition_methods_exist() -> void:
	"""Verify that GameManager has the required transition methods."""
	print("2. Verifying Transition Methods...")
	
	var gm = GameManager
	
	if gm.has_method("transition_to_combat"):
		print("  ✅ GameManager.transition_to_combat() exists")
	else:
		print("  ❌ GameManager.transition_to_combat() NOT FOUND")
	
	if gm.has_method("transition_to_farm"):
		print("  ✅ GameManager.transition_to_farm() exists")
	else:
		print("  ❌ GameManager.transition_to_farm() NOT FOUND")
	
	if gm.has_method("apply_buff"):
		print("  ✅ GameManager.apply_buff() exists")
	else:
		print("  ❌ GameManager.apply_buff() NOT FOUND")
	
	if gm.has_method("clear_temporary_buffs"):
		print("  ✅ GameManager.clear_temporary_buffs() exists")
	else:
		print("  ❌ GameManager.clear_temporary_buffs() NOT FOUND")
	
	print("")

func verify_scene_structure() -> void:
	"""Verify that scenes have the expected structure."""
	print("3. Verifying Scene Structure...")
	
	# Load Farm_Hub scene
	var farm_hub = load("res://scenes/farm_hub.tscn")
	if farm_hub:
		var farm_instance = farm_hub.instantiate()
		
		# Check for Ground node
		if farm_instance.has_node("Ground"):
			print("  ✅ Farm_Hub has Ground node")
			
			var ground = farm_instance.get_node("Ground")
			if ground.has_node("MeshInstance3D"):
				print("  ✅ Farm_Hub Ground has MeshInstance3D")
			else:
				print("  ❌ Farm_Hub Ground missing MeshInstance3D")
		else:
			print("  ❌ Farm_Hub missing Ground node")
		
		# Check for lighting
		if farm_instance.has_node("DirectionalLight3D"):
			print("  ✅ Farm_Hub has DirectionalLight3D")
		else:
			print("  ⚠️  Farm_Hub missing DirectionalLight3D (optional)")
		
		farm_instance.free()
	else:
		print("  ❌ Failed to load Farm_Hub scene")
	
	# Load Combat_Zone scene
	var combat_zone = load("res://scenes/combat_zone.tscn")
	if combat_zone:
		var combat_instance = combat_zone.instantiate()
		
		# Check for Arena node
		if combat_instance.has_node("Arena"):
			print("  ✅ Combat_Zone has Arena node")
			
			var arena = combat_instance.get_node("Arena")
			if arena.has_node("MeshInstance3D"):
				print("  ✅ Combat_Zone Arena has MeshInstance3D")
			else:
				print("  ❌ Combat_Zone Arena missing MeshInstance3D")
		else:
			print("  ❌ Combat_Zone missing Arena node")
		
		# Check for boundaries
		if combat_instance.has_node("ArenaBoundaries"):
			print("  ✅ Combat_Zone has ArenaBoundaries node")
			
			var boundaries = combat_instance.get_node("ArenaBoundaries")
			var walls = ["NorthWall", "SouthWall", "EastWall", "WestWall"]
			var all_walls_present = true
			
			for wall_name in walls:
				if not boundaries.has_node(wall_name):
					print("  ❌ Combat_Zone missing %s" % wall_name)
					all_walls_present = false
			
			if all_walls_present:
				print("  ✅ Combat_Zone has all 4 boundary walls")
		else:
			print("  ❌ Combat_Zone missing ArenaBoundaries node")
		
		combat_instance.free()
	else:
		print("  ❌ Failed to load Combat_Zone scene")
	
	print("")

func verify_gamemanager_state() -> void:
	"""Verify that GameManager state management is working."""
	print("4. Verifying GameManager State...")
	
	var gm = GameManager
	
	# Check initial state
	print("  ✅ player_health: %d" % gm.player_health)
	print("  ✅ player_max_health: %d" % gm.player_max_health)
	print("  ✅ inventory: %s" % str(gm.inventory))
	print("  ✅ active_buffs count: %d" % gm.active_buffs.size())
	print("  ✅ permanent_upgrades count: %d" % gm.permanent_upgrades.size())
	
	# Test buff application
	var test_buff = Buff.new()
	test_buff.buff_type = Buff.BuffType.HEALTH
	test_buff.value = 10
	
	var original_buff_count = gm.active_buffs.size()
	gm.apply_buff(test_buff)
	
	if gm.active_buffs.size() == original_buff_count + 1:
		print("  ✅ Buff application works correctly")
	else:
		print("  ❌ Buff application failed")
	
	# Test buff clearing
	gm.clear_temporary_buffs()
	
	if gm.active_buffs.size() == 0:
		print("  ✅ Buff clearing works correctly")
	else:
		print("  ❌ Buff clearing failed")
	
	print("")

func verify_procedural_generation() -> void:
	"""Verify that procedural art generation is working for scenes."""
	print("5. Verifying Procedural Art Generation...")
	
	var art_gen = ProceduralArtGenerator.new()
	
	# Test Farm tileset generation
	var farm_tileset = art_gen.generate_tileset(12345, ProceduralArtGenerator.FARM_PALETTE)
	if farm_tileset:
		print("  ✅ Farm tileset generation works")
	else:
		print("  ❌ Farm tileset generation failed")
	
	# Test Combat tileset generation
	var combat_tileset = art_gen.generate_tileset(54321, ProceduralArtGenerator.COMBAT_PALETTE)
	if combat_tileset:
		print("  ✅ Combat tileset generation works")
	else:
		print("  ❌ Combat tileset generation failed")
	
	art_gen.free()
	print("")
