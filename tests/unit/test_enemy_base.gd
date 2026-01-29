extends GdUnitTestSuite
## Unit tests for EnemyBase and enemy variants

func test_enemy_base_exists() -> void:
	var enemy_script = load("res://scripts/enemies/enemy_base.gd")
	assert_that(enemy_script).is_not_null()

func test_enemy_has_health_system() -> void:
	var enemy = EnemyBase.new()
	
	assert_that(enemy.max_health).is_greater(0)
	assert_that(enemy.current_health).is_equal(enemy.max_health)
	
	enemy.queue_free()

func test_enemy_take_damage() -> void:
	var enemy = EnemyBase.new()
	add_child(enemy)
	
	var initial_health = enemy.current_health
	enemy.take_damage(20)
	
	assert_that(enemy.current_health).is_equal(initial_health - 20)
	
	remove_child(enemy)
	enemy.queue_free()

func test_enemy_dies_at_zero_health() -> void:
	var enemy = EnemyBase.new()
	add_child(enemy)
	
	var signal_monitor = monitor_signal(enemy, "died")
	
	enemy.current_health = 10
	enemy.take_damage(15)
	
	assert_signal(signal_monitor).is_emitted()
	assert_that(enemy.is_dead).is_true()
	
	remove_child(enemy)

func test_enemy_drops_loot_on_death() -> void:
	var enemy = EnemyBase.new()
	add_child(enemy)
	
	enemy.loot_drop = {"credits": 50}
	var initial_credits = GameManager.get_inventory_amount("credits")
	
	enemy.current_health = 1
	enemy.take_damage(10)
	
	# Loot should be added to inventory
	assert_that(GameManager.get_inventory_amount("credits")).is_equal(initial_credits + 50)
	
	remove_child(enemy)

func test_melee_charger_moves_fast() -> void:
	var charger = MeleeCharger.new()
	
	assert_that(charger.charge_speed).is_greater(charger.move_speed)
	
	charger.queue_free()

func test_ranged_shooter_has_projectile() -> void:
	var shooter = RangedShooter.new()
	
	assert_that(shooter.projectile_scene).is_not_null()
	assert_that(shooter.fire_rate).is_greater(0.0)
	
	shooter.queue_free()

func test_tank_enemy_has_armor() -> void:
	var tank = TankEnemy.new()
	
	assert_that(tank.armor).is_greater(0)
	assert_that(tank.max_health).is_greater(100)  # Tanks have high health
	
	tank.queue_free()

func test_tank_armor_reduces_damage() -> void:
	var tank = TankEnemy.new()
	add_child(tank)
	
	tank.armor = 50  # 50% damage reduction
	var initial_health = tank.current_health
	
	tank.take_damage(100)
	
	# Should take less than 100 damage due to armor
	var damage_taken = initial_health - tank.current_health
	assert_that(damage_taken).is_less(100)
	
	remove_child(tank)
	tank.queue_free()

func test_enemy_signals_exist() -> void:
	var enemy = EnemyBase.new()
	
	assert_that(enemy.has_signal("died")).is_true()
	assert_that(enemy.has_signal("attacked_player")).is_true()
	
	enemy.queue_free()
