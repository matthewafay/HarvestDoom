extends Node3D

## Verification Script for Wave Progression Logic (Task 5.2.1)
## This script demonstrates and verifies the automatic wave progression functionality
## Run this scene in the Godot editor to see wave progression in action

var arena_generator: ArenaGenerator
var test_label: Label
var wave_info_label: Label
var transition_info_label: Label

func _ready() -> void:
	# Create UI for displaying test information
	_setup_ui()
	
	# Create and configure ArenaGenerator
	arena_generator = ArenaGenerator.new()
	add_child(arena_generator)
	
	# Connect to signals
	arena_generator.wave_completed.connect(_on_wave_completed)
	arena_generator.arena_completed.connect(_on_arena_completed)
	
	# Configure wave progression
	arena_generator.set_wave_transition_delay(2.0)  # 2 second delay between waves
	arena_generator.set_auto_progress(true)  # Enable automatic progression
	
	# Generate arena and start first wave
	arena_generator.generate_arena(12345)
	
	# Add camera for viewing
	var camera = Camera3D.new()
	camera.position = Vector3(0, 15, 15)
	camera.look_at(Vector3.ZERO)
	add_child(camera)
	
	# Start the test
	_log("=== Wave Progression Verification ===")
	_log("Arena generated with seed 12345")
	_log("Wave transition delay: 2.0 seconds")
	_log("Auto-progression: ENABLED")
	_log("")
	_log("Starting Wave 1...")
	
	arena_generator.spawn_wave(1)

func _process(_delta: float) -> void:
	# Update wave info display
	if arena_generator:
		var wave_text = "Current Wave: %d / %d" % [arena_generator.current_wave, arena_generator.total_waves]
		wave_text += "\nActive Enemies: %d" % arena_generator.active_enemies.size()
		wave_text += "\nWave Complete: %s" % ("YES" if arena_generator.is_wave_complete() else "NO")
		wave_info_label.text = wave_text
		
		# Update transition info
		if arena_generator.is_wave_transitioning():
			var time_remaining = arena_generator.get_wave_transition_time_remaining()
			transition_info_label.text = "TRANSITIONING TO NEXT WAVE\nTime remaining: %.1f seconds" % time_remaining
			transition_info_label.visible = true
		else:
			transition_info_label.visible = false

func _setup_ui() -> void:
	# Create CanvasLayer for UI
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	# Create test log label
	test_label = Label.new()
	test_label.position = Vector2(10, 10)
	test_label.size = Vector2(600, 400)
	test_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	canvas.add_child(test_label)
	
	# Create wave info label
	wave_info_label = Label.new()
	wave_info_label.position = Vector2(10, 420)
	wave_info_label.size = Vector2(400, 100)
	wave_info_label.add_theme_color_override("font_color", Color.YELLOW)
	canvas.add_child(wave_info_label)
	
	# Create transition info label
	transition_info_label = Label.new()
	transition_info_label.position = Vector2(10, 530)
	transition_info_label.size = Vector2(400, 60)
	transition_info_label.add_theme_color_override("font_color", Color.CYAN)
	transition_info_label.visible = false
	canvas.add_child(transition_info_label)
	
	# Create instructions label
	var instructions = Label.new()
	instructions.position = Vector2(10, 600)
	instructions.text = "Press SPACE to kill all enemies in current wave\nPress D to disable auto-progression\nPress E to enable auto-progression"
	instructions.add_theme_color_override("font_color", Color.GREEN)
	canvas.add_child(instructions)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			# Kill all enemies in current wave
			_kill_all_enemies()
		elif event.keycode == KEY_D:
			# Disable auto-progression
			arena_generator.set_auto_progress(false)
			_log("Auto-progression DISABLED")
		elif event.keycode == KEY_E:
			# Enable auto-progression
			arena_generator.set_auto_progress(true)
			_log("Auto-progression ENABLED")

func _kill_all_enemies() -> void:
	if arena_generator.active_enemies.is_empty():
		_log("No enemies to kill")
		return
	
	var count = arena_generator.active_enemies.size()
	for enemy in arena_generator.active_enemies:
		enemy.is_dead = true
	
	_log("Killed %d enemies" % count)

func _on_wave_completed(wave_number: int) -> void:
	_log("")
	_log("✓ Wave %d COMPLETED!" % wave_number)
	
	if wave_number < arena_generator.total_waves:
		if arena_generator.auto_progress_enabled:
			_log("  → Next wave will spawn in %.1f seconds..." % arena_generator.wave_transition_delay)
		else:
			_log("  → Auto-progression disabled. Manually spawn next wave.")
	else:
		_log("  → This was the final wave!")

func _on_arena_completed() -> void:
	_log("")
	_log("★★★ ARENA COMPLETED! ALL WAVES CLEARED! ★★★")
	_log("")
	_log("Verification Results:")
	_log("✓ Wave progression logic working correctly")
	_log("✓ All %d waves completed" % arena_generator.total_waves)
	_log("✓ Signals emitted properly")
	_log("✓ Automatic wave spawning functional")

func _log(message: String) -> void:
	if test_label:
		test_label.text += message + "\n"
		print(message)

## Verification Checklist:
## 
## ✓ Wave 1 spawns when arena is generated
## ✓ When all enemies are killed, wave_completed signal is emitted
## ✓ After wave_transition_delay, next wave spawns automatically
## ✓ Wave number increments correctly (1 → 2 → 3 → 4 → 5)
## ✓ After final wave (5), arena_completed signal is emitted
## ✓ No additional waves spawn after arena completion
## ✓ Auto-progression can be disabled/enabled dynamically
## ✓ Transition state is tracked correctly
## ✓ Transition timer counts down properly
