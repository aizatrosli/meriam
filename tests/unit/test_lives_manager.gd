## Unit tests for LivesManager.
## Mirrors Unity's LivesManagerTests (EditMode NUnit).
extends GutTest

var lives_manager: LivesManager

func before_each() -> void:
	lives_manager = LivesManager.new()
	lives_manager.initialize(3)

func after_each() -> void:
	lives_manager = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_initialize_sets_lives_to_starting_count() -> void:
	assert_eq(lives_manager.lives_remaining, 3)

func test_lose_life_decrements_lives() -> void:
	lives_manager.lose_life()
	assert_eq(lives_manager.lives_remaining, 2)

func test_is_game_over_false_when_lives_above_zero() -> void:
	assert_false(lives_manager.is_game_over)

func test_is_game_over_true_when_lives_reach_zero() -> void:
	lives_manager.lose_life()
	lives_manager.lose_life()
	lives_manager.lose_life()
	assert_true(lives_manager.is_game_over)

func test_lose_life_does_not_go_below_zero() -> void:
	lives_manager.lose_life()
	lives_manager.lose_life()
	lives_manager.lose_life()
	lives_manager.lose_life()  # extra call
	assert_eq(lives_manager.lives_remaining, 0)

func test_life_lost_signal_emitted() -> void:
	watch_signals(lives_manager)
	lives_manager.lose_life()
	assert_signal_emitted(lives_manager, "life_lost")

func test_game_over_signal_emitted_when_last_life_lost() -> void:
	watch_signals(lives_manager)
	lives_manager.lose_life()
	lives_manager.lose_life()
	lives_manager.lose_life()
	assert_signal_emitted(lives_manager, "game_over")

func test_game_over_signal_not_emitted_prematurely() -> void:
	watch_signals(lives_manager)
	lives_manager.lose_life()
	assert_signal_not_emitted(lives_manager, "game_over")
