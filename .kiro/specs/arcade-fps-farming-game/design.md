# Design Document: Arcade FPS Farming Game

## Overview

This design document describes the architecture and implementation approach for a prototype game that combines arcade FPS combat with farming progression. The game is built in Godot 4.x using GDScript, with all visual content generated procedurally at runtime. The core loop alternates between a peaceful farming hub and intense combat arenas, with farming resources providing combat advantages.

The design emphasizes modularity, short play sessions (10-15 minutes), and responsive arcade-style gameplay. All systems are designed to be independent and communicate through Godot's signal system.

## Architecture

### High-Level Structure

The game follows a scene-based architecture with three primary scenes:

1. **Farm Hub Scene** - Peaceful farming area with crop management and NPC interaction
2. **Combat Zone Scene** - Procedural arena with FPS combat
3. **Persistent Game Manager** - Autoload singleton managing state, progression, and transitions

```
GameManager (Autoload Singleton)
├── PlayerState (health, inventory, buffs, upgrades)
├── ProgressionManager (permanent upgrades, save/load)
├── ProceduralArtGenerator (visual content generation)
└── SceneTransitionManager (scene loading, state preservation)

Farm Hub Scene
├── FarmGrid (plot management)
├── CropSystem (growth, harvesting)
├── NPCInteraction (future expansion)
└── HubUI (inventory, upgrades)

Combat Zone Scene
├── ArenaGenerator (layout, enemy spawns)
├── PlayerController (movement, shooting)
├── EnemyManager (AI, spawning)
├── WeaponSystem (firing, switching)
└── CombatUI (health, ammo, buffs)
```

### Scene Flow

```
Game Start → Load Save Data → Farm Hub
                                  ↓
                    Player Interacts with Portal
                                  ↓
                    Apply Buffs → Combat Zone
                                  ↓
                    Complete/Die → Clear Buffs
                                  ↓
                            Return to Farm Hub
```

## Components and Interfaces

### 1. GameManager (Autoload Singleton)

**Responsibility**: Central state management and coordination between systems.

**Interface**:
```gdscript
class_name GameManager

# Player state
var player_health: int
var player_max_health: int
var inventory: Dictionary  # {resource_type: count}
var active_buffs: Array[Buff]
var permanent_upgrades: Dictionary  # {upgrade_id: level}

# Methods
func apply_buff(buff: Buff) -> void
func clear_temporary_buffs() -> void
func unlock_upgrade(upgrade_id: String) -> void
func transition_to_combat() -> void
func transition_to_farm() -> void
func save_game() -> void
func load_game() -> void

# Signals
signal health_changed(new_health: int, max_health: int)
signal buff_applied(buff: Buff)
signal buff_cleared()
signal upgrade_unlocked(upgrade_id: String)
```

### 2. ProceduralArtGenerator

**Responsibility**: Generate all visual content at runtime using deterministic seeded RNG.

**Interface**:
```gdscript
class_name ProceduralArtGenerator

# Color palettes
const FARM_PALETTE = [Color("#8BC34A"), Color("#FFC107"), Color("#795548"), Color("#4CAF50")]
const COMBAT_PALETTE = [Color("#212121"), Color("#F44336"), Color("#9C27B0"), Color("#607D8B")]

# Methods
func generate_tileset(seed_value: int, palette: Array[Color]) -> Texture2D
func generate_crop_sprite(crop_type: String, growth_stage: int, seed_value: int) -> Texture2D
func generate_enemy_sprite(enemy_type: String, seed_value: int) -> Texture2D
func generate_weapon_sprite(weapon_type: String, seed_value: int) -> Texture2D
func generate_ui_element(element_type: String, seed_value: int) -> Texture2D

# Internal helpers
func _create_shape_from_primitives(shape_data: Dictionary, palette: Array[Color]) -> Image
func _apply_palette_swap(base_image: Image, new_palette: Array[Color]) -> Image
```

**Generation Rules**:
- Use `seed()` function to ensure deterministic output
- Build shapes from primitives: rectangles, circles, triangles
- Limit palette to 4-6 colors per biome
- Use simple geometric patterns for consistency

### 3. PlayerController

**Responsibility**: Handle first-person movement, camera control, and input.

**Interface**:
```gdscript
class_name PlayerController extends CharacterBody3D

# Movement parameters
@export var move_speed: float = 5.0
@export var dash_speed: float = 15.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

# Camera
@onready var camera: Camera3D = $Camera3D
var mouse_sensitivity: float = 0.002

# State
var is_dashing: bool = false
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0

# Methods
func _physics_process(delta: float) -> void
func _input(event: InputEvent) -> void
func perform_dash(direction: Vector3) -> void
func take_damage(amount: int) -> void

# Signals
signal died()
signal dash_performed()
```

### 4. WeaponSystem

**Responsibility**: Manage weapon firing, switching, and ammunition.

**Interface**:
```gdscript
class_name WeaponSystem extends Node3D

# Weapon data
enum WeaponType { PISTOL, SHOTGUN, PLANT_WEAPON }
var current_weapon: WeaponType = WeaponType.PISTOL
var ammo: Dictionary = {
    WeaponType.SHOTGUN: 20,
    WeaponType.PLANT_WEAPON: 10
}

# Weapon stats (modified by upgrades)
var fire_rate: Dictionary = {
    WeaponType.PISTOL: 0.2,
    WeaponType.SHOTGUN: 0.8,
    WeaponType.PLANT_WEAPON: 0.5
}

# Methods
func fire_weapon() -> void
func switch_weapon(weapon_type: WeaponType) -> void
func add_ammo(weapon_type: WeaponType, amount: int) -> void
func apply_weapon_mod(mod_type: String) -> void

# Signals
signal weapon_fired(weapon_type: WeaponType)
signal weapon_switched(weapon_type: WeaponType)
signal ammo_changed(weapon_type: WeaponType, amount: int)
```

### 5. EnemyBase

**Responsibility**: Base class for all enemy types with common behavior.

**Interface**:
```gdscript
class_name EnemyBase extends CharacterBody3D

# Stats
@export var max_health: int = 100
@export var move_speed: float = 3.0
@export var damage: int = 10
@export var loot_drop: Dictionary = {"credits": 10}

var current_health: int
var target: Node3D  # Player reference

# Methods (to be overridden)
func _ready() -> void
func _physics_process(delta: float) -> void
func take_damage(amount: int) -> void
func attack_player() -> void
func die() -> void

# Signals
signal died(loot: Dictionary)
signal attacked_player(damage: int)
```

**Enemy Variants**:

```gdscript
# Melee Charger - Fast, low health, charges at player
class_name MeleeCharger extends EnemyBase
@export var charge_speed: float = 8.0

# Ranged Shooter - Medium speed, shoots projectiles
class_name RangedShooter extends EnemyBase
@export var projectile_speed: float = 10.0
@export var fire_rate: float = 1.5

# Tank Enemy - Slow, high health, high damage
class_name TankEnemy extends EnemyBase
@export var armor: int = 50
```

### 6. FarmGrid

**Responsibility**: Manage farming plots and crop placement.

**Interface**:
```gdscript
class_name FarmGrid extends Node2D

# Grid configuration
@export var grid_size: Vector2i = Vector2i(3, 4)  # 12 plots
@export var plot_size: float = 64.0

# State
var plots: Array[Plot] = []

# Methods
func _ready() -> void
func get_plot_at_position(world_pos: Vector2) -> Plot
func plant_crop(plot: Plot, crop_type: String) -> bool
func harvest_crop(plot: Plot) -> Dictionary
func update_crop_growth(delta: float) -> void

# Signals
signal crop_planted(plot: Plot, crop_type: String)
signal crop_harvested(plot: Plot, resources: Dictionary)
```

### 7. Plot

**Responsibility**: Individual farming plot with crop state.

**Interface**:
```gdscript
class_name Plot extends Node2D

enum PlotState { EMPTY, GROWING, HARVESTABLE }

var state: PlotState = PlotState.EMPTY
var crop_type: String = ""
var growth_progress: float = 0.0
var growth_time: float = 30.0  # seconds or runs

# Methods
func plant(crop_type: String) -> void
func update_growth(delta: float) -> void
func harvest() -> Dictionary
func get_visual_stage() -> int  # 0-3 for sprite generation

# Signals
signal growth_completed()
```

### 8. ArenaGenerator

**Responsibility**: Generate combat arena layouts and enemy spawn patterns.

**Interface**:
```gdscript
class_name ArenaGenerator extends Node3D

# Arena templates
var arena_templates: Array[Dictionary] = [
    {"size": Vector2(20, 20), "cover_count": 5, "spawn_points": 4},
    {"size": Vector2(25, 15), "cover_count": 7, "spawn_points": 6}
]

# Methods
func generate_arena(seed_value: int) -> void
func spawn_wave(wave_number: int) -> void
func get_random_spawn_point() -> Vector3
func is_wave_complete() -> bool

# Signals
signal wave_completed(wave_number: int)
signal arena_completed()
```

### 9. ProgressionManager

**Responsibility**: Handle permanent upgrades and save/load functionality.

**Interface**:
```gdscript
class_name ProgressionManager

# Upgrade definitions
const UPGRADES = {
    "max_health_1": {"cost": 100, "effect": {"max_health": 20}},
    "dash_cooldown_1": {"cost": 150, "effect": {"dash_cooldown": -0.2}},
    "fire_rate_1": {"cost": 120, "effect": {"fire_rate_multiplier": 1.2}}
}

var unlocked_upgrades: Array[String] = []
var save_retry_count: int = 0
var cached_save_data: SaveData = null

# Methods
func can_afford_upgrade(upgrade_id: String) -> bool
func purchase_upgrade(upgrade_id: String) -> bool
func get_total_stat_bonus(stat_name: String) -> float
func save_to_file() -> void
func load_from_file() -> void
func _attempt_save_with_retry(data: SaveData, attempt: int) -> bool
func _cache_failed_save(data: SaveData) -> void

# Signals
signal save_failed(error_message: String)
signal save_succeeded()
```

## Data Models

### Buff

```gdscript
class_name Buff extends Resource

enum BuffType { HEALTH, AMMO, WEAPON_MOD }

@export var buff_type: BuffType
@export var value: int
@export var duration: int = 1  # Number of runs
@export var weapon_mod_type: String = ""  # For weapon mods

func apply_to_player(player: PlayerController) -> void:
    match buff_type:
        BuffType.HEALTH:
            GameManager.player_max_health += value
        BuffType.AMMO:
            GameManager.inventory["ammo"] += value
        BuffType.WEAPON_MOD:
            player.weapon_system.apply_weapon_mod(weapon_mod_type)
```

### CropData

```gdscript
class_name CropData extends Resource

@export var crop_id: String
@export var display_name: String
@export var growth_time: float  # In seconds or runs
@export var buff_provided: Buff
@export var seed_cost: int = 10

# Visual generation parameters
@export var base_color: Color
@export var shape_type: String  # "round", "tall", "leafy"
```

### SaveData

```gdscript
class_name SaveData extends Resource

@export var unlocked_upgrades: Array[String] = []
@export var inventory: Dictionary = {}
@export var plot_states: Array[Dictionary] = []
@export var total_runs_completed: int = 0
@export var timestamp: int = 0

func to_dict() -> Dictionary:
    return {
        "unlocked_upgrades": unlocked_upgrades,
        "inventory": inventory,
        "plot_states": plot_states,
        "total_runs_completed": total_runs_completed,
        "timestamp": timestamp
    }

static func from_dict(data: Dictionary) -> SaveData:
    var save = SaveData.new()
    save.unlocked_upgrades = data.get("unlocked_upgrades", [])
    save.inventory = data.get("inventory", {})
    save.plot_states = data.get("plot_states", [])
    save.total_runs_completed = data.get("total_runs_completed", 0)
    save.timestamp = data.get("timestamp", 0)
    return save
```

### 10. UIManager

**Responsibility**: Manage all user interface elements and interaction prompts across both scenes.

**Interface**:
```gdscript
class_name UIManager extends CanvasLayer

# UI Panels
@onready var combat_ui: CombatUI = $CombatUI
@onready var farm_ui: FarmUI = $FarmUI
@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt

# Methods
func show_combat_ui() -> void
func show_farm_ui() -> void
func update_health_display(current: int, max: int) -> void
func update_ammo_display(weapon_type: WeaponSystem.WeaponType, amount: int) -> void
func update_buff_display(buffs: Array[Buff]) -> void
func update_inventory_display(inventory: Dictionary) -> void
func show_interaction_prompt(text: String, position: Vector2) -> void
func hide_interaction_prompt() -> void

# Signals
signal upgrade_button_pressed(upgrade_id: String)
signal portal_entered()
```

**Sub-components**:

```gdscript
# Combat UI - Displays health, ammo, buffs during combat
class_name CombatUI extends Control

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var ammo_label: Label = $AmmoLabel
@onready var buff_container: HBoxContainer = $BuffContainer
@onready var weapon_indicator: TextureRect = $WeaponIndicator

func update_health(current: int, max: int) -> void
func update_ammo(amount: int) -> void
func add_buff_icon(buff: Buff) -> void
func clear_buff_icons() -> void
func show_weapon_switch(weapon_type: WeaponSystem.WeaponType) -> void
```

```gdscript
# Farm UI - Displays inventory, upgrades, crop status
class_name FarmUI extends Control

@onready var inventory_panel: Panel = $InventoryPanel
@onready var upgrade_panel: Panel = $UpgradePanel
@onready var crop_status_panel: Panel = $CropStatusPanel

func update_inventory(inventory: Dictionary) -> void
func populate_upgrades(available_upgrades: Array[Dictionary]) -> void
func update_crop_status(plots: Array[Plot]) -> void
func highlight_affordable_upgrades(currency: int) -> void
```

```gdscript
# Interaction Prompt - Shows context-sensitive prompts
class_name InteractionPrompt extends Control

@onready var prompt_label: Label = $PromptLabel
@onready var background: NinePatchRect = $Background

var current_target: Node = null

func show_prompt(text: String, world_position: Vector3) -> void
func hide_prompt() -> void
func update_position(world_position: Vector3) -> void
```

**Design Rationale**: Separating UI into distinct components allows each scene to show only relevant information. The InteractionPrompt system provides clear feedback for all interactive objects (plots, portals, NPCs). Using procedurally generated UI elements maintains the art-free approach while ensuring readability through high-contrast colors.

### 11. CollisionManager

**Responsibility**: Handle collision detection and physics interactions for player, enemies, and projectiles.

**Interface**:
```gdscript
class_name CollisionManager extends Node

# Collision layers (bit flags)
const LAYER_PLAYER = 1
const LAYER_ENEMY = 2
const LAYER_PROJECTILE = 4
const LAYER_ENVIRONMENT = 8
const LAYER_INTERACTIVE = 16

# Methods
func setup_player_collision(player: CharacterBody3D) -> void
func setup_enemy_collision(enemy: EnemyBase) -> void
func setup_projectile_collision(projectile: Area3D) -> void
func check_line_of_sight(from: Vector3, to: Vector3) -> bool
```

**Design Rationale**: Using Godot's collision layers and masks ensures proper physics interactions. Player collides with environment and enemies, projectiles collide with enemies and environment, enemies collide with environment but not each other (prevents clustering). This prevents movement through solid objects (Requirement 1.5).

### 12. FeedbackSystem

**Responsibility**: Provide visual and audio feedback for game events.

**Interface**:
```gdscript
class_name FeedbackSystem extends Node

# Visual feedback
func spawn_damage_number(amount: int, position: Vector3) -> void
func spawn_hit_effect(position: Vector3, is_critical: bool) -> void
func flash_screen(color: Color, duration: float) -> void
func shake_camera(intensity: float, duration: float) -> void

# Procedural particle effects
func create_impact_particles(position: Vector3, color: Color) -> void
func create_death_explosion(position: Vector3, enemy_type: String) -> void
func create_harvest_effect(position: Vector2, crop_type: String) -> void

# Signals
signal feedback_completed(feedback_type: String)
```

**Design Rationale**: Centralizing feedback ensures consistent visual language. Damage numbers and hit effects satisfy Requirements 2.3 and 9.2 for clear combat feedback. All effects are generated procedurally using simple shapes and color palettes to maintain the art-free approach.

## Data Models

### Buff

```gdscript
class_name Buff extends Resource

enum BuffType { HEALTH, AMMO, WEAPON_MOD }

@export var buff_type: BuffType
@export var value: int
@export var duration: int = 1  # Number of runs
@export var weapon_mod_type: String = ""  # For weapon mods

func apply_to_player(player: PlayerController) -> void:
    match buff_type:
        BuffType.HEALTH:
            GameManager.player_max_health += value
        BuffType.AMMO:
            GameManager.inventory["ammo"] += value
        BuffType.WEAPON_MOD:
            player.weapon_system.apply_weapon_mod(weapon_mod_type)
```

### CropData

```gdscript
class_name CropData extends Resource

@export var crop_id: String
@export var display_name: String
@export var growth_time: float  # In seconds or runs
@export var buff_provided: Buff
@export var seed_cost: int = 10

# Visual generation parameters
@export var base_color: Color
@export var shape_type: String  # "round", "tall", "leafy"
```

**Crop Growth Mechanics**: Crops can grow based on either elapsed real-time (seconds) or completed combat runs, configurable per crop type. This dual-mode system allows fast-growing crops (time-based) for immediate buffs and slow-growing crops (run-based) for powerful upgrades. The Plot component tracks both timers and increments appropriately based on the crop's growth_mode setting.

### SaveData

```gdscript
class_name SaveData extends Resource

@export var unlocked_upgrades: Array[String] = []
@export var inventory: Dictionary = {}
@export var plot_states: Array[Dictionary] = []
@export var total_runs_completed: int = 0
@export var timestamp: int = 0

func to_dict() -> Dictionary:
    return {
        "unlocked_upgrades": unlocked_upgrades,
        "inventory": inventory,
        "plot_states": plot_states,
        "total_runs_completed": total_runs_completed,
        "timestamp": timestamp
    }

static func from_dict(data: Dictionary) -> SaveData:
    var save = SaveData.new()
    save.unlocked_upgrades = data.get("unlocked_upgrades", [])
    save.inventory = data.get("inventory", {})
    save.plot_states = data.get("plot_states", [])
    save.total_runs_completed = data.get("total_runs_completed", 0)
    save.timestamp = data.get("timestamp", 0)
    return save
```

**Save Error Handling**: The ProgressionManager implements retry logic with exponential backoff for save failures. If saving fails after 3 attempts, the system notifies the player via UI and caches the save data in memory for the next successful save opportunity (Requirement 16.4).

## Export and Distribution Configuration

**Target Platform**: Windows standalone executable

**Export Settings**:
```
Export Mode: Embedded PCK
Architecture: x86_64
Optimization: Size
Excluded Modules: 
  - Movie Maker
  - Multiplayer
  - Navigation (if unused)
  - Physics 2D (if 3D only)
Compression: ZSTD (high compression)
Encryption: None (not required for prototype)
```

**Size Optimization Strategy**:
1. Embed all resources in executable (no external .pck file)
2. Exclude unused Godot engine modules during export
3. Use ZSTD compression for maximum size reduction
4. Generate all visuals at runtime (no texture assets)
5. Use minimal audio (procedural or excluded for prototype)

**Target Size**: Under 50MB for complete executable (Requirement 17.3)

**Portability**: The executable is fully portable and can run from any directory without installation or external dependencies (Requirements 17.4, 17.7). Save data is stored in the user's AppData directory using Godot's `user://` path.

**Design Rationale**: Embedded PCK mode creates a single-file distribution that's easier for players to manage. Excluding unused engine modules significantly reduces file size. The procedural art approach eliminates texture assets, which are typically the largest component of game executables.

## Correctness Properties


### Property 1: Player Movement Responsiveness

**Validates: Requirements 1.1, 1.3, 1.4**

**Property**: For all valid directional inputs, the player character's velocity changes within one physics frame, and movement speed remains constant across scene transitions.

**Test Strategy**: 
- Generate random input sequences (WASD combinations, dash inputs)
- Verify velocity changes occur in the same frame as input
- Verify movement speed is identical in Farm_Hub and Combat_Zone scenes
- Verify dash cooldown prevents multiple dashes within cooldown period

### Property 2: Weapon Firing Consistency

**Validates: Requirements 2.1, 2.2, 2.4, 2.5**

**Property**: For all weapon types, firing behavior matches specification: Pistol never depletes ammo, Shotgun consumes exactly 1 ammo per shot, and fire rate limits are enforced.

**Test Strategy**:
- Generate random firing sequences with varying timing
- Verify Pistol ammo never decreases
- Verify Shotgun ammo decreases by exactly 1 per successful shot
- Verify shots cannot occur faster than specified fire_rate
- Verify Shotgun cannot fire when ammo is 0

### Property 3: Enemy Behavior Determinism

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

**Property**: For all enemy types, behavior is deterministic given the same player position and enemy state. Enemies always drop loot upon death.

**Test Strategy**:
- Generate random player positions and enemy configurations
- Verify MeleeCharger always moves toward player when detected
- Verify RangedShooter fires projectiles when line of sight exists
- Verify TankEnemy continues advancing when damaged
- Verify all enemies spawn loot when health reaches 0
- Verify enemy behavior is reproducible with same initial conditions

### Property 4: Farming State Transitions

**Validates: Requirements 4.2, 4.3, 4.4, 4.5**

**Property**: Plot state transitions follow the strict sequence: EMPTY → GROWING → HARVESTABLE → EMPTY. Growth progress is monotonically increasing.

**Test Strategy**:
- Generate random planting and harvesting sequences
- Verify plots cannot skip states (e.g., EMPTY directly to HARVESTABLE)
- Verify growth_progress never decreases
- Verify harvest only succeeds when state is HARVESTABLE
- Verify plot returns to EMPTY after successful harvest
- Verify growth progresses based on configured mode (time or runs)

### Property 5: Buff Application and Clearing

**Validates: Requirements 5.1, 5.2, 5.3, 5.4**

**Property**: Buffs applied before entering Combat_Zone persist throughout the run and are cleared upon returning to Farm_Hub. Buff effects are additive and reversible.

**Test Strategy**:
- Generate random buff combinations
- Verify buffs are active throughout entire combat run
- Verify all buffs are cleared on return to Farm_Hub
- Verify player stats return to base values (plus permanent upgrades) after buff clearing
- Verify multiple buffs of same type stack correctly

### Property 6: Progression Persistence

**Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5**

**Property**: Permanent upgrades, once unlocked, persist across all game sessions. Save data is consistent with game state.

**Test Strategy**:
- Generate random upgrade purchase sequences
- Verify unlocked upgrades persist after save/load cycle
- Verify upgrade effects apply immediately upon unlock
- Verify save data matches current game state before save
- Verify loaded data correctly restores game state
- Test save/load at various game states (mid-farming, post-combat, etc.)

### Property 7: Scene Transition State Preservation

**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

**Property**: Player state (inventory, permanent upgrades) is preserved across all scene transitions. Temporary buffs are applied on Combat_Zone entry and cleared on exit.

**Test Strategy**:
- Generate random game state configurations
- Transition between scenes multiple times
- Verify inventory contents are identical before and after transitions
- Verify permanent upgrades remain active across transitions
- Verify temporary buffs are present in Combat_Zone and absent in Farm_Hub
- Verify player health resets appropriately based on death vs completion

### Property 8: Combat Zone Wave Completion

**Validates: Requirements 8.2, 8.4**

**Property**: Wave completion occurs if and only if all enemies in the current wave are defeated. Run completion occurs if and only if all waves are completed.

**Test Strategy**:
- Generate random enemy configurations and wave counts
- Verify wave does not complete while any enemy has health > 0
- Verify wave completes immediately when last enemy dies
- Verify next wave spawns only after current wave completion
- Verify run completion only occurs after final wave

### Property 9: Health and Death Mechanics

**Validates: Requirements 9.1, 9.2, 9.3, 9.4**

**Property**: Player health is bounded by [0, max_health]. Death occurs if and only if health reaches 0. Death results in loss of run loot and return to Farm_Hub.

**Test Strategy**:
- Generate random damage sequences
- Verify health never exceeds max_health
- Verify health never goes below 0
- Verify death state triggers exactly when health reaches 0
- Verify run loot is cleared on death
- Verify player returns to Farm_Hub after death
- Verify permanent progression is not lost on death

### Property 10: Procedural Generation Determinism

**Validates: Requirements 12.1, 12.9**

**Property**: For any given seed value, procedural generation produces identical output across all invocations.

**Test Strategy**:
- Generate random seed values
- Generate visual content multiple times with same seed
- Verify pixel-perfect equality of generated images
- Test across all generation types: tilesets, crops, enemies, weapons, UI
- Verify different seeds produce different outputs

### Property 11: UI Information Accuracy

**Validates: Requirements 10.1, 10.2, 10.4**

**Property**: All UI displays accurately reflect current game state with no delay or desynchronization.

**Test Strategy**:
- Generate random game state changes
- Verify health display matches GameManager.player_health
- Verify ammo display matches WeaponSystem.ammo
- Verify buff display matches GameManager.active_buffs
- Verify inventory display matches GameManager.inventory
- Verify weapon indicator updates immediately on weapon switch

### Property 12: Collision Detection Correctness

**Validates: Requirements 1.5, 2.3, 3.5**

**Property**: Collision detection prevents invalid states: player cannot pass through solid objects, projectiles register hits on enemies, enemies deal damage on player contact.

**Test Strategy**:
- Generate random movement paths toward obstacles
- Verify player position never intersects solid geometry
- Generate random projectile trajectories
- Verify projectile-enemy collisions register damage
- Verify enemy-player collisions register damage
- Verify collision layers prevent unintended interactions

## Testing Framework

**Primary Framework**: GdUnit4 (Godot 4.x native testing framework)

**Property-Based Testing**: Custom property test harness built on GdUnit4 with random input generation

**Test Organization**:
```
tests/
├── unit/
│   ├── test_player_controller.gd
│   ├── test_weapon_system.gd
│   ├── test_farm_grid.gd
│   └── test_procedural_art_generator.gd
├── integration/
│   ├── test_scene_transitions.gd
│   ├── test_combat_flow.gd
│   └── test_save_load.gd
└── property/
    ├── test_movement_properties.gd
    ├── test_weapon_properties.gd
    ├── test_farming_properties.gd
    └── test_progression_properties.gd
```

**Test Execution**: All tests run via GdUnit4 test runner. Property tests execute 100+ iterations with random inputs per property.

## Implementation Phases

### Phase 1: Core Systems (Foundation)
- GameManager singleton with state management
- PlayerController with movement and camera
- Basic scene structure (Farm_Hub, Combat_Zone)
- ProceduralArtGenerator with basic shape generation

### Phase 2: Combat Mechanics
- WeaponSystem with Pistol and Shotgun
- EnemyBase and three enemy variants
- Projectile system and collision detection
- ArenaGenerator with basic templates
- FeedbackSystem for combat feedback

### Phase 3: Farming Systems
- FarmGrid and Plot management
- CropData and growth mechanics
- Buff system and application
- Harvest and planting interactions

### Phase 4: Progression and UI
- ProgressionManager with upgrades
- SaveData and persistence
- UIManager with all UI components
- Interaction prompt system

### Phase 5: Polish and Export
- Visual atmosphere tuning (palettes, effects)
- Session length balancing
- Export configuration and size optimization
- Final testing and bug fixes

## Design Decisions and Rationales

### Decision 1: Autoload Singleton for GameManager
**Rationale**: Godot's autoload system provides a persistent singleton that survives scene transitions, making it ideal for managing player state, inventory, and progression. This eliminates the need for manual state serialization between scenes.

### Decision 2: Signal-Based Communication
**Rationale**: Using Godot's signal system for inter-component communication maintains loose coupling and makes systems independently testable. For example, the WeaponSystem emits signals that UIManager listens to, without either component knowing about the other's implementation.

### Decision 3: Procedural Art at Runtime
**Rationale**: Generating all visuals at runtime eliminates asset files, reducing executable size and ensuring visual consistency through code. Using seeded RNG makes generation deterministic and reproducible, which is essential for testing and debugging.

### Decision 4: Dual-Mode Crop Growth
**Rationale**: Supporting both time-based and run-based growth gives designers flexibility to balance immediate vs long-term progression. Fast-growing crops (time-based) provide quick buffs for new players, while slow-growing crops (run-based) reward consistent play over multiple sessions.

### Decision 5: Embedded PCK Export
**Rationale**: Single-file distribution is more user-friendly and reduces confusion. Players can simply download and run the executable without worrying about keeping multiple files together. This also prevents issues with missing or corrupted .pck files.

### Decision 6: Collision Layer Architecture
**Rationale**: Using Godot's collision layers and masks provides efficient physics filtering. Preventing enemy-enemy collisions avoids clustering and pathfinding issues, while maintaining necessary player-enemy and projectile-enemy interactions.

### Decision 7: Separate UI Components per Scene
**Rationale**: Farm_Hub and Combat_Zone have different UI needs. Separating CombatUI and FarmUI allows each to be optimized for its context and prevents cluttering either scene with irrelevant information.

### Decision 8: Resource-Based Data Models
**Rationale**: Using Godot's Resource class for Buff, CropData, and SaveData enables easy serialization, inspector editing, and type safety. Resources can be saved to disk and loaded efficiently, which is essential for the save system.
