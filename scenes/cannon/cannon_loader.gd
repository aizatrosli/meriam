## CannonLoader – controlled by Player 2 (Anak Bongsu).
## Player must hold the load button for load_duration seconds to fully
## pack the meriam with gunpowder. Releasing early resets progress.
## Replaces Unity's CannonLoader MonoBehaviour.
class_name CannonLoader
extends Node

## Injected by Cannon._ready() or game.gd
var config: GameConfig = null

var is_loaded: bool = false
var load_progress: float = 0.0  # 0.0 – 1.0
var _load_timer: float = 0.0
var _is_loading: bool = false

var load_duration: float:
	get: return config.cannon_load_duration if config else 2.0

## Emitted when loading completes (progress reaches 1.0).
signal load_complete()

# ---------------------------------------------------------------------------
# Process
# ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	if not _is_loading or is_loaded:
		return
	_load_timer += delta
	load_progress = clampf(_load_timer / load_duration, 0.0, 1.0)
	if _load_timer >= load_duration:
		is_loaded = true
		_is_loading = false
		load_complete.emit()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func set_config(cfg: GameConfig) -> void:
	config = cfg

func begin_loading() -> void:
	if is_loaded:
		return
	_is_loading = true

func cancel_loading() -> void:
	_is_loading = false
	_load_timer = 0.0
	load_progress = 0.0
	is_loaded = false

## Instantly complete loading (used in tests / debug).
func force_load() -> void:
	_load_timer = load_duration
	load_progress = 1.0
	is_loaded = true
	_is_loading = false
	load_complete.emit()
