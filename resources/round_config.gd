## RoundConfig – configuration for one round of the Raya night meriam game.
## Replaces Unity's RoundConfigSO ScriptableObject.
class_name RoundConfig
extends Resource

# ---------------------------------------------------------------------------
# Round Info
# ---------------------------------------------------------------------------
@export var round_number: int = 1

## Malay announcement shown before the round starts, e.g. "Pusingan 1".
@export var round_announcement_malay: String = "Pusingan 1"

# ---------------------------------------------------------------------------
# Target Spawning
# ---------------------------------------------------------------------------
@export var time_between_spawns: float = 1.5
@export var round_start_delay: float = 3.0

## Targets to spawn this round.
@export var targets: Array[TargetSpawnEntry] = []

# ---------------------------------------------------------------------------
# Scoring
# ---------------------------------------------------------------------------
@export var completion_bonus_score: int = 500
@export var time_limit: float = 60.0
