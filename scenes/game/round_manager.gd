## RoundManager – sequences rounds from GameConfig.rounds[].
## Drives TargetSpawner with the current RoundConfig.
## Replaces Unity's RoundManager MonoBehaviour.
class_name RoundManager
extends Node

@export var config: GameConfig
@export var target_spawner: TargetSpawner

var current_round_index: int = -1
var targets_remaining_in_round: int = 0

var is_last_round: bool:
	get: return current_round_index >= config.rounds.size() - 1

## Emitted when a new round starts. Arg: round number (1-based).
signal round_started(round_number: int)
## Emitted when a round ends. Arg: round number (1-based).
signal round_complete(round_number: int)
## Emitted when all rounds have been completed.
signal all_rounds_complete()

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	GameManager.target_hit.connect(_on_target_hit)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func start_round(round_index: int) -> void:
	if round_index < 0 or round_index >= config.rounds.size():
		push_error("[RoundManager] Invalid round index: %d" % round_index)
		return
	current_round_index = round_index
	var round_cfg: RoundConfig = config.rounds[round_index]
	targets_remaining_in_round = _count_targets(round_cfg)
	target_spawner.spawn_round(round_cfg)
	round_started.emit(round_index + 1)
	GameManager.state_machine.transition_to(GameState.State.PLAYING)

func advance_round() -> void:
	if is_last_round:
		all_rounds_complete.emit()
		GameManager.on_all_rounds_complete()
		return
	var next := current_round_index + 1
	GameManager.on_round_complete(next + 1)
	round_complete.emit(next)
	start_round(next)

func register_target_defeated() -> void:
	targets_remaining_in_round = maxi(0, targets_remaining_in_round - 1)
	if targets_remaining_in_round == 0:
		round_complete.emit(current_round_index + 1)
		await get_tree().create_timer(1.5).timeout
		advance_round()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _count_targets(round_cfg: RoundConfig) -> int:
	var total := 0
	for entry: TargetSpawnEntry in round_cfg.targets:
		total += entry.count
	return total

func _on_target_hit(_score_value: int) -> void:
	register_target_defeated()
