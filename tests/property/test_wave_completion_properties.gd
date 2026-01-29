extends GdUnitTestSuite
## Property-Based Tests for Wave Completion Logic
##
## Tests Property 8: Combat Zone Wave Completion
## **Validates: Requirements 8.4**
##
## Property: Wave completion occurs if and only if all enemies in the current wave
## are defeated. Run completion occurs if and only if all waves are completed.

const ITERATIONS = 100

# Helper function to create a mock enemy
class MockEnemy extends EnemyBase:
	func _init() -> void:
		super._init()
		max_health = 100
		current_health = 100
	
	func set_dead(dead: bool) -> void:
		is_dead = dead
		if dead:
			current_health = 0
		else:
			current_health = max_health
	
	# Override to prevent automatic player finding
	func _find_player() -> void:
		pass
	
	# Override to prevent sprite generation
	func _apply_procedural_sprite() -> void:
		pass

func before_test() -> void:
	# Ensure GameManager is available
	if not Engine.has_singleton("GameManager"):
		assert_that(false).is_true().override_failure_message("GameManager singleton not found")

func test_property_wave_not_complete_with_alive_enemies() -> void:
	"""Property: Wave does not complete while any enemy has health > 0."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Generate random number of enemies (1-10)
		var enemy_count = randi_range(1, 10)
		
		# Add enemies to active_enemies array
		for j in range(enemy_count):
			var enemy = MockEnemy.new()
			arena.active_enemies.append(enemy)
			arena.add_child(enemy)
		
		# Randomly kill some enemies, but leave at least one alive
		var alive_count = randi_range(1, enemy_count)
		for j in range(enemy_count - alive_count):
			arena.active_enemies[j].set_dead(true)
		
		# Verify wave is NOT complete (at least one enemy alive)
		var wave_complete = arena.is_wave_complete()
		assert_that(wave_complete).is_false()
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_wave_completes_when_all_enemies_dead() -> void:
	"""Property: Wave completes immediately when last enemy dies."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Generate random number of enemies (1-10)
		var enemy_count = randi_range(1, 10)
		
		# Add enemies to active_enemies array
		for j in range(enemy_count):
			var enemy = MockEnemy.new()
			arena.active_enemies.append(enemy)
			arena.add_child(enemy)
		
		# Kill all enemies
		for enemy in arena.active_enemies:
			enemy.set_dead(true)
		
		# Verify wave IS complete (all enemies dead)
		var wave_complete = arena.is_wave_complete()
		assert_that(wave_complete).is_true()
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_wave_complete_with_no_enemies() -> void:
	"""Property: Wave is complete when there are no enemies."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# No enemies in active_enemies array
		arena.active_enemies.clear()
		
		# Verify wave IS complete (no enemies)
		var wave_complete = arena.is_wave_complete()
		assert_that(wave_complete).is_true()
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_run_not_complete_before_all_waves() -> void:
	"""Property: Run does not complete until all waves are finished."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Set total waves
		arena.total_waves = randi_range(3, 10)
		
		# Set current wave to less than total (not at final wave)
		arena.current_wave = randi_range(1, arena.total_waves - 1)
		
		# Clear all enemies (wave is complete)
		arena.active_enemies.clear()
		
		# Mark wave as complete but not run
		arena.wave_complete_emitted = true
		arena.run_completed = false
		
		# Verify run is NOT complete (more waves remaining)
		var run_complete = arena.is_run_complete()
		assert_that(run_complete).is_false()
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_run_completes_after_final_wave() -> void:
	"""Property: Run completes if and only if all waves are completed."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Set total waves
		arena.total_waves = randi_range(3, 10)
		
		# Set current wave to final wave
		arena.current_wave = arena.total_waves
		
		# Clear all enemies (final wave is complete)
		arena.active_enemies.clear()
		
		# Mark run as completed
		arena.run_completed = true
		arena.wave_complete_emitted = true
		
		# Verify run IS complete (all waves done)
		var run_complete = arena.is_run_complete()
		assert_that(run_complete).is_true()
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_wave_completion_signal_emitted_once() -> void:
	"""Property: wave_completed signal is emitted exactly once per wave."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Disable auto-progression to control wave spawning
		arena.set_auto_progress(false)
		
		# Generate arena and spawn first wave
		arena.generate_arena(randi())
		arena.spawn_wave(1)
		
		# Track signal emissions
		var signal_count = 0
		var signal_callback = func(wave_num: int):
			signal_count += 1
		
		arena.wave_completed.connect(signal_callback)
		
		# Kill all enemies
		for enemy in arena.active_enemies:
			if is_instance_valid(enemy):
				enemy.take_damage(enemy.max_health)
		
		# Process multiple frames to allow signal emission
		for j in range(10):
			arena._process(0.016)  # Simulate 60 FPS
			await get_tree().process_frame
		
		# Verify signal was emitted exactly once
		assert_that(signal_count).is_equal(1)
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_arena_completion_signal_emitted_once() -> void:
	"""Property: arena_completed signal is emitted exactly once per run."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Disable auto-progression
		arena.set_auto_progress(false)
		
		# Set to single wave for faster testing
		arena.total_waves = 1
		
		# Generate arena and spawn wave
		arena.generate_arena(randi())
		arena.spawn_wave(1)
		
		# Track signal emissions
		var signal_count = 0
		var signal_callback = func():
			signal_count += 1
		
		arena.arena_completed.connect(signal_callback)
		
		# Kill all enemies
		for enemy in arena.active_enemies:
			if is_instance_valid(enemy):
				enemy.take_damage(enemy.max_health)
		
		# Process multiple frames to allow signal emission
		for j in range(10):
			arena._process(0.016)
			await get_tree().process_frame
		
		# Verify signal was emitted exactly once
		assert_that(signal_count).is_equal(1)
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_next_wave_spawns_only_after_current_complete() -> void:
	"""Property: Next wave spawns only after current wave completion."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Enable auto-progression with short delay
		arena.set_auto_progress(true)
		arena.set_wave_transition_delay(0.1)
		
		# Set multiple waves
		arena.total_waves = randi_range(2, 5)
		
		# Generate arena and spawn first wave
		arena.generate_arena(randi())
		arena.spawn_wave(1)
		
		var initial_wave = arena.current_wave
		var initial_enemy_count = arena.active_enemies.size()
		
		# Verify we're on wave 1
		assert_that(initial_wave).is_equal(1)
		assert_that(initial_enemy_count).is_greater(0)
		
		# Kill all enemies in current wave
		for enemy in arena.active_enemies:
			if is_instance_valid(enemy):
				enemy.take_damage(enemy.max_health)
		
		# Process frames to trigger wave completion and transition
		for j in range(20):
			arena._process(0.016)
			await get_tree().process_frame
		
		# Verify we progressed to next wave
		assert_that(arena.current_wave).is_greater(initial_wave)
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_wave_complete_flag_resets_on_new_wave() -> void:
	"""Property: wave_complete_emitted flag resets when spawning new wave."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Disable auto-progression
		arena.set_auto_progress(false)
		
		# Generate arena
		arena.generate_arena(randi())
		
		# Spawn first wave
		arena.spawn_wave(1)
		
		# Manually set wave_complete_emitted to true
		arena.wave_complete_emitted = true
		
		# Spawn next wave
		arena.spawn_wave(2)
		
		# Verify flag was reset
		assert_that(arena.wave_complete_emitted).is_false()
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_run_completion_requires_wave_completion() -> void:
	"""Property: Run cannot complete if current wave is not complete."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Set to final wave
		arena.total_waves = randi_range(3, 5)
		arena.current_wave = arena.total_waves
		
		# Add at least one alive enemy
		var enemy = MockEnemy.new()
		arena.active_enemies.append(enemy)
		arena.add_child(enemy)
		enemy.set_dead(false)
		
		# Mark run as "completed" but wave is not actually complete
		arena.run_completed = true
		
		# Verify run is NOT complete (wave still has enemies)
		var run_complete = arena.is_run_complete()
		assert_that(run_complete).is_false()
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_active_enemies_cleaned_on_wave_complete_check() -> void:
	"""Property: is_wave_complete() removes invalid/dead enemies from active_enemies."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Add mix of alive and dead enemies
		var total_enemies = randi_range(5, 10)
		var dead_count = randi_range(1, total_enemies - 1)
		
		for j in range(total_enemies):
			var enemy = MockEnemy.new()
			arena.active_enemies.append(enemy)
			arena.add_child(enemy)
			
			# Mark some as dead
			if j < dead_count:
				enemy.set_dead(true)
		
		var initial_count = arena.active_enemies.size()
		
		# Call is_wave_complete (should clean up dead enemies)
		var wave_complete = arena.is_wave_complete()
		
		# Verify dead enemies were removed from array
		var remaining_count = arena.active_enemies.size()
		assert_that(remaining_count).is_less(initial_count)
		assert_that(remaining_count).is_equal(total_enemies - dead_count)
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func test_property_wave_completion_deterministic() -> void:
	"""Property: Wave completion state is deterministic based on enemy states."""
	
	for i in range(ITERATIONS):
		var arena = ArenaGenerator.new()
		add_child(arena)
		
		# Add random number of enemies with random states
		var enemy_count = randi_range(1, 10)
		var alive_count = randi_range(0, enemy_count)
		
		for j in range(enemy_count):
			var enemy = MockEnemy.new()
			arena.active_enemies.append(enemy)
			arena.add_child(enemy)
			
			# Set dead/alive state
			enemy.set_dead(j >= alive_count)
		
		# Check wave completion multiple times
		var result1 = arena.is_wave_complete()
		var result2 = arena.is_wave_complete()
		var result3 = arena.is_wave_complete()
		
		# All results should be identical (deterministic)
		assert_that(result1).is_equal(result2)
		assert_that(result2).is_equal(result3)
		
		# Result should match expected (complete if no alive enemies)
		var expected = (alive_count == 0)
		assert_that(result1).is_equal(expected)
		
		# Cleanup
		remove_child(arena)
		arena.queue_free()

func after_test() -> void:
	# Cleanup
	pass
