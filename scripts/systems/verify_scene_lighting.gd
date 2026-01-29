extends Node
## Verification script for scene lighting and camera positioning
## Tests that both Farm_Hub and Combat_Zone have proper lighting setup

func _ready() -> void:
	print("=== Scene Lighting Verification ===")
	verify_farm_hub_lighting()
	verify_combat_zone_lighting()
	print("=== Verification Complete ===")
	get_tree().quit()

## Verifies Farm Hub lighting configuration
func verify_farm_hub_lighting() -> void:
	print("\n--- Farm Hub Lighting ---")
	
	var farm_hub_scene = load("res://scenes/farm_hub.tscn")
	var farm_hub = farm_hub_scene.instantiate()
	add_child(farm_hub)
	
	# Check for main directional light
	var main_light = farm_hub.get_node_or_null("DirectionalLight3D")
	if main_light:
		print("✓ Main DirectionalLight3D found")
		print("  - Light Energy: %.2f" % main_light.light_energy)
		print("  - Light Color: %s" % main_light.light_color)
		print("  - Shadows Enabled: %s" % main_light.shadow_enabled)
		print("  - Shadow Mode: %d" % main_light.directional_shadow_mode)
		
		# Verify bright atmosphere
		if main_light.light_energy >= 1.2:
			print("  ✓ Light energy appropriate for bright atmosphere")
		else:
			print("  ✗ Light energy too low for bright atmosphere")
	else:
		print("✗ Main DirectionalLight3D not found")
	
	# Check for fill light
	var fill_light = farm_hub.get_node_or_null("FillLight")
	if fill_light:
		print("✓ Fill light found for ambient illumination")
		print("  - Light Energy: %.2f" % fill_light.light_energy)
	else:
		print("⚠ No fill light found (optional)")
	
	# Check environment
	var world_env = farm_hub.get_node_or_null("WorldEnvironment")
	if world_env and world_env.environment:
		var env = world_env.environment
		print("✓ WorldEnvironment found")
		print("  - Ambient Light Energy: %.2f" % env.ambient_light_energy)
		print("  - Glow Enabled: %s" % env.glow_enabled)
		print("  - Tonemap Mode: %d" % env.tonemap_mode)
		
		# Verify bright settings
		if env.ambient_light_energy >= 0.8:
			print("  ✓ Ambient light appropriate for cozy atmosphere")
		else:
			print("  ✗ Ambient light too low")
	else:
		print("✗ WorldEnvironment not found")
	
	# Check camera placeholder
	var camera_placeholder = farm_hub.get_node_or_null("CameraPlaceholder")
	if camera_placeholder:
		print("✓ Camera placeholder found")
		print("  - Position: %s" % camera_placeholder.position)
		print("  - Rotation (degrees): %s" % camera_placeholder.rotation_degrees)
	else:
		print("✗ Camera placeholder not found")
	
	farm_hub.queue_free()

## Verifies Combat Zone lighting configuration
func verify_combat_zone_lighting() -> void:
	print("\n--- Combat Zone Lighting ---")
	
	var combat_zone_scene = load("res://scenes/combat_zone.tscn")
	var combat_zone = combat_zone_scene.instantiate()
	add_child(combat_zone)
	
	# Check for main directional light
	var main_light = combat_zone.get_node_or_null("DirectionalLight3D")
	if main_light:
		print("✓ Main DirectionalLight3D found")
		print("  - Light Energy: %.2f" % main_light.light_energy)
		print("  - Light Color: %s" % main_light.light_color)
		print("  - Shadows Enabled: %s" % main_light.shadow_enabled)
		print("  - Shadow Mode: %d" % main_light.directional_shadow_mode)
		
		# Verify dark atmosphere
		if main_light.light_energy <= 1.0:
			print("  ✓ Light energy appropriate for dark atmosphere")
		else:
			print("  ✗ Light energy too high for dark atmosphere")
	else:
		print("✗ Main DirectionalLight3D not found")
	
	# Check for rim light
	var rim_light = combat_zone.get_node_or_null("RimLight")
	if rim_light:
		print("✓ Rim light found for dramatic effect")
		print("  - Light Energy: %.2f" % rim_light.light_energy)
		print("  - Light Color: %s" % rim_light.light_color)
	else:
		print("⚠ No rim light found (optional)")
	
	# Check environment
	var world_env = combat_zone.get_node_or_null("WorldEnvironment")
	if world_env and world_env.environment:
		var env = world_env.environment
		print("✓ WorldEnvironment found")
		print("  - Ambient Light Energy: %.2f" % env.ambient_light_energy)
		print("  - Glow Enabled: %s" % env.glow_enabled)
		print("  - Tonemap Mode: %d" % env.tonemap_mode)
		
		# Verify dark settings
		if env.ambient_light_energy <= 0.6:
			print("  ✓ Ambient light appropriate for tense atmosphere")
		else:
			print("  ✗ Ambient light too high")
		
		# Check for SSAO (adds depth to dark scenes)
		if env.ssao_enabled:
			print("  ✓ SSAO enabled for enhanced depth")
		else:
			print("  ⚠ SSAO not enabled (optional but recommended)")
	else:
		print("✗ WorldEnvironment not found")
	
	# Check camera placeholder
	var camera_placeholder = combat_zone.get_node_or_null("CameraPlaceholder")
	if camera_placeholder:
		print("✓ Camera placeholder found")
		print("  - Position: %s" % camera_placeholder.position)
		print("  - Rotation (degrees): %s" % camera_placeholder.rotation_degrees)
	else:
		print("✗ Camera placeholder not found")
	
	combat_zone.queue_free()
