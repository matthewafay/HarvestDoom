extends CanvasLayer
## UIManager - Central UI management for all game scenes
##
## Manages all user interface elements across both Farm_Hub and Combat_Zone scenes.
## Provides a unified interface for updating UI displays and showing/hiding scene-specific UI.
##
## Responsibilities:
## - Manage CombatUI (health, ammo, buffs, weapon indicator)
## - Manage FarmUI (inventory, upgrades, crop status)
## - Manage InteractionPrompt (context-sensitive prompts)
## - Connect to GameManager signals for automatic UI updates
## - Switch between Farm and Combat UI modes
##
## Validates: Requirements 10.1, 10.2, 10.3

class_name UIManager

# UI Components
var combat_ui: CombatUI = null
var farm_ui: FarmUI = null
var interaction_prompt: InteractionPrompt = null

# Current UI mode
enum UIMode { FARM, COMBAT }
var current_mode: UIMode = UIMode.FARM

# Signals
signal upgrade_button_pressed(upgrade_id: String)
signal portal_entered()

func _ready() -> void:
	_create_ui_components()
	_connect_signals()
	
	# Start with farm UI visible
	show_farm_ui()

## Create all UI component instances
func _create_ui_components() -> void:
	# Create CombatUI
	combat_ui = CombatUI.new()
	combat_ui.name = "CombatUI"
	combat_ui.visible = false
	add_child(combat_ui)
	
	# Create FarmUI
	farm_ui = FarmUI.new()
	farm_ui.name = "FarmUI"
	farm_ui.visible = false
	add_child(farm_ui)
	
	# Load InteractionPrompt scene
	var prompt_scene = load("res://scenes/interaction_prompt.tscn")
	if prompt_scene:
		interaction_prompt = prompt_scene.instantiate()
		interaction_prompt.name = "InteractionPrompt"
		add_child(interaction_prompt)
	else:
		push_error("UIManager: Failed to load interaction_prompt.tscn")

## Connect to GameManager signals for automatic UI updates
func _connect_signals() -> void:
	if not GameManager:
		push_error("UIManager: GameManager not found")
		return
	
	# Connect health changes
	GameManager.health_changed.connect(_on_health_changed)
	
	# Connect buff changes
	GameManager.buff_applied.connect(_on_buff_applied)
	GameManager.buff_cleared.connect(_on_buff_cleared)
	
	# Connect upgrade unlocked
	GameManager.upgrade_unlocked.connect(_on_upgrade_unlocked)
	
	# Connect FarmUI signals
	if farm_ui:
		farm_ui.upgrade_button_pressed.connect(_on_upgrade_button_pressed)

## Show combat UI and hide farm UI
func show_combat_ui() -> void:
	current_mode = UIMode.COMBAT
	
	if combat_ui:
		combat_ui.visible = true
		# Update combat UI with current state
		_update_combat_ui()
	
	if farm_ui:
		farm_ui.visible = false

## Show farm UI and hide combat UI
func show_farm_ui() -> void:
	current_mode = UIMode.FARM
	
	if farm_ui:
		farm_ui.visible = true
		# Update farm UI with current state
		_update_farm_ui()
	
	if combat_ui:
		combat_ui.visible = false

## Update health display
func update_health_display(current: int, max_health: int) -> void:
	if combat_ui and current_mode == UIMode.COMBAT:
		combat_ui.update_health(current, max_health)

## Update ammo display
func update_ammo_display(weapon_type: int, amount: int) -> void:
	if combat_ui and current_mode == UIMode.COMBAT:
		combat_ui.update_ammo(weapon_type, amount)

## Update buff display
func update_buff_display(buffs: Array) -> void:
	if combat_ui and current_mode == UIMode.COMBAT:
		combat_ui.update_buffs(buffs)

## Update inventory display
func update_inventory_display(inventory: Dictionary) -> void:
	if farm_ui and current_mode == UIMode.FARM:
		farm_ui.update_inventory(inventory)

## Show interaction prompt
func show_interaction_prompt(text: String, position: Vector2 = Vector2.ZERO) -> void:
	if interaction_prompt:
		interaction_prompt.show_prompt(text, position)

## Hide interaction prompt
func hide_interaction_prompt() -> void:
	if interaction_prompt:
		interaction_prompt.hide_prompt()

## Update interaction prompt position from 3D world position
func update_prompt_position_from_world(world_position: Vector3, camera: Camera3D) -> void:
	if interaction_prompt:
		interaction_prompt.update_position_from_world(world_position, camera)

## Update all combat UI elements with current game state
func _update_combat_ui() -> void:
	if not combat_ui:
		return
	
	# Update health
	combat_ui.update_health(GameManager.player_health, GameManager.player_max_health)
	
	# Update buffs
	combat_ui.update_buffs(GameManager.active_buffs)
	
	# Ammo will be updated by weapon system signals

## Update all farm UI elements with current game state
func _update_farm_ui() -> void:
	if not farm_ui:
		return
	
	# Update inventory
	farm_ui.update_inventory(GameManager.inventory)
	
	# Update upgrades list
	if GameManager.progression_manager:
		farm_ui.update_upgrades(GameManager.progression_manager)

## Handle health changed signal from GameManager
func _on_health_changed(new_health: int, max_health: int) -> void:
	update_health_display(new_health, max_health)

## Handle buff applied signal from GameManager
func _on_buff_applied(buff) -> void:
	update_buff_display(GameManager.active_buffs)

## Handle buff cleared signal from GameManager
func _on_buff_cleared() -> void:
	update_buff_display(GameManager.active_buffs)

## Handle upgrade unlocked signal from GameManager
func _on_upgrade_unlocked(upgrade_id: String) -> void:
	# Refresh farm UI to show updated upgrades
	if farm_ui and current_mode == UIMode.FARM:
		_update_farm_ui()

## Handle upgrade button pressed from FarmUI
func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	upgrade_button_pressed.emit(upgrade_id)
