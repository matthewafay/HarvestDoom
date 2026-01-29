extends Node3D
## Farm Hub Scene
## The peaceful farming area where players plant crops and prepare for combat runs.
## This scene includes the FarmGrid system and interaction prompts.

@onready var ground_mesh: MeshInstance3D = $Ground/MeshInstance3D
@onready var farming_area: Marker3D = $FarmingArea

# Seed for deterministic tileset generation
const FARM_TILESET_SEED: int = 12345

# Farm system components
var farm_grid: FarmGrid = null
var interaction_prompt: InteractionPrompt = null
var farm_interaction_manager: FarmInteractionManager = null

# Player reference (will be set when player enters scene)
var player: Node3D = null

func _ready() -> void:
	_setup_ground_plane()
	_setup_farm_system()
	_setup_interaction_system()
	_find_player()

## Creates a simple ground plane mesh for the farm hub with procedurally generated tileset
func _setup_ground_plane() -> void:
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(30, 30)
	plane_mesh.subdivide_width = 10
	plane_mesh.subdivide_depth = 10
	
	# Generate procedural tileset using ProceduralArtGenerator
	var art_generator = ProceduralArtGenerator.new()
	var tileset_texture = art_generator.generate_tileset(FARM_TILESET_SEED, ProceduralArtGenerator.FARM_PALETTE)
	
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
	farm_grid = FarmGrid.new()
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

## Set up the interaction prompt system
func _setup_interaction_system() -> void:
	# Load and instantiate the interaction prompt scene
	var prompt_scene = load("res://scenes/interaction_prompt.tscn")
	if prompt_scene:
		interaction_prompt = prompt_scene.instantiate()
		add_child(interaction_prompt)
	else:
		push_error("FarmHub: Failed to load interaction_prompt.tscn")
		return
	
	# Create the farm interaction manager
	farm_interaction_manager = FarmInteractionManager.new()
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
	if player != null and farm_interaction_manager != null and farm_grid != null and interaction_prompt != null:
		farm_interaction_manager.initialize(farm_grid, interaction_prompt, player)
	else:
		if player == null:
			push_warning("FarmHub: Player node not found - interaction system will not work")

## Get the farm grid instance
func get_farm_grid() -> FarmGrid:
	return farm_grid

## Get the interaction manager instance
func get_interaction_manager() -> FarmInteractionManager:
	return farm_interaction_manager
