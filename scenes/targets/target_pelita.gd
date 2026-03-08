## TargetPelita – traditional oil lamp hung on a string.
## Swings gently; when hit the flame extinguishes with a smoke puff.
## Common sight in kampung during Ramadan / Raya night.
## Replaces Unity's TargetPelita MonoBehaviour.
class_name TargetPelita
extends TargetBase

# ---------------------------------------------------------------------------
# Visual Asset Replacements
# ---------------------------------------------------------------------------
## REPLACE ME: Assign a Sprite2D texture for the pelita body (lamp body).
## Suggested: a traditional clay or glass oil lamp image, approx 24×40 px,
## pivot at the suspension point (top-centre) so it swings naturally
## (e.g. res://assets/pelita_body.png).
@export var body_texture: Texture2D

## REPLACE ME: Assign a texture for the flame sprite (FlameSpriteD).
## Suggested: a small flickering flame image, approx 16×24 px, orange/yellow,
## or an AnimatedTexture with 3–4 flame frames for a lively look
## (e.g. res://assets/flame.png).
@export var flame_texture: Texture2D

## REPLACE ME: Assign a PointLight2D texture for the glow around the flame.
## Suggested: a soft radial gradient exported as a Texture2D (e.g. light_blob.png).
## Without a texture the PointLight2D still casts a coloured glow via its color property.
@export var flame_light_texture: Texture2D

@export var flame_node: Node2D
@export var smoke_vfx_scene: PackedScene
@export var swing_amplitude: float = 15.0  # degrees
@export var swing_frequency: float = 0.8   # Hz

var _swing_offset: float

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	super._ready()
	_swing_offset = randf_range(0.0, TAU)

	# Apply exported textures to sprite placeholders when provided by the artist.
	var body_sprite := get_node_or_null("Sprite2D") as Sprite2D
	if body_sprite and body_texture:
		body_sprite.texture = body_texture

	var flame_sprite := get_node_or_null("FlameNode/FlameSpriteD") as Sprite2D
	if flame_sprite and flame_texture:
		flame_sprite.texture = flame_texture

	var point_light := get_node_or_null("FlameNode/PointLight2D") as PointLight2D
	if point_light and flame_light_texture:
		point_light.texture = flame_light_texture

# ---------------------------------------------------------------------------
# Process
# ---------------------------------------------------------------------------

func _process(_delta: float) -> void:
	if not is_alive:
		return
	var t := Time.get_ticks_msec() * 0.001
	var angle := swing_amplitude * sin(t * swing_frequency * TAU + _swing_offset)
	rotation_degrees = angle

# ---------------------------------------------------------------------------
# Virtual hooks
# ---------------------------------------------------------------------------

func _on_hit() -> void:
	# Briefly dim the flame on hit (mirrors Unity's Light2D disable)
	if flame_node:
		flame_node.visible = false
		get_tree().create_timer(0.1).timeout.connect(func(): flame_node.visible = true)

func _spawn_death_effect() -> void:
	if flame_node:
		flame_node.visible = false
	if smoke_vfx_scene:
		var vfx := smoke_vfx_scene.instantiate()
		get_tree().get_root().add_child(vfx)
		vfx.global_position = global_position
