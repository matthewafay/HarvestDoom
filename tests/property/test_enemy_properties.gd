extends GdUnitTestSuite
## Property-Based Tests for Enemy Behavior
##
## Tests Property 3: Enemy Behavior Determinism
## Validates: Requirements 3.1, 3.2, 3.3, 3.4

const ITERATIONS = 100

func before_test() -> void:
	# Reset GameManager inventory
	GameManager.inventory = {"credits": 0}

func test_property_enemies_always_drop_loot_on_death() -> void:
	"""Property: All enemies spawn loot when health reaches 0."""
	for i in range(ITERATIONS):
		var enemy = EnemyBase.new()
		add_child(enemy)
		
		enemy.loot_drop = {"credits": randi_range(5, 20)}
		var initial_credits = GameManager.get_inventory_amount("credits")
		
		# Kill enemy
		enemy.current_health = 1
		enemy.take_damage(10)
		
		# Loot should be added
		assert_that(GameManager.get_inventory_amount("credits")).is_greater(initial_credits)
		
		remove_child(enemy)

func test_property_melee_charger_always_moves_toward_player() -> void:
	"""Property: MeleeCharger always moves directly toward player when detected."""
	for i in range(ITERATIONS):
		var charger = MeleeCharger.new()
		add_child(charger)
		
		# Create mock player
		var mock_player = Node3D.new()
		mock_player.global_position = Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
		add_child(mock_player)
		
		charger.target = mock_player
		charger._update_ai(0.016)  # One frame
		
		# Velocity should point toward player
		var direction_to_player = (mock_player.global_position - charger.global_position).normalized()
		var velocity_direction = Vector2(charger.velocity.x, charger.velocity.z).normalized()
		var expected_direction = Vector2(direction_to_player.x, direction_to_player.z).normalized()
		
		# Directions should be similar (allowing for small floating point errors)
		if velocity_direction.length() > 0:
			var dot_product = velocity_direction.dot(expected_direction)
			assert_that(dot_product).is_greater(0.9)  # Nearly parallel
		
		remove_child(mock_player)
		mock_player.queue_free()
		remove_child(charger)
		charger.queue_free()

func test_property_tank_continues_advancing_when_damaged() -> void:
	"""Property: TankEnemy continues advancing when damaged."""
	for i in range(ITERATIONS):
		var tank = TankEnemy.new()
		add_child(tank)
		
		# Create mock player
		var mock_player = Node3D.new()
		mock_player.global_position = Vector3(10, 0, 0)
		add_child(mock_player)
		
		tank.target = mock_player
		
		# Update AI before damage
		tank._update_ai(0.016)
		var velocity_before = tank.velocity
		
		# Take damage
		tank.take_damage(50)
		
		# Update AI after damage
		tank._update_ai(0.016)
		var velocity_after = tank.velocity
		
		# Should still be moving (not stunned or knocked back)
		if not tank.is_dead:
			assert_that(Vector2(velocity_after.x, velocity_after.z).length()).is_greater(0.0)
		
		remove_child(mock_player)
		mock_player.queue_free()
		remove_child(tank)
		tank.queue_free()

func test_property_enemy_health_never_negative() -> void:
	"""Property: Enemy health never goes below 0."""
	for i in range(ITERATIONS):
		var enemy = EnemyBase.new()
		add_child(enemy)
		
		enemy.current_health = randi_range(10, 50)
		var overkill_damage = enemy.current_health + randi_range(100, 500)
		
		enemy.take_damage(overkill_damage)
		
		# Health should be 0, not negative
		assert_that(enemy.current_health).is_greater_equal(0)
		
		remove_child(enemy)

func test_property_dead_enemies_dont_take_damage() -> void:
	"""Property: Dead enemies don't process further damage."""
	for i in range(ITERATIONS):
		var enemy = EnemyBase.new()
		add_child(enemy)
		
		# Kill enemy
		enemy.current_health = 1
		enemy.take_damage(10)
		
		var health_after_death = enemy.current_health
		
		# Try to damage again
		enemy.take_damage(100)
		
		# Health shouldn't change
		assert_that(enemy.current_health).is_equal(health_after_death)
		
		remove_child(enemy)

func test_property_loot_amount_matches_definition() -> void:
	"""Property: Loot dropped matches loot_drop dictionary."""
	for i in range(ITERATIONS):
		var enemy = EnemyBase.new()
		add_child(enemy)
		
		var loot_amount = randi_range(10, 100)
		enemy.loot_drop = {"credits": loot_amount}
		
		var initial_credits = GameManager.get_inventory_amount("credits")
		
		# Kill enemy
		enemy.current_health = 1
		enemy.take_damage(10)
		
		# Exact loot amount should be added
		assert_that(GameManager.get_inventory_amount("credits")).is_equal(initial_credits + loot_amount)
		
		remove_child(enemy)
		
		# Reset for next iteration
		GameManager.inventory["credits"] = 0

func test_property_enemy_move_speed_positive() -> void:
	"""Property: All enemies have positive move speed."""
	var enemy_types = [EnemyBase.new(), MeleeCharger.new(), RangedShooter.new(), TankEnemy.new()]
	
	for enemy in enemy_types:
		assert_that(enemy.move_speed).is_greater(0.0)
		enemy.queue_free()

func test_property_enemy_damage_positive() -> void:
	"""Property: All enemies have positive damage values."""
	var enemy_types = [EnemyBase.new(), MeleeCharger.new(), RangedShooter.new(), TankEnemy.new()]
	
	for enemy in enemy_types:
		assert_that(enemy.damage).is_greater(0)
		enemy.queue_free()

func after_test() -> void:
	# Reset GameManager
	GameManager.inventory = {"credits": 0}
