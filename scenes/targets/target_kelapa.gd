## TargetKelapa – coconut placed on a post or stacked in the yard.
## When hit it tumbles and rolls away with a satisfying thunk.
## Replaces Unity's TargetKelapa MonoBehaviour (Rigidbody2D physics).
##
## Node type: RigidBody2D (physics body that can roll).
class_name TargetKelapa
extends RigidBody2D

# ---------------------------------------------------------------------------
# Visual Asset Replacements
# ---------------------------------------------------------------------------
## REPLACE ME: Assign a Sprite2D texture for the kelapa (coconut).
## Suggested: a round brown coconut viewed from above, approx 40×40 px,
## so the circular collider (radius 20) wraps it cleanly
## (e.g. res://assets/kelapa.png).
@export var body_texture: Texture2D

## REPLACE ME: Assign an AudioStream for the coconut-hit thunk sound.
## Suggested: a wooden knock or coconut impact clip in OGG format
## (e.g. res://assets/audio/kelapa_hit.ogg).
@export var hit_sound: AudioStream

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

	# Apply exported texture to the kelapa sprite when provided by the artist.
	# Falls back to a brown circle so the coconut is visible without art assets.
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		if body_texture == null:
			body_texture = _make_circle_texture(20, Color(0.45, 0.28, 0.10))
		sprite.texture = body_texture

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

	# Play hit sound if an AudioStreamPlayer2D child node is present in the scene.
	var audio := get_node_or_null("AudioStreamPlayer2D") as AudioStreamPlayer2D
	if audio and hit_sound:
		audio.stream = hit_sound
		audio.play()

func _on_death() -> void:
	var score_value: int = config.score_value if config else 100
	GameManager.on_target_defeated(score_value)
	# Don't destroy immediately – let it roll first
	get_tree().create_timer(1.5).timeout.connect(queue_free)

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
