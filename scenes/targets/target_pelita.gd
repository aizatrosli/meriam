## TargetPelita – traditional oil lamp hung on a string.
## Swings gently; when hit the flame extinguishes with a smoke puff.
## Common sight in kampung during Ramadan / Raya night.
## Replaces Unity's TargetPelita MonoBehaviour.
class_name TargetPelita
extends TargetBase

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
