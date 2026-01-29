extends Control
## BuffConsumptionUI - UI for consuming buffs before combat
##
## Displays available buffs in the player's inventory and allows them to
## activate buffs before entering combat. Buffs are consumed from inventory
## and added to GameManager.active_buffs.
##
## Validates: Requirements 5.4, 10.2

class_name BuffConsumptionUI

# UI elements
var buff_container: VBoxContainer
var title_label: Label

# Available buff resources (preloaded)
const HEALTH_BUFF_20 = preload("res://resources/buffs/health_buff_20.tres")
const HEALTH_BUFF_40 = preload("res://resources/buffs/health_buff_40.tres")
const AMMO_BUFF_50 = preload("res://resources/buffs/ammo_buff_50.tres")
const WEAPON_MOD_DAMAGE = preload("res://resources/buffs/weapon_mod_damage.tres")
const WEAPON_MOD_FIRE_RATE = preload("res://resources/buffs/weapon_mod_fire_rate.tres")

# Buff definitions: [buff_resource, inventory_key, display_name]
var buff_definitions: Array = [
	[HEALTH_BUFF_20, "health_buff_20", "+20 Max Health"],
	[HEALTH_BUFF_40, "health_buff_40", "+40 Max Health"],
	[AMMO_BUFF_50, "ammo_buff_50", "+50 Ammo"],
	[WEAPON_MOD_DAMAGE, "weapon_mod_damage", "Damage Boost"],
	[WEAPON_MOD_FIRE_RATE, "weapon_mod_fire_rate", "Fire Rate Boost"]
]

func _ready() -> void:
	_setup_ui()
	_update_buff_list()
	
	# Connect to GameManager signals to update UI
	if GameManager:
		GameManager.buff_applied.connect(_on_buff_applied)

## Set up the UI elements
func _setup_ui() -> void:
	# Set up the control node
	anchor_left = 0.7
	anchor_top = 0.1
	anchor_right = 0.95
	anchor_bottom = 0.5
	
	# Create background panel
	var panel = Panel.new()
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	add_child(panel)
	
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.anchor_left = 0.05
	main_container.anchor_top = 0.05
	main_container.anchor_right = 0.95
	main_container.anchor_bottom = 0.95
	add_child(main_container)
	
	# Create title label
	title_label = Label.new()
	title_label.text = "Buffs (Click to Activate)"
	title_label.add_theme_font_size_override("font_size", 20)
	main_container.add_child(title_label)
	
	# Create separator
	var separator = HSeparator.new()
	main_container.add_child(separator)
	
	# Create scroll container for buff list
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(scroll_container)
	
	# Create buff container
	buff_container = VBoxContainer.new()
	buff_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(buff_container)

## Update the list of available buffs
func _update_buff_list() -> void:
	# Clear existing buff buttons
	for child in buff_container.get_children():
		child.queue_free()
	
	# Add button for each available buff
	for buff_def in buff_definitions:
		var buff_resource = buff_def[0]
		var inventory_key = buff_def[1]
		var display_name = buff_def[2]
		
		# Check if player has this buff in inventory
		var count = GameManager.get_inventory_amount(inventory_key)
		if count > 0:
			_create_buff_button(buff_resource, inventory_key, display_name, count)
	
	# Show message if no buffs available
	if buff_container.get_child_count() == 0:
		var no_buffs_label = Label.new()
		no_buffs_label.text = "No buffs available.\nHarvest crops to get buffs!"
		no_buffs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		buff_container.add_child(no_buffs_label)

## Create a button for a buff
func _create_buff_button(buff_resource: Buff, inventory_key: String, display_name: String, count: int) -> void:
	var button = Button.new()
	button.text = "%s (x%d)" % [display_name, count]
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Connect button press to consume buff
	button.pressed.connect(_on_buff_button_pressed.bind(buff_resource, inventory_key))
	
	buff_container.add_child(button)

## Handle buff button press
func _on_buff_button_pressed(buff_resource: Buff, inventory_key: String) -> void:
	# Check if player still has the buff
	if not GameManager.has_inventory_amount(inventory_key, 1):
		push_warning("BuffConsumptionUI: Tried to consume buff but none available")
		_update_buff_list()
		return
	
	# Consume buff from inventory
	GameManager.add_to_inventory(inventory_key, -1)
	
	# Apply buff to GameManager (will be activated when entering combat)
	GameManager.apply_buff(buff_resource)
	
	# Update UI
	_update_buff_list()
	
	print("Buff activated: %s" % inventory_key)

## Handle buff applied signal
func _on_buff_applied(buff: Buff) -> void:
	# Could add visual feedback here
	pass

