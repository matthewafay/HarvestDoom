# Testing Strategy

## Test-Driven Development Approach

Write tests alongside implementation, not after. This catches issues early and ensures code is testable.

## Test Prioritization

### Always Test
- **Core game logic**: State transitions, calculations, game rules
- **Data structures**: Resources, save data, buff/crop definitions
- **System interactions**: Scene transitions, combat flow, farming cycle
- **Edge cases**: Boundary values, null inputs, invalid states

### Test When Needed
- **UI logic**: Only test complex UI state management
- **Visual generation**: Test determinism, not visual appearance
- **Performance**: Only if performance is critical

### Don't Test
- **Godot engine features**: Trust the engine works
- **Simple getters/setters**: No logic to test
- **Trivial wrappers**: Direct pass-throughs to engine functions

## Test Organization

### Unit Tests (Fast, Isolated)
Test individual classes without dependencies:
```gdscript
func test_plot_plant_success() -> void:
    var plot = Plot.new()
    var crop = CropData.new()
    crop.crop_id = "test_crop"
    
    var result = plot.plant(crop)
    
    assert_bool(result).is_true()
    assert_int(plot.state).is_equal(Plot.PlotState.GROWING)
```

### Integration Tests (Slower, Real Dependencies)
Test system interactions:
```gdscript
func test_harvest_adds_to_inventory() -> void:
    var farm_grid = FarmGrid.new()
    var plot = farm_grid.get_plot(0, 0)
    plot.plant(health_berry_crop)
    plot.growth_progress = plot.growth_time
    
    var result = plot.harvest()
    
    assert_dict(result).contains_keys(["crop_id", "buff"])
```

### Property Tests (Comprehensive, Random)
Test universal properties with random inputs:
```gdscript
func test_health_never_negative() -> void:
    for i in range(100):
        var player = PlayerController.new()
        var damage = randi() % 1000
        
        player.take_damage(damage)
        
        assert_int(player.health).is_greater_equal(0)
```

## Test Naming

Use descriptive names that explain the test:
```gdscript
# Good
func test_plant_on_empty_plot_succeeds() -> void:
func test_plant_on_occupied_plot_fails() -> void:
func test_harvest_before_growth_complete_fails() -> void:

# Avoid
func test_plant() -> void:
func test_harvest() -> void:
func test_plot() -> void:
```

## Test Structure (AAA Pattern)

Always use Arrange-Act-Assert:
```gdscript
func test_example() -> void:
    # Arrange - Set up test data
    var player = PlayerController.new()
    player.health = 100
    
    # Act - Perform the action
    player.take_damage(30)
    
    # Assert - Verify the result
    assert_int(player.health).is_equal(70)
    
    # Cleanup
    player.free()
```

## Test Efficiency

### Use auto_free() for Cleanup
```gdscript
func test_example() -> void:
    var node = auto_free(Node.new())  # Automatically freed after test
    # No need to call node.free()
```

### Reuse Test Data
```gdscript
var test_crop: CropData

func before() -> void:
    test_crop = CropData.new()
    test_crop.crop_id = "test"
    test_crop.growth_time = 10.0

func test_plant_with_test_crop() -> void:
    var plot = auto_free(Plot.new())
    assert_bool(plot.plant(test_crop)).is_true()
```

### Mock Heavy Dependencies
```gdscript
func test_without_art_generator() -> void:
    var plot = auto_free(Plot.new())
    plot.art_generator = null  # Skip expensive sprite generation
    plot.plant(test_crop)
    # Test logic without visual generation
```

## When Tests Fail

### Debug Process
1. Read the assertion message carefully
2. Add print statements to see actual values
3. Run single test in isolation
4. Check for setup/cleanup issues
5. Verify test assumptions are correct

### Fix Immediately
Don't accumulate failing tests. Fix them right away or mark them as skipped with a TODO:
```gdscript
@warning_ignore("unused_parameter")
func test_complex_feature() -> void:
    skip_test("TODO: Implement after refactor")
```

## Test Coverage Goals

- **Core systems**: 80%+ coverage
- **Game logic**: 90%+ coverage
- **UI/Visual**: 50%+ coverage (focus on logic, not rendering)
- **Property tests**: All 12 correctness properties validated

## Running Tests Efficiently

### During Development
Run tests for the file you're working on:
```bash
# Right-click test file in Godot → "Run Test(s)"
```

### Before Committing
Run all tests in the relevant category:
```bash
# Unit tests for quick validation
Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64_console.exe --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/unit/
```

### Before Pushing
Run all tests:
```bash
# Full test suite
Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64_console.exe --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/
```

## Test Maintenance

### Keep Tests Simple
Tests should be easier to understand than the code they test.

### Update Tests with Code
When changing functionality, update tests immediately.

### Delete Obsolete Tests
Remove tests for removed features. Don't let dead tests accumulate.

### Refactor Tests
If tests become hard to maintain, refactor them like production code.

## Red-Green-Refactor Cycle

1. **Red**: Write a failing test
2. **Green**: Write minimal code to make it pass
3. **Refactor**: Improve code while keeping tests green
4. **Repeat**: Move to next feature

This ensures every line of code has a purpose and is tested.
