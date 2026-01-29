extends Node
## GameManager - Central state management singleton
##
## This autoload singleton manages all persistent game state across scene transitions.
## It coordinates player state, inventory, buffs, permanent upgrades, and scene transitions.
## 
## Responsibilities:
## - Maintain player health and max health
## - Manage inventory resources (Dictionary of resource_type: count)
## - Track active temporary buffs (Array of Buff resources)
## - Store permanent upgrades (Dictionary of upgrade_id: level)
## - Coordinate scene transitions between Farm_Hub and Combat_Zone
## - Provide signals for state changes to decouple systems
##
## Validates: Requirements 7.5, 11.2
##
## Note: This is an autoload singleton, so it should not have a class_name declaration
## to avoid naming conflicts. Access it globally via the autoload name "GameManager".

# Player state variables
var player_health: int = 100
var player_max_health: int = 100

# Inventory: Dictionary mapping resource types to quantities
# Example: {"credits": 50, "health_seeds": 3, "ammo_seeds": 2}
var inventory: Dictionary = {}

# Run loot: Dictionary tracking loot collected during the current combat run
# This is separate from permanent inventory and only added on successful run completion
# Cleared on player death (Requirement 9.4)
var run_loot: Dictionary = {}

# Active buffs: Array of Buff resources that apply to the current/next run
# Buffs are cleared when returning to Farm_Hub after a combat run
# Note: Using untyped Array to avoid initialization order issues with Buff class
var active_buffs: Array = []

# Permanent upgrades: Dictionary mapping upgrade IDs to their levels
# Example: {"max_health_1": 1, "dash_cooldown_1": 1, "fire_rate_1": 2}
var permanent_upgrades: Dictionary = {}

# Signals for state changes
signal health_changed(new_health: int, max_health: int)
signal buff_applied(buff)  # buff: Buff (untyped to avoid loading order issues)
signal buff_cleared()
signal upgrade_unlocked(upgrade_id: String)

func _ready() -> void:
	# Initialize default inventory values
	_initialize_inventory()

func _initialize_inventory() -> void:
	"""Initialize inventory with default starting values."""
	if inventory.is_empty():
		inventory = {
			"credits": 0,
			"health_seeds": 0,
			"ammo_seeds": 0,
			"weapon_mod_seeds": 0
		}

func apply_buff(buff) -> void:
	"""Apply a buff to the player for the next combat run.
	
	Args:
		buff: The Buff resource to apply (untyped to avoid loading order issues)
	"""
	if buff == null:
		push_error("GameManager.apply_buff: Cannot apply null buff")
		return
	
	active_buffs.append(buff)
	buff_applied.emit(buff)

func clear_temporary_buffs() -> void:
	"""Clear all temporary buffs. Called when returning to Farm_Hub after a combat run."""
	active_buffs.clear()
	buff_cleared.emit()

func unlock_upgrade(upgrade_id: String) -> void:
	"""Unlock or level up a permanent upgrade.
	
	Args:
		upgrade_id: The unique identifier for the upgrade
	"""
	if upgrade_id.is_empty():
		push_error("GameManager.unlock_upgrade: upgrade_id cannot be empty")
		return
	
	# Increment upgrade level (or set to 1 if new)
	if permanent_upgrades.has(upgrade_id):
		permanent_upgrades[upgrade_id] += 1
	else:
		permanent_upgrades[upgrade_id] = 1
	
	upgrade_unlocked.emit(upgrade_id)

func transition_to_combat() -> void:
	"""Transition from Farm_Hub to Combat_Zone.
	
	This method will:
	- Apply all active buffs to the player
	- Load the Combat_Zone scene
	- Preserve all state variables
	
	Validates: Requirements 7.1, 7.3, 7.5
	"""
	# Apply all active buffs before entering combat
	for buff in active_buffs:
		if buff != null:
			# Note: apply_to_player will be fully functional when PlayerController exists
			# For now, buffs modify GameManager state directly
			buff.apply_to_player(null)
	
	# Load the Combat_Zone scene
	var combat_scene_path = "res://scenes/combat_zone.tscn"
	var error = get_tree().change_scene_to_file(combat_scene_path)
	
	if error != OK:
		push_error("GameManager.transition_to_combat: Failed to load Combat_Zone scene. Error code: %d" % error)
		return
	
	# State variables (health, inventory, upgrades, buffs) are automatically preserved
	# because GameManager is an autoload singleton that persists across scene changes

func transition_to_farm() -> void:
	"""Transition from Combat_Zone back to Farm_Hub.
	
	This method will:
	- Clear all temporary buffs
	- Load the Farm_Hub scene
	- Preserve inventory and permanent upgrades
	
	Validates: Requirements 7.2, 7.4, 7.5
	"""
	# Clear all temporary buffs when returning to farm
	clear_temporary_buffs()
	
	# Load the Farm_Hub scene
	var farm_scene_path = "res://scenes/farm_hub.tscn"
	var error = get_tree().change_scene_to_file(farm_scene_path)
	
	if error != OK:
		push_error("GameManager.transition_to_farm: Failed to load Farm_Hub scene. Error code: %d" % error)
		return
	
	# State variables (health, inventory, upgrades) are automatically preserved
	# because GameManager is an autoload singleton that persists across scene changes
	# Buffs have been cleared as required

func save_game() -> void:
	"""Save current game state to disk.
	
	Saves:
	- Permanent upgrades
	- Inventory resources
	- Crop growth states (via ProgressionManager)
	"""
	# TODO: Implement in task 8.3
	push_warning("GameManager.save_game: Not yet implemented")

func load_game() -> void:
	"""Load saved game state from disk.
	
	Loads:
	- Permanent upgrades
	- Inventory resources
	- Crop growth states (via ProgressionManager)
	"""
	# TODO: Implement in task 8.3
	push_warning("GameManager.load_game: Not yet implemented")

func set_player_health(new_health: int) -> void:
	"""Set player health and emit signal.
	
	Args:
		new_health: The new health value (will be clamped to [0, max_health])
	"""
	player_health = clampi(new_health, 0, player_max_health)
	health_changed.emit(player_health, player_max_health)

func modify_player_health(delta: int) -> void:
	"""Modify player health by a delta amount.
	
	Args:
		delta: Amount to add (positive) or subtract (negative) from health
	"""
	set_player_health(player_health + delta)

func set_max_health(new_max_health: int) -> void:
	"""Set player max health and emit signal.
	
	Args:
		new_max_health: The new maximum health value (must be positive)
	"""
	if new_max_health <= 0:
		push_error("GameManager.set_max_health: max_health must be positive")
		return
	
	player_max_health = new_max_health
	# Ensure current health doesn't exceed new max
	if player_health > player_max_health:
		player_health = player_max_health
	health_changed.emit(player_health, player_max_health)

func add_to_inventory(resource_type: String, amount: int) -> void:
	"""Add resources to inventory.
	
	Args:
		resource_type: The type of resource (e.g., "credits", "health_seeds")
		amount: The amount to add (can be negative to subtract)
	"""
	if not inventory.has(resource_type):
		inventory[resource_type] = 0
	
	inventory[resource_type] += amount
	# Ensure inventory values don't go negative
	if inventory[resource_type] < 0:
		inventory[resource_type] = 0

func get_inventory_amount(resource_type: String) -> int:
	"""Get the amount of a specific resource in inventory.
	
	Args:
		resource_type: The type of resource to query
		
	Returns:
		The amount of the resource, or 0 if not found
	"""
	return inventory.get(resource_type, 0)

func has_inventory_amount(resource_type: String, amount: int) -> bool:
	"""Check if inventory has at least the specified amount of a resource.
	
	Args:
		resource_type: The type of resource to check
		amount: The minimum amount required
		
	Returns:
		True if inventory has at least the specified amount
	"""
	return get_inventory_amount(resource_type) >= amount

func add_to_run_loot(resource_type: String, amount: int) -> void:
	"""Add resources to run loot (temporary loot collected during combat).
	
	This loot is tracked separately and only added to permanent inventory
	on successful run completion. Cleared on player death.
	
	Args:
		resource_type: The type of resource (e.g., "credits")
		amount: The amount to add
		
	Validates: Requirement 8.4 (loot collection during combat)
	"""
	if not run_loot.has(resource_type):
		run_loot[resource_type] = 0
	
	run_loot[resource_type] += amount
	
	# Ensure run loot values don't go negative
	if run_loot[resource_type] < 0:
		run_loot[resource_type] = 0

func finalize_run_loot() -> void:
	"""Transfer all run loot to permanent inventory on successful run completion.
	
	Called when the player successfully completes a combat run.
	Clears the run_loot dictionary after transfer.
	
	Validates: Requirement 8.4 (loot collection during combat)
	"""
	# Transfer all run loot to permanent inventory
	for resource_type in run_loot.keys():
		var amount = run_loot[resource_type]
		add_to_inventory(resource_type, amount)
	
	# Clear run loot
	run_loot.clear()

func clear_run_loot() -> void:
	"""Clear all run loot without adding to permanent inventory.
	
	Called when the player dies during a combat run.
	
	Validates: Requirement 9.4 (lose loot on death)
	"""
	run_loot.clear()

func get_run_loot_amount(resource_type: String) -> int:
	"""Get the amount of a specific resource in run loot.
	
	Args:
		resource_type: The type of resource to query
		
	Returns:
		The amount of the resource in run loot, or 0 if not found
	"""
	return run_loot.get(resource_type, 0)

func get_total_run_loot() -> int:
	"""Get the total amount of all loot collected in the current run.
	
	Returns:
		Sum of all loot values
	"""
	var total = 0
	for amount in run_loot.values():
		total += amount
	return total
