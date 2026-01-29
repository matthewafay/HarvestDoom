extends GdUnitTestSuite
## Integration tests for save/load cycles
##
## Tests the complete save/load system including:
## - Saving and loading game state
## - Persistence of upgrades, inventory, and crop states
## - Error handling and recovery
##
## Validates: Requirements 16.1, 16.2, 16.3, 16.4, 16.5

var game_manager: Node
var save_path: String = "user://save_game.json"

func before_test() -> void:
	# Get reference to GameManager autoload
	game_manager = get_node("/root/GameManager")
	
	# Clear any existing save file
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
	
	# Reset GameManager state
	game_manager.player_health = 100
	game_manager.player_max_health = 100
	game_manager.inventory.clear()
	game_manager.permanent_upgrades.clear()
	game_manager.active_buffs.clear()

func after_test() -> void:
	# Clean up save file after each test
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)

func test_save_creates_file() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 100)
	
	# Act
	game_manager.save_game()
	
	# Assert
	assert_bool(FileAccess.file_exists(save_path)).is_true()

func test_save_and_load_inventory() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 250)
	game_manager.add_to_inventory("health_seeds", 5)
	game_manager.add_to_inventory("ammo_seeds", 3)
	
	# Act - Save
	game_manager.save_game()
	
	# Clear state
	game_manager.inventory.clear()
	
	# Act - Load
	game_manager.load_game()
	
	# Assert
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(250)
	assert_int(game_manager.get_inventory_amount("health_seeds")).is_equal(5)
	assert_int(game_manager.get_inventory_amount("ammo_seeds")).is_equal(3)

func test_save_and_load_upgrades() -> void:
	# Arrange
	game_manager.unlock_upgrade("max_health_1")
	game_manager.unlock_upgrade("dash_cooldown_1")
	game_manager.unlock_upgrade("fire_rate_1")
	
	# Act - Save
	game_manager.save_game()
	
	# Clear state
	game_manager.permanent_upgrades.clear()
	
	# Act - Load
	game_manager.load_game()
	
	# Assert
	assert_bool(game_manager.permanent_upgrades.has("max_health_1")).is_true()
	assert_bool(game_manager.permanent_upgrades.has("dash_cooldown_1")).is_true()
	assert_bool(game_manager.permanent_upgrades.has("fire_rate_1")).is_true()

func test_save_and_load_multiple_times() -> void:
	# First save/load cycle
	game_manager.add_to_inventory("credits", 100)
	game_manager.save_game()
	game_manager.inventory.clear()
	game_manager.load_game()
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(100)
	
	# Second save/load cycle with more data
	game_manager.add_to_inventory("credits", 50)
	game_manager.unlock_upgrade("max_health_1")
	game_manager.save_game()
	game_manager.inventory.clear()
	game_manager.permanent_upgrades.clear()
	game_manager.load_game()
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(150)
	assert_bool(game_manager.permanent_upgrades.has("max_health_1")).is_true()
	
	# Third save/load cycle
	game_manager.add_to_inventory("health_seeds", 10)
	game_manager.save_game()
	game_manager.inventory.clear()
	game_manager.load_game()
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(150)
	assert_int(game_manager.get_inventory_amount("health_seeds")).is_equal(10)

func test_load_nonexistent_file() -> void:
	# Arrange - Ensure no save file exists
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
	
	# Set some initial state
	game_manager.add_to_inventory("credits", 50)
	
	# Act - Load (should not crash, just warn)
	game_manager.load_game()
	
	# Assert - State should be unchanged
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(50)

func test_save_preserves_all_data() -> void:
	# Arrange - Set up complex game state
	game_manager.add_to_inventory("credits", 500)
	game_manager.add_to_inventory("health_seeds", 10)
	game_manager.add_to_inventory("ammo_seeds", 8)
	game_manager.add_to_inventory("weapon_mod_seeds", 3)
	game_manager.unlock_upgrade("max_health_1")
	game_manager.unlock_upgrade("max_health_2")
	game_manager.unlock_upgrade("dash_cooldown_1")
	game_manager.unlock_upgrade("fire_rate_1")
	game_manager.unlock_upgrade("move_speed_1")
	
	# Act - Save and load
	game_manager.save_game()
	game_manager.inventory.clear()
	game_manager.permanent_upgrades.clear()
	game_manager.load_game()
	
	# Assert - All data preserved
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(500)
	assert_int(game_manager.get_inventory_amount("health_seeds")).is_equal(10)
	assert_int(game_manager.get_inventory_amount("ammo_seeds")).is_equal(8)
	assert_int(game_manager.get_inventory_amount("weapon_mod_seeds")).is_equal(3)
	assert_int(game_manager.permanent_upgrades.size()).is_equal(5)
	assert_bool(game_manager.permanent_upgrades.has("max_health_1")).is_true()
	assert_bool(game_manager.permanent_upgrades.has("max_health_2")).is_true()
	assert_bool(game_manager.permanent_upgrades.has("dash_cooldown_1")).is_true()
	assert_bool(game_manager.permanent_upgrades.has("fire_rate_1")).is_true()
	assert_bool(game_manager.permanent_upgrades.has("move_speed_1")).is_true()

func test_save_after_upgrade_purchase() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 200)
	var progression_manager = game_manager.progression_manager
	
	# Act - Purchase upgrade (should auto-save)
	var success = progression_manager.purchase_upgrade("max_health_1")
	
	# Assert - Purchase succeeded
	assert_bool(success).is_true()
	
	# Clear state and reload
	game_manager.inventory.clear()
	game_manager.permanent_upgrades.clear()
	game_manager.load_game()
	
	# Assert - Upgrade and remaining credits persisted
	assert_bool(game_manager.permanent_upgrades.has("max_health_1")).is_true()
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(100)

func test_empty_inventory_saves_correctly() -> void:
	# Arrange - Empty inventory
	game_manager.inventory.clear()
	
	# Act
	game_manager.save_game()
	game_manager.add_to_inventory("credits", 999)  # Add something
	game_manager.load_game()
	
	# Assert - Should load empty inventory
	assert_int(game_manager.get_inventory_amount("credits")).is_equal(0)

func test_save_data_timestamp() -> void:
	# Arrange
	game_manager.add_to_inventory("credits", 100)
	var time_before = Time.get_unix_time_from_system()
	
	# Act
	game_manager.save_game()
	
	# Load and check timestamp
	var file = FileAccess.open(save_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	json.parse(json_string)
	var data = json.data
	
	var time_after = Time.get_unix_time_from_system()
	
	# Assert - Timestamp should be between before and after
	assert_int(data["timestamp"]).is_greater_equal(time_before)
	assert_int(data["timestamp"]).is_less_equal(time_after)
