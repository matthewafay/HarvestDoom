extends Control
## PauseMenu - In-game pause menu with options
##
## Displays when ESC is pressed, pauses the game, and provides options
## to resume, save, or quit.

class_name PauseMenu

var is_paused: bool = false

# UI Elements
var panel: Panel
var resume_button: Button
var save_button: Button
var quit_button: Button

func _ready() -> void:
	_setup_ui()
	visible = false
	# Process input even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	is_paused = not is_paused
	visible = is_paused
	get_tree().paused = is_paused
	
	# Toggle mouse capture
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _setup_ui() -> void:
	# Set up full screen overlay
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Dark overlay background
	var overlay = ColorRect.new()
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	
	# Center panel
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 350)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -200
	panel.offset_top = -175
	panel.offset_right = 200
	panel.offset_bottom = 175
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.95)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.5, 0.5, 0.5, 1.0)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)
	
	# Container for buttons
	var container = VBoxContainer.new()
	container.anchor_left = 0.1
	container.anchor_top = 0.1
	container.anchor_right = 0.9
	container.anchor_bottom = 0.9
	container.add_theme_constant_override("separation", 20)
	panel.add_child(container)
	
	# Title
	var title = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	container.add_child(spacer)
	
	# Resume button
	resume_button = _create_button("Resume Game")
	resume_button.pressed.connect(_on_resume_pressed)
	container.add_child(resume_button)
	
	# Save button
	save_button = _create_button("Save Game")
	save_button.pressed.connect(_on_save_pressed)
	container.add_child(save_button)
	
	# Quit button
	quit_button = _create_button("Quit to Desktop")
	quit_button.pressed.connect(_on_quit_pressed)
	container.add_child(quit_button)
	
	# Controls hint
	var hint = Label.new()
	hint.text = "Press ESC to resume"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(hint)

func _create_button(text: String) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 50)
	button.add_theme_font_size_override("font_size", 20)
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.3, 0.3, 0.3, 1.0)
	normal_style.corner_radius_top_left = 5
	normal_style.corner_radius_top_right = 5
	normal_style.corner_radius_bottom_left = 5
	normal_style.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.4, 0.4, 0.4, 1.0)
	hover_style.corner_radius_top_left = 5
	hover_style.corner_radius_top_right = 5
	hover_style.corner_radius_bottom_left = 5
	hover_style.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.5, 0.5, 0.5, 1.0)
	pressed_style.corner_radius_top_left = 5
	pressed_style.corner_radius_top_right = 5
	pressed_style.corner_radius_bottom_left = 5
	pressed_style.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	return button

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_save_pressed() -> void:
	if GameManager:
		GameManager.save_game()
		# Show feedback
		save_button.text = "Saved!"
		await get_tree().create_timer(1.0).timeout
		save_button.text = "Save Game"

func _on_quit_pressed() -> void:
	# Save before quitting
	if GameManager:
		GameManager.save_game()
	get_tree().quit()
