extends GdUnitTestSuite
## Unit tests for WeaponSystem
##
## Tests weapon firing, ammunition, switching, and modifications.
## Validates Requirements 2.1, 2.2, 2.4, 2.5, 2.6, 5.3

func test_weapon_system_exists() -> void:
	var weapon_script = load("res://scripts/combat/weapon_system.gd")
	assert_that(weapon_script).is_not_null()

func test_weapon_types_enum() -> void:
	var weapon = WeaponSystem.new()
	
	# Check enum values exist
	assert_that(WeaponSystem.WeaponType.PISTOL).is_equal(0)
	assert_that(WeaponSystem.WeaponType.SHOTGUN).is_equal(1)
	assert_that(WeaponSystem.WeaponType.PLANT_WEAPON).is_equal(2)
	
	weapon.queue_free()

func test_initial_weapon_is_pistol() -> void:
	var weapon = WeaponSystem.new()
	
	assert_that(weapon.current_weapon).is_equal(WeaponSystem.WeaponType.PISTOL)
	
	weapon.queue_free()

func test_pistol_has_infinite_ammo() -> void:
	var weapon = WeaponSystem.new()
	
	# Pistol should not be in ammo dictionary (infinite ammo)
	var pistol_ammo = weapon.get_current_ammo()
	assert_that(pistol_ammo).is_equal(-1)  # -1 indicates infinite
	
	weapon.queue_free()

func test_shotgun_has_finite_ammo() -> void:
	var weapon = WeaponSystem.new()
	
	# Shotgun should have ammo count
	assert_that(weapon.ammo[WeaponSystem.WeaponType.SHOTGUN]).is_greater(0)
	
	weapon.queue_free()

func test_weapon_switching() -> void:
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	# Monitor signal
	var signal_monitor = monitor_signal(weapon, "weapon_switched")
	
	# Switch to shotgun
	weapon.switch_weapon(WeaponSystem.WeaponType.SHOTGUN)
	
	assert_that(weapon.current_weapon).is_equal(WeaponSystem.WeaponType.SHOTGUN)
	assert_signal(signal_monitor).is_emitted()
	
	remove_child(weapon)
	weapon.queue_free()

func test_add_ammo() -> void:
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	var initial_ammo = weapon.ammo[WeaponSystem.WeaponType.SHOTGUN]
	
	# Add ammo
	weapon.add_ammo(WeaponSystem.WeaponType.SHOTGUN, 10)
	
	assert_that(weapon.ammo[WeaponSystem.WeaponType.SHOTGUN]).is_equal(initial_ammo + 10)
	
	remove_child(weapon)
	weapon.queue_free()

func test_pistol_add_ammo_has_no_effect() -> void:
	var weapon = WeaponSystem.new()
	add_child(weapon)
	
	# Try to add ammo to pistol (should have no effect)
	weapon.add_ammo(WeaponSystem.WeaponType.PISTOL, 100)
	
	# Pistol should still have infinite ammo
	assert_that(weapon.get_current_ammo()).is_equal(-1)
	
	remove_child(weapon)
	weapon.queue_free()

func test_fire_rate_limits() -> void:
	var weapon = WeaponSystem.new()
	
	# Check fire rates are positive
	assert_that(weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]).is_greater(0.0)
	assert_that(weapon.fire_rate[WeaponSystem.WeaponType.SHOTGUN]).is_greater(0.0)
	assert_that(weapon.fire_rate[WeaponSystem.WeaponType.PLANT_WEAPON]).is_greater(0.0)
	
	weapon.queue_free()

func test_weapon_mod_application() -> void:
	var weapon = WeaponSystem.new()
	
	var initial_fire_rate = weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]
	
	# Apply fire rate mod
	weapon.apply_weapon_mod("fire_rate")
	
	# Fire rate should be reduced (faster firing)
	assert_that(weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]).is_less(initial_fire_rate)
	
	weapon.queue_free()

func test_clear_weapon_mods() -> void:
	var weapon = WeaponSystem.new()
	
	# Apply mod
	weapon.apply_weapon_mod("fire_rate")
	var modified_fire_rate = weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]
	
	# Clear mods
	weapon.clear_weapon_mods()
	
	# Fire rate should be reset to default
	assert_that(weapon.fire_rate[WeaponSystem.WeaponType.PISTOL]).is_equal(0.2)
	
	weapon.queue_free()

func test_can_fire_checks_ammo() -> void:
	var weapon = WeaponSystem.new()
	
	# Pistol can always fire
	weapon.current_weapon = WeaponSystem.WeaponType.PISTOL
	assert_that(weapon.can_fire()).is_true()
	
	# Shotgun with ammo can fire
	weapon.current_weapon = WeaponSystem.WeaponType.SHOTGUN
	weapon.ammo[WeaponSystem.WeaponType.SHOTGUN] = 10
	assert_that(weapon.can_fire()).is_true()
	
	# Shotgun without ammo cannot fire
	weapon.ammo[WeaponSystem.WeaponType.SHOTGUN] = 0
	assert_that(weapon.can_fire()).is_false()
	
	weapon.queue_free()

func test_weapon_signals_exist() -> void:
	var weapon = WeaponSystem.new()
	
	assert_that(weapon.has_signal("weapon_fired")).is_true()
	assert_that(weapon.has_signal("weapon_switched")).is_true()
	assert_that(weapon.has_signal("ammo_changed")).is_true()
	
	weapon.queue_free()
