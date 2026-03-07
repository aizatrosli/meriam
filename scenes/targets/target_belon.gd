## TargetBelon – colourful balloon tied to a post in the kampung yard.
## Floats upward slowly; when hit it pops with confetti.
## High-value but hard-to-hit bonus target.
## Replaces Unity's TargetBelon MonoBehaviour.
class_name TargetBelon
extends TargetBase

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
