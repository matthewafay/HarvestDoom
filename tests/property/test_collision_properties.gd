extends GdUnitTestSuite
## Property-Based Tests for Collision Detection
##
## Tests Property 12: Collision Detection Correctness
## Validates: Requirements 1.5, 2.3, 3.5

const ITERATIONS = 100

func test_property_player_collides_with_environment() -> void:
	"""Property: Player collision mask includes environment."""
	var collision_mgr = CollisionManager.new()
	
	for i in range(ITERATIONS):
		var player = CharacterBody3D.new()
		collision_mgr.setup_player_collision(player)
		
		var has_environment_mask = (player.collision_mask & CollisionManager.LAYER_ENVIRONMENT) != 0
		assert_that(has_environment_mask).is_true()
		
		player.queue_free()
	
	collision_mgr.queue_free()

func test_property_player_collides_with_enemies() -> void:
	"""Property: Player collision mask includes enemies."""
	var collision_mgr = CollisionManager.new()
	
	for i in range(ITERATIONS):
		var player = CharacterBody3D.new()
		collision_mgr.setup_player_collision(player)
		
		var has_enemy_mask = (player.collision_mask & CollisionManager.LAYER_ENEMY) != 0
		assert_that(has_enemy_mask).is_true()
		
		player.queue_free()
	
	collision_mgr.queue_free()

func test_property_projectiles_collide_with_enemies() -> void:
	"""Property: Projectile collision mask includes enemies."""
	var collision_mgr = CollisionManager.new()
	
	for i in range(ITERATIONS):
		var projectile = Area3D.new()
		collision_mgr.setup_projectile_collision(projectile)
		
		var has_enemy_mask = (projectile.collision_mask & CollisionManager.LAYER_ENEMY) != 0
		assert_that(has_enemy_mask).is_true()
		
		projectile.queue_free()
	
	collision_mgr.queue_free()

func test_property_projectiles_collide_with_environment() -> void:
	"""Property: Projectile collision mask includes environment."""
	var collision_mgr = CollisionManager.new()
	
	for i in range(ITERATIONS):
		var projectile = Area3D.new()
		collision_mgr.setup_projectile_collision(projectile)
		
		var has_environment_mask = (projectile.collision_mask & CollisionManager.LAYER_ENVIRONMENT) != 0
		assert_that(has_environment_mask).is_true()
		
		projectile.queue_free()
	
	collision_mgr.queue_free()

func test_property_enemies_dont_collide_with_enemies() -> void:
	"""Property: Enemies do not collide with other enemies."""
	var collision_mgr = CollisionManager.new()
	
	for i in range(ITERATIONS):
		var enemy = CharacterBody3D.new()
		collision_mgr.setup_enemy_collision(enemy)
		
		var has_enemy_mask = (enemy.collision_mask & CollisionManager.LAYER_ENEMY) != 0
		assert_that(has_enemy_mask).is_false()
		
		enemy.queue_free()
	
	collision_mgr.queue_free()

func test_property_enemies_collide_with_player() -> void:
	"""Property: Enemy collision mask includes player."""
	var collision_mgr = CollisionManager.new()
	
	for i in range(ITERATIONS):
		var enemy = CharacterBody3D.new()
		collision_mgr.setup_enemy_collision(enemy)
		
		var has_player_mask = (enemy.collision_mask & CollisionManager.LAYER_PLAYER) != 0
		assert_that(has_player_mask).is_true()
		
		enemy.queue_free()
	
	collision_mgr.queue_free()

func test_property_collision_layers_are_unique() -> void:
	"""Property: All collision layer constants are unique powers of 2."""
	var layers = [
		CollisionManager.LAYER_PLAYER,
		CollisionManager.LAYER_ENEMY,
		CollisionManager.LAYER_PROJECTILE,
		CollisionManager.LAYER_ENVIRONMENT,
		CollisionManager.LAYER_INTERACTIVE
	]
	
	# Check all are powers of 2
	for layer in layers:
		var is_power_of_two = (layer & (layer - 1)) == 0 and layer != 0
		assert_that(is_power_of_two).is_true()
	
	# Check all are unique
	for i in range(layers.size()):
		for j in range(i + 1, layers.size()):
			assert_that(layers[i]).is_not_equal(layers[j])

func test_property_interactive_detects_player() -> void:
	"""Property: Interactive objects detect player."""
	var collision_mgr = CollisionManager.new()
	
	for i in range(ITERATIONS):
		var interactive = Area3D.new()
		collision_mgr.setup_interactive_collision(interactive)
		
		var has_player_mask = (interactive.collision_mask & CollisionManager.LAYER_PLAYER) != 0
		assert_that(has_player_mask).is_true()
		
		interactive.queue_free()
	
	collision_mgr.queue_free()

func test_property_layer_setup_is_idempotent() -> void:
	"""Property: Setting up collision multiple times produces same result."""
	var collision_mgr = CollisionManager.new()
	
	for i in range(ITERATIONS):
		var player = CharacterBody3D.new()
		
		# Setup multiple times
		collision_mgr.setup_player_collision(player)
		var first_layer = player.collision_layer
		var first_mask = player.collision_mask
		
		collision_mgr.setup_player_collision(player)
		var second_layer = player.collision_layer
		var second_mask = player.collision_mask
		
		# Should be identical
		assert_that(second_layer).is_equal(first_layer)
		assert_that(second_mask).is_equal(first_mask)
		
		player.queue_free()
	
	collision_mgr.queue_free()
