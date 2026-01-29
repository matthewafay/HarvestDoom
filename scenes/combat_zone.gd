extends Node3D
## Combat Zone Scene
## The procedural arena where FPS combat occurs with enemy waves and intense action.
## Validates: Requirements 7.2, 8.4

@onready var arena_floor: MeshInstance3D = $Arena/MeshInstance3D
@onready var arena_boundaries: Node3D = $ArenaBoundaries

# ArenaGenerator instance for wave management
var arena_generator = null

# Player reference for death handling
var player = null

# UIManager instance
var ui_manager = null

# Seeds for deterministic tileset generation
const COMBAT_FLOOR_SEED: int = 54321
const COMBAT_WALL_SEED: int = 54322

func _ready() -> void:
	_setup_arena_floor()
	_setup_arena_boundaries()
	_setup_arena_generator()
	_setup_player()
	_setup_ui_manager()
	_start_combat_run()

## Sets up the arena floor with procedurally generated tileset
## Uses COMBAT_PALETTE colors for dark, aggressive atmosphere
func _setup_arena_floor() -> void:
	# Create a 25x25 plane mesh with subdivisions for visual quality
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(25, 25)
	plane_mesh.subdivide_width = 10
	plane_mesh.subdivide_depth = 10
	
	# Assign the mesh
	arena_floor.mesh = plane_mesh
	
	# Generate procedural tileset using ProceduralArtGenerator
	var art_gen_script = load("res://scripts/systems/procedural_art_generator.gd")
	var art_generator = art_gen_script.new()
	var combat_palette = art_generator.COMBAT_PALETTE
	var tileset_texture = art_generator.generate_tileset(COMBAT_FLOOR_SEED, combat_palette)
	
	# Create material with procedurally generated tileset
	var material = StandardMaterial3D.new()
	material.albedo_texture = tileset_texture
	material.roughness = 0.9  # High roughness for combat arena feel
	material.metallic = 0.1   # Slight metallic for industrial look
	material.uv1_scale = Vector3(3, 3, 1)  # Tile the texture across the plane
	
	# Apply the material
	arena_floor.material_override = material

## Sets up the arena boundary walls with collision and procedurally generated visuals
## Creates 4 walls (North, South, East, West) to contain the combat area
func _setup_arena_boundaries() -> void:
	# Wall configuration
	const WALL_HEIGHT = 3.0
	const WALL_THICKNESS = 0.5
	const ARENA_SIZE = 25.0
	
	# Wall definitions: [name, size, is_horizontal]
	var walls = [
		["NorthWall", Vector3(ARENA_SIZE, WALL_HEIGHT, WALL_THICKNESS), true],
		["SouthWall", Vector3(ARENA_SIZE, WALL_HEIGHT, WALL_THICKNESS), true],
		["EastWall", Vector3(WALL_THICKNESS, WALL_HEIGHT, ARENA_SIZE), false],
		["WestWall", Vector3(WALL_THICKNESS, WALL_HEIGHT, ARENA_SIZE), false]
	]
	
	# Generate procedural tileset for walls using ProceduralArtGenerator
	var art_gen_script = load("res://scripts/systems/procedural_art_generator.gd")
	var art_generator = art_gen_script.new()
	var combat_palette = art_generator.COMBAT_PALETTE
	var wall_tileset_texture = art_generator.generate_tileset(COMBAT_WALL_SEED, combat_palette)
	
	# Create material for walls with procedural tileset
	var wall_material = StandardMaterial3D.new()
	wall_material.albedo_texture = wall_tileset_texture
	wall_material.roughness = 0.8
	wall_material.metallic = 0.2
	wall_material.uv1_scale = Vector3(2, 2, 1)  # Tile the texture
	
	# Set up each wall
	for wall_data in walls:
		var wall_name = wall_data[0]
		var wall_size = wall_data[1]
		
		var wall_node = arena_boundaries.get_node(wall_name)
		if wall_node:
			# Set up collision shape
			var collision_shape = wall_node.get_node("CollisionShape3D")
			var box_shape = BoxShape3D.new()
			box_shape.size = wall_size
			collision_shape.shape = box_shape
			
			# Set up mesh
			var mesh_instance = wall_node.get_node("MeshInstance3D")
			var box_mesh = BoxMesh.new()
			box_mesh.size = wall_size
			mesh_instance.mesh = box_mesh
			mesh_instance.material_override = wall_material


## Set up the ArenaGenerator and connect its signals
## Validates: Requirements 7.2, 8.4
func _setup_arena_generator() -> void:
	# Create ArenaGenerator instance
	var arena_gen_script = load("res://scripts/systems/arena_generator.gd")
	arena_generator = arena_gen_script.new()
	arena_generator.name = "ArenaGenerator"
	add_child(arena_generator)
	
	# Connect signals for run completion and scene transition
	arena_generator.arena_completed.connect(_on_arena_completed)
	arena_generator.wave_completed.connect(_on_wave_completed)
	
	print("ArenaGenerator initialized and signals connected")

## Set up the player and connect death signal
## Validates: Requirement 9.4
func _setup_player() -> void:
	# Find or create player instance
	var player_spawn_point = $PlayerSpawnPoint
	
	# Check if player already exists in scene
	player = get_node_or_null("Player")
	
	if not player:
		# Create player instance
		var player_scene = load("res://scenes/player.tscn")
		if player_scene:
			player = player_scene.instantiate()
			player.name = "Player"
			add_child(player)
			
			# Position player at spawn point
			if player_spawn_point:
				player.global_position = player_spawn_point.global_position
		else:
			push_error("Failed to load player scene")
			return
	
	# Connect player death signal
	if player:
		player.died.connect(_on_player_died)
		print("Player initialized and death signal connected")
	
	# Connect weapon system signals to UI
	if player and player.has_node("WeaponSystem"):
		var weapon_system = player.get_node("WeaponSystem")
		weapon_system.weapon_switched.connect(_on_weapon_switched)
		weapon_system.ammo_changed.connect(_on_ammo_changed)

## Handle weapon switched
func _on_weapon_switched(weapon_type: int) -> void:
	if ui_manager and ui_manager.combat_ui:
		ui_manager.combat_ui.show_weapon_switch(weapon_type)

## Handle ammo changed
func _on_ammo_changed(weapon_type: int, amount: int) -> void:
	if ui_manager:
		ui_manager.update_ammo_display(weapon_type, amount)

## Start the combat run by generating arena and spawning first wave
## Validates: Requirements 7.3, 8.1, 8.2
func _start_combat_run() -> void:
	if not arena_generator:
		push_error("Cannot start combat run: ArenaGenerator not initialized")
		return
	
	# Generate arena with a seed (could be randomized or based on run count)
	var arena_seed = randi()
	arena_generator.generate_arena(arena_seed)
	
	# Spawn the first wave
	arena_generator.spawn_wave(1)
	
	print("Combat run started with arena seed: %d" % arena_seed)

## Handle arena completion (all waves cleared)
## Finalizes loot and transitions back to Farm_Hub
## Validates: Requirements 7.2, 7.4, 8.4
func _on_arena_completed() -> void:
	print("Arena completed! Finalizing loot and returning to Farm_Hub...")
	
	# Finalize run loot (transfer to permanent inventory)
	if GameManager:
		GameManager.finalize_run_loot()
		print("Run loot finalized: %d total resources collected" % GameManager.get_total_run_loot())
		
		# Decrement buff durations (buffs last for multiple runs)
		GameManager.decrement_buff_durations()
	
	# Transition back to Farm_Hub
	# Use call_deferred to avoid issues with scene tree changes during signal processing
	call_deferred("_transition_to_farm_hub")

## Handle wave completion (informational)
## Validates: Requirement 8.4
func _on_wave_completed(wave_number: int) -> void:
	print("Wave %d completed!" % wave_number)
	# Could add UI feedback, sound effects, etc. here

## Handle player death
## Clears loot and transitions back to Farm_Hub
## Validates: Requirements 7.2, 7.4, 9.4
func _on_player_died() -> void:
	print("Player died! Clearing loot and returning to Farm_Hub...")
	
	# Clear run loot (player loses loot on death)
	if GameManager:
		GameManager.clear_run_loot()
		print("Run loot cleared (lost on death)")
	
	# Transition back to Farm_Hub
	# Use call_deferred to avoid issues with scene tree changes during signal processing
	call_deferred("_transition_to_farm_hub")

## Transition to Farm_Hub scene
## Validates: Requirements 7.2, 7.4, 7.5
func _transition_to_farm_hub() -> void:
	if GameManager:
		GameManager.transition_to_farm()
	else:
		push_error("Cannot transition to Farm_Hub: GameManager not found")

## Set up the UIManager
func _setup_ui_manager() -> void:
	# Create UIManager instance
	var ui_manager_script = load("res://scripts/ui/ui_manager.gd")
	ui_manager = ui_manager_script.new()
	ui_manager.name = "UIManager"
	add_child(ui_manager)
	
	# Show combat UI
	ui_manager.show_combat_ui()
	
	print("UIManager initialized with CombatUI")
