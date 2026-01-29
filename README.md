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

**Current Status**: Feature Complete - Ready for Export

All core systems implemented:
- ✅ Player movement, combat, and health system
- ✅ Three enemy types with AI (Melee, Ranged, Tank)
- ✅ Weapon system (Pistol, Shotgun, Plant Weapon)
- ✅ Farming system with time-based crop growth
- ✅ Buff system linking farming to combat
- ✅ Progression system with permanent upgrades
- ✅ Save/load system with retry logic
- ✅ Scene transitions between Farm Hub and Combat Zone
- ✅ UI system (Combat UI, Farm UI, Interaction Prompts)
- ✅ Procedural art generation for all visuals
- ✅ Visual atmosphere (warm farm, dark combat)
- ✅ Balanced for 10-15 minute play sessions

See `.kiro/specs/arcade-fps-farming-game/tasks.md` for detailed task completion status.

## Building for Windows

### Export Configuration

The project includes export presets configured for Windows Desktop:

1. Open the project in Godot 4.6 or later
2. Go to **Project → Export**
3. Select "Windows Desktop" preset
4. Click **Export Project**
5. Choose output location (default: `./builds/ArcadeFPSFarming.exe`)

### Export Settings

- **Platform**: Windows Desktop (x86_64)
- **Embed PCK**: Yes (single .exe file)
- **Compression**: ZSTD (optimized for size)
- **Target Size**: Under 50MB
- **No external dependencies required**

### Running the Game

Simply double-click `ArcadeFPSFarming.exe` - no installation needed!

Save data is stored in: `%APPDATA%/Godot/app_userdata/Arcade FPS Farming Game/`

## Quick Start Guide

### First Time Playing

1. **Farm Hub**: You start in the peaceful farming area
   - Walk around with WASD
   - Approach plots and press E to plant crops
   - Wait for crops to grow (45-75 seconds)
   - Harvest crops for buffs

2. **Enter Combat**: Walk to the glowing portal and press E
   - Your harvested buffs are applied
   - Fight through 5 waves of enemies
   - Collect credits from defeated enemies

3. **Return to Farm**: Complete all waves or die
   - Successful completion: Keep all credits earned
   - Death: Lose credits from that run
   - Use credits to purchase permanent upgrades

4. **Progression**: Repeat the loop
   - Buy upgrades (health, speed, fire rate, dash)
   - Plant better crops for stronger buffs
   - Tackle harder waves with improved stats

### Combat Tips

- **Pistol**: Infinite ammo, good for basic enemies
- **Shotgun**: Limited ammo, devastating at close range
- **Dash**: Use Shift to dodge enemy attacks (1.5s cooldown)
- **Kiting**: Keep moving to avoid melee enemies
- **Prioritize**: Kill ranged shooters first, then tanks

### Farming Tips

- **Health Berry** (45s): +20 max health for next run
- **Ammo Grain** (60s): +50 shotgun ammo
- **Weapon Flower** (75s): Increased fire rate
- Plant multiple crops for stacked buffs
- Crops continue growing during combat runs

## System Requirements

**Minimum**:
- OS: Windows 10 (64-bit)
- Processor: Dual-core 2.0 GHz
- Memory: 2 GB RAM
- Graphics: OpenGL 3.3 compatible
- Storage: 50 MB available space

**Recommended**:
- OS: Windows 10/11 (64-bit)
- Processor: Quad-core 2.5 GHz
- Memory: 4 GB RAM
- Graphics: Dedicated GPU with OpenGL 3.3+
- Storage: 50 MB available space

Target: Stable 60 FPS during combat with 10+ enemies

## License

[To be determined]
