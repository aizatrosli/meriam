## Unit tests for GameState (state machine).
## Mirrors Unity's GameStateMachineTests (EditMode NUnit).
extends GutTest

var sm: GameState

func before_each() -> void:
	sm = GameState.new()

func after_each() -> void:
	sm = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_initial_state_is_main_menu() -> void:
	assert_eq(sm.current_state, GameState.State.MAIN_MENU)

func test_valid_transition_main_menu_to_countdown() -> void:
	sm.transition_to(GameState.State.ROUND_COUNTDOWN)
	assert_eq(sm.current_state, GameState.State.ROUND_COUNTDOWN)

func test_valid_transition_countdown_to_playing() -> void:
	sm.transition_to(GameState.State.ROUND_COUNTDOWN)
	sm.transition_to(GameState.State.PLAYING)
	assert_eq(sm.current_state, GameState.State.PLAYING)

func test_valid_transition_playing_to_paused() -> void:
	_reach_state(GameState.State.PLAYING)
	sm.transition_to(GameState.State.PAUSED)
	assert_eq(sm.current_state, GameState.State.PAUSED)

func test_valid_transition_playing_to_game_over() -> void:
	_reach_state(GameState.State.PLAYING)
	sm.transition_to(GameState.State.GAME_OVER)
	assert_eq(sm.current_state, GameState.State.GAME_OVER)

func test_valid_transition_playing_to_round_complete() -> void:
	_reach_state(GameState.State.PLAYING)
	sm.transition_to(GameState.State.ROUND_COMPLETE)
	assert_eq(sm.current_state, GameState.State.ROUND_COMPLETE)

func test_invalid_transition_does_not_change_state() -> void:
	# Cannot go from MAIN_MENU directly to PLAYING
	sm.transition_to(GameState.State.PLAYING)
	assert_eq(sm.current_state, GameState.State.MAIN_MENU)

func test_same_state_transition_is_no_op() -> void:
	watch_signals(sm)
	sm.transition_to(GameState.State.MAIN_MENU)
	assert_signal_not_emitted(sm, "state_changed")

func test_state_changed_signal_emitted_on_valid_transition() -> void:
	watch_signals(sm)
	sm.transition_to(GameState.State.ROUND_COUNTDOWN)
	assert_signal_emitted(sm, "state_changed")

func test_state_changed_signal_carries_from_and_to() -> void:
	watch_signals(sm)
	sm.transition_to(GameState.State.ROUND_COUNTDOWN)
	assert_signal_emitted_with_parameters(sm, "state_changed", [
		GameState.State.MAIN_MENU,
		GameState.State.ROUND_COUNTDOWN
	])

func test_game_over_to_main_menu_valid() -> void:
	_reach_state(GameState.State.PLAYING)
	sm.transition_to(GameState.State.GAME_OVER)
	sm.transition_to(GameState.State.MAIN_MENU)
	assert_eq(sm.current_state, GameState.State.MAIN_MENU)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _reach_state(target: GameState.State) -> void:
	# Walk the valid transition path to reach target state
	match target:
		GameState.State.ROUND_COUNTDOWN:
			sm.transition_to(GameState.State.ROUND_COUNTDOWN)
		GameState.State.PLAYING:
			sm.transition_to(GameState.State.ROUND_COUNTDOWN)
			sm.transition_to(GameState.State.PLAYING)
		GameState.State.PAUSED:
			_reach_state(GameState.State.PLAYING)
			sm.transition_to(GameState.State.PAUSED)
		_:
			pass
