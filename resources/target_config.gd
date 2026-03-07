## TargetConfig – data for a single target type in the Raya night scene.
## Replaces Unity's TargetConfigSO ScriptableObject.
## Examples: Pelita (oil lamp), Kelapa (coconut), Belon (balloon).
class_name TargetConfig
extends Resource

enum TargetType {
	STATIONARY,  ## Periuk, Pasu Bunga
	SWINGING,    ## Pelita (oil lamp on string), Tanglung (lantern)
	ROLLING,     ## Kelapa (coconut)
	FLOATING,    ## Belon (balloon) drifts upward slowly
}

# ---------------------------------------------------------------------------
# Identity
# ---------------------------------------------------------------------------
@export var target_id: String = ""
## Malay name shown in UI, e.g. "Pelita", "Kelapa".
@export var display_name_malay: String = ""

# ---------------------------------------------------------------------------
# Stats
# ---------------------------------------------------------------------------
@export var base_health: int = 1
@export var score_value: int = 100

# ---------------------------------------------------------------------------
# Scene
# ---------------------------------------------------------------------------
@export var scene: PackedScene

# ---------------------------------------------------------------------------
# Behaviour
# ---------------------------------------------------------------------------
@export var type: TargetType = TargetType.STATIONARY
## Does the target swing or sway? True for hanging targets like pelita.
@export var is_swinging: bool = false
## Does the target move across the yard? True for rolling coconuts.
@export var is_moving: bool = false
@export var move_speed: float = 1.0
