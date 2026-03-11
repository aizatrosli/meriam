## CannonProjectile – the bola meriam (cannonball) launched from the meriam buluh.
## Travels in a parabolic arc. Damages any node in the "damageable" group on contact.
## Notifies GameManager of a miss if it falls off-screen without hitting anything.
## Replaces Unity's CannonProjectile (Rigidbody2D + OnTriggerEnter2D).
##
## Node type: Area2D (trigger – matches Unity's trigger collider approach).
class_name CannonProjectile
extends Area2D

# ---------------------------------------------------------------------------
# Visual Asset Replacements
# ---------------------------------------------------------------------------
## REPLACE ME: Assign a texture for the bola meriam (cannonball).
## Suggested: a dark iron or carved-wood sphere image, approx 16×16 px,
## centred on the sprite pivot (e.g. res://assets/cannonball.png).
## The Sprite2D is pre-scaled to 0.5×, so a 32×32 source image works well.
@export var ball_texture: Texture2D

var _damage: int = 1
var _lifetime: float = 4.0
var _velocity: Vector2 = Vector2.ZERO
var _hit: bool = false  # prevents miss notification if we already hit something

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Apply exported texture to the cannonball sprite when provided by the artist.
	# Falls back to a dark-grey circle so the projectile is visible without art assets.
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		if ball_texture == null:
			ball_texture = _make_circle_texture(8, Color(0.2, 0.2, 0.2))
		sprite.texture = ball_texture

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

# ---------------------------------------------------------------------------
# Placeholder texture helper (used when no art assets are assigned)
# ---------------------------------------------------------------------------

static func _make_circle_texture(radius: int, color: Color) -> ImageTexture:
	var d := radius * 2
	var img := Image.create(d, d, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	for y in d:
		for x in d:
			var dx := x - radius
			var dy := y - radius
			if dx * dx + dy * dy <= radius * radius:
				img.set_pixel(x, y, color)
	return ImageTexture.create_from_image(img)
