extends GdUnitTestSuite
## Property-Based Tests for Weapon System
##
## Tests Property 2: Weapon Firing Consistency
## Validates: Requirements 2.1, 2.2, 2.4, 2.5
##
## Property: For all weapon types, firing behavior matches specification:
## Pistol never depletes ammo, Shotgun consumes exactly 1 ammo per shot,
## and fire rate limits are enforced.

const ITERATIONS = 100

func test_property_pistol_never_depletes_ammo() -> void:
	"""Property: Pistol ammo never decreases."""
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	weapon.current_weapon = WeaponSystem.WeaponType.PISTOL
	
	for i in range(ITERATIONS):
		# Fire pistol
		weapon.last_fire_time = 0.0  # Reset fire rate limit
		weapon.fire_weapon()
		
		# Pistol should still have infinite ammo
		assert_that(weapon.get_current_ammo()).is_equal(-1)
	
	remove_child(weapon)
	weapon.queue_free()

func test_property_shotgun_consumes_exactly_one_ammo() -> void:
	"""Property: Shotgun consumes exactly 1 ammo per successful shot."""
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	weapon.current_weapon = WeaponSystem.WeaponType.SHOTGUN
	
	for i in range(min(ITERATIONS, 20)):  # Limited by initial ammo
		var ammo_before = weapon.ammo[WeaponSystem.WeaponType.SHOTGUN]
		
		if ammo_before <= 0:
			break
		
		# Fire shotgun
		weapon.last_fire_time = 0.0  # Reset fire rate limit
		weapon.fire_weapon()
		
		var ammo_after = weapon.ammo[WeaponSystem.WeaponType.SHOTGUN]
		
		# Exactly 1 ammo should be consumed
		assert_that(ammo_after).is_equal(ammo_before - 1)
	
	remove_child(weapon)
	weapon.queue_free()

func test_property_shotgun_cannot_fire_with_zero_ammo() -> void:
	"""Property: Shotgun cannot fire when ammo is 0."""
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	weapon.current_weapon = WeaponSystem.WeaponType.SHOTGUN
	weapon.ammo[WeaponSystem.WeaponType.SHOTGUN] = 0
	
	for i in range(ITERATIONS):
		weapon.last_fire_time = 0.0  # Reset fire rate limit
		
		# Monitor signal
		var signal_monitor = monitor_signal(weapon, "weapon_fired")
		
		# Try to fire
		weapon.fire_weapon()
		
		# Should not fire
		assert_signal(signal_monitor).is_not_emitted()
		
		# Ammo should still be 0
		assert_that(weapon.ammo[WeaponSystem.WeaponType.SHOTGUN]).is_equal(0)
	
	remove_child(weapon)
	weapon.queue_free()

func test_property_fire_rate_enforced() -> void:
	"""Property: Shots cannot occur faster than specified fire_rate."""
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	weapon.current_weapon = WeaponSystem.WeaponType.PISTOL
	var fire_rate = weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]
	
	# Fire first shot
	weapon.last_fire_time = 0.0
	weapon.fire_weapon()
	var first_fire_time = weapon.last_fire_time
	
	# Try to fire immediately (should be blocked)
	weapon.fire_weapon()
	var second_fire_time = weapon.last_fire_time
	
	# Fire time should not have changed (shot was blocked)
	assert_that(second_fire_time).is_equal(first_fire_time)
	
	remove_child(weapon)
	weapon.queue_free()

func test_property_all_weapons_have_positive_fire_rate() -> void:
	"""Property: All weapons have positive fire rate values."""
	var weapon = WeaponSystem.new()
	
	for weapon_type in weapon.fire_rate.keys():
		assert_that(weapon.fire_rate[weapon_type]).is_greater(0.0)
	
	weapon.queue_free()

func test_property_ammo_never_negative() -> void:
	"""Property: Ammo count never goes below 0."""
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	for weapon_type in [WeaponSystem.WeaponType.SHOTGUN, WeaponSystem.WeaponType.PLANT_WEAPON]:
		weapon.current_weapon = weapon_type
		weapon.ammo[weapon_type] = 5
		
		# Fire until out of ammo
		for i in range(20):
			weapon.last_fire_time = 0.0
			weapon.fire_weapon()
			
			# Ammo should never be negative
			assert_that(weapon.ammo[weapon_type]).is_greater_equal(0)
	
	remove_child(weapon)
	weapon.queue_free()

func test_property_weapon_switch_is_instant() -> void:
	"""Property: Weapon switching happens instantly."""
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	for i in range(ITERATIONS):
		var target_weapon = [
			WeaponSystem.WeaponType.PISTOL,
			WeaponSystem.WeaponType.SHOTGUN,
			WeaponSystem.WeaponType.PLANT_WEAPON
		][randi() % 3]
		
		weapon.switch_weapon(target_weapon)
		
		# Weapon should be switched immediately
		assert_that(weapon.current_weapon).is_equal(target_weapon)
	
	remove_child(weapon)
	weapon.queue_free()

func test_property_add_ammo_increases_count() -> void:
	"""Property: Adding ammo always increases the count by exact amount."""
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	for i in range(ITERATIONS):
		var weapon_type = WeaponSystem.WeaponType.SHOTGUN
		var initial_ammo = weapon.ammo[weapon_type]
		var ammo_to_add = randi_range(1, 50)
		
		weapon.add_ammo(weapon_type, ammo_to_add)
		
		var expected_ammo = initial_ammo + ammo_to_add
		assert_that(weapon.ammo[weapon_type]).is_equal(expected_ammo)
		
		# Reset for next iteration
		weapon.ammo[weapon_type] = 20
	
	remove_child(weapon)
	weapon.queue_free()

func test_property_fire_rate_mod_reduces_fire_time() -> void:
	"""Property: Fire rate modification reduces time between shots."""
	var weapon = WeaponSystem.new()
	
	var initial_fire_rate = weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]
	
	weapon.apply_weapon_mod("fire_rate")
	
	var modified_fire_rate = weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]
	
	# Modified fire rate should be less (faster)
	assert_that(modified_fire_rate).is_less(initial_fire_rate)
	
	weapon.queue_free()

func test_property_clear_mods_restores_defaults() -> void:
	"""Property: Clearing mods restores all values to defaults."""
	var weapon = WeaponSystem.new()
	
	# Store defaults
	var default_pistol_rate = 0.2
	var default_shotgun_rate = 0.8
	
	# Apply mods
	weapon.apply_weapon_mod("fire_rate")
	
	# Clear mods
	weapon.clear_weapon_mods()
	
	# Should be back to defaults
	assert_that(weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]).is_equal(default_pistol_rate)
	assert_that(weapon.fire_rate[WeaponSystem.WeaponType.SHOTGUN]).is_equal(default_shotgun_rate)
	
	weapon.queue_free()
