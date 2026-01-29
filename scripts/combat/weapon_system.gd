extends Node3D
## WeaponSystem - Manages weapon firing, switching, and ammunition
##
## Handles all weapon-related functionality including firing mechanics,
## ammunition management, weapon switching, and weapon modifications.
##
## Responsibilities:
## - Fire weapons with appropriate patterns (single shot, spread)
## - Manage ammunition for each weapon type
## - Handle weapon switching
## - Apply temporary weapon modifications from buffs
## - Enforce fire rate limits
##
## Validates: Requirements 2.1, 2.2, 2.4, 2.5, 2.6, 5.3

class_name WeaponSystem

# Weapon types
enum WeaponType { PISTOL, SHOTGUN, PLANT_WEAPON }

# Current weapon state
var current_weapon: WeaponType = WeaponType.PISTOL

# Ammunition tracking (Pistol has infinite ammo)
var ammo: Dictionary = {
	WeaponType.SHOTGUN: 20,
	WeaponType.PLANT_WEAPON: 10
}

# Fire rate in seconds between shots (modified by upgrades)
var fire_rate: Dictionary = {
	WeaponType.PISTOL: 0.2,
	WeaponType.SHOTGUN: 0.8,
	WeaponType.PLANT_WEAPON: 0.5
}

# Fire rate tracking
var last_fire_time: float = 0.0

# Weapon modifications (temporary buffs)
var active_mods: Dictionary = {}

# Projectile scene
var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")

# Signals
signal weapon_fired(weapon_type: WeaponType)
signal weapon_switched(weapon_type: WeaponType)
signal ammo_changed(weapon_type: WeaponType, amount: int)

func _ready() -> void:
	# Initialize ammo tracking
	_emit_initial_ammo_signals()

func _emit_initial_ammo_signals() -> void:
	"""Emit initial ammo signals for UI synchronization."""
	for weapon_type in ammo.keys():
		ammo_changed.emit(weapon_type, ammo[weapon_type])

func fire_weapon() -> void:
	"""Fire the currently equipped weapon.
	
	Validates: Requirements 2.1, 2.2, 2.4, 2.5
	"""
	# Check fire rate limit
	var current_time = Time.get_ticks_msec() / 1000.0
	var time_since_last_fire = current_time - last_fire_time
	
	if time_since_last_fire < fire_rate[current_weapon]:
		return  # Fire rate limit not met
	
	# Check ammunition (Pistol has infinite ammo)
	if current_weapon != WeaponType.PISTOL:
		if ammo[current_weapon] <= 0:
			return  # No ammo
		
		# Consume ammo
		ammo[current_weapon] -= 1
		ammo_changed.emit(current_weapon, ammo[current_weapon])
	
	# Fire weapon based on type
	match current_weapon:
		WeaponType.PISTOL:
			_fire_pistol()
		WeaponType.SHOTGUN:
			_fire_shotgun()
		WeaponType.PLANT_WEAPON:
			_fire_plant_weapon()
	
	# Update fire time
	last_fire_time = current_time
	
	# Emit signal
	weapon_fired.emit(current_weapon)

func _fire_pistol() -> void:
	"""Fire a single projectile (Pistol pattern)."""
	_spawn_projectile(Vector3.FORWARD, 0.0)

func _fire_shotgun() -> void:
	"""Fire spread projectiles (Shotgun pattern)."""
	# Shotgun fires 5 projectiles in a spread pattern
	var spread_angle = 15.0  # degrees
	var projectile_count = 5
	
	for i in range(projectile_count):
		var angle_offset = (i - projectile_count / 2.0) * spread_angle
		_spawn_projectile(Vector3.FORWARD, deg_to_rad(angle_offset))

func _fire_plant_weapon() -> void:
	"""Fire plant weapon projectile (special pattern)."""
	# Plant weapon fires a single projectile (can be modified by buffs)
	_spawn_projectile(Vector3.FORWARD, 0.0)

func _spawn_projectile(direction: Vector3, angle_offset: float) -> void:
	"""Spawn a projectile in the specified direction.
	
	Args:
		direction: Base direction vector
		angle_offset: Angle offset in radians for spread
	"""
	if not projectile_scene:
		push_error("WeaponSystem: projectile_scene not loaded")
		return
	
	var projectile = projectile_scene.instantiate()
	
	# Get player camera for direction
	var player = get_parent()
	if player and player.has_node("Camera3D"):
		var camera = player.get_node("Camera3D")
		
		# Calculate projectile direction with angle offset
		var forward = -camera.global_transform.basis.z
		if angle_offset != 0.0:
			forward = forward.rotated(camera.global_transform.basis.y, angle_offset)
		
		# Set projectile position and direction
		projectile.global_position = camera.global_position + forward * 0.5
		projectile.direction = forward
		
		# Add to scene
		get_tree().root.add_child(projectile)

func switch_weapon(weapon_type: WeaponType) -> void:
	"""Switch to a different weapon instantly.
	
	Args:
		weapon_type: The weapon to switch to
		
	Validates: Requirement 2.6
	"""
	if weapon_type == current_weapon:
		return  # Already equipped
	
	current_weapon = weapon_type
	weapon_switched.emit(weapon_type)

func add_ammo(weapon_type: WeaponType, amount: int) -> void:
	"""Add ammunition to a specific weapon.
	
	Args:
		weapon_type: The weapon to add ammo to
		amount: The amount of ammo to add
		
	Validates: Requirement 5.2
	"""
	if weapon_type == WeaponType.PISTOL:
		return  # Pistol has infinite ammo
	
	if not ammo.has(weapon_type):
		ammo[weapon_type] = 0
	
	ammo[weapon_type] += amount
	ammo_changed.emit(weapon_type, ammo[weapon_type])

func apply_weapon_mod(mod_type: String) -> void:
	"""Apply a temporary weapon modification.
	
	Args:
		mod_type: The type of modification (e.g., "fire_rate", "damage", "spread")
		
	Validates: Requirement 5.3
	"""
	active_mods[mod_type] = true
	
	# Apply modification effects
	match mod_type:
		"fire_rate":
			# Increase fire rate by 20%
			for weapon in fire_rate.keys():
				fire_rate[weapon] *= 0.8
		"damage":
			# Damage increase would be handled by projectile
			pass
		"spread":
			# Spread reduction would be handled by firing logic
			pass

func clear_weapon_mods() -> void:
	"""Clear all temporary weapon modifications."""
	active_mods.clear()
	
	# Reset fire rates to default
	fire_rate = {
		WeaponType.PISTOL: 0.2,
		WeaponType.SHOTGUN: 0.8,
		WeaponType.PLANT_WEAPON: 0.5
	}

func get_current_ammo() -> int:
	"""Get ammunition count for current weapon.
	
	Returns:
		Ammo count, or -1 for infinite ammo (Pistol)
	"""
	if current_weapon == WeaponType.PISTOL:
		return -1  # Infinite ammo
	
	return ammo.get(current_weapon, 0)

func can_fire() -> bool:
	"""Check if the current weapon can fire.
	
	Returns:
		True if weapon can fire (has ammo and fire rate allows)
	"""
	# Check fire rate
	var current_time = Time.get_ticks_msec() / 1000.0
	var time_since_last_fire = current_time - last_fire_time
	
	if time_since_last_fire < fire_rate[current_weapon]:
		return false
	
	# Check ammo (Pistol always can fire)
	if current_weapon == WeaponType.PISTOL:
		return true
	
	return ammo.get(current_weapon, 0) > 0
