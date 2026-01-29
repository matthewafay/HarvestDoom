extends EnemyBase
## TankEnemy - Slow, high-health enemy that advances toward player
##
## Continues advancing slowly even when damaged, with high health and armor.
##
## Validates: Requirements 3.3, 3.5

class_name TankEnemy

@export var armor: int = 50
@export var attack_range: float = 2.0

func _ready() -> void:
	super._ready()
	
	# Override stats for tank enemy
	max_health = 200
	current_health = max_health
	move_speed = 1.5
	damage = 25

func _update_ai(delta: float) -> void:
	"""Continue advancing slowly toward player.
	
	Validates: Requirement 3.3
	"""
	if not target:
		return
	
	# Always move toward player (slow but steady)
	var direction = get_direction_to_player()
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# Attack if in range
	if is_player_in_range(attack_range):
		attack_player()

func take_damage(amount: int) -> void:
	"""Apply damage with armor reduction.
	
	Tank has armor that reduces incoming damage.
	"""
	if is_dead:
		return
	
	# Reduce damage by armor percentage
	var armor_reduction = armor / 100.0
	var actual_damage = int(amount * (1.0 - armor_reduction))
	
	# Ensure at least 1 damage gets through
	if actual_damage < 1:
		actual_damage = 1
	
	current_health -= actual_damage
	
	# Visual feedback
	_show_damage_feedback(actual_damage)
	
	# Check for death
	if current_health <= 0:
		die()
	
	# Tank continues advancing even when damaged (no knockback or stun)
