# Contributing to Arcade FPS Farming Game

## Development Setup

### Prerequisites
- Godot 4.3 or later
- GdUnit4 testing framework (see `GDUNIT4_INSTALLATION_GUIDE.md`)
- Git for version control

### Getting Started
1. Clone the repository
2. Open `project.godot` in Godot Editor
3. Install GdUnit4 plugin (see `GDUNIT4_INSTALLATION_GUIDE.md`)
4. Run verification test: `tests/unit/test_gdunit_verification.gd`
5. The project should load with the proper directory structure

## Project Structure

See `ARCHITECTURE.md` for detailed architecture documentation.

### Directory Organization
- `/scenes/` - Godot scene files (.tscn)
- `/scripts/` - GDScript files (.gd), organized by system
- `/resources/` - Resource files (.tres, .res)
- `/tests/` - Test files (unit, integration, property-based)

## Coding Standards

### GDScript Style Guide

#### Naming Conventions
- **Classes**: PascalCase (`class_name PlayerController`)
- **Files**: snake_case (`player_controller.gd`)
- **Variables**: snake_case (`var current_health: int`)
- **Constants**: UPPER_SNAKE_CASE (`const MAX_HEALTH = 100`)
- **Methods**: snake_case (`func take_damage()`)
- **Signals**: snake_case (`signal health_changed`)
- **Private methods**: Prefix with underscore (`func _internal_method()`)

#### Type Hints
Always use type hints for better code clarity and error detection:

```gdscript
# Good
func calculate_damage(base_damage: int, multiplier: float) -> int:
    return int(base_damage * multiplier)

var player_health: int = 100
var enemies: Array[EnemyBase] = []

# Avoid
func calculate_damage(base_damage, multiplier):
    return base_damage * multiplier

var player_health = 100
var enemies = []
```

#### Code Organization
1. Class declaration
2. Signals
3. Enums
4. Constants
5. Exported variables
6. Public variables
7. Private variables
8. Onready variables
9. Built-in methods (_ready, _process, etc.)
10. Public methods
11. Private methods

Example:
```gdscript
class_name PlayerController extends CharacterBody3D

# Signals
signal health_changed(new_health: int)
signal died()

# Enums
enum State { IDLE, MOVING, DASHING }

# Constants
const MAX_HEALTH: int = 100
const MOVE_SPEED: float = 5.0

# Exported variables
@export var dash_cooldown: float = 1.0

# Public variables
var current_health: int = MAX_HEALTH
var current_state: State = State.IDLE

# Private variables
var _dash_timer: float = 0.0

# Onready variables
@onready var camera: Camera3D = $Camera3D

# Built-in methods
func _ready() -> void:
    current_health = MAX_HEALTH

func _physics_process(delta: float) -> void:
    _update_movement(delta)

# Public methods
func take_damage(amount: int) -> void:
    current_health -= amount
    health_changed.emit(current_health)

# Private methods
func _update_movement(delta: float) -> void:
    # Implementation
    pass
```

#### Comments and Documentation
- Document public methods with clear descriptions
- Explain complex algorithms or non-obvious logic
- Use `#` for single-line comments
- Use `##` for documentation comments (shows in editor)

```gdscript
## Applies damage to the player and triggers death if health reaches zero.
## Returns true if the player died, false otherwise.
func take_damage(amount: int) -> bool:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health)
    
    if current_health <= 0:
        _trigger_death()
        return true
    
    return false
```

### Signal Usage
- Use signals for inter-component communication
- Avoid direct references between unrelated systems
- Name signals as past-tense verbs or state changes

```gdscript
# Good
signal health_changed(new_health: int)
signal enemy_died(loot: Dictionary)
signal weapon_fired(weapon_type: WeaponType)

# Avoid
signal health(value: int)
signal enemy(data: Dictionary)
signal fire(type: int)
```

### Resource Usage
- Use Godot's Resource class for data that needs serialization
- Create custom Resource classes for game data (buffs, crops, save data)
- Store resources in `/resources/` directory

```gdscript
class_name Buff extends Resource

@export var buff_type: BuffType
@export var value: int
@export var duration: int = 1

func apply_to_player(player: PlayerController) -> void:
    # Implementation
    pass
```

## Testing Guidelines

### Test Organization
- **Unit tests**: Test individual classes in isolation (`/tests/unit/`)
- **Integration tests**: Test system interactions (`/tests/integration/`)
- **Property tests**: Test universal properties (`/tests/property/`)

See `tests/README.md` for comprehensive testing documentation and `tests/GDUNIT4_QUICK_REFERENCE.md` for quick assertion reference.

### Writing Tests
- Use GdUnit4 framework
- Test file names: `test_<class_name>.gd`
- Test method names: `test_<behavior>_<expected_result>()`
- All test classes must extend `GdUnitTestSuite`

```gdscript
extends GdUnitTestSuite

func test_take_damage_reduces_health() -> void:
    var player = PlayerController.new()
    player.current_health = 100
    
    player.take_damage(30)
    
    assert_int(player.current_health).is_equal(70)

func test_take_damage_triggers_death_at_zero_health() -> void:
    var player = PlayerController.new()
    player.current_health = 10
    
    var died_signal_emitted = false
    player.died.connect(func(): died_signal_emitted = true)
    
    player.take_damage(10)
    
    assert_bool(died_signal_emitted).is_true()
```

### Property-Based Testing
- Test universal properties that should hold for all inputs
- Generate random input sequences
- Run 100+ iterations per property

```gdscript
func test_property_health_never_negative() -> void:
    for i in range(100):
        var player = PlayerController.new()
        var damage = randi() % 1000
        
        player.take_damage(damage)
        
        assert_int(player.current_health).is_greater_equal(0)
```

## Git Workflow

### Commit Messages
Follow conventional commit format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(player): add dash mechanic with cooldown

Implemented dash ability that allows quick directional movement.
Added cooldown timer to prevent spam.

Validates: Requirements 1.3

---

fix(farming): prevent planting on occupied plots

Added state check to ensure plots are empty before planting.

Fixes: Issue #42

---

test(weapon): add property tests for firing consistency

Added property-based tests to verify weapon firing behavior
matches specification across all weapon types.

Validates: Property 2
```

### Branch Naming
- `feature/<task-id>-<description>` - New features
- `fix/<issue-id>-<description>` - Bug fixes
- `test/<description>` - Test additions
- `docs/<description>` - Documentation updates

Examples:
- `feature/1.2.1-game-manager-singleton`
- `fix/42-plot-planting-bug`
- `test/property-movement-responsiveness`

## Development Workflow

### Implementing Tasks
1. Read the task description in `tasks.md`
2. Review related requirements in `requirements.md`
3. Review design in `design.md`
4. Create a feature branch
5. Implement the task
6. Write tests (unit, integration, property as needed)
7. Run all tests and ensure they pass
8. Update documentation if needed
9. Commit with proper message
10. Mark task as complete in `tasks.md`

### Task Completion Checklist
- [ ] Implementation matches requirements
- [ ] Code follows style guidelines
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No compiler warnings or errors
- [ ] Task marked complete in tasks.md

## Performance Guidelines

### Optimization Priorities
1. **Correctness first**: Make it work correctly
2. **Clarity second**: Make it readable and maintainable
3. **Performance third**: Optimize only when necessary

### Common Optimizations
- Cache procedurally generated sprites
- Use object pooling for frequently instantiated objects (enemies, projectiles)
- Proper collision layer/mask configuration
- Avoid unnecessary signal emissions
- Use `@onready` for node references

### Performance Testing
- Profile with Godot's built-in profiler
- Target: Stable 60 FPS during combat with 10+ enemies
- Test on target hardware specifications

## Questions or Issues?

- Check `ARCHITECTURE.md` for design decisions
- Review `requirements.md` and `design.md` in `.kiro/specs/`
- Refer to task details in `tasks.md`

## Code Review Guidelines

When reviewing code:
1. Verify it matches requirements and design
2. Check for proper type hints and documentation
3. Ensure tests are present and passing
4. Look for potential performance issues
5. Verify proper signal usage and loose coupling
6. Check for code style consistency

## Additional Resources

- [Godot 4 Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [GdUnit4 Documentation](https://mikeschulze.github.io/gdUnit4/)
