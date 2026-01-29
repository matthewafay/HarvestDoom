# Godot-Specific Conventions

## Code Style Shortcuts

### Type Hints
Always use type hints - they catch errors early and improve autocomplete:
```gdscript
# Good
func take_damage(amount: int) -> void:
    health -= amount

# Avoid
func take_damage(amount):
    health -= amount
```

### Node References
Use `@onready` for node references to avoid null checks:
```gdscript
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera3D = $Camera3D
```

### Signals Over Polling
Use signals instead of checking state every frame:
```gdscript
# Good
signal health_changed(new_value: int)
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)

# Avoid
var health_changed: bool = false
func _process(delta: float) -> void:
    if health_changed:
        update_ui()
```

## Performance Patterns

### Object Pooling
For frequently spawned objects (projectiles, enemies), use pooling:
```gdscript
var projectile_pool: Array[Projectile] = []

func get_projectile() -> Projectile:
    if projectile_pool.is_empty():
        return Projectile.new()
    return projectile_pool.pop_back()

func return_projectile(proj: Projectile) -> void:
    proj.visible = false
    projectile_pool.append(proj)
```

### Collision Layers
Always set proper collision layers/masks - prevents unnecessary collision checks:
```gdscript
# Player should only collide with Environment, Enemy, Interactive
collision_layer = 1  # Layer 1 (Player)
collision_mask = 0b10110  # Layers 2 (Enemy), 4 (Environment), 5 (Interactive)
```

### Caching
Cache expensive operations:
```gdscript
# Good - cache the result
var _cached_sprite: ImageTexture = null
func get_sprite() -> ImageTexture:
    if _cached_sprite == null:
        _cached_sprite = generate_sprite()
    return _cached_sprite

# Avoid - regenerates every time
func get_sprite() -> ImageTexture:
    return generate_sprite()
```

## Common Godot Patterns

### State Machines
Use enums for state management:
```gdscript
enum State { IDLE, MOVING, ATTACKING, DEAD }
var current_state: State = State.IDLE

func _process(delta: float) -> void:
    match current_state:
        State.IDLE:
            _process_idle(delta)
        State.MOVING:
            _process_moving(delta)
        State.ATTACKING:
            _process_attacking(delta)
```

### Resource Loading
Preload resources at compile time when possible:
```gdscript
# Good - preload (compile time)
const PROJECTILE_SCENE = preload("res://scenes/projectile.tscn")

# Avoid - load (runtime)
var projectile_scene = load("res://scenes/projectile.tscn")
```

### Scene Instantiation
Use typed instantiation:
```gdscript
# Good
var projectile: Projectile = PROJECTILE_SCENE.instantiate()

# Avoid
var projectile = PROJECTILE_SCENE.instantiate()
```

## Testing Shortcuts

### Scene Runners
Use GdUnit4 scene runners for scene testing:
```gdscript
func test_scene_loads() -> void:
    var runner = scene_runner("res://scenes/farm_hub.tscn")
    var scene = runner.scene()
    assert_object(scene).is_not_null()
    # Cleanup is automatic
```

### Mock Autoloads
Mock autoload singletons in tests:
```gdscript
func before_test() -> void:
    # Mock GameManager for isolated testing
    var mock_gm = auto_free(Node.new())
    mock_gm.set_script(load("res://scripts/autoload/game_manager.gd"))
    add_child(mock_gm)
```

## Debugging Tips

### Print Debugging
Use typed print statements:
```gdscript
print("Health: %d, Position: %v" % [health, global_position])
push_warning("Unexpected state: %s" % state)
push_error("Critical failure in %s" % get_path())
```

### Breakpoints
Use `breakpoint` keyword for conditional debugging:
```gdscript
if health < 0:
    breakpoint  # Stops execution here
```

### Remote Debugging
Use the console version for detailed output:
```bash
Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64_console.exe --path .
```

## Common Pitfalls to Avoid

### Memory Leaks
Always free nodes you create:
```gdscript
# Good
var node = Node.new()
add_child(node)
# Later...
node.queue_free()

# Avoid - memory leak
var node = Node.new()
# Never freed
```

### Null References
Check for null before accessing:
```gdscript
# Good
if sprite != null:
    sprite.visible = false

# Or use optional chaining (Godot 4.x)
sprite?.set_visible(false)
```

### Frame-Rate Dependent Logic
Use delta time for movement:
```gdscript
# Good
velocity.x = direction * speed * delta

# Avoid - frame-rate dependent
velocity.x = direction * speed
```

## Quick Reference

**Node Lifecycle:**
1. `_init()` - Constructor
2. `_enter_tree()` - Added to scene tree
3. `_ready()` - Scene fully loaded
4. `_process(delta)` - Every frame
5. `_physics_process(delta)` - Fixed timestep
6. `_exit_tree()` - Removed from scene tree

**Common Node Types:**
- `Node2D` / `Node3D` - Base spatial nodes
- `CharacterBody2D` / `CharacterBody3D` - Physics characters
- `Area2D` / `Area3D` - Trigger zones
- `Sprite2D` / `Sprite3D` - Image display
- `Camera2D` / `Camera3D` - Viewport cameras

**Input Handling:**
```gdscript
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("fire"):
        fire_weapon()

func _unhandled_input(event: InputEvent) -> void:
    # Only called if not handled by UI
    pass
```
