## TargetBase – abstract base for all Raya night targets in the kampung yard.
## Add to the "damageable" group so CannonProjectile can find it via group query.
## Replaces Unity's abstract TargetBase MonoBehaviour + IDamageable interface.
class_name TargetBase
extends Node2D

@export var config: TargetConfig

var _current_health: int = 0

var max_health: int:
	get: return config.base_health if config else 1
var current_health: int:
	get: return _current_health
var is_alive: bool:
	get: return _current_health > 0

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	add_to_group("damageable")
	_current_health = max_health

func initialize(health_multiplier: float = 1.0) -> void:
	_current_health = maxi(1, roundi(max_health * health_multiplier))

# ---------------------------------------------------------------------------
# IDamageable interface (via duck-typing / group membership)
# ---------------------------------------------------------------------------

func take_damage(amount: int) -> void:
	if not is_alive or amount <= 0:
		return
	_current_health -= amount
	_on_hit()
	if _current_health <= 0:
		_on_death()

# ---------------------------------------------------------------------------
# Virtual hooks (override in subclasses)
# ---------------------------------------------------------------------------

## Called on every hit (VFX: pelita flickers, pot wobbles).
func _on_hit() -> void:
	pass

## Called when health reaches zero.
func _on_death() -> void:
	var score_value: int = config.score_value if config else 100
	GameManager.on_target_defeated(score_value)
	_spawn_death_effect()
	queue_free()

## Override to play themed destruction effects:
##   Pelita: extinguish + smoke puff
##   Kelapa: tumble/roll away
##   Belon: pop + confetti
func _spawn_death_effect() -> void:
	pass
