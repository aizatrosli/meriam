## Unit tests for ScoreManager autoload.
## Mirrors Unity's ScoreManagerTests (EditMode NUnit).
extends GutTest

var score_manager: Node

func before_each() -> void:
	# Instantiate a fresh ScoreManager for each test (not the autoload singleton)
	score_manager = load("res://autoloads/score_manager.gd").new()
	score_manager.reset_score()

func after_each() -> void:
	score_manager.free()

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_initial_score_is_zero() -> void:
	assert_eq(score_manager.get_current_score(), 0, "Score should start at 0")

func test_add_score_increases_current_score() -> void:
	score_manager.add_score(100)
	assert_eq(score_manager.get_current_score(), 100)

func test_add_score_accumulates() -> void:
	score_manager.add_score(100)
	score_manager.add_score(250)
	assert_eq(score_manager.get_current_score(), 350)

func test_add_zero_does_not_change_score() -> void:
	score_manager.add_score(0)
	assert_eq(score_manager.get_current_score(), 0)

func test_add_negative_does_not_change_score() -> void:
	score_manager.add_score(-50)
	assert_eq(score_manager.get_current_score(), 0)

func test_reset_score_returns_to_zero() -> void:
	score_manager.add_score(500)
	score_manager.reset_score()
	assert_eq(score_manager.get_current_score(), 0)

func test_score_changed_signal_emitted_on_add() -> void:
	watch_signals(score_manager)
	score_manager.add_score(100)
	assert_signal_emitted(score_manager, "score_changed")

func test_score_changed_signal_emitted_on_reset() -> void:
	watch_signals(score_manager)
	score_manager.reset_score()
	assert_signal_emitted(score_manager, "score_changed")

func test_score_changed_signal_carries_new_score() -> void:
	watch_signals(score_manager)
	score_manager.add_score(200)
	assert_signal_emitted_with_parameters(score_manager, "score_changed", [200])
