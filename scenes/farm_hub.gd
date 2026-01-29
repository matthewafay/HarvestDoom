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
	_setup_ui_manager()
	_setup_interaction_system()
	_find_player()

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
	
	# Give player some seeds for testing
	if GameManager:
		GameManager.add_to_inventory("health_seeds", 5)
		GameManager.add_to_inventory("ammo_seeds", 3)
		GameManager.add_to_inventory("weapon_mod_seeds", 2)

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
	
	print("UIManager initialized with FarmUI")

## Set up the interaction prompt system
func _setup_interaction_system() -> void:
	# The interaction prompt is now managed by UIManager
	# Create the farm interaction manager
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
