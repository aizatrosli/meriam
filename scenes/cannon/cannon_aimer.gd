## CannonAimer – controlled by Player 1 (Anak Sulung).
## Rotates the meriam buluh barrel pivot within [min_angle, max_angle].
## Locks aiming during the cooldown after a shot.
## Replaces Unity's CannonAimer MonoBehaviour.
class_name CannonAimer
extends Node2D

## Set by Cannon._ready() – the Node2D whose rotation_degrees drives the barrel.
var barrel_pivot: Node2D = null

## Set by Cannon._ready() via cannon.gd reading from GameConfig resource.
var config: GameConfig = null

var current_angle: float = 0.0
var is_locked: bool = false

var min_angle: float:
	get: return config.min_aim_angle if config else 0.0
var max_aim_angle: float:
	get: return config.max_aim_angle if config else 75.0

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func set_config(cfg: GameConfig) -> void:
	config = cfg

func adjust_aim(delta_angle: float) -> void:
	if is_locked:
		return
	set_aim_angle(current_angle + delta_angle)

func set_aim_angle(angle: float) -> void:
	if is_locked:
		return
	current_angle = clampf(angle, min_angle, max_aim_angle)
	_apply_rotation()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _apply_rotation() -> void:
	if barrel_pivot:
		barrel_pivot.rotation_degrees = current_angle
