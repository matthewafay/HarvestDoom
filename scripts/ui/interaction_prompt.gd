extends Control
## InteractionPrompt - Displays context-sensitive interaction prompts to the player
##
## This is a basic implementation for Phase 6 that shows simple text prompts
## when the player is near interactive objects (plots, portals, etc.).
## This will be enhanced with the full UIManager in Phase 10.
##
## Responsibilities:
## - Display prompt text at appropriate screen position
## - Show/hide based on player proximity to interactive objects
## - Update prompt text based on interaction context
##
## Validates: Requirements 10.3, 4.5, 12.5

class_name InteractionPrompt

## Label displaying the prompt text
@onready var prompt_label: Label = $PromptLabel

## Background panel for better readability
@onready var background: Panel = $Background

## Reference to the current interactive target (if any)
var current_target: Node = null

## Whether the prompt is currently visible
var is_visible: bool = false

func _ready() -> void:
	# Start hidden
	hide_prompt()
	
	# Set up label properties
	if prompt_label:
		prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Set up background
	if background:
		# Create a simple dark background for readability
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.1, 0.1, 0.1, 0.8)
		style_box.border_width_left = 2
		style_box.border_width_right = 2
		style_box.border_width_top = 2
		style_box.border_width_bottom = 2
		style_box.border_color = Color(0.8, 0.8, 0.8, 1.0)
		style_box.corner_radius_top_left = 4
		style_box.corner_radius_top_right = 4
		style_box.corner_radius_bottom_left = 4
		style_box.corner_radius_bottom_right = 4
		background.add_theme_stylebox_override("panel", style_box)

## Show the interaction prompt with specified text
## @param text: The prompt text to display (e.g., "Press E to Plant")
## @param screen_position: Optional screen position (defaults to bottom center)
func show_prompt(text: String, screen_position: Vector2 = Vector2.ZERO) -> void:
	if prompt_label == null:
		push_error("InteractionPrompt.show_prompt: prompt_label is null")
		return
	
	prompt_label.text = text
	
	# Position the prompt
	if screen_position != Vector2.ZERO:
		position = screen_position
	else:
		# Default to bottom center of screen
		var viewport_size = get_viewport_rect().size
		position = Vector2(viewport_size.x / 2.0 - size.x / 2.0, viewport_size.y - 100)
	
	visible = true
	is_visible = true

## Hide the interaction prompt
func hide_prompt() -> void:
	visible = false
	is_visible = false
	current_target = null

## Update the prompt position based on a 3D world position
## Useful for prompts that follow objects in the world
## @param world_position: 3D position in world space
## @param camera: Camera3D to use for projection
func update_position_from_world(world_position: Vector3, camera: Camera3D) -> void:
	if camera == null:
		return
	
	# Project 3D world position to 2D screen position
	var screen_pos = camera.unproject_position(world_position)
	
	# Offset to center the prompt above the object
	screen_pos.y -= 50
	screen_pos.x -= size.x / 2.0
	
	position = screen_pos

## Check if the prompt is currently showing
## @returns: true if prompt is visible
func is_showing() -> bool:
	return is_visible

## Set the current interactive target
## @param target: The Node that can be interacted with
func set_target(target: Node) -> void:
	current_target = target

## Get the current interactive target
## @returns: The current target Node, or null if none
func get_target() -> Node:
	return current_target
