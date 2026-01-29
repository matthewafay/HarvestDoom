extends Node

## FeedbackSystem
## Provides visual and audio feedback for game events.
## Centralizes all feedback effects to ensure consistent visual language.
## All effects are generated procedurally using simple shapes and color palettes.
##
## Note: This is an autoload singleton, so it should not have a class_name declaration
## to avoid naming conflicts. Access it globally via the autoload name "FeedbackSystem".

# Signals
signal feedback_completed(feedback_type: String)

# References
var camera: Camera3D = null
var screen_flash: ColorRect = null

# Camera shake state
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var original_camera_position: Vector3 = Vector3.ZERO

# Screen flash state
var flash_timer: float = 0.0
var flash_duration: float = 0.0
var flash_color: Color = Color.WHITE

func _ready() -> void:
	# Initialize screen flash overlay
	_setup_screen_flash()

func _process(delta: float) -> void:
	# Update camera shake
	if shake_timer > 0.0:
		_update_camera_shake(delta)
	
	# Update screen flash
	if flash_timer > 0.0:
		_update_screen_flash(delta)

## Visual Feedback Methods

## Spawns a floating damage number at the specified position
func spawn_damage_number(amount: int, position: Vector3) -> void:
	var damage_label = Label3D.new()
	damage_label.text = str(amount)
	damage_label.font_size = 32
	damage_label.modulate = Color.RED if amount > 0 else Color.GREEN
	damage_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	damage_label.position = position
	
	# Add to scene
	get_tree().current_scene.add_child(damage_label)
	
	# Animate upward and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position", position + Vector3(0, 2, 0), 1.0)
	tween.tween_property(damage_label, "modulate:a", 0.0, 1.0)
	tween.finished.connect(func(): damage_label.queue_free())
	
	feedback_completed.emit("damage_number")

## Spawns a hit effect at the specified position
func spawn_hit_effect(position: Vector3, is_critical: bool = false) -> void:
	var effect_color = Color.YELLOW if is_critical else Color.WHITE
	create_impact_particles(position, effect_color)
	feedback_completed.emit("hit_effect")

## Flashes the screen with the specified color for the given duration
func flash_screen(color: Color, duration: float) -> void:
	if screen_flash == null:
		push_warning("FeedbackSystem: screen_flash not initialized")
		return
	
	flash_color = color
	flash_duration = duration
	flash_timer = duration
	screen_flash.visible = true
	screen_flash.modulate = color

## Shakes the camera with the specified intensity and duration
func shake_camera(intensity: float, duration: float) -> void:
	if camera == null:
		# Try to find camera in scene
		camera = get_viewport().get_camera_3d()
		if camera == null:
			push_warning("FeedbackSystem: No camera found for shake effect")
			return
	
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
	original_camera_position = camera.position

## Procedural Particle Effects

## Creates impact particles at the specified position with the given color
func create_impact_particles(position: Vector3, color: Color) -> void:
	var particles = CPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 0.5
	particles.explosiveness = 1.0
	
	# Particle appearance
	particles.mesh = SphereMesh.new()
	particles.mesh.radius = 0.05
	particles.mesh.height = 0.1
	
	# Particle behavior
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 5.0
	particles.gravity = Vector3(0, -9.8, 0)
	
	# Color
	var gradient = Gradient.new()
	gradient.add_point(0.0, color)
	gradient.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = gradient
	
	# Add to scene
	get_tree().current_scene.add_child(particles)
	
	# Clean up after lifetime
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()
	
	feedback_completed.emit("impact_particles")

## Creates a death explosion effect for the specified enemy type
func create_death_explosion(position: Vector3, enemy_type: String) -> void:
	# Determine color based on enemy type
	var explosion_color: Color
	match enemy_type:
		"MeleeCharger":
			explosion_color = Color.RED
		"RangedShooter":
			explosion_color = Color.PURPLE
		"TankEnemy":
			explosion_color = Color.DARK_GRAY
		_:
			explosion_color = Color.ORANGE
	
	# Create larger particle explosion
	var particles = CPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 50
	particles.lifetime = 1.0
	particles.explosiveness = 1.0
	
	# Particle appearance
	particles.mesh = SphereMesh.new()
	particles.mesh.radius = 0.1
	particles.mesh.height = 0.2
	
	# Particle behavior
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 3.0
	particles.initial_velocity_max = 8.0
	particles.gravity = Vector3(0, -9.8, 0)
	
	# Color gradient
	var gradient = Gradient.new()
	gradient.add_point(0.0, explosion_color)
	gradient.add_point(0.5, explosion_color.lightened(0.3))
	gradient.add_point(1.0, Color(explosion_color.r, explosion_color.g, explosion_color.b, 0.0))
	particles.color_ramp = gradient
	
	# Add to scene
	get_tree().current_scene.add_child(particles)
	
	# Clean up after lifetime
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()
	
	feedback_completed.emit("death_explosion")

## Creates a harvest effect for the specified crop type (2D)
func create_harvest_effect(position: Vector2, crop_type: String) -> void:
	# Determine color based on crop type
	var harvest_color: Color
	match crop_type:
		"health_crop":
			harvest_color = Color.GREEN
		"ammo_crop":
			harvest_color = Color.YELLOW
		"weapon_mod_crop":
			harvest_color = Color.PURPLE
		_:
			harvest_color = Color.WHITE
	
	# Create 2D particle effect
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 30
	particles.lifetime = 0.8
	particles.explosiveness = 1.0
	
	# Particle behavior
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 150.0
	particles.gravity = Vector2(0, 200.0)
	
	# Color gradient
	var gradient = Gradient.new()
	gradient.add_point(0.0, harvest_color)
	gradient.add_point(1.0, Color(harvest_color.r, harvest_color.g, harvest_color.b, 0.0))
	particles.color_ramp = gradient
	
	# Add to scene
	get_tree().current_scene.add_child(particles)
	
	# Clean up after lifetime
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()
	
	feedback_completed.emit("harvest_effect")

## Internal Helper Methods

## Sets up the screen flash overlay
func _setup_screen_flash() -> void:
	screen_flash = ColorRect.new()
	screen_flash.name = "ScreenFlash"
	screen_flash.color = Color.WHITE
	screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_flash.visible = false
	
	# Make it cover the entire screen
	screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Add to viewport as overlay
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "FeedbackCanvas"
	canvas_layer.layer = 100  # High layer to be on top
	add_child(canvas_layer)
	canvas_layer.add_child(screen_flash)

## Updates camera shake effect
func _update_camera_shake(delta: float) -> void:
	shake_timer -= delta
	
	if shake_timer <= 0.0:
		# Shake complete, restore original position
		if camera != null:
			camera.position = original_camera_position
		shake_intensity = 0.0
		feedback_completed.emit("camera_shake")
		return
	
	# Apply random shake offset
	if camera != null:
		var shake_offset = Vector3(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		camera.position = original_camera_position + shake_offset

## Updates screen flash effect
func _update_screen_flash(delta: float) -> void:
	flash_timer -= delta
	
	if flash_timer <= 0.0:
		# Flash complete
		screen_flash.visible = false
		flash_timer = 0.0
		feedback_completed.emit("screen_flash")
		return
	
	# Fade out the flash
	var alpha = flash_timer / flash_duration
	screen_flash.modulate = Color(flash_color.r, flash_color.g, flash_color.b, alpha)

## Sets the camera reference for shake effects
func set_camera(new_camera: Camera3D) -> void:
	camera = new_camera
	if camera != null:
		original_camera_position = camera.position
