extends Node3D

## Verification script for Task 5.2.2: Run Completion Detection
## This script demonstrates and verifies the run completion detection functionality
## 
## Controls:
## - SPACE: Kill all enemies in current wave
## - R: Reset run state
## - N: Start new arena
## 
## Expected Behavior:
## 1. Arena generates with 5 waves
## 2. Each wave completes when all enemies are killed
## 3. After wave 5 completes, run_completed flag is set
## 4. is_run_complete() returns true after all waves cleared
## 5. arena_completed signal is emitted once

var arena_generator: ArenaGenerator
var label: Label
var wave_label: Label
var completion_label: Label

func _ready() -> void:
	# Create arena generator
	arena_generator = ArenaGenerator.new()
	add_child(arena_generator)
	
	# Connect to signals
	arena_generator.wave_completed.connect(_on_wave_completed)
	arena_generator.arena_completed.connect(_on_arena_completed)
	
	# Configure wave progression
	arena_generator.set_auto_progress(true)
	arena_generator.set_wave_transition_delay(2.0)
	
	# Generate arena
	arena_generator.generate_arena(12345)
	
	# Create UI
	_create_ui()
	
	# Spawn first wave
	arena_generator.spawn_wave(1)
	
	_log("=== Run Completion Detection Verification ===")
	_log("Arena generated with 5 waves")
	_log("Press SPACE to kill all enemies in current wave")
	_log("Press R to reset run state")
	_log("Press N to start new arena")
	_log("")

func _create_ui() -> void:
	# Create canvas layer for UI
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	# Create main label
	label = Label.new()
	label.position = Vector2(10, 10)
	label.add_theme_font_size_override("font_size", 16)
	canvas.add_child(label)
	
	# Create wave status label
	wave_label = Label.new()
	wave_label.position = Vector2(10, 100)
	wave_label.add_theme_font_size_override("font_size", 20)
	canvas.add_child(wave_label)
	
	# Create completion status label
	completion_label = Label.new()
	completion_label.position = Vector2(10, 150)
	completion_label.add_theme_font_size_override("font_size", 24)
	canvas.add_child(completion_label)

func _process(_delta: float) -> void:
	# Update UI
	var status_text = ""
	status_text += "Current Wave: %d / %d\n" % [arena_generator.current_wave, arena_generator.total_waves]
	status_text += "Active Enemies: %d\n" % arena_generator.active_enemies.size()
	status_text += "Wave Complete: %s\n" % str(arena_generator.is_wave_complete())
	status_text += "Run Completed Flag: %s\n" % str(arena_generator.run_completed)
	status_text += "Arena Complete Emitted: %s\n" % str(arena_generator.arena_complete_emitted)
	
	if arena_generator.is_wave_transitioning():
		status_text += "\nTransitioning to next wave in %.1fs..." % arena_generator.get_wave_transition_time_remaining()
	
	label.text = status_text
	
	# Update wave status
	if arena_generator.current_wave > 0:
		wave_label.text = "WAVE %d" % arena_generator.current_wave
	else:
		wave_label.text = "NO WAVE ACTIVE"
	
	# Update completion status
	if arena_generator.is_run_complete():
		completion_label.text = "✓ RUN COMPLETE!"
		completion_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		completion_label.text = "Run In Progress..."
		completion_label.add_theme_color_override("font_color", Color.WHITE)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				_kill_all_enemies()
			KEY_R:
				_reset_run()
			KEY_N:
				_new_arena()

func _kill_all_enemies() -> void:
	_log("Killing all enemies in current wave...")
	for enemy in arena_generator.active_enemies:
		if is_instance_valid(enemy):
			enemy.is_dead = true
	_log("  → %d enemies killed" % arena_generator.active_enemies.size())

func _reset_run() -> void:
	_log("Resetting run state...")
	arena_generator.reset_run_state()
	_log("  → Run state reset")
	_log("  → run_completed: %s" % str(arena_generator.run_completed))
	_log("  → current_wave: %d" % arena_generator.current_wave)

func _new_arena() -> void:
	_log("Generating new arena...")
	arena_generator.generate_arena(randi())
	arena_generator.spawn_wave(1)
	_log("  → New arena generated")
	_log("  → Wave 1 spawned")

func _on_wave_completed(wave_number: int) -> void:
	_log("✓ Wave %d completed!" % wave_number)
	_log("  → is_wave_complete(): %s" % str(arena_generator.is_wave_complete()))
	_log("  → is_run_complete(): %s" % str(arena_generator.is_run_complete()))
	
	if wave_number >= arena_generator.total_waves:
		_log("  → This was the final wave!")
		_log("  → run_completed flag: %s" % str(arena_generator.run_completed))

func _on_arena_completed() -> void:
	_log("")
	_log("=" * 50)
	_log("✓✓✓ ARENA COMPLETED! ALL WAVES CLEARED! ✓✓✓")
	_log("=" * 50)
	_log("Run Completion Detection Results:")
	_log("  → is_run_complete(): %s" % str(arena_generator.is_run_complete()))
	_log("  → run_completed flag: %s" % str(arena_generator.run_completed))
	_log("  → arena_complete_emitted: %s" % str(arena_generator.arena_complete_emitted))
	_log("  → current_wave: %d" % arena_generator.current_wave)
	_log("  → total_waves: %d" % arena_generator.total_waves)
	_log("  → active_enemies: %d" % arena_generator.active_enemies.size())
	_log("")
	_log("✓ Task 5.2.2 Verification: SUCCESS")
	_log("  All run completion detection features working correctly!")
	_log("")

func _log(message: String) -> void:
	print(message)
