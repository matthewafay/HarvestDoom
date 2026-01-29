# Project Structure

## Directory Organization

```
arcade-fps-farming-game/
├── .kiro/                     # Kiro IDE configuration
│   ├── specs/                 # Feature specifications
│   │   └── arcade-fps-farming-game/
│   │       ├── requirements.md
│   │       ├── design.md
│   │       └── tasks.md
│   └── steering/              # AI assistant steering rules
│
├── scenes/                    # Godot scene files (.tscn)
│   ├── farm_hub.tscn         # Main farming hub scene
│   ├── combat_zone.tscn      # Combat arena scene
│   ├── player.tscn           # Player character
│   ├── projectile.tscn       # Projectile prefab
│   ├── enemy_projectile.tscn # Enemy projectile prefab
│   ├── interaction_prompt.tscn # UI interaction prompt
│   └── verify_*.tscn         # Manual verification scenes
│
├── scripts/                   # GDScript source files (.gd)
│   ├── autoload/             # Singleton scripts (persist across scenes)
│   │   └── game_manager.gd   # Central state management
│   │
│   ├── player/               # Player-related scripts
│   │   └── player_controller.gd
│   │
│   ├── combat/               # Combat system scripts
│   │   ├── projectile.gd
│   │   └── weapon_system.gd
│   │
│   ├── enemies/              # Enemy AI scripts
│   │   ├── enemy_base.gd     # Base class for all enemies
│   │   ├── melee_charger.gd
│   │   ├── ranged_shooter.gd
│   │   ├── tank_enemy.gd
│   │   └── enemy_projectile.gd
│   │
│   ├── farming/              # Farming system scripts
│   │   ├── farm_grid.gd      # Grid management
│   │   ├── plot.gd           # Individual plot logic
│   │   ├── farm_interaction_manager.gd
│   │   ├── demo_crop_sprites.gd
│   │   ├── verify_*.gd       # Manual verification scripts
│   │   └── README.md         # Farming system documentation
│   │
│   ├── systems/              # Core game systems
│   │   ├── procedural_art_generator.gd  # Runtime art generation
│   │   ├── arena_generator.gd           # Combat arena generation
│   │   ├── feedback_system.gd           # Visual/audio feedback
│   │   ├── collision_manager.gd         # Collision handling
│   │   └── verify_*.gd                  # Manual verification scripts
│   │
│   └── ui/                   # UI scripts
│       └── interaction_prompt.gd
│
├── resources/                 # Godot resource files (.tres, .gd)
│   ├── buffs/                # Buff resource definitions
│   │   ├── buff.gd           # Buff base class
│   │   ├── health_buff_20.tres
│   │   ├── health_buff_40.tres
│   │   ├── ammo_buff_50.tres
│   │   ├── weapon_mod_damage.tres
│   │   └── weapon_mod_fire_rate.tres
│   │
│   ├── crops/                # Crop data resources
│   │   ├── crop_data.gd      # CropData base class
│   │   ├── health_berry.tres
│   │   ├── vitality_herb.tres
│   │   ├── ammo_grain.tres
│   │   ├── power_root.tres
│   │   ├── weapon_flower.tres
│   │   ├── CROP_REFERENCE.md
│   │   └── README.md
│   │
│   └── save_data.gd          # Save data structure
│
├── tests/                     # GdUnit4 test files
│   ├── unit/                 # Unit tests (individual components)
│   │   ├── test_game_manager.gd
│   │   ├── test_player_controller.gd
│   │   ├── test_weapon_system.gd
│   │   ├── test_enemy_base.gd
│   │   ├── test_plot.gd
│   │   ├── test_farm_grid.gd
│   │   ├── test_crop_data.gd
│   │   ├── test_buff.gd
│   │   ├── test_procedural_art_generator.gd
│   │   ├── test_arena_generator.gd
│   │   ├── test_feedback_system.gd
│   │   └── test_*.gd
│   │
│   ├── integration/          # Integration tests (system interactions)
│   │   ├── test_scene_transitions.gd
│   │   ├── test_farm_interaction.gd
│   │   ├── test_crop_sprite_integration.gd
│   │   ├── test_wave_completion_transitions.gd
│   │   └── test_*.gd
│   │
│   ├── property/             # Property-based tests (correctness properties)
│   │   ├── test_movement_properties.gd
│   │   ├── test_weapon_properties.gd
│   │   ├── test_health_properties.gd
│   │   ├── test_enemy_properties.gd
│   │   ├── test_farming_state_transitions.gd
│   │   ├── test_plot_properties.gd
│   │   ├── test_farm_grid_properties.gd
│   │   ├── test_generation_determinism.gd
│   │   ├── test_wave_completion_properties.gd
│   │   └── test_*.gd
│   │
│   ├── README.md             # Testing framework documentation
│   └── GDUNIT4_QUICK_REFERENCE.md
│
├── project.godot             # Godot project configuration
├── icon.svg                  # Project icon
├── README.md                 # Project overview
├── ARCHITECTURE.md           # Architecture documentation
├── CONTRIBUTING.md           # Development guidelines
├── QUICKSTART.md             # Quick start guide
└── TASK_*.md                 # Task completion summaries
```

## Key Directories

### `/scenes/`
Contains all Godot scene files. Scenes are the primary organizational unit in Godot.

- Main scenes: `farm_hub.tscn`, `combat_zone.tscn`
- Prefabs: `player.tscn`, `projectile.tscn`, `enemy_projectile.tscn`
- UI components: `interaction_prompt.tscn`
- Verification scenes: `verify_*.tscn` for manual testing

### `/scripts/`
Contains all GDScript source files, organized by system responsibility.

**Subdirectory Rules:**
- `autoload/`: Singleton scripts that persist across scenes (registered in project.godot)
- `player/`: Player-specific logic (movement, camera, health)
- `combat/`: Combat mechanics (weapons, projectiles)
- `enemies/`: Enemy AI and behavior (base class + variants)
- `farming/`: Farming system (grid, plots, crops, interaction)
- `systems/`: Core game systems (procedural generation, arena, feedback)
- `ui/`: User interface scripts

**Naming Convention:** `snake_case.gd` (e.g., `player_controller.gd`)

### `/resources/`
Contains Godot Resource files for data serialization.

- `buffs/`: Buff definitions (health, ammo, weapon mods)
- `crops/`: Crop data (growth time, buffs, visual parameters)
- `save_data.gd`: Save data structure

**Naming Convention:** `snake_case.tres` for resource instances, `snake_case.gd` for resource classes

### `/tests/`
Contains all GdUnit4 test files, organized by test type.

- `unit/`: Test individual classes in isolation
- `integration/`: Test system interactions
- `property/`: Test universal correctness properties

**Naming Convention:** `test_<component_name>.gd` (e.g., `test_player_controller.gd`)

### `/.kiro/`
Kiro IDE configuration and specifications.

- `specs/`: Feature specifications (requirements, design, tasks)
- `steering/`: AI assistant steering rules

## File Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Scripts | snake_case | `player_controller.gd` |
| Scenes | snake_case | `farm_hub.tscn` |
| Resources | snake_case | `health_buff_20.tres` |
| Classes | PascalCase | `class_name PlayerController` |
| Tests | test_snake_case | `test_player_controller.gd` |

## Script Organization Pattern

All scripts follow this internal structure:

1. Class declaration (`class_name`)
2. Signals
3. Enums
4. Constants
5. Exported variables (`@export`)
6. Public variables
7. Private variables (prefixed with `_`)
8. Onready variables (`@onready`)
9. Built-in methods (`_ready`, `_process`, etc.)
10. Public methods
11. Private methods (prefixed with `_`)

## Resource Organization

Resources use Godot's Resource system for type-safe serialization:

- **Buff**: Extends `Resource`, defines temporary combat bonuses
- **CropData**: Extends `Resource`, defines crop properties and growth
- **SaveData**: Extends `Resource`, defines persistent game state

## Scene Organization

Scenes are organized hierarchically:

- **farm_hub.tscn**: Main farming scene with FarmGrid and UI
- **combat_zone.tscn**: Combat arena with ArenaGenerator and wave spawning
- **player.tscn**: Player character with Camera3D and collision
- Prefabs: Reusable scene instances (projectiles, UI elements)

## Documentation Files

- `README.md`: Project overview and quick reference
- `ARCHITECTURE.md`: Detailed architecture documentation
- `CONTRIBUTING.md`: Development guidelines and coding standards
- `QUICKSTART.md`: Quick start guide for new developers
- `tests/README.md`: Testing framework documentation
- `scripts/farming/README.md`: Farming system documentation
- `resources/crops/README.md`: Crop system documentation
- `TASK_*.md`: Task completion summaries (generated during development)

## Special Files

- `.gdignore`: Marks directories to ignore in Godot's file system
- `project.godot`: Godot project configuration (autoloads, input, physics)
- `icon.svg`: Project icon
- `.gitignore`: Git ignore rules
- `.gitattributes`: Git attributes configuration

## Adding New Components

When adding new components, follow these patterns:

**New Script:**
1. Place in appropriate `/scripts/` subdirectory
2. Use `class_name` declaration
3. Follow script organization pattern
4. Add corresponding test in `/tests/unit/`

**New Scene:**
1. Place in `/scenes/` directory
2. Use snake_case naming
3. Attach script from `/scripts/`
4. Add to scene tree or instantiate dynamically

**New Resource:**
1. Create resource class in `/resources/` subdirectory
2. Create resource instances as `.tres` files
3. Use `@export` for inspector editing
4. Add validation method (`is_valid()`)

**New Test:**
1. Place in appropriate `/tests/` subdirectory
2. Extend `GdUnitTestSuite`
3. Use `test_` prefix for test methods
4. Follow Arrange-Act-Assert pattern
