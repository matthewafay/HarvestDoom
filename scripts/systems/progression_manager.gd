extends Node
## ProgressionManager - Handles permanent upgrades and progression
##
## This class manages the upgrade system, including upgrade definitions,
## costs, purchase logic, and stat calculations. It works with GameManager
## to maintain upgrade state.
##
## Responsibilities:
## - Define available upgrades and their costs
## - Validate upgrade purchases
## - Calculate cumulative stat bonuses from upgrades
## - Coordinate with save system
##
## Validates: Requirements 6.1, 6.3

# Upgrade definitions: upgrade_id -> {cost, effect}
# Effect dictionary contains stat_name -> value pairs
# Costs tuned for meaningful progression over 10-15 minute sessions
const UPGRADES = {
	"max_health_1": {
		"cost": 80,  # Reduced from 100 for faster progression
		"effect": {"max_health": 20},
		"display_name": "Health Boost I",
		"description": "Increase max health by 20"
	},
	"max_health_2": {
		"cost": 150,  # Reduced from 200
		"effect": {"max_health": 30},
		"display_name": "Health Boost II",
		"description": "Increase max health by 30",
		"requires": ["max_health_1"]
	},
	"max_health_3": {
		"cost": 250,  # Reduced from 350
		"effect": {"max_health": 50},
		"display_name": "Health Boost III",
		"description": "Increase max health by 50",
		"requires": ["max_health_2"]
	},
	"dash_cooldown_1": {
		"cost": 100,  # Reduced from 150
		"effect": {"dash_cooldown": -0.2},
		"display_name": "Quick Dash I",
		"description": "Reduce dash cooldown by 0.2s"
	},
	"dash_cooldown_2": {
		"cost": 180,  # Reduced from 250
		"effect": {"dash_cooldown": -0.3},
		"display_name": "Quick Dash II",
		"description": "Reduce dash cooldown by 0.3s",
		"requires": ["dash_cooldown_1"]
	},
	"fire_rate_1": {
		"cost": 90,  # Reduced from 120
		"effect": {"fire_rate_multiplier": 1.2},
		"display_name": "Rapid Fire I",
		"description": "Increase fire rate by 20%"
	},
	"fire_rate_2": {
		"cost": 160,  # Reduced from 220
		"effect": {"fire_rate_multiplier": 1.4},
		"display_name": "Rapid Fire II",
		"description": "Increase fire rate by 40%",
		"requires": ["fire_rate_1"]
	},
	"move_speed_1": {
		"cost": 70,  # Reduced from 100
		"effect": {"move_speed": 1.0},
		"display_name": "Swift Movement I",
		"description": "Increase movement speed by 1.0"
	},
	"move_speed_2": {
		"cost": 130,  # Reduced from 180
		"effect": {"move_speed": 1.5},
		"display_name": "Swift Movement II",
		"description": "Increase movement speed by 1.5",
		"requires": ["move_speed_1"]
	}
}

# Signals
signal save_failed(error_message: String)
signal save_succeeded()

# Cached save data for recovery (untyped to avoid loading order issues)
var cached_save_data = null

func can_afford_upgrade(upgrade_id: String) -> bool:
	"""Check if the player can afford an upgrade.
	
	Args:
		upgrade_id: The unique identifier for the upgrade
		
	Returns:
		True if player has enough credits and meets requirements
	"""
	if not UPGRADES.has(upgrade_id):
		push_error("ProgressionManager.can_afford_upgrade: Unknown upgrade_id '%s'" % upgrade_id)
		return false
	
	var upgrade_data = UPGRADES[upgrade_id]
	var cost = upgrade_data.get("cost", 0)
	
	# Check if already purchased
	if GameManager.permanent_upgrades.has(upgrade_id):
		return false
	
	# Check prerequisites
	if upgrade_data.has("requires"):
		for required_id in upgrade_data["requires"]:
			if not GameManager.permanent_upgrades.has(required_id):
				return false
	
	# Check if player has enough credits
	return GameManager.has_inventory_amount("credits", cost)

func purchase_upgrade(upgrade_id: String) -> bool:
	"""Purchase an upgrade if affordable.
	
	Args:
		upgrade_id: The unique identifier for the upgrade
		
	Returns:
		True if purchase was successful, false otherwise
	"""
	if not can_afford_upgrade(upgrade_id):
		return false
	
	var upgrade_data = UPGRADES[upgrade_id]
	var cost = upgrade_data.get("cost", 0)
	
	# Deduct cost from inventory
	GameManager.add_to_inventory("credits", -cost)
	
	# Unlock the upgrade
	GameManager.unlock_upgrade(upgrade_id)
	
	# Apply upgrade effects immediately
	_apply_upgrade_effects(upgrade_id)
	
	# Save game after upgrade purchase (Requirement 16.1)
	GameManager.save_game()
	
	return true

func _apply_upgrade_effects(upgrade_id: String) -> void:
	"""Apply the effects of an upgrade immediately.
	
	Args:
		upgrade_id: The unique identifier for the upgrade
	"""
	if not UPGRADES.has(upgrade_id):
		return
	
	var upgrade_data = UPGRADES[upgrade_id]
	var effects = upgrade_data.get("effect", {})
	
	for stat_name in effects.keys():
		var value = effects[stat_name]
		
		match stat_name:
			"max_health":
				GameManager.set_max_health(GameManager.player_max_health + value)
			"dash_cooldown":
				# Dash cooldown is applied by PlayerController reading total bonus
				pass
			"fire_rate_multiplier":
				# Fire rate is applied by WeaponSystem reading total bonus
				pass
			"move_speed":
				# Move speed is applied by PlayerController reading total bonus
				pass

func get_total_stat_bonus(stat_name: String) -> float:
	"""Calculate the cumulative bonus for a stat from all unlocked upgrades.
	
	Args:
		stat_name: The name of the stat (e.g., "max_health", "dash_cooldown")
		
	Returns:
		The total bonus value for the stat
	"""
	var total_bonus: float = 0.0
	
	for upgrade_id in GameManager.permanent_upgrades.keys():
		if not UPGRADES.has(upgrade_id):
			continue
		
		var upgrade_data = UPGRADES[upgrade_id]
		var effects = upgrade_data.get("effect", {})
		
		if effects.has(stat_name):
			total_bonus += effects[stat_name]
	
	return total_bonus

func get_available_upgrades_ids() -> Array[String]:
	"""Get a list of upgrade IDs that can be purchased.
	
	Returns:
		Array of upgrade IDs that are available for purchase
	"""
	var available: Array[String] = []
	
	for upgrade_id in UPGRADES.keys():
		# Skip already purchased upgrades
		if GameManager.permanent_upgrades.has(upgrade_id):
			continue
		
		# Check prerequisites
		var upgrade_data = UPGRADES[upgrade_id]
		var can_purchase = true
		
		if upgrade_data.has("requires"):
			for required_id in upgrade_data["requires"]:
				if not GameManager.permanent_upgrades.has(required_id):
					can_purchase = false
					break
		
		if can_purchase:
			available.append(upgrade_id)
	
	return available

func get_upgrade_info(upgrade_id: String) -> Dictionary:
	"""Get display information for an upgrade.
	
	Args:
		upgrade_id: The unique identifier for the upgrade
		
	Returns:
		Dictionary with display_name, description, cost, and affordable flag
	"""
	if not UPGRADES.has(upgrade_id):
		return {}
	
	var upgrade_data = UPGRADES[upgrade_id]
	
	return {
		"upgrade_id": upgrade_id,
		"display_name": upgrade_data.get("display_name", upgrade_id),
		"description": upgrade_data.get("description", ""),
		"cost": upgrade_data.get("cost", 0),
		"affordable": can_afford_upgrade(upgrade_id),
		"purchased": GameManager.permanent_upgrades.has(upgrade_id)
	}

func get_available_upgrades() -> Array:
	"""Get a list of all upgrades with their info for UI display.
	
	Returns:
		Array of dictionaries with upgrade information
	"""
	var upgrades_list: Array = []
	
	for upgrade_id in UPGRADES.keys():
		var upgrade_data = UPGRADES[upgrade_id]
		var is_unlocked = GameManager.permanent_upgrades.has(upgrade_id)
		
		# Check prerequisites
		var can_purchase = true
		if upgrade_data.has("requires"):
			for required_id in upgrade_data["requires"]:
				if not GameManager.permanent_upgrades.has(required_id):
					can_purchase = false
					break
		
		# Only show upgrades that meet prerequisites or are already unlocked
		if can_purchase or is_unlocked:
			upgrades_list.append({
				"id": upgrade_id,
				"name": upgrade_data.get("display_name", upgrade_id),
				"description": upgrade_data.get("description", ""),
				"cost": upgrade_data.get("cost", 0),
				"is_unlocked": is_unlocked
			})
	
	return upgrades_list
