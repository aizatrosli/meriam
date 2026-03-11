## TargetBelon – colourful balloon tied to a post in the kampung yard.
## Floats upward slowly; when hit it pops with confetti.
## High-value but hard-to-hit bonus target.
## Replaces Unity's TargetBelon MonoBehaviour.
class_name TargetBelon
extends TargetBase

# ---------------------------------------------------------------------------
# Visual Asset Replacements
# ---------------------------------------------------------------------------
## REPLACE ME: Assign a Sprite2D texture for the balloon (belon).
## Suggested: a round balloon image with a highlight/sheen, approx 32×40 px,
## pivot at the bottom-centre (knot point) so it sways realistically
## (e.g. res://assets/belon.png).
@export var balloon_texture: Texture2D

## REPLACE ME: Set the balloon colour tint (applied as Sprite2D.modulate).
## Change this per-instance in the Inspector for red, blue, yellow, green variety.
## Default is festive pink for Raya celebrations.
@export var balloon_color: Color = Color(1, 0.2, 0.5, 1)

@export var drift_speed: float = 0.3
@export var drift_amplitude: float = 0.2
@export var pop_vfx_scene: PackedScene

var _start_pos: Vector2

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	super._ready()
	_start_pos = position

	# Apply exported texture and colour tint to the balloon sprite.
	# Falls back to a solid-colour circle so the balloon is visible without art assets.
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		if balloon_texture == null:
			balloon_texture = _make_circle_texture(18, balloon_color)
		sprite.texture = balloon_texture
		sprite.modulate = balloon_color

# ---------------------------------------------------------------------------
# Process
# ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	if not is_alive:
		return
	# Gentle upward drift with side-sway (mirrors Unity's Update)
	var drift := drift_amplitude * sin(Time.get_ticks_msec() * 0.001 * 1.2)
	position.x = _start_pos.x + drift
	position.y -= drift_speed * delta

# ---------------------------------------------------------------------------
# Virtual hooks
# ---------------------------------------------------------------------------

func _spawn_death_effect() -> void:
	if pop_vfx_scene:
		var vfx := pop_vfx_scene.instantiate()
		get_tree().get_root().add_child(vfx)
		vfx.global_position = global_position

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
