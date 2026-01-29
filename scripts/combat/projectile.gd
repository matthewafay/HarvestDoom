extends Area3D
## Projectile - Bullet/projectile that damages enemies
##
## Handles projectile movement, collision detection, and damage application.
##
## Responsibilities:
## - Move in a straight line at constant speed
## - Detect collisions with enemies and environment
## - Apply damage to enemies on hit
## - Self-destruct after lifetime or collision
##
## Validates: Requirements 2.3, 3.5

class_name Projectile

# Projectile properties
@export var speed: float = 20.0
@export var damage: int = 10
@export var lifetime: float = 5.0

# Movement
var direction: Vector3 = Vector3.FORWARD
var time_alive: float = 0.0

func _ready() -> void:
	# Set up collision detection
	collision_layer = 4  # LAYER_PROJECTILE
	collision_mask = 10  # LAYER_ENEMY (2) + LAYER_ENVIRONMENT (8)
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# Move projectile
	global_position += direction * speed * delta
	
	# Track lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	"""Handle collision with a physics body."""
	# Check if it's an enemy
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Destroy projectile on any collision
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	"""Handle collision with an area."""
	# Check if it's an enemy
	if area.has_method("take_damage"):
		area.take_damage(damage)
	
	# Destroy projectile
	queue_free()
