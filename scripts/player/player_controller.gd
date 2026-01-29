extends CharacterBody3D
## PlayerController - First-person player character controller
##
## Handles player movement, camera control, dashing, and health management.
## This controller works in both Farm_Hub and Combat_Zone scenes with consistent behavior.
##
## Responsibilities:
## - Process WASD movement input with immediate acceleration
## - Handle mouse look for camera rotation
## - Implement dash mechanic with cooldown
## - Manage player health and death state
## - Maintain collision detection with environment
##
## Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 9.1, 9.2, 9.3

class_name PlayerController

# Movement parameters
@export var move_speed: float = 5.0
@export var dash_speed: float = 15.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

# Camera
@onready var camera: Camera3D = $Camera3D
@onready var weapon_system = $WeaponSystem
var mouse_sensitivity: float = 0.002

# State
var is_dashing: bool = false
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0

# Signals
signal died()
signal dash_performed()

func _ready() -> void:
	# Capture mouse for first-person control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Sync health with GameManager
	if GameManager:
		GameManager.health_changed.connect(_on_health_changed)

func _physics_process(delta: float) -> void:
	# Update dash timers
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	
	# Handle movement
	_handle_movement(delta)
	
	# Apply physics
	move_and_slide()

func _input(event: InputEvent) -> void:
	# Handle mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_handle_mouse_look(event)
	
	# Handle dash input
	if event.is_action_pressed("dash") and not is_dashing and cooldown_timer <= 0.0:
		_perform_dash()
	
	# Handle weapon firing
	if event.is_action_pressed("fire") and weapon_system:
		weapon_system.fire_weapon()
	
	# Handle weapon switching (WeaponType enum: PISTOL=0, SHOTGUN=1, PLANT_WEAPON=2)
	if event.is_action_pressed("switch_weapon_1") and weapon_system:
		weapon_system.switch_weapon(0)  # PISTOL
	if event.is_action_pressed("switch_weapon_2") and weapon_system:
		weapon_system.switch_weapon(1)  # SHOTGUN

func _handle_movement(delta: float) -> void:
	"""Process WASD movement input with immediate acceleration."""
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var current_speed := dash_speed if is_dashing else move_speed
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta

func _handle_mouse_look(event: InputEventMouseMotion) -> void:
	"""Rotate camera based on mouse movement."""
	# Rotate player body horizontally
	rotate_y(-event.relative.x * mouse_sensitivity)
	
	# Rotate camera vertically (with clamping)
	if camera:
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _perform_dash() -> void:
	"""Execute a quick directional dash."""
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Only dash if there's input direction
	if input_dir.length() > 0.0:
		is_dashing = true
		dash_timer = dash_duration
		cooldown_timer = dash_cooldown
		dash_performed.emit()

func take_damage(amount: int) -> void:
	"""Apply damage to the player.
	
	Args:
		amount: The amount of damage to apply (positive integer)
	"""
	if GameManager:
		GameManager.modify_player_health(-amount)
		
		# Check for death
		if GameManager.player_health <= 0:
			_trigger_death()

func _trigger_death() -> void:
	"""Handle player death state."""
	died.emit()
	
	# Note: Scene transition is handled by the Combat_Zone scene
	# which listens to the died signal and manages loot clearing

func _on_health_changed(new_health: int, max_health: int) -> void:
	"""React to health changes from GameManager."""
	# This can be used for visual feedback, sound effects, etc.
	pass

func _unhandled_input(event: InputEvent) -> void:
	# Toggle mouse capture with ESC key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
