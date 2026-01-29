extends Node3D
## Farm Hub Scene
## The peaceful farming area where players plant crops and prepare for combat runs.
## This scene includes the FarmGrid system and interaction prompts.

@onready var ground_mesh: MeshInstance3D = $Ground/MeshInstance3D
@onready var farming_area: Marker3D = $FarmingArea

# Seed for deterministic tileset generation
const FARM_TILESET_SEED: int = 12345

# Farm system components
var farm_grid = null  # FarmGrid instance
var farm_interaction_manager = null  # FarmInteractionManager instance
var ui_manager = null  # UIManager instance

# Player reference (will be set when player enters scene)
var player: Node3D = null

func _ready() -> void:
	_setup_ground_plane()
	_setup_farm_system()
	_setup_player()
	_setup_portal_indicator()
	_setup_ui_manager()
	_setup_interaction_system()
	_find_player()

func _process(_delta: float) -> void:
	_check_plot_interaction()

## Check for plot interaction using simple distance check
func _check_plot_interaction() -> void:
	if not player or not farm_grid or not ui_manager or not ui_manager.interaction_prompt:
		return
	
	var player_pos = player.global_position
	var closest_plot = null
	var closest_distance = 999999.0
	var interaction_range = 3.0
	
	# Check each plot
	var plots = farm_grid.get_all_plots()
	for i in range(plots.size()):
		var plot = plots[i]
		if not is_instance_valid(plot):
			continue
		
		# Convert 2D plot position to 3D world position
		var plot_2d_pos = plot.position + farm_grid.position
		var plot_3d_pos = Vector3(plot_2d_pos.x, 0, plot_2d_pos.y)
		if farming_area:
			plot_3d_pos += farming_area.position
		
		var distance = player_pos.distance_to(plot_3d_pos)
		if distance < interaction_range and distance < closest_distance:
			closest_plot = plot
			closest_distance = distance
	
	# Update prompt
	if closest_plot:
		var prompt_text = ""
		# PlotState: EMPTY=0, GROWING=1, HARVESTABLE=2
		match closest_plot.state:
			0:  # EMPTY
				prompt_text = "[E] Plant Crop (Health Seeds: %d)" % GameManager.get_inventory_amount("health_seeds")
			1:  # GROWING
				var progress = int(closest_plot.get_growth_progress() * 100)
				prompt_text = "Growing... %d%%" % progress
			2:  # HARVESTABLE
				prompt_text = "[E] Harvest Crop!"
		
		ui_manager.interaction_prompt.show_prompt(prompt_text)
		
		# Handle interaction
		if Input.is_action_just_pressed("interact"):
			_interact_with_plot(closest_plot)
	else:
		ui_manager.interaction_prompt.hide_prompt()

## Interact with a plot (plant or harvest)
func _interact_with_plot(plot) -> void:
	if not plot or not farm_grid:
		return
	
	match plot.state:
		0:  # EMPTY - try to plant
			print("DEBUG: Attempting to plant. Health seeds in inventory: %d" % GameManager.get_inventory_amount("health_seeds"))
			
			# Load a default crop for testing
			var crop_data_script = load("res://resources/crops/crop_data.gd")
			var crop = crop_data_script.new()
			crop.crop_id = "health_berry"
			crop.display_name = "Health Berry"
			crop.growth_time = 5.0  # 5 seconds for testing
			crop.seed_cost = 1
			crop.base_color = Color(1.0, 0.2, 0.2)
			crop.shape_type = "round"
			crop.growth_mode = "time"
			
			# Create a simple buff for the crop
			var buff_script = load("res://resources/buffs/buff.gd")
			var buff = buff_script.new()
			buff.buff_type = 0  # HEALTH
			buff.value = 20
			buff.duration = 1
			crop.buff_provided = buff
			
			print("DEBUG: Crop created. crop_id=%s, seed_cost=%d, buff_provided=%s" % [crop.crop_id, crop.seed_cost, str(crop.buff_provided)])
			
			# Try to plant
			if farm_grid.plant_crop(plot, crop):
				print("✓ Planted Health Berry! Remaining seeds: %d" % GameManager.get_inventory_amount("health_seeds"))
			else:
				print("✗ Failed to plant - not enough seeds. Have: %d, Need: %d" % [
					GameManager.get_inventory_amount("health_seeds"),
					crop.seed_cost
				])
		
		2:  # HARVESTABLE - try to harvest
			var resources = farm_grid.harvest_crop(plot)
			if not resources.is_empty():
				print("✓ Harvested crop!")
			else:
				print("✗ Failed to harvest")

## Creates a simple ground plane mesh for the farm hub with procedurally generated tileset
func _setup_ground_plane() -> void:
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(30, 30)
	plane_mesh.subdivide_width = 10
	plane_mesh.subdivide_depth = 10
	
	# Generate procedural tileset using ProceduralArtGenerator
	var art_gen_script = load("res://scripts/systems/procedural_art_generator.gd")
	var art_generator = art_gen_script.new()
	var farm_palette = art_generator.FARM_PALETTE
	var tileset_texture = art_generator.generate_tileset(FARM_TILESET_SEED, farm_palette)
	
	# Create material with procedurally generated tileset
	var material := StandardMaterial3D.new()
	material.albedo_texture = tileset_texture
	material.roughness = 0.8
	material.uv1_scale = Vector3(4, 4, 1)  # Tile the texture across the plane
	
	plane_mesh.material = material
	ground_mesh.mesh = plane_mesh

## Set up the farm grid system
func _setup_farm_system() -> void:
	# Create FarmGrid instance
	var farm_grid_script = load("res://scripts/farming/farm_grid.gd")
	farm_grid = farm_grid_script.new()
	farm_grid.grid_size = Vector2i(3, 4)  # 12 plots
	farm_grid.plot_size = 2.0  # 2 meters per plot
	
	# Position the farm grid at the farming area marker
	if farming_area:
		farm_grid.position = Vector2(farming_area.position.x, farming_area.position.z)
	
	# Add to scene (as child of root, since FarmGrid is Node2D)
	add_child(farm_grid)
	
	# Create 3D visual representations for the plots
	_create_plot_visuals()
	
	# Give player some seeds for testing
	if GameManager:
		GameManager.add_to_inventory("health_seeds", 5)
		GameManager.add_to_inventory("ammo_seeds", 3)
		GameManager.add_to_inventory("weapon_mod_seeds", 2)
		print("✓ Added seeds to inventory: health=%d, ammo=%d, weapon_mod=%d" % [
			GameManager.get_inventory_amount("health_seeds"),
			GameManager.get_inventory_amount("ammo_seeds"),
			GameManager.get_inventory_amount("weapon_mod_seeds")
		])

## Set up the player character
func _setup_player() -> void:
	# Load and instantiate the player scene
	var player_scene = load("res://scenes/player.tscn")
	if player_scene:
		player = player_scene.instantiate()
		player.name = "Player"
		# Position player near the farm area
		player.position = Vector3(0, 1, 5)
		add_child(player)
		print("Player instantiated at position: ", player.position)
	else:
		push_error("FarmHub: Failed to load player scene")

## Add visual indicator for the combat portal
func _setup_portal_indicator() -> void:
	# Add a floating label pointing to the portal
	var portal_label = Label3D.new()
	portal_label.text = "⚔️ COMBAT PORTAL →"
	portal_label.font_size = 48
	portal_label.modulate = Color(1.0, 0.3, 0.3, 1.0)
	portal_label.outline_size = 12
	portal_label.outline_modulate = Color(0, 0, 0, 1.0)
	portal_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Position it between player and portal
	portal_label.position = Vector3(0, 3, 7)
	add_child(portal_label)
	
	# Make it pulse/animate
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(portal_label, "position:y", 3.5, 1.0)
	tween.tween_property(portal_label, "position:y", 3.0, 1.0)

## Create 3D visual representations for farm plots
func _create_plot_visuals() -> void:
	if farm_grid == null:
		return
	
	var plot_size = farm_grid.plot_size
	var grid_size = farm_grid.grid_size
	
	# Calculate grid offset to center the grid
	var grid_width = grid_size.x * plot_size
	var grid_height = grid_size.y * plot_size
	var offset = Vector3(-grid_width / 2.0, 0, -grid_height / 2.0)
	
	# Create visual markers for each plot
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			# Create a simple box mesh for the plot
			var mesh_instance = MeshInstance3D.new()
			var box_mesh = BoxMesh.new()
			box_mesh.size = Vector3(plot_size * 0.9, 0.1, plot_size * 0.9)
			mesh_instance.mesh = box_mesh
			
			# Create material with brighter color
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.6, 0.4, 0.2, 1.0)  # Lighter brown
			material.roughness = 0.8
			material.emission_enabled = true
			material.emission = Color(0.3, 0.2, 0.1, 1.0)  # Slight glow
			mesh_instance.set_surface_override_material(0, material)
			
			# Position the plot visual
			var plot_position = Vector3(
				x * plot_size + plot_size / 2.0,
				0.05,
				y * plot_size + plot_size / 2.0
			) + offset
			
			if farming_area:
				plot_position += farming_area.position
			
			mesh_instance.position = plot_position
			add_child(mesh_instance)
			
			# Add a small label above the first plot as a hint
			if x == 0 and y == 0:
				var label_3d = Label3D.new()
				label_3d.text = "← PLANT HERE (Press E)"
				label_3d.font_size = 32
				label_3d.modulate = Color(1.0, 1.0, 0.0, 1.0)
				label_3d.outline_size = 8
				label_3d.outline_modulate = Color(0, 0, 0, 1.0)
				label_3d.position = plot_position + Vector3(0, 1.5, 0)
				label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				add_child(label_3d)

## Set up the UIManager
func _setup_ui_manager() -> void:
	# Create UIManager instance
	var ui_manager_script = load("res://scripts/ui/ui_manager.gd")
	ui_manager = ui_manager_script.new()
	ui_manager.name = "UIManager"
	add_child(ui_manager)
	
	# Show farm UI
	ui_manager.show_farm_ui()
	
	# Connect upgrade button signal
	ui_manager.upgrade_button_pressed.connect(_on_upgrade_button_pressed)
	
	# Add instructions label
	_add_instructions()
	
	print("UIManager initialized with FarmUI")

## Add control instructions to the UI
func _add_instructions() -> void:
	# Add crosshair in center of screen
	_add_crosshair()
	
	# Create objective tracker panel
	var objective_panel = Panel.new()
	objective_panel.position = Vector2(20, 420)
	objective_panel.custom_minimum_size = Vector2(400, 200)
	
	var obj_style = StyleBoxFlat.new()
	obj_style.bg_color = Color(0.1, 0.3, 0.1, 0.9)
	obj_style.border_width_left = 3
	obj_style.border_width_right = 3
	obj_style.border_width_top = 3
	obj_style.border_width_bottom = 3
	obj_style.border_color = Color(0.4, 0.8, 0.4, 1.0)
	obj_style.corner_radius_top_left = 6
	obj_style.corner_radius_top_right = 6
	obj_style.corner_radius_bottom_left = 6
	obj_style.corner_radius_bottom_right = 6
	objective_panel.add_theme_stylebox_override("panel", obj_style)
	
	var obj_container = VBoxContainer.new()
	obj_container.position = Vector2(15, 10)
	obj_container.custom_minimum_size = Vector2(370, 180)
	objective_panel.add_child(obj_container)
	
	# Title
	var obj_title = Label.new()
	obj_title.text = "🎯 CURRENT OBJECTIVES"
	obj_title.add_theme_font_size_override("font_size", 20)
	obj_title.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4, 1.0))
	obj_container.add_child(obj_title)
	
	var separator = HSeparator.new()
	obj_container.add_child(separator)
	
	# Objectives
	var objectives = Label.new()
	objectives.text = """1. Walk to the BROWN PLOTS (WASD to move)
2. Stand near a plot and press E to PLANT
3. Wait for crops to grow (or skip for testing)
4. Press E again to HARVEST when ready
5. Activate buffs in the panel (bottom right)
6. Walk to the GLOWING PORTAL to enter combat!

💡 TIP: You start with 5 Health Seeds!"""
	
	objectives.add_theme_font_size_override("font_size", 14)
	objectives.add_theme_color_override("font_color", Color.WHITE)
	objectives.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	obj_container.add_child(objectives)
	
	# Controls panel (smaller, repositioned)
	var controls_panel = Panel.new()
	controls_panel.position = Vector2(20, 640)
	controls_panel.custom_minimum_size = Vector2(250, 140)
	
	var ctrl_style = StyleBoxFlat.new()
	ctrl_style.bg_color = Color(0, 0, 0, 0.8)
	ctrl_style.border_width_left = 2
	ctrl_style.border_width_right = 2
	ctrl_style.border_width_top = 2
	ctrl_style.border_width_bottom = 2
	ctrl_style.border_color = Color(0.6, 0.6, 0.6, 0.8)
	ctrl_style.corner_radius_top_left = 4
	ctrl_style.corner_radius_top_right = 4
	ctrl_style.corner_radius_bottom_left = 4
	ctrl_style.corner_radius_bottom_right = 4
	controls_panel.add_theme_stylebox_override("panel", ctrl_style)
	
	var controls = Label.new()
	controls.text = """⌨️ CONTROLS:
WASD - Move
Mouse - Look
E - Interact
ESC - Quit"""
	
	controls.position = Vector2(10, 10)
	controls.add_theme_font_size_override("font_size", 14)
	controls.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	controls_panel.add_child(controls)
	
	if ui_manager:
		ui_manager.add_child(objective_panel)
		ui_manager.add_child(controls_panel)

## Set up the interaction prompt system
func _setup_interaction_system() -> void:
	# Add a raycast to the player for detecting plots
	if player:
		var raycast = RayCast3D.new()
		raycast.name = "InteractionRaycast"
		raycast.target_position = Vector3(0, 0, -3)  # 3 meters forward
		raycast.collision_mask = 8  # Environment layer (where plots are)
		raycast.enabled = true
		player.add_child(raycast)
		
		# Store reference for interaction checking
		player.set_meta("interaction_raycast", raycast)
	
	# The interaction prompt is now managed by UIManager
	# Create the farm interaction manager (but it won't work properly due to 2D/3D mismatch)
	var farm_interaction_script = load("res://scripts/farming/farm_interaction_manager.gd")
	farm_interaction_manager = farm_interaction_script.new()
	add_child(farm_interaction_manager)

## Find the player node in the scene
func _find_player() -> void:
	# Try to find player node
	player = get_node_or_null("Player")
	
	if player == null:
		# Player might be added later, try again in a moment
		await get_tree().create_timer(0.1).timeout
		player = get_node_or_null("Player")
	
	# Initialize the interaction manager once player is found
	if player != null and farm_interaction_manager != null and farm_grid != null and ui_manager != null:
		farm_interaction_manager.initialize(farm_grid, ui_manager.interaction_prompt, player)
	else:
		if player == null:
			push_warning("FarmHub: Player node not found - interaction system will not work")

## Get the farm grid instance
func get_farm_grid():
	return farm_grid

## Get the interaction manager instance
func get_interaction_manager():
	return farm_interaction_manager

## Add crosshair to center of screen
func _add_crosshair() -> void:
	if not ui_manager:
		return
	
	# Create crosshair container
	var crosshair_container = Control.new()
	crosshair_container.anchor_left = 0.5
	crosshair_container.anchor_top = 0.5
	crosshair_container.anchor_right = 0.5
	crosshair_container.anchor_bottom = 0.5
	crosshair_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create crosshair lines
	var crosshair_size = 20
	var crosshair_thickness = 3
	var crosshair_gap = 5
	var crosshair_color = Color(1, 1, 1, 0.8)
	
	# Top line
	var top = ColorRect.new()
	top.color = crosshair_color
	top.size = Vector2(crosshair_thickness, crosshair_size)
	top.position = Vector2(-crosshair_thickness/2, -crosshair_size - crosshair_gap)
	crosshair_container.add_child(top)
	
	# Bottom line
	var bottom = ColorRect.new()
	bottom.color = crosshair_color
	bottom.size = Vector2(crosshair_thickness, crosshair_size)
	bottom.position = Vector2(-crosshair_thickness/2, crosshair_gap)
	crosshair_container.add_child(bottom)
	
	# Left line
	var left = ColorRect.new()
	left.color = crosshair_color
	left.size = Vector2(crosshair_size, crosshair_thickness)
	left.position = Vector2(-crosshair_size - crosshair_gap, -crosshair_thickness/2)
	crosshair_container.add_child(left)
	
	# Right line
	var right = ColorRect.new()
	right.color = crosshair_color
	right.size = Vector2(crosshair_size, crosshair_thickness)
	right.position = Vector2(crosshair_gap, -crosshair_thickness/2)
	crosshair_container.add_child(right)
	
	# Center dot
	var center = ColorRect.new()
	center.color = crosshair_color
	center.size = Vector2(4, 4)
	center.position = Vector2(-2, -2)
	crosshair_container.add_child(center)
	
	ui_manager.add_child(crosshair_container)

## Handle upgrade button pressed
func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	if not GameManager or not GameManager.progression_manager:
		push_error("FarmHub: Cannot purchase upgrade - GameManager or ProgressionManager not found")
		return
	
	# Attempt to purchase the upgrade
	var success = GameManager.progression_manager.purchase_upgrade(upgrade_id)
	
	if success:
		print("FarmHub: Successfully purchased upgrade: %s" % upgrade_id)
		# UI will update automatically via GameManager signals
	else:
		print("FarmHub: Failed to purchase upgrade: %s" % upgrade_id)
