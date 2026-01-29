extends EnemyBase
## MeleeCharger - Fast melee enemy that charges at the player
##
## Moves directly toward the player at high speed and deals damage on collision.
##
## Validates: Requirements 3.1, 3.5

class_name MeleeCharger

@export var charge_speed: float = 8.0
@export var attack_range: float = 1.5

func _ready() -> void:
	super._ready()
	
	# Override stats for melee charger
	max_health = 50
	current_health = max_health
	move_speed = charge_speed
	damage = 15

func _update_ai(delta: float) -> void:
	"""Move directly toward player at high speed.
	
	Validates: Requirement 3.1
	"""
	if not target:
		return
	
	# Get direction to player
	var direction = get_direction_to_player()
	
	# Move toward player
	velocity.x = direction.x * charge_speed
	velocity.z = direction.z * charge_speed
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# Attack if in range
	if is_player_in_range(attack_range):
		attack_player()

func _on_body_entered(body: Node) -> void:
	"""Handle collision with player."""
	if body == target:
		attack_player()
