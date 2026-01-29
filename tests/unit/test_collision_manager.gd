extends GdUnitTestSuite
## Unit tests for CollisionManager

func test_collision_manager_exists() -> void:
	var collision_mgr = CollisionManager.new()
	assert_that(collision_mgr).is_not_null()
	collision_mgr.queue_free()

func test_layer_constants() -> void:
	assert_that(CollisionManager.LAYER_PLAYER).is_equal(1)
	assert_that(CollisionManager.LAYER_ENEMY).is_equal(2)
	assert_that(CollisionManager.LAYER_PROJECTILE).is_equal(4)
	assert_that(CollisionManager.LAYER_ENVIRONMENT).is_equal(8)
	assert_that(CollisionManager.LAYER_INTERACTIVE).is_equal(16)

func test_setup_player_collision() -> void:
	var collision_mgr = CollisionManager.new()
	var player = CharacterBody3D.new()
	
	collision_mgr.setup_player_collision(player)
	
	assert_that(player.collision_layer).is_equal(CollisionManager.LAYER_PLAYER)
	assert_that(player.collision_mask).is_equal(CollisionManager.LAYER_ENEMY | CollisionManager.LAYER_ENVIRONMENT)
	
	player.queue_free()
	collision_mgr.queue_free()

func test_setup_enemy_collision() -> void:
	var collision_mgr = CollisionManager.new()
	var enemy = CharacterBody3D.new()
	
	collision_mgr.setup_enemy_collision(enemy)
	
	assert_that(enemy.collision_layer).is_equal(CollisionManager.LAYER_ENEMY)
	assert_that(enemy.collision_mask).is_equal(CollisionManager.LAYER_PLAYER | CollisionManager.LAYER_ENVIRONMENT)
	
	enemy.queue_free()
	collision_mgr.queue_free()

func test_setup_projectile_collision() -> void:
	var collision_mgr = CollisionManager.new()
	var projectile = Area3D.new()
	
	collision_mgr.setup_projectile_collision(projectile)
	
	assert_that(projectile.collision_layer).is_equal(CollisionManager.LAYER_PROJECTILE)
	assert_that(projectile.collision_mask).is_equal(CollisionManager.LAYER_ENEMY | CollisionManager.LAYER_ENVIRONMENT)
	
	projectile.queue_free()
	collision_mgr.queue_free()

func test_setup_interactive_collision() -> void:
	var collision_mgr = CollisionManager.new()
	var interactive = Area3D.new()
	
	collision_mgr.setup_interactive_collision(interactive)
	
	assert_that(interactive.collision_layer).is_equal(CollisionManager.LAYER_INTERACTIVE)
	assert_that(interactive.collision_mask).is_equal(CollisionManager.LAYER_PLAYER)
	
	interactive.queue_free()
	collision_mgr.queue_free()

func test_get_layer_name() -> void:
	var collision_mgr = CollisionManager.new()
	
	assert_that(collision_mgr.get_layer_name(CollisionManager.LAYER_PLAYER)).is_equal("Player")
	assert_that(collision_mgr.get_layer_name(CollisionManager.LAYER_ENEMY)).is_equal("Enemy")
	assert_that(collision_mgr.get_layer_name(CollisionManager.LAYER_PROJECTILE)).is_equal("Projectile")
	assert_that(collision_mgr.get_layer_name(CollisionManager.LAYER_ENVIRONMENT)).is_equal("Environment")
	assert_that(collision_mgr.get_layer_name(CollisionManager.LAYER_INTERACTIVE)).is_equal("Interactive")
	
	collision_mgr.queue_free()

func test_enemies_dont_collide_with_each_other() -> void:
	var collision_mgr = CollisionManager.new()
	var enemy = CharacterBody3D.new()
	
	collision_mgr.setup_enemy_collision(enemy)
	
	# Enemy mask should NOT include LAYER_ENEMY
	var has_enemy_mask = (enemy.collision_mask & CollisionManager.LAYER_ENEMY) != 0
	assert_that(has_enemy_mask).is_false()
	
	enemy.queue_free()
	collision_mgr.queue_free()
