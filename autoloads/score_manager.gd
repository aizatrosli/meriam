## ScoreManager – autoload singleton for score accounting.
## Replaces Unity's ScoreManager pure C# class.
## Pure logic: no Node dependencies. Easily unit-tested.
extends Node

const HIGH_SCORE_KEY := "MeriamRaya_HighScore"

var current_score: int = 0

## Emitted whenever the score changes. Arg: new score.
signal score_changed(new_score: int)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func get_current_score() -> int:
	return current_score

func get_high_score() -> int:
	return ProjectSettings.get_setting("application/run/high_score", 0) \
		if not _config_file.has_section_key("scores", HIGH_SCORE_KEY) \
		else _config_file.get_value("scores", HIGH_SCORE_KEY, 0)

func add_score(points: int) -> void:
	if points <= 0:
		return
	current_score += points
	if current_score > get_high_score():
		_save_high_score(current_score)
	score_changed.emit(current_score)

func reset_score() -> void:
	current_score = 0
	score_changed.emit(current_score)

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

var _config_file := ConfigFile.new()
const _SAVE_PATH := "user://meriam_raya_save.cfg"

func _ready() -> void:
	_config_file.load(_SAVE_PATH)

func _save_high_score(score: int) -> void:
	_config_file.set_value("scores", HIGH_SCORE_KEY, score)
	_config_file.save(_SAVE_PATH)
