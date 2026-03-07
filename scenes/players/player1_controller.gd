## Player1Controller – Anak Sulung (Elder Child) controls aiming the meriam barrel.
## Receives processed aim deltas from PlayerInputRouter.
## Replaces Unity's Player1Controller MonoBehaviour.
class_name Player1Controller
extends Node

@export var aimer: CannonAimer

# ---------------------------------------------------------------------------
# Public API (called by PlayerInputRouter)
# ---------------------------------------------------------------------------

func on_aim_input(delta_angle: float) -> void:
	aimer.adjust_aim(delta_angle)
