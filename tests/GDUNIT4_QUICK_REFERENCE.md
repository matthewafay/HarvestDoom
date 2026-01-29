# GdUnit4 Quick Reference Card

## Test Structure

```gdscript
class_name MyTest
extends GdUnitTestSuite

const __source = 'res://scripts/my_script.gd'

func before() -> void:
    # Runs once before all tests

func before_test() -> void:
    # Runs before each test

func test_my_feature() -> void:
    # Test implementation

func after_test() -> void:
    # Runs after each test

func after() -> void:
    # Runs once after all tests
```

## Common Assertions

### Boolean
```gdscript
assert_bool(value).is_true()
assert_bool(value).is_false()
```

### Integer
```gdscript
assert_int(value).is_equal(42)
assert_int(value).is_not_equal(0)
assert_int(value).is_greater(10)
assert_int(value).is_less(100)
assert_int(value).is_between(10, 100)
assert_int(value).is_even()
assert_int(value).is_odd()
assert_int(value).is_negative()
assert_int(value).is_positive()
```

### Float
```gdscript
assert_float(value).is_equal(3.14)
assert_float(value).is_equal_approx(3.14, 0.01)
assert_float(value).is_greater(0.0)
assert_float(value).is_less(10.0)
assert_float(value).is_between(0.0, 10.0)
```

### String
```gdscript
assert_str(value).is_equal("text")
assert_str(value).is_not_equal("other")
assert_str(value).is_empty()
assert_str(value).is_not_empty()
assert_str(value).contains("substring")
assert_str(value).starts_with("prefix")
assert_str(value).ends_with("suffix")
assert_str(value).has_length(10)
```

### Array
```gdscript
assert_array(value).is_empty()
assert_array(value).is_not_empty()
assert_array(value).has_size(5)
assert_array(value).contains([1, 2, 3])
assert_array(value).contains_exactly([1, 2, 3])
assert_array(value).contains_exactly_in_any_order([3, 1, 2])
```

### Dictionary
```gdscript
assert_dict(value).is_empty()
assert_dict(value).is_not_empty()
assert_dict(value).has_size(3)
assert_dict(value).contains_keys(["key1", "key2"])
assert_dict(value).contains_key_value("key", "value")
assert_dict(value).not_contains_keys(["key3"])
```

### Object
```gdscript
assert_object(value).is_null()
assert_object(value).is_not_null()
assert_object(value).is_instanceof(Node)
assert_object(value).is_not_instanceof(Node2D)
assert_object(value).is_same(other_ref)
assert_object(value).is_not_same(other_ref)
```

### Generic
```gdscript
assert_that(value).is_equal(expected)
assert_that(value).is_not_equal(other)
assert_that(value).is_null()
assert_that(value).is_not_null()
```

## Signal Testing

```gdscript
# Monitor signals
var monitor = monitor_signals(object)

# Check if signal was emitted
assert_signal(monitor).is_emitted("signal_name")
assert_signal(monitor).is_emitted("signal_name", [arg1, arg2])
assert_signal(monitor).is_not_emitted("signal_name")

# Check emission count
assert_signal(monitor).is_emitted_count("signal_name", 3)
```

## Scene Testing

```gdscript
# Create scene runner
var runner = scene_runner("res://scenes/my_scene.tscn")

# Get scene instance
var scene = runner.scene()

# Simulate frames
runner.simulate_frames(10)

# Simulate until signal
await runner.simulate_until_signal(scene, "ready", 1.0)

# Simulate until condition
await runner.simulate_until(func(): return scene.is_ready, 1.0)

# Cleanup is automatic
```

## Parameterized Tests

```gdscript
@warning_ignore("unused_parameter")
func test_with_parameters(
    input: int,
    expected: int,
    test_parameters := [
        [1, 2],
        [2, 4],
        [3, 6]
    ]
) -> void:
    assert_int(input * 2).is_equal(expected)
```

## Fuzzers (Random Data)

```gdscript
# Random integer
var rand_int = Fuzzers.rangei(1, 100)

# Random float
var rand_float = Fuzzers.rangef(0.0, 1.0)

# Random string
var rand_str = Fuzzers.random_string(10)

# Random from array
var rand_item = Fuzzers.from_array([1, 2, 3, 4, 5])

# Random Vector2
var rand_vec2 = Fuzzers.vec2(-10.0, 10.0)

# Random Vector3
var rand_vec3 = Fuzzers.vec3(-10.0, 10.0)

# Random Color
var rand_color = Fuzzers.color()
```

## Async Testing

```gdscript
func test_async_operation() -> void:
    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 0.1
    timer.one_shot = true
    timer.start()
    
    # Wait for signal
    await timer.timeout
    
    # Verify
    assert_bool(timer.is_stopped()).is_true()
    
    # Cleanup
    timer.queue_free()
```

## Mocking (Advanced)

```gdscript
# Create a mock
var mock_obj = mock(MyClass)

# Verify method was called
verify(mock_obj, 1).my_method()
verify(mock_obj, 2).my_method(arg1, arg2)

# Verify method was never called
verify(mock_obj, 0).other_method()

# Stub return value
do_return(42).on(mock_obj).my_method()
```

## Spying (Advanced)

```gdscript
# Create a spy (partial mock)
var spy_obj = spy(MyClass.new())

# Call real methods
spy_obj.real_method()

# Verify calls
verify(spy_obj, 1).real_method()

# Stub specific methods
do_return(100).on(spy_obj).specific_method()
```

## Test Timeouts

```gdscript
# Set timeout for specific test (in milliseconds)
func test_with_timeout() -> void:
    set_test_timeout(5000)  # 5 seconds
    # Test code
```

## Skipping Tests

```gdscript
# Skip a test
@warning_ignore("unused_parameter")
func test_skip_example(skip := true) -> void:
    # This test will be skipped
    pass

# Skip with reason
@warning_ignore("unused_parameter")
func test_skip_with_reason(skip := "Not implemented yet") -> void:
    # This test will be skipped with reason
    pass
```

## Test Organization

```gdscript
# Group related tests with descriptive names
func test_player_movement_forward() -> void:
    pass

func test_player_movement_backward() -> void:
    pass

func test_player_movement_strafe_left() -> void:
    pass

func test_player_movement_strafe_right() -> void:
    pass
```

## Property-Based Testing Pattern

```gdscript
func test_property_holds_for_all_inputs() -> void:
    # Run many iterations
    for i in range(100):
        # Generate random input
        var input = Fuzzers.rangei(1, 1000)
        
        # Perform operation
        var result = my_function(input)
        
        # Verify property holds
        assert_bool(result >= 0).is_true()
```

## Common Patterns

### Testing Node Creation
```gdscript
func test_node_creation() -> void:
    var node = Node.new()
    assert_object(node).is_not_null()
    assert_object(node).is_instanceof(Node)
    node.free()
```

### Testing Scene Instantiation
```gdscript
func test_scene_instantiation() -> void:
    var scene = load("res://scenes/my_scene.tscn").instantiate()
    assert_object(scene).is_not_null()
    scene.free()
```

### Testing Signal Emission
```gdscript
func test_signal_emission() -> void:
    var emitter = Node.new()
    emitter.add_user_signal("my_signal")
    
    var monitor = monitor_signals(emitter)
    emitter.emit_signal("my_signal")
    
    assert_signal(monitor).is_emitted("my_signal")
    emitter.free()
```

### Testing State Changes
```gdscript
func test_state_change() -> void:
    var obj = MyStateMachine.new()
    assert_that(obj.state).is_equal("idle")
    
    obj.change_state("running")
    assert_that(obj.state).is_equal("running")
    
    obj.free()
```

### Testing Error Conditions
```gdscript
func test_error_handling() -> void:
    var obj = MyClass.new()
    
    # Should not throw error
    obj.safe_method()
    
    # Should handle invalid input gracefully
    var result = obj.method_with_validation(null)
    assert_that(result).is_null()
    
    obj.free()
```

## Running Tests

### From Editor
- Right-click test file → "Run Test(s)"
- Right-click test function → "Run Test(s)"
- GdUnit Inspector → "Run All Tests"

### From Command Line
```bash
# Run all tests
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/

# Run specific suite
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite tests/unit/test_my_class.gd
```

## Tips

1. **Name tests descriptively**: `test_player_takes_damage_reduces_health()`
2. **One assertion per test**: Focus on testing one thing
3. **Use before_test/after_test**: Set up and clean up properly
4. **Free created nodes**: Always call `.free()` on created nodes
5. **Test edge cases**: Empty, null, boundary values
6. **Use property-based testing**: For universal properties
7. **Document complex tests**: Add comments explaining why
8. **Keep tests fast**: Avoid unnecessary waits
9. **Test behavior, not implementation**: Focus on what, not how
10. **Run tests frequently**: Catch issues early

## Resources

- **Full Documentation**: https://mikeschulze.github.io/gdUnit4/
- **GitHub**: https://github.com/MikeSchulze/gdUnit4
- **API Reference**: In official documentation
- **Examples**: `tests/unit/test_gdunit_verification.gd`

---

**Quick Start**: Create a test file extending `GdUnitTestSuite`, add functions starting with `test_`, use assertions, run from editor!
