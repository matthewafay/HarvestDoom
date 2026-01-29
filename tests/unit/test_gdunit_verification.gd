# GdUnit generated TestSuite
# This test suite verifies that GdUnit4 is properly installed and configured
# for the Arcade FPS Farming Game project.
#
# To run this test:
# 1. Ensure GdUnit4 plugin is installed and enabled
# 2. Right-click this file in the FileSystem panel
# 3. Select "Run Test(s)" from the context menu
# 4. Check the GdUnit Inspector for results

class_name GdUnitVerificationTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://tests/unit/test_gdunit_verification.gd'

## Test that GdUnit4 basic assertions are working
func test_gdunit_basic_assertions() -> void:
	# Boolean assertions
	assert_bool(true).is_true()
	assert_bool(false).is_false()
	
	# Integer assertions
	assert_int(1 + 1).is_equal(2)
	assert_int(5).is_greater(3)
	assert_int(2).is_less(5)
	
	# String assertions
	assert_str("GdUnit4").is_not_empty()
	assert_str("Godot").contains("dot")
	assert_str("test").has_length(4)

## Test that we can create and verify arrays
func test_array_assertions() -> void:
	var test_array = [1, 2, 3, 4, 5]
	
	# Array content assertions
	assert_array(test_array).contains([1, 2, 3])
	assert_array(test_array).has_size(5)
	assert_array(test_array).is_not_empty()
	
	# Array element assertions
	assert_that(test_array[0]).is_equal(1)
	assert_that(test_array[4]).is_equal(5)

## Test that we can create and verify dictionaries
func test_dictionary_assertions() -> void:
	var test_dict = {
		"name": "Arcade FPS Farming Game",
		"version": "0.1.0",
		"engine": "Godot",
		"framework": "GdUnit4"
	}
	
	# Dictionary structure assertions
	assert_dict(test_dict).contains_keys(["name", "version", "engine", "framework"])
	assert_dict(test_dict).has_size(4)
	assert_dict(test_dict).is_not_empty()
	
	# Dictionary value assertions
	assert_that(test_dict["name"]).is_equal("Arcade FPS Farming Game")
	assert_that(test_dict["engine"]).is_equal("Godot")

## Test that we can verify object types
func test_object_type_assertions() -> void:
	var node = Node.new()
	var node2d = Node2D.new()
	var node3d = Node3D.new()
	
	# Type assertions
	assert_object(node).is_not_null()
	assert_object(node).is_instanceof(Node)
	assert_object(node2d).is_instanceof(Node2D)
	assert_object(node3d).is_instanceof(Node3D)
	
	# Cleanup
	node.free()
	node2d.free()
	node3d.free()

## Test that we can verify floating point numbers
func test_float_assertions() -> void:
	var pi_approx = 3.14159
	var e_approx = 2.71828
	
	# Float assertions with tolerance
	assert_float(pi_approx).is_equal_approx(3.14, 0.01)
	assert_float(e_approx).is_equal_approx(2.72, 0.01)
	assert_float(pi_approx).is_greater(3.0)
	assert_float(e_approx).is_less(3.0)

## Test that we can verify Vector2 and Vector3
func test_vector_assertions() -> void:
	var vec2 = Vector2(1.0, 2.0)
	var vec3 = Vector3(1.0, 2.0, 3.0)
	
	# Vector2 assertions
	assert_that(vec2.x).is_equal(1.0)
	assert_that(vec2.y).is_equal(2.0)
	
	# Vector3 assertions
	assert_that(vec3.x).is_equal(1.0)
	assert_that(vec3.y).is_equal(2.0)
	assert_that(vec3.z).is_equal(3.0)

## Test that test lifecycle methods work
func before_test() -> void:
	# This runs before each test
	pass

func after_test() -> void:
	# This runs after each test
	pass

## Test that we can use test parameters (parameterized testing)
@warning_ignore("unused_parameter")
func test_parameterized_example(value: int, expected: int, test_parameters := [
	[1, 1],
	[2, 2],
	[3, 3],
	[5, 5]
]) -> void:
	assert_int(value).is_equal(expected)

## Test that we can verify signals
func test_signal_verification() -> void:
	var node = Node.new()
	
	# Add a custom signal
	node.add_user_signal("test_signal")
	
	# Monitor the signal
	var signal_monitor = monitor_signals(node)
	
	# Emit the signal
	node.emit_signal("test_signal")
	
	# Verify signal was emitted
	assert_signal(signal_monitor).is_emitted("test_signal")
	
	# Cleanup
	node.free()

## Test that we can use fuzzer for random testing
func test_fuzzer_example() -> void:
	# Generate random integers
	var random_int = Fuzzers.rangei(1, 100)
	assert_int(random_int).is_between(1, 100)
	
	# Generate random strings
	var random_string = Fuzzers.random_string(10)
	assert_str(random_string).has_length(10)

## Test that async operations work (if needed for future tests)
func test_await_example() -> void:
	# Create a timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.start()
	
	# Wait for timeout signal
	await timer.timeout
	
	# Verify timer finished
	assert_bool(timer.is_stopped()).is_true()
	
	# Cleanup
	timer.queue_free()
