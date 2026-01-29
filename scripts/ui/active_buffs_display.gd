extends Control
## ActiveBuffsDisplay - Shows active buffs during combat
##
## Displays a list of currently active buffs with their remaining duration.
## Updates automatically when buffs are applied or cleared.
##
## Validates: Requirements 5.4, 10.1

class_name ActiveBuffsDisplay

# UI elements
var buff_container: VBoxContainer
var title_label: Label

func _ready() -> void:
	_setup_ui()
	_update_buff_display()
	
	# Connect to GameManager signals
	if GameManager:
		GameManager.buff_applied.connect(_on_buff_changed)
		GameManager.buff_cleared.connect(_on_buff_changed)

## Set up the UI elements
func _setup_ui() -> void:
	# Position in top-right corner
	anchor_left = 0.75
	anchor_top = 0.05
	anchor_right = 0.95
	anchor_bottom = 0.35
	
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
	title_label.text = "Active Buffs"
	title_label.add_theme_font_size_override("font_size", 18)
	main_container.add_child(title_label)
	
	# Create separator
	var separator = HSeparator.new()
	main_container.add_child(separator)
	
	# Create buff container
	buff_container = VBoxContainer.new()
	buff_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(buff_container)

## Update the buff display
func _update_buff_display() -> void:
	# Clear existing labels
	for child in buff_container.get_children():
		child.queue_free()
	
	# Check if GameManager exists
	if not GameManager:
		return
	
	# Display each active buff
	var buff_count = 0
	for i in range(GameManager.active_buffs.size()):
		var buff = GameManager.active_buffs[i]
		if buff == null:
			continue
		
		# Get buff duration
		var duration = GameManager.buff_durations.get(i, 1)
		
		# Create label for buff
		var buff_label = Label.new()
		buff_label.text = _get_buff_description(buff, duration)
		buff_label.add_theme_font_size_override("font_size", 14)
		buff_container.add_child(buff_label)
		
		buff_count += 1
	
	# Show message if no buffs active
	if buff_count == 0:
		var no_buffs_label = Label.new()
		no_buffs_label.text = "No active buffs"
		no_buffs_label.add_theme_font_size_override("font_size", 14)
		no_buffs_label.modulate = Color(0.7, 0.7, 0.7)
		buff_container.add_child(no_buffs_label)

## Get a description string for a buff
func _get_buff_description(buff, duration: int) -> String:
	var description = ""
	
	# Determine buff type and value
	if buff.has("buff_type") and buff.has("value"):
		match buff.buff_type:
			0:  # HEALTH
				description = "+%d Max HP" % buff.value
			1:  # AMMO
				description = "+%d Ammo" % buff.value
			2:  # WEAPON_MOD
				if buff.has("weapon_mod_type"):
					description = buff.weapon_mod_type.capitalize()
				else:
					description = "Weapon Mod"
			_:
				description = "Unknown Buff"
	else:
		description = "Buff"
	
	# Add duration if more than 1 run
	if duration > 1:
		description += " (%d runs)" % duration
	
	return description

## Handle buff changed signal
func _on_buff_changed(_buff = null) -> void:
	_update_buff_display()

