extends GdUnitTestSuite

## Unit tests for ProgressionManager
##
## Tests upgrade purchase logic, cost validation, and stat calculations

var progression_manager: Node
var game_manager: Node

func before_test() -> void:
	# Create mock GameManager
	game_manager = auto_free(Node.new())
	game_manager.set_script(load("res://scripts/autoload/game_manager.gd"))
	game_manager.set_name("GameManager")
	add_child(game_manager)
	
	# Create ProgressionManager
	progression_manager = auto_free(Node.new())
	progression_manager.set_script(load("res://scripts/systems/progression_manager.gd"))
	add_child(progression_manager)

func test_can_afford_upgrade_with_sufficient_credits() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 150)
	
	# Act
	var can_afford = progression_manager.can_afford_upgrade("max_health_1")
	
	# Assert
	assert_bool(can_afford).is_true()

func test_cannot_afford_upgrade_with_insufficient_credits() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 50)
	
	# Act
	var can_afford = progression_manager.can_afford_upgrade("max_health_1")
	
	# Assert
	assert_bool(can_afford).is_false()

func test_cannot_afford_already_purchased_upgrade() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 200)
	game_manager.unlock_upgrade("max_health_1")
	
	# Act
	var can_afford = progression_manager.can_afford_upgrade("max_health_1")
	
	# Assert
	assert_bool(can_afford).is_false()

func test_cannot_afford_upgrade_without_prerequisites() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 300)
	
	# Act - Try to buy max_health_2 without max_health_1
	var can_afford = progression_manager.can_afford_upgrade("max_health_2")
	
	# Assert
	assert_bool(can_afford).is_false()

func test_can_afford_upgrade_with_prerequisites() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 300)
	game_manager.unlock_upgrade("max_health_1")
	
	# Act
	var can_afford = progression_manager.can_afford_upgrade("max_health_2")
	
	# Assert
	assert_bool(can_afford).is_true()

func test_purchase_upgrade_success() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 150)
	var initial_credits = game_manager.get_inventory_amount("credits")
	
	# Act
	var success = progression_manager.purchase_upgrade("max_health_1")
	
	# Assert
	assert_bool(success).is_true()
	assert_bool(game_manager.permanent_upgrades.has("max_health_1")).is_true()
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(initial_credits - 100)

func test_purchase_upgrade_failure_insufficient_credits() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 50)
	
	# Act
	var success = progression_manager.purchase_upgrade("max_health_1")
	
	# Assert
	assert_bool(success).is_false()
	assert_bool(game_manager.permanent_upgrades.has("max_health_1")).is_false()

func test_get_total_stat_bonus_single_upgrade() -> void:
	# Arrange
	game_manager.unlock_upgrade("max_health_1")
	
	# Act
	var bonus = progression_manager.get_total_stat_bonus("max_health")
	
	# Assert
	assert_float(bonus).is_equal(20.0)

func test_get_total_stat_bonus_multiple_upgrades() -> void:
	# Arrange
	game_manager.unlock_upgrade("max_health_1")
	game_manager.unlock_upgrade("max_health_2")
	
	# Act
	var bonus = progression_manager.get_total_stat_bonus("max_health")
	
	# Assert
	assert_float(bonus).is_equal(50.0)  # 20 + 30

func test_get_total_stat_bonus_no_upgrades() -> void:
	# Act
	var bonus = progression_manager.get_total_stat_bonus("max_health")
	
	# Assert
	assert_float(bonus).is_equal(0.0)

func test_get_available_upgrades_all_available() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 1000)
	
	# Act
	var available = progression_manager.get_available_upgrades()
	
	# Assert
	assert_array(available).contains(["max_health_1", "dash_cooldown_1", "fire_rate_1", "move_speed_1"])

func test_get_available_upgrades_excludes_purchased() -> void:
	# Arrange
	game_manager.unlock_upgrade("max_health_1")
	
	# Act
	var available = progression_manager.get_available_upgrades()
	
	# Assert
	assert_array(available).not_contains(["max_health_1"])

func test_get_available_upgrades_includes_unlocked_tier_2() -> void:
	# Arrange
	game_manager.unlock_upgrade("max_health_1")
	
	# Act
	var available = progression_manager.get_available_upgrades()
	
	# Assert
	assert_array(available).contains(["max_health_2"])

func test_get_upgrade_info_returns_correct_data() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 150)
	
	# Act
	var info = progression_manager.get_upgrade_info("max_health_1")
	
	# Assert
	assert_str(info.get("display_name")).is_equal("Health Boost I")
	assert_int(info.get("cost")).is_equal(100)
	assert_bool(info.get("affordable")).is_true()
	assert_bool(info.get("purchased")).is_false()

func test_purchase_applies_max_health_immediately() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 150)
	var initial_max_health = game_manager.player_max_health
	
	# Act
	progression_manager.purchase_upgrade("max_health_1")
	
	# Assert
	assert_int(game_manager.player_max_health).is_equal(initial_max_health + 20)

