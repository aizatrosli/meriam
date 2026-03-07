## CannonProjectile – the bola meriam (cannonball) launched from the meriam buluh.
## Travels in a parabolic arc. Damages any node in the "damageable" group on contact.
## Notifies GameManager of a miss if it falls off-screen without hitting anything.
## Replaces Unity's CannonProjectile (Rigidbody2D + OnTriggerEnter2D).
##
## Node type: Area2D (trigger – matches Unity's trigger collider approach).
class_name CannonProjectile
extends Area2D

var _damage: int = 1
var _lifetime: float = 4.0
var _velocity: Vector2 = Vector2.ZERO
var _hit: bool = false  # prevents miss notification if we already hit something

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# Gravity-affected movement (parabolic arc)
	_velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	position += _velocity * delta

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and not _hit:
		# Destroyed by lifetime timer without hitting anything = miss
		GameManager.on_projectile_missed()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func launch(angle_deg: float, speed: float, damage: int, lifetime: float) -> void:
	_damage = damage
	_lifetime = lifetime
	var direction := Vector2.RIGHT.rotated(deg_to_rad(-angle_deg))
	_velocity = direction * speed
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_expired)

# ---------------------------------------------------------------------------
# Collision handlers
# ---------------------------------------------------------------------------

func _on_body_entered(body: Node2D) -> void:
	_try_damage(body)

func _on_area_entered(area: Area2D) -> void:
	_try_damage(area)

func _try_damage(node: Node) -> void:
	if _hit:
		return
	if node.is_in_group("damageable") and node.has_method("take_damage"):
		_hit = true
		node.take_damage(_damage)
		queue_free()

func _on_lifetime_expired() -> void:
	if not _hit:
		queue_free()
