extends Area3D
## EnemyProjectile - Projectile fired by enemies at the player
##
## Similar to player projectile but targets player instead of enemies.

class_name EnemyProjectile

@export var speed: float = 10.0
@export var damage: int = 10
@export var lifetime: float = 5.0

var direction: Vector3 = Vector3.FORWARD
var time_alive: float = 0.0

func _ready() -> void:
	# Set up collision detection
	collision_layer = 2  # LAYER_ENEMY
	collision_mask = 1  # LAYER_PLAYER
	
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
	"""Handle collision with player."""
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	"""Handle collision with player area."""
	if area.has_method("take_damage"):
		area.take_damage(damage)
	
	queue_free()
