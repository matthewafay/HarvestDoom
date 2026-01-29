extends Area3D
## CombatPortal - Interactive portal to enter Combat_Zone
##
## This portal allows the player to transition from Farm_Hub to Combat_Zone.
## When the player enters the portal's area, an interaction prompt is displayed.
## Pressing the interact key triggers the scene transition.
##
## Validates: Requirements 7.1, 10.3

class_name CombatPortal

## Reference to the interaction prompt UI
var interaction_prompt: Node = null

## Whether the player is currently in range
var player_in_range: bool = false

## Reference to the player node
var player: Node3D = null

func _ready() -> void:
	# Set up collision layers
	collision_layer = 16  # LAYER_INTERACTIVE
	collision_mask = 1    # LAYER_PLAYER
	
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Find interaction prompt in the scene
	_find_interaction_prompt()

func _process(_delta: float) -> void:
	# Check for interact input when player is in range
	if player_in_range and Input.is_action_just_pressed("interact"):
		_enter_combat()

func _on_body_entered(body: Node3D) -> void:
	# Check if the entering body is the player
	if body.get_script() and body.get_script().resource_path.ends_with("player_controller.gd"):
		player = body
		player_in_range = true
		_show_prompt()

func _on_body_exited(body: Node3D) -> void:
	# Check if the exiting body is the player
	if body == player:
		player = null
		player_in_range = false
		_hide_prompt()

func _enter_combat() -> void:
	"""Trigger transition to Combat_Zone."""
	_hide_prompt()
	
	# Transition to combat via GameManager
	if GameManager:
		GameManager.transition_to_combat()
	else:
		push_error("CombatPortal._enter_combat: GameManager not found")

func _show_prompt() -> void:
	"""Display interaction prompt to the player."""
	if interaction_prompt:
		var prompt_text = "Press E to Enter Combat"
		
		# Check if it's UIManager or InteractionPrompt
		if interaction_prompt.has_method("show_interaction_prompt"):
			# It's UIManager
			interaction_prompt.show_interaction_prompt(prompt_text)
		elif interaction_prompt.has_method("show_prompt"):
			# It's InteractionPrompt directly
			var prompt_position = global_position
			interaction_prompt.show_prompt(prompt_text, prompt_position)

func _hide_prompt() -> void:
	"""Hide the interaction prompt."""
	if interaction_prompt:
		# Check if it's UIManager or InteractionPrompt
		if interaction_prompt.has_method("hide_interaction_prompt"):
			# It's UIManager
			interaction_prompt.hide_interaction_prompt()
		elif interaction_prompt.has_method("hide_prompt"):
			# It's InteractionPrompt directly
			interaction_prompt.hide_prompt()

func _find_interaction_prompt() -> void:
	"""Find the InteractionPrompt node in the scene tree."""
	var root = get_tree().current_scene
	if root == null:
		return
	
	# Look for UIManager first
	var ui_manager = _find_node_recursive(root, "ui_manager.gd")
	if ui_manager and ui_manager.has_method("show_interaction_prompt"):
		interaction_prompt = ui_manager
		return
	
	# Fallback: Search for InteractionPrompt node directly
	for child in root.get_children():
		if child.get_script() and child.get_script().resource_path.ends_with("interaction_prompt.gd"):
			interaction_prompt = child
			return
	
	# If not found at root level, search deeper
	interaction_prompt = _find_node_recursive(root, "interaction_prompt.gd")

func _find_node_recursive(node: Node, script_name: String) -> Node:
	"""Recursively search for a node with a specific script."""
	for child in node.get_children():
		if child.get_script() and child.get_script().resource_path.ends_with(script_name):
			return child
		
		var result = _find_node_recursive(child, script_name)
		if result:
			return result
	
	return null

