## TargetKelapa – coconut placed on a post or stacked in the yard.
## When hit it tumbles and rolls away with a satisfying thunk.
## Replaces Unity's TargetKelapa MonoBehaviour (Rigidbody2D physics).
##
## Node type: RigidBody2D (physics body that can roll).
class_name TargetKelapa
extends RigidBody2D

@export var config: TargetConfig
@export var roll_force: float = 200.0

var _current_health: int = 0

var max_health: int:
	get: return config.base_health if config else 1
var is_alive: bool:
	get: return _current_health > 0

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	add_to_group("damageable")
	_current_health = max_health
	freeze = true  # kinematic until hit

func initialize(health_multiplier: float = 1.0) -> void:
	_current_health = maxi(1, roundi(max_health * health_multiplier))

# ---------------------------------------------------------------------------
# IDamageable (duck-typed)
# ---------------------------------------------------------------------------

func take_damage(amount: int) -> void:
	if not is_alive or amount <= 0:
		return
	_current_health -= amount
	_on_hit()
	if _current_health <= 0:
		_on_death()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _on_hit() -> void:
	# Release physics – let it roll away (mirrors Unity's AddForce / AddTorque)
	freeze = false
	apply_central_impulse(Vector2.RIGHT * roll_force)
	apply_torque_impulse(roll_force * 0.5)

func _on_death() -> void:
	var score_value: int = config.score_value if config else 100
	GameManager.on_target_defeated(score_value)
	# Don't destroy immediately – let it roll first
	get_tree().create_timer(1.5).timeout.connect(queue_free)
