extends Control
## FarmUI - Farm-specific UI display
##
## Displays inventory resources, available upgrades, and crop growth status in the farm hub.
## Provides buttons for purchasing upgrades and consuming buffs.
##
## Validates: Requirements 10.2, 10.5

class_name FarmUI

# UI Elements
var inventory_panel: Panel = null
var inventory_container: VBoxContainer = null
var upgrade_panel: Panel = null
var upgrade_container: VBoxContainer = null
var buff_panel: Panel = null

# Signals
signal upgrade_button_pressed(upgrade_id: String)

func _ready() -> void:
	_setup_ui()

## Set up all UI elements
func _setup_ui() -> void:
	# Set up the control node to fill the screen
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create inventory panel (top-left)
	_create_inventory_panel()
	
	# Create upgrade panel (right side)
	_create_upgrade_panel()
	
	# Create buff consumption panel (using existing BuffConsumptionUI)
	_create_buff_panel()

## Create inventory display panel
func _create_inventory_panel() -> void:
	# Background panel
	inventory_panel = Panel.new()
	inventory_panel.position = Vector2(20, 20)
	inventory_panel.custom_minimum_size = Vector2(300, 250)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.4, 0.6, 0.4, 1.0)  # Green border for farm theme
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	inventory_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(inventory_panel)
	
	# Main container
	var main_container = VBoxContainer.new()
	main_container.position = Vector2(10, 10)
	main_container.custom_minimum_size = Vector2(280, 230)
	inventory_panel.add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "Inventory"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.8, 1.0, 0.8, 1.0))  # Light green
	main_container.add_child(title)
	
	# Separator
	var separator = HSeparator.new()
	main_container.add_child(separator)
	
	# Inventory container
	inventory_container = VBoxContainer.new()
	inventory_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(inventory_container)

## Create upgrade panel
func _create_upgrade_panel() -> void:
	# Background panel
	upgrade_panel = Panel.new()
	upgrade_panel.anchor_left = 0.65
	upgrade_panel.anchor_top = 0.05
	upgrade_panel.anchor_right = 0.95
	upgrade_panel.anchor_bottom = 0.7
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.6, 0.5, 0.3, 1.0)  # Gold border for upgrades
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	upgrade_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(upgrade_panel)
	
	# Main container
	var main_container = VBoxContainer.new()
	main_container.anchor_left = 0.05
	main_container.anchor_top = 0.05
	main_container.anchor_right = 0.95
	main_container.anchor_bottom = 0.95
	upgrade_panel.add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "Permanent Upgrades"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5, 1.0))  # Gold
	main_container.add_child(title)
	
	# Separator
	var separator = HSeparator.new()
	main_container.add_child(separator)
	
	# Scroll container for upgrades
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(scroll_container)
	
	# Upgrade container
	upgrade_container = VBoxContainer.new()
	upgrade_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(upgrade_container)

## Create buff consumption panel
func _create_buff_panel() -> void:
	# Use the existing BuffConsumptionUI
	var buff_ui = BuffConsumptionUI.new()
	buff_ui.name = "BuffConsumptionUI"
	add_child(buff_ui)

## Update inventory display
func update_inventory(inventory: Dictionary) -> void:
	if not inventory_container:
		return
	
	# Clear existing labels
	for child in inventory_container.get_children():
		child.queue_free()
	
	# Display each inventory item
	var items = [
		["credits", "Credits"],
		["health_seeds", "Health Seeds"],
		["ammo_seeds", "Ammo Seeds"],
		["weapon_mod_seeds", "Weapon Mod Seeds"],
		["health_buff_20", "Health Buff +20"],
		["health_buff_40", "Health Buff +40"],
		["ammo_buff_50", "Ammo Buff +50"],
		["weapon_mod_damage", "Damage Mod"],
		["weapon_mod_fire_rate", "Fire Rate Mod"]
	]
	
	for item in items:
		var key = item[0]
		var display_name = item[1]
		var amount = inventory.get(key, 0)
		
		# Only show items with non-zero amounts or important items
		if amount > 0 or key == "credits":
			var item_label = Label.new()
			item_label.text = "%s: %d" % [display_name, amount]
			item_label.add_theme_font_size_override("font_size", 16)
			
			# Color code by type
			if key == "credits":
				item_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))  # Gold
			elif key.ends_with("_seeds"):
				item_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6, 1.0))  # Light green
			else:
				item_label.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0, 1.0))  # Purple for buffs
			
			inventory_container.add_child(item_label)

## Update upgrades display
func update_upgrades(progression_manager: Node) -> void:
	if not upgrade_container or not progression_manager:
		return
	
	# Clear existing upgrade buttons
	for child in upgrade_container.get_children():
		child.queue_free()
	
	# Get available upgrades from ProgressionManager
	if not progression_manager.has_method("get_available_upgrades"):
		push_warning("FarmUI: ProgressionManager does not have get_available_upgrades method")
		return
	
	var available_upgrades = progression_manager.get_available_upgrades()
	var player_credits = GameManager.get_inventory_amount("credits")
	
	# Display each upgrade
	for upgrade_data in available_upgrades:
		var upgrade_id = upgrade_data.get("id", "")
		var display_name = upgrade_data.get("name", "Unknown")
		var description = upgrade_data.get("description", "")
		var cost = upgrade_data.get("cost", 0)
		var is_unlocked = upgrade_data.get("is_unlocked", false)
		var can_afford = player_credits >= cost
		
		# Create upgrade container
		var upgrade_item = VBoxContainer.new()
		upgrade_item.custom_minimum_size = Vector2(0, 80)
		upgrade_container.add_child(upgrade_item)
		
		# Upgrade name
		var name_label = Label.new()
		name_label.text = display_name
		name_label.add_theme_font_size_override("font_size", 18)
		if is_unlocked:
			name_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5, 1.0))  # Green for unlocked
		else:
			name_label.add_theme_color_override("font_color", Color.WHITE)
		upgrade_item.add_child(name_label)
		
		# Description
		var desc_label = Label.new()
		desc_label.text = description
		desc_label.add_theme_font_size_override("font_size", 14)
		desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		upgrade_item.add_child(desc_label)
		
		# Purchase button
		if not is_unlocked:
			var button = Button.new()
			button.text = "Purchase (%d credits)" % cost
			button.disabled = not can_afford
			
			if can_afford:
				button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
			else:
				button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
			
			button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade_id))
			upgrade_item.add_child(button)
		else:
			var unlocked_label = Label.new()
			unlocked_label.text = "✓ Unlocked"
			unlocked_label.add_theme_font_size_override("font_size", 16)
			unlocked_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5, 1.0))
			upgrade_item.add_child(unlocked_label)
		
		# Separator
		var separator = HSeparator.new()
		upgrade_container.add_child(separator)

## Handle upgrade button pressed
func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	upgrade_button_pressed.emit(upgrade_id)
