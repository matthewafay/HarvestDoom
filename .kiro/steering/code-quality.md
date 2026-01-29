# Code Quality Guidelines

## SOLID Principles (Adapted for Godot)

### Single Responsibility
Each class should have one clear purpose:
```gdscript
# Good - focused responsibility
class_name Plot
# Manages a single farming plot

# Avoid - too many responsibilities
class_name FarmingSystem
# Manages plots, crops, inventory, UI, and save data
```

### Open/Closed
Extend behavior through inheritance/composition, not modification:
```gdscript
# Good - extend EnemyBase for new types
class_name TankEnemy extends EnemyBase

# Avoid - adding if/else for every enemy type
func update_enemy(type: String) -> void:
    if type == "tank":
        # tank logic
    elif type == "melee":
        # melee logic
```

### Liskov Substitution
Subclasses should work wherever parent class works:
```gdscript
# Good - all enemies can use base methods
var enemy: EnemyBase = TankEnemy.new()
enemy.take_damage(10)  # Works for any EnemyBase

# Avoid - subclass breaks parent contract
class_name BrokenEnemy extends EnemyBase:
    func take_damage(amount: int) -> void:
        push_error("This enemy can't take damage!")
```

### Interface Segregation
Don't force classes to implement unused methods:
```gdscript
# Good - separate concerns
signal health_changed(new_health: int)
signal died()

# Avoid - forcing all entities to implement everything
func get_inventory() -> Array:  # Not all entities have inventory
    return []
```

### Dependency Inversion
Depend on abstractions (signals, interfaces) not concrete classes:
```gdscript
# Good - depends on signal, not specific UI class
signal health_changed(new_health: int)

# Avoid - direct dependency on UI
var ui_manager: UIManager
func take_damage(amount: int) -> void:
    health -= amount
    ui_manager.update_health_bar(health)
```

## Code Smells to Avoid

### Long Methods
Keep methods under 20 lines. Extract complex logic:
```gdscript
# Good
func _process(delta: float) -> void:
    _update_movement(delta)
    _update_combat(delta)
    _update_visuals()

# Avoid
func _process(delta: float) -> void:
    # 100 lines of mixed logic
```

### Magic Numbers
Use named constants:
```gdscript
# Good
const MAX_HEALTH: int = 100
const DASH_COOLDOWN: float = 1.5

# Avoid
if health > 100:
    health = 100
if dash_timer < 1.5:
    return
```

### Deep Nesting
Flatten with early returns:
```gdscript
# Good
func plant(crop: CropData) -> bool:
    if state != PlotState.EMPTY:
        return false
    if crop == null:
        return false
    
    _do_plant(crop)
    return true

# Avoid
func plant(crop: CropData) -> bool:
    if state == PlotState.EMPTY:
        if crop != null:
            _do_plant(crop)
            return true
    return false
```

### Duplicate Code
Extract common logic:
```gdscript
# Good
func _apply_damage(target: Node, amount: int) -> void:
    if target.has_method("take_damage"):
        target.take_damage(amount)

func _on_projectile_hit(body: Node) -> void:
    _apply_damage(body, damage)

func _on_explosion_hit(body: Node) -> void:
    _apply_damage(body, explosion_damage)

# Avoid - duplicated logic in both methods
```

### God Objects
Avoid classes that do everything. Split responsibilities:
```gdscript
# Good - separate concerns
class_name GameManager  # State management only
class_name SaveManager  # Save/load only
class_name SceneManager  # Scene transitions only

# Avoid
class_name GameManager:
    # 1000 lines managing everything
```

## Naming Conventions

### Be Descriptive
```gdscript
# Good
var current_health: int
var max_health: int
var is_invulnerable: bool
var time_since_last_shot: float

# Avoid
var hp: int
var max: int
var inv: bool
var t: float
```

### Use Verb-Noun for Methods
```gdscript
# Good
func calculate_damage() -> int
func spawn_enemy() -> void
func update_health_bar() -> void

# Avoid
func damage() -> int
func enemy() -> void
func health() -> void
```

### Boolean Prefixes
```gdscript
# Good
var is_alive: bool
var has_weapon: bool
var can_dash: bool

# Avoid
var alive: bool
var weapon: bool
var dash: bool
```

## Error Handling

### Validate Inputs
```gdscript
func plant(crop: CropData) -> bool:
    if crop == null:
        push_error("Plot.plant: crop is null")
        return false
    
    if not crop.is_valid():
        push_error("Plot.plant: crop data is invalid")
        return false
    
    # Proceed with planting
```

### Fail Fast
```gdscript
# Good - fail immediately
func _ready() -> void:
    if not has_node("Sprite2D"):
        push_error("Missing required Sprite2D node")
        return
    
    sprite = $Sprite2D

# Avoid - fail later with cryptic error
func _ready() -> void:
    sprite = $Sprite2D  # Crashes if missing
```

### Use Assertions for Development
```gdscript
func set_health(value: int) -> void:
    assert(value >= 0, "Health cannot be negative")
    assert(value <= max_health, "Health exceeds maximum")
    health = value
```

## Performance Considerations

### Avoid Premature Optimization
Write clear code first, optimize only when profiling shows issues.

### Profile Before Optimizing
Use Godot's profiler to find actual bottlenecks:
```
Debug → Profiler → Start Profiling
```

### Common Optimizations
```gdscript
# Cache expensive lookups
@onready var game_manager: GameManager = get_node("/root/GameManager")

# Use collision layers properly
collision_mask = 0b10110  # Only check relevant layers

# Pool frequently created objects
var enemy_pool: Array[Enemy] = []

# Batch operations
for enemy in enemies:
    enemy.update(delta)  # Better than individual signals
```

## Documentation

### Document Public APIs
```gdscript
## Applies damage to the plot's crop, potentially destroying it.
## Returns true if the crop was destroyed, false otherwise.
func damage_crop(amount: int) -> bool:
    pass
```

### Document Complex Logic
```gdscript
# Calculate growth progress using exponential decay
# to simulate realistic plant growth curves
var growth_factor = 1.0 - exp(-delta * growth_rate)
growth_progress += growth_factor
```

### Don't Document Obvious Code
```gdscript
# Bad - obvious from code
## Sets the health to the given value
func set_health(value: int) -> void:
    health = value

# Good - no comment needed, code is clear
func set_health(value: int) -> void:
    health = value
```

## Code Review Checklist

Before considering code complete:
- [ ] All type hints present
- [ ] No magic numbers (use constants)
- [ ] Methods under 20 lines
- [ ] No deep nesting (max 3 levels)
- [ ] Descriptive variable/method names
- [ ] Input validation for public methods
- [ ] Error messages are clear
- [ ] Tests written and passing
- [ ] No compiler warnings
- [ ] Follows project conventions

## Refactoring Triggers

Refactor when you see:
- Duplicate code (DRY violation)
- Methods over 20 lines
- Classes over 300 lines
- More than 3 levels of nesting
- Unclear variable names
- Complex conditionals
- God objects doing too much

## Quick Wins

Small changes that improve code quality:
1. Add type hints everywhere
2. Extract magic numbers to constants
3. Rename unclear variables
4. Add early returns to reduce nesting
5. Split long methods
6. Add input validation
7. Write missing tests
8. Remove dead code
9. Fix compiler warnings
10. Add documentation comments

## Remember

**Good code is:**
- Easy to read
- Easy to test
- Easy to change
- Easy to debug

**Bad code is:**
- Clever but confusing
- Tightly coupled
- Hard to test
- Full of surprises

When in doubt, choose clarity over cleverness.
