# Quick Start Guide

## Opening the Project

1. **Install Godot 4.3+**
   - Download from [godotengine.org](https://godotengine.org/download)
   - Extract and run the Godot editor

2. **Open the Project**
   - Launch Godot
   - Click "Import"
   - Navigate to this directory and select `project.godot`
   - Click "Import & Edit"

3. **Verify Setup**
   - The project should open with the Farm Hub scene
   - Check that the directory structure is visible in the FileSystem dock
   - Verify no errors in the Output panel

## Project Overview

This is an arcade FPS farming game that combines:
- **Farming Hub**: Peaceful area for planting crops and managing upgrades
- **Combat Zone**: Fast-paced FPS arena with procedural enemies
- **Progression**: Permanent upgrades and temporary buffs from crops

## Key Directories

```
├── scenes/          # Scene files (.tscn)
├── scripts/         # GDScript files (.gd)
│   ├── autoload/   # Singleton managers
│   ├── player/     # Player controller and weapons
│   ├── combat/     # Combat systems
│   ├── enemies/    # Enemy AI
│   ├── farming/    # Farming systems
│   ├── systems/    # Core systems
│   └── ui/         # User interface
├── resources/       # Resource files (.tres)
└── tests/          # Test files (GdUnit4)
```

## Current Status

**All Phases Complete** ✅

The game is feature-complete and ready to play:
- ✅ Phase 1-6: Core systems (player, combat, enemies, farming)
- ✅ Phase 7-10: Buffs, progression, transitions, UI
- ✅ Phase 11-12: Visual atmosphere and balance tuning
- ✅ Phase 13-14: Performance optimization and export configuration

**Ready to Export**: See README.md for build instructions

See `.kiro/specs/arcade-fps-farming-game/tasks.md` for full task list.

## Next Steps

### For Developers

1. **Review Documentation**
   - Read `ARCHITECTURE.md` for system design
   - Read `CONTRIBUTING.md` for coding standards
   - Review `.kiro/specs/arcade-fps-farming-game/requirements.md`
   - Review `.kiro/specs/arcade-fps-farming-game/design.md`

2. **Install Testing Framework**
   - Complete task 1.1.5: Install GdUnit4
   - Follow GdUnit4 installation instructions

3. **Start Implementation**
   - Begin with Phase 1 tasks in `tasks.md`
   - Follow the task order for proper dependencies
   - Write tests alongside implementation

### For Testers

1. **Wait for Playable Build**
   - Current status: Project setup phase
   - Playable builds will be available after Phase 2-3

2. **Review Requirements**
   - See `.kiro/specs/arcade-fps-farming-game/requirements.md`
   - Understand expected gameplay features

## Controls (When Implemented)

- **WASD**: Move
- **Mouse**: Look around
- **Left Click**: Fire weapon
- **Shift**: Dash
- **E**: Interact with objects
- **1/2**: Switch weapons

## Architecture Highlights

### Autoload Singletons
- **GameManager**: Central state management
- **CollisionManager**: Physics layer management
- **FeedbackSystem**: Visual/audio feedback

### Scene Flow
```
Farm Hub ←→ Combat Zone
    ↓           ↓
  Farming    FPS Combat
  Upgrades   Wave-based
  Buffs      Loot drops
```

### Key Systems
- **Procedural Art**: All visuals generated at runtime
- **Buff System**: Crops provide temporary combat bonuses
- **Progression**: Permanent upgrades persist across sessions
- **Save System**: Automatic saving of progress

## Testing

### Running Tests (After GdUnit4 Installation)

1. Open the GdUnit4 panel in Godot
2. Select test suite to run
3. Click "Run Tests"
4. View results in the panel

### Test Types
- **Unit Tests**: Individual class testing
- **Integration Tests**: System interaction testing
- **Property Tests**: Universal property validation

## Common Issues

### Project Won't Open
- Ensure you're using Godot 4.3 or later
- Check that `project.godot` exists in the root directory

### Missing Directories
- Directories with only `.gdignore` files are placeholders
- They'll be populated as development progresses

### No Main Scene
- The main scene (`scenes/farm_hub.tscn`) is a placeholder
- It will be fully implemented in later phases

## Resources

### Documentation
- `README.md` - Project overview
- `ARCHITECTURE.md` - System design
- `CONTRIBUTING.md` - Development guidelines
- `.kiro/specs/arcade-fps-farming-game/` - Full specifications

### External Links
- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [GdUnit4 Testing](https://mikeschulze.github.io/gdUnit4/)

## Getting Help

1. Check the documentation files listed above
2. Review the requirements and design documents
3. Look at the task details in `tasks.md`
4. Check the architecture documentation

## Development Phases

1. **Phase 1**: Project Setup and Core Systems ← *Current*
2. **Phase 2**: Player Movement and Camera
3. **Phase 3**: Combat System
4. **Phase 4**: Enemy System
5. **Phase 5**: Arena and Enemy Management
6. **Phase 6**: Farming System
7. **Phase 7**: Buff and Resource System
8. **Phase 8**: Progression System
9. **Phase 9**: Scene Transitions
10. **Phase 10**: User Interface
11. **Phase 11**: Visual Atmosphere
12. **Phase 12**: Session Pacing and Balance
13. **Phase 13**: Performance and Polish
14. **Phase 14**: Export and Distribution
15. **Phase 15**: Testing and Validation
16. **Phase 16**: Documentation and Delivery

## Project Goals

- **Short Sessions**: 10-15 minute gameplay loops
- **Portable**: Single executable under 50MB
- **Procedural**: All art generated at runtime
- **Tested**: Comprehensive unit and property-based tests
- **Modular**: Clean, maintainable architecture

---

**Ready to start developing?** Begin with the tasks in Phase 1 of `tasks.md`!
