# Technology Stack

## Engine & Language

- **Engine**: Godot 4.6 (or later 4.x versions)
- **Language**: GDScript
- **Platform**: Windows (primary target)

## Testing Framework

- **GdUnit4**: Comprehensive unit testing framework for Godot 4.x
- Installation guide: `GDUNIT4_INSTALLATION_GUIDE.md`
- Quick reference: `tests/GDUNIT4_QUICK_REFERENCE.md`
- Full documentation: `tests/README.md`

## Project Configuration

- **Main Scene**: `res://scenes/farm_hub.tscn`
- **Resolution**: 1920x1080 (fullscreen mode 2)
- **Physics**: 3D with 5 collision layers (Player, Enemy, Projectile, Environment, Interactive)
- **Rendering**: Forward Plus renderer with MSAA 3D enabled

## Autoload Singletons

These scripts are automatically loaded and persist across scenes:

- `GameManager`: `res://scripts/autoload/game_manager.gd`
- `FeedbackSystem`: `res://scripts/systems/feedback_system.gd`

## Input Actions

Configured in `project.godot`:

- `move_forward` (W), `move_backward` (S), `move_left` (A), `move_right` (D)
- `dash` (Shift)
- `fire` (Left Mouse Button)
- `interact` (E)
- `switch_weapon_1` (1), `switch_weapon_2` (2)

## Local Godot Installation

The project includes a local Godot installation for debugging and troubleshooting:

- **Location**: `Godot_v4.6-stable_mono_win64/`
- **Editor**: `Godot_v4.6-stable_mono_win64.exe`
- **Console**: `Godot_v4.6-stable_mono_win64_console.exe` (for debugging with console output)

### When to Use Console Version

Use `Godot_v4.6-stable_mono_win64_console.exe` when:
- Debugging runtime errors or crashes
- Viewing detailed console output and error messages
- Running headless tests from command line
- Troubleshooting autoload or scene loading issues
- Investigating performance problems

The console version provides full stdout/stderr output that's essential for debugging.

## Common Commands

### Running the Game

From Godot Editor:
- Press F5 or click "Run Project" button
- Scene will start at `farm_hub.tscn`

From Command Line (with console output):
```bash
Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64_console.exe --path . res://scenes/farm_hub.tscn
```

### Running Tests

**From Godot Editor:**
```
Right-click test file → "Run Test(s)"
OR
Open GdUnit Inspector panel → "Run All Tests"
```

**From Command Line (for CI/CD):**
```bash
# Run all tests (using local Godot installation)
Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64_console.exe --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/

# Run specific test directory
Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64_console.exe --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/unit/

# Run with XML report
Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64_console.exe --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/ --report-xml

# Run single test file with console output
Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64_console.exe --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/unit/test_plot.gd
```

### Verification Tests

Run these to verify setup:
```
tests/unit/test_gdunit_verification.gd - Verify GdUnit4 installation
scripts/systems/verify_*.gd - Manual verification scripts for specific systems
scripts/farming/verify_*.gd - Manual verification scripts for farming systems
```

### Building for Distribution

From Godot Editor:
```
Project → Export → Windows Desktop
Target: Windows executable (.exe)
```

## Dependencies

### Required
- Godot 4.6 or later (Mono version not required - using GDScript only)
- GdUnit4 plugin (installed via AssetLib or manual installation)

### Optional
- Git for version control
- Text editor with GDScript support (VS Code with Godot extension recommended)

## Development Tools

### Godot Editor Features Used
- Scene editor for .tscn files
- Script editor with GDScript syntax highlighting
- Inspector for resource editing (.tres files)
- Debugger for runtime inspection
- Profiler for performance analysis
- GdUnit Inspector panel for test execution

### File Formats
- `.gd` - GDScript source files
- `.tscn` - Scene files (text format)
- `.tres` - Resource files (text format)
- `.godot` - Project configuration

## Performance Targets

- **Frame Rate**: Stable 60 FPS during combat with 10+ enemies
- **Executable Size**: Under 50MB
- **Load Times**: Scene transitions under 1 second

## Physics Configuration

Collision layers (defined in `project.godot`):
1. **Player** - Player character
2. **Enemy** - Enemy entities
3. **Projectile** - Bullets and projectiles
4. **Environment** - Static world geometry
5. **Interactive** - Interactable objects (plots, portals)

## Rendering Settings

- **Texture Filter**: Nearest (pixel art style)
- **MSAA**: 2x for 3D
- **VSync**: Enabled (mode 1)
- **Default Clear Color**: Dark gray (0.1, 0.1, 0.1)
