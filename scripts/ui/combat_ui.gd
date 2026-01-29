extends Control
## CombatUI - Combat-specific UI display
##
## Displays health bar, ammo count, active buffs, and weapon indicator during combat.
## All UI elements are generated procedurally using high-contrast colors for readability.
##
## Validates: Requirements 10.1, 10.4, 10.5, 12.8

class_name CombatUI

# UI Elements
var health_bar: ProgressBar = null
var health_label: Label = null
var ammo_label: Label = null
var buff_container: HBoxContainer = null
var weapon_indicator: Label = null

# Weapon type names for display
const WEAPON_NAMES = {
	0: "Pistol",  # WeaponSystem.WeaponType.PISTOL
	1: "Shotgun", # WeaponSystem.WeaponType.SHOTGUN
	2: "Plant Weapon" # WeaponSystem.WeaponType.PLANT_WEAPON
}

func _ready() -> void:
	_setup_ui()

## Set up all UI elements with procedural styling
func _setup_ui() -> void:
	# Set up the control node to fill the screen
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create health bar (top-left)
	_create_health_bar()
	
	# Create ammo display (top-left, below health)
	_create_ammo_display()
	
	# Create buff container (top-right)
	_create_buff_container()
	
	# Create weapon indicator (bottom-center)
	_create_weapon_indicator()

## Create health bar with procedural styling
func _create_health_bar() -> void:
	# Container for health bar
	var health_container = VBoxContainer.new()
	health_container.position = Vector2(20, 20)
	health_container.custom_minimum_size = Vector2(300, 60)
	add_child(health_container)
	
	# Health label
	health_label = Label.new()
	health_label.text = "Health: 100 / 100"
	health_label.add_theme_font_size_override("font_size", 18)
	health_label.add_theme_color_override("font_color", Color.WHITE)
	health_container.add_child(health_label)
	
	# Health progress bar
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(300, 30)
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	
	# Create procedural style for health bar
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_style.border_width_left = 2
	bg_style.border_width_right = 2
	bg_style.border_width_top = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(0.5, 0.5, 0.5, 1.0)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # Red for health
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	
	health_bar.add_theme_stylebox_override("background", bg_style)
	health_bar.add_theme_stylebox_override("fill", fill_style)
	
	health_container.add_child(health_bar)

## Create ammo display
func _create_ammo_display() -> void:
	ammo_label = Label.new()
	ammo_label.position = Vector2(20, 100)
	ammo_label.text = "Ammo: ∞"
	ammo_label.add_theme_font_size_override("font_size", 20)
	ammo_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))  # Yellow
	
	# Add background for better readability
	var bg_panel = Panel.new()
	bg_panel.position = Vector2(15, 95)
	bg_panel.custom_minimum_size = Vector2(150, 35)
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	bg_style.border_width_left = 2
	bg_style.border_width_right = 2
	bg_style.border_width_top = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(0.5, 0.5, 0.5, 0.8)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	bg_panel.add_theme_stylebox_override("panel", bg_style)
	
	add_child(bg_panel)
	add_child(ammo_label)

## Create buff container
func _create_buff_container() -> void:
	# Background panel
	var buff_panel = Panel.new()
	buff_panel.anchor_left = 0.75
	buff_panel.anchor_top = 0.02
	buff_panel.anchor_right = 0.98
	buff_panel.anchor_bottom = 0.25
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.5, 0.5, 0.5, 1.0)
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	buff_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(buff_panel)
	
	# Main container
	var main_container = VBoxContainer.new()
	main_container.anchor_left = 0.05
	main_container.anchor_top = 0.05
	main_container.anchor_right = 0.95
	main_container.anchor_bottom = 0.95
	buff_panel.add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "Active Buffs"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color.WHITE)
	main_container.add_child(title)
	
	# Separator
	var separator = HSeparator.new()
	main_container.add_child(separator)
	
	# Buff container
	buff_container = HBoxContainer.new()
	buff_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	buff_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	main_container.add_child(buff_container)

## Create weapon indicator
func _create_weapon_indicator() -> void:
	weapon_indicator = Label.new()
	weapon_indicator.anchor_left = 0.5
	weapon_indicator.anchor_top = 0.9
	weapon_indicator.anchor_right = 0.5
	weapon_indicator.anchor_bottom = 0.9
	weapon_indicator.pivot_offset = Vector2(0, 0)
	weapon_indicator.text = "Pistol"
	weapon_indicator.add_theme_font_size_override("font_size", 24)
	weapon_indicator.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1.0))  # Green
	weapon_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Add background
	var bg_panel = Panel.new()
	bg_panel.anchor_left = 0.45
	bg_panel.anchor_top = 0.88
	bg_panel.anchor_right = 0.55
	bg_panel.anchor_bottom = 0.92
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	bg_style.border_width_left = 2
	bg_style.border_width_right = 2
	bg_style.border_width_top = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(0.5, 0.5, 0.5, 0.8)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	bg_panel.add_theme_stylebox_override("panel", bg_style)
	
	add_child(bg_panel)
	add_child(weapon_indicator)

## Update health display
func update_health(current: int, max_health: int) -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current
	
	if health_label:
		health_label.text = "Health: %d / %d" % [current, max_health]
		
		# Change color based on health percentage
		var health_percent = float(current) / float(max_health)
		if health_percent > 0.5:
			health_label.add_theme_color_override("font_color", Color.WHITE)
		elif health_percent > 0.25:
			health_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))  # Orange
		else:
			health_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))  # Red

## Update ammo display
func update_ammo(weapon_type: int, amount: int) -> void:
	if not ammo_label:
		return
	
	# Pistol has infinite ammo
	if weapon_type == 0:  # PISTOL
		ammo_label.text = "Ammo: ∞"
	else:
		ammo_label.text = "Ammo: %d" % amount

## Update buff display
func update_buffs(buffs: Array) -> void:
	if not buff_container:
		return
	
	# Clear existing buff icons
	for child in buff_container.get_children():
		child.queue_free()
	
	# Add buff icons
	if buffs.is_empty():
		var no_buffs = Label.new()
		no_buffs.text = "None"
		no_buffs.add_theme_font_size_override("font_size", 14)
		no_buffs.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
		buff_container.add_child(no_buffs)
	else:
		for i in range(buffs.size()):
			var buff = buffs[i]
			if buff == null:
				continue
			
			var buff_label = Label.new()
			buff_label.text = _get_buff_text(buff, i)
			buff_label.add_theme_font_size_override("font_size", 14)
			buff_label.add_theme_color_override("font_color", _get_buff_color(buff))
			buff_container.add_child(buff_label)

## Get display text for a buff
func _get_buff_text(buff, index: int) -> String:
	var text = ""
	
	if buff.has("buff_type") and buff.has("value"):
		match buff.buff_type:
			0:  # HEALTH
				text = "+%d HP" % buff.value
			1:  # AMMO
				text = "+%d Ammo" % buff.value
			2:  # WEAPON_MOD
				if buff.has("weapon_mod_type"):
					text = buff.weapon_mod_type.capitalize()
				else:
					text = "Weapon Mod"
			_:
				text = "Buff"
	else:
		text = "Buff"
	
	# Add duration if available
	if GameManager and GameManager.buff_durations.has(index):
		var duration = GameManager.buff_durations[index]
		if duration > 1:
			text += " (%d)" % duration
	
	return text

## Get color for a buff based on type
func _get_buff_color(buff) -> Color:
	if not buff.has("buff_type"):
		return Color.WHITE
	
	match buff.buff_type:
		0:  # HEALTH
			return Color(0.8, 0.3, 0.3, 1.0)  # Red
		1:  # AMMO
			return Color(1.0, 0.9, 0.3, 1.0)  # Yellow
		2:  # WEAPON_MOD
			return Color(0.6, 0.3, 0.9, 1.0)  # Purple
		_:
			return Color.WHITE

## Show weapon switch indicator
func show_weapon_switch(weapon_type: int) -> void:
	if not weapon_indicator:
		return
	
	var weapon_name = WEAPON_NAMES.get(weapon_type, "Unknown")
	weapon_indicator.text = weapon_name
	
	# Flash the indicator
	var tween = create_tween()
	tween.tween_property(weapon_indicator, "modulate:a", 0.3, 0.1)
	tween.tween_property(weapon_indicator, "modulate:a", 1.0, 0.1)
