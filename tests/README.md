# Testing Framework Documentation

## Overview

This directory contains all automated tests for the Arcade FPS Farming Game project. The testing framework uses **GdUnit4**, a comprehensive unit testing framework for Godot 4.x.

## Directory Structure

```
tests/
├── unit/              # Unit tests for individual components
│   └── test_gdunit_verification.gd  # Verification test for GdUnit4 setup
├── integration/       # Integration tests for system interactions
└── property/          # Property-based tests for correctness properties
```

### Unit Tests (`unit/`)

Unit tests verify individual components in isolation:
- **GameManager**: State management, buff system, transitions
- **PlayerController**: Movement, camera, health
- **WeaponSystem**: Firing, switching, ammo management
- **EnemyBase**: AI behavior, damage, death
- **FarmGrid & Plot**: Planting, growth, harvesting
- **ProceduralArtGenerator**: Deterministic generation
- **ProgressionManager**: Upgrades, save/load

**Naming Convention**: `test_<component_name>.gd`

Example: `test_player_controller.gd`, `test_weapon_system.gd`

### Integration Tests (`integration/`)

Integration tests verify interactions between multiple systems:
- **Scene Transitions**: Farm Hub ↔ Combat Zone
- **Combat Flow**: Player → Weapon → Enemy → Loot
- **Save/Load**: Persistence across sessions
- **Buff Lifecycle**: Application → Combat → Clearing
- **Progression Flow**: Loot → Upgrades → Player Stats

**Naming Convention**: `test_<system_interaction>.gd`

Example: `test_scene_transitions.gd`, `test_combat_flow.gd`

### Property-Based Tests (`property/`)

Property-based tests verify universal properties hold across many random inputs:
- **Property 1**: Player Movement Responsiveness
- **Property 2**: Weapon Firing Consistency
- **Property 3**: Enemy Behavior Determinism
- **Property 4**: Farming State Transitions
- **Property 5**: Buff Application and Clearing
- **Property 6**: Progression Persistence
- **Property 7**: Scene Transition State Preservation
- **Property 8**: Combat Zone Wave Completion
- **Property 9**: Health and Death Mechanics
- **Property 10**: Procedural Generation Determinism
- **Property 11**: UI Information Accuracy
- **Property 12**: Collision Detection Correctness

**Naming Convention**: `test_property_<number>_<name>.gd`

Example: `test_property_01_movement_responsiveness.gd`

## Test Structure

All test files should follow this structure:

```gdscript
# GdUnit generated TestSuite
class_name <TestClassName>
extends GdUnitTestSuite

# Reference to the source being tested
const __source = 'res://path/to/source.gd'

# Setup before all tests (optional)
func before() -> void:
    # Runs once before all tests in this suite
    pass

# Setup before each test (optional)
func before_test() -> void:
    # Runs before each individual test
    pass

# Cleanup after each test (optional)
func after_test() -> void:
    # Runs after each individual test
    pass

# Cleanup after all tests (optional)
func after() -> void:
    # Runs once after all tests in this suite
    pass

# Test functions must start with "test_"
func test_example() -> void:
    # Arrange: Set up test data
    var value = 42
    
    # Act: Perform the action being tested
    var result = value * 2
    
    # Assert: Verify the result
    assert_int(result).is_equal(84)
```

## GdUnit4 Assertions

### Basic Assertions

```gdscript
# Boolean
assert_bool(value).is_true()
assert_bool(value).is_false()

# Integer
assert_int(value).is_equal(expected)
assert_int(value).is_greater(min)
assert_int(value).is_less(max)
assert_int(value).is_between(min, max)

# Float
assert_float(value).is_equal_approx(expected, tolerance)
assert_float(value).is_greater(min)

# String
assert_str(value).is_equal(expected)
assert_str(value).contains(substring)
assert_str(value).is_empty()
assert_str(value).has_length(length)

# Array
assert_array(value).contains([elements])
assert_array(value).has_size(size)
assert_array(value).is_empty()

# Dictionary
assert_dict(value).contains_keys([keys])
assert_dict(value).has_size(size)
assert_dict(value).is_empty()

# Object
assert_object(value).is_null()
assert_object(value).is_not_null()
assert_object(value).is_instanceof(Type)
assert_object(value).is_same(other)

# Generic
assert_that(value).is_equal(expected)
assert_that(value).is_not_equal(other)
```

### Signal Assertions

```gdscript
# Monitor signals
var signal_monitor = monitor_signals(object)

# Verify signal emission
assert_signal(signal_monitor).is_emitted("signal_name")
assert_signal(signal_monitor).is_emitted("signal_name", [args])
assert_signal(signal_monitor).is_not_emitted("signal_name")
```

### Scene Testing

```gdscript
# Create a scene runner
var runner = scene_runner("res://path/to/scene.tscn")

# Get the scene instance
var scene = runner.scene()

# Simulate frames
runner.simulate_frames(10)

# Simulate time
await runner.simulate_until_signal(scene, "ready", 1.0)

# Cleanup is automatic
```

## Property-Based Testing

Property-based tests use random input generation to verify properties hold across many cases:

```gdscript
func test_property_example() -> void:
    # Run 100 iterations with random inputs
    for i in range(100):
        # Generate random inputs
        var input = Fuzzers.rangei(1, 100)
        
        # Perform operation
        var result = some_function(input)
        
        # Verify property holds
        assert_bool(result >= 0).is_true()
```

### GdUnit4 Fuzzers

```gdscript
# Random integers
Fuzzers.rangei(min, max)

# Random floats
Fuzzers.rangef(min, max)

# Random strings
Fuzzers.random_string(length)

# Random from array
Fuzzers.from_array([options])

# Random Vector2
Fuzzers.vec2(min, max)

# Random Vector3
Fuzzers.vec3(min, max)
```

## Running Tests

### From Godot Editor

1. **Run Single Test**:
   - Right-click on a test function in the script editor
   - Select "Run Test(s)"

2. **Run Test File**:
   - Right-click on a test file in FileSystem
   - Select "Run Test(s)"

3. **Run Test Directory**:
   - Right-click on `tests/unit/`, `tests/integration/`, or `tests/property/`
   - Select "Run Test(s)"

4. **Run All Tests**:
   - Open GdUnit Inspector panel
   - Click "Run All Tests"

### From Command Line

For CI/CD integration:

```bash
# Run all tests
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/

# Run specific directory
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/unit/

# Run with XML report
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/ --report-xml
```

## Test Coverage Goals

- **Unit Tests**: >80% code coverage for core systems
- **Integration Tests**: All major system interactions covered
- **Property Tests**: All 12 correctness properties verified

## Best Practices

### 1. Test Naming

- Use descriptive names that explain what is being tested
- Follow the pattern: `test_<action>_<expected_result>`
- Example: `test_player_takes_damage_reduces_health()`

### 2. Test Independence

- Each test should be independent and not rely on other tests
- Use `before_test()` and `after_test()` for setup/cleanup
- Don't share state between tests

### 3. Arrange-Act-Assert

Structure tests clearly:
```gdscript
func test_example() -> void:
    # Arrange: Set up test conditions
    var player = PlayerController.new()
    
    # Act: Perform the action
    player.take_damage(10)
    
    # Assert: Verify the result
    assert_int(player.health).is_equal(90)
    
    # Cleanup
    player.free()
```

### 4. Test One Thing

- Each test should verify one specific behavior
- If testing multiple aspects, create separate test functions
- This makes failures easier to diagnose

### 5. Use Meaningful Assertions

```gdscript
# Good: Specific assertion
assert_int(player.health).is_equal(90)

# Avoid: Generic assertion
assert_that(player.health == 90).is_true()
```

### 6. Clean Up Resources

Always free created nodes and resources:
```gdscript
func test_example() -> void:
    var node = Node.new()
    # ... test code ...
    node.free()  # Always cleanup
```

### 7. Test Edge Cases

- Empty inputs
- Null values
- Boundary values (0, max, min)
- Invalid states

### 8. Document Complex Tests

Add comments explaining:
- Why the test exists
- What property it verifies
- Any non-obvious setup or assertions

## Continuous Integration

Tests should be run automatically on:
- Every commit (pre-commit hook)
- Every pull request (CI pipeline)
- Before releases

## Troubleshooting

### Tests Not Found

- Ensure test files extend `GdUnitTestSuite`
- Verify test functions start with `test_`
- Check that files are in the correct directory

### Tests Failing Unexpectedly

- Check for shared state between tests
- Verify cleanup in `after_test()`
- Look for timing issues with async operations

### Slow Tests

- Avoid unnecessary `await` calls
- Use `simulate_frames()` instead of real-time waits
- Mock expensive operations

## Resources

- **GdUnit4 Documentation**: https://mikeschulze.github.io/gdUnit4/
- **GdUnit4 GitHub**: https://github.com/MikeSchulze/gdUnit4
- **Design Document**: See `.kiro/specs/arcade-fps-farming-game/design.md` for correctness properties
- **Requirements**: See `.kiro/specs/arcade-fps-farming-game/requirements.md` for acceptance criteria

## Next Steps

1. ✅ Install and verify GdUnit4 (run `test_gdunit_verification.gd`)
2. ✅ Implement unit tests as components are developed
3. ✅ Add integration tests for system interactions
4. ✅ Implement property-based tests for correctness properties
5. ✅ Achieve >80% code coverage
6. ✅ Set up CI/CD pipeline for automated testing

---

**Note**: This testing framework is essential for ensuring the game meets all requirements and maintains quality throughout development.
