# Arcade FPS Farming Game

A prototype game that blends fast-paced arcade FPS combat with cozy farming and town progression. Built with Godot 4.x using GDScript, featuring procedurally generated visuals and short play sessions (10-15 minutes).

## Project Structure

```
arcade-fps-farming-game/
├── project.godot              # Godot project configuration
├── icon.svg                   # Project icon
├── README.md                  # This file
│
├── scenes/                    # Scene files (.tscn)
│   ├── farm_hub.tscn         # Main farming hub scene
│   ├── combat_zone.tscn      # Combat arena scene
│   ├── ui/                   # UI scene components
│   ├── enemies/              # Enemy scene instances
│   └── props/                # Interactive objects
│
├── scripts/                   # GDScript files (.gd)
│   ├── autoload/             # Singleton/autoload scripts
│   │   ├── game_manager.gd
│   │   ├── collision_manager.gd
│   │   └── feedback_system.gd
│   │
│   ├── player/               # Player-related scripts
│   │   ├── player_controller.gd
│   │   └── weapon_system.gd
│   │
│   ├── combat/               # Combat system scripts
│   │   ├── projectile.gd
│   │   └── arena_generator.gd
│   │
│   ├── enemies/              # Enemy AI scripts
│   │   ├── enemy_base.gd
│   │   ├── melee_charger.gd
│   │   ├── ranged_shooter.gd
│   │   └── tank_enemy.gd
│   │
│   ├── farming/              # Farming system scripts
│   │   ├── farm_grid.gd
│   │   ├── plot.gd
│   │   └── crop_data.gd
│   │
│   ├── systems/              # Core game systems
│   │   ├── procedural_art_generator.gd
│   │   ├── progression_manager.gd
│   │   └── scene_transition_manager.gd
│   │
│   └── ui/                   # UI scripts
│       ├── ui_manager.gd
│       ├── combat_ui.gd
│       ├── farm_ui.gd
│       └── interaction_prompt.gd
│
├── resources/                 # Resource files (.tres, .res)
│   ├── buffs/                # Buff resource definitions
│   ├── crops/                # Crop data resources
│   └── save_data/            # Save data templates
│
└── tests/                     # Test files (GdUnit4)
    ├── unit/                 # Unit tests
    ├── integration/          # Integration tests
    └── property/             # Property-based tests
```

## Directory Organization

### `/scenes/`
Contains all Godot scene files (.tscn). Scenes are organized by type:
- Main scenes (farm_hub, combat_zone)
- UI components
- Enemy prefabs
- Interactive objects

### `/scripts/`
Contains all GDScript files (.gd), organized by system:

- **`autoload/`**: Singleton scripts that persist across scenes (GameManager, CollisionManager, FeedbackSystem)
- **`player/`**: Player controller and weapon system
- **`combat/`**: Combat-related scripts (projectiles, arena generation)
- **`enemies/`**: Enemy AI and behavior scripts
- **`farming/`**: Farming system (grid, plots, crops)
- **`systems/`**: Core game systems (procedural art, progression, transitions)
- **`ui/`**: User interface scripts

### `/resources/`
Contains Godot resource files (.tres, .res):
- **`buffs/`**: Buff definitions (health, ammo, weapon mods)
- **`crops/`**: Crop data (growth time, buffs provided)
- **`save_data/`**: Save data templates

### `/tests/`
Contains all test files using GdUnit4:
- **`unit/`**: Unit tests for individual classes
- **`integration/`**: Integration tests for system interactions
- **`property/`**: Property-based tests for correctness properties

See `tests/README.md` for comprehensive testing documentation.

## Testing Framework

This project uses **GdUnit4** for comprehensive testing:

- **Installation Guide**: See `GDUNIT4_INSTALLATION_GUIDE.md`
- **Testing Documentation**: See `tests/README.md`
- **Quick Reference**: See `tests/GDUNIT4_QUICK_REFERENCE.md`
- **Verification Test**: Run `tests/unit/test_gdunit_verification.gd` to verify setup

### Running Tests

**From Godot Editor**:
- Right-click any test file → "Run Test(s)"
- Use GdUnit Inspector panel → "Run All Tests"

**From Command Line** (for CI/CD):
```bash
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/
```

## Key Features

- **Dual Gameplay Loop**: Alternate between peaceful farming and intense FPS combat
- **Procedural Visuals**: All art generated at runtime using deterministic algorithms
- **Short Sessions**: Complete gameplay loops in 10-15 minutes
- **Progression System**: Permanent upgrades and temporary buffs
- **Property-Based Testing**: Comprehensive correctness properties validated through testing

## Technical Details

- **Engine**: Godot 4.x
- **Language**: GDScript
- **Testing Framework**: GdUnit4
- **Target Platform**: Windows (standalone .exe)
- **Target Size**: Under 50MB
- **Architecture**: Scene-based with autoload singletons

## Input Controls

- **WASD**: Movement
- **Mouse**: Camera look
- **Left Click**: Fire weapon
- **Shift**: Dash
- **E**: Interact
- **1/2**: Switch weapons

## Physics Layers

1. **Player** (Layer 1): Player character
2. **Enemy** (Layer 2): Enemy entities
3. **Projectile** (Layer 3): Bullets and projectiles
4. **Environment** (Layer 4): Static world geometry
5. **Interactive** (Layer 5): Interactable objects (plots, portals)

## Development Status

This project is currently in Phase 1: Project Setup and Core Systems.

See `.kiro/specs/arcade-fps-farming-game/tasks.md` for detailed implementation tasks.

## License

[To be determined]
