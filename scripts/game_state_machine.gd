## GameState – enum-driven state machine for the Meriam Raya game flow.
## Replaces Unity's GameStateMachine pure C# class.
## Plain GDScript object (not a Node) – easily unit-tested.
class_name GameState
extends RefCounted

enum State {
	MAIN_MENU,
	ROUND_COUNTDOWN,
	PLAYING,
	PAUSED,
	ROUND_COMPLETE,
	GAME_OVER,
	VICTORY,
}

var current_state: State = State.MAIN_MENU

## Emitted when a valid transition occurs. Args: (from_state, to_state).
signal state_changed(from_state: State, to_state: State)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func transition_to(new_state: State) -> void:
	if new_state == current_state:
		return
	if not _is_valid_transition(current_state, new_state):
		push_warning("[GameState] Invalid transition: %s -> %s" % [
			State.keys()[current_state], State.keys()[new_state]
		])
		return
	var previous := current_state
	current_state = new_state
	state_changed.emit(previous, current_state)

# ---------------------------------------------------------------------------
# Transition table (mirrors Unity's C# switch expression)
# ---------------------------------------------------------------------------

static func _is_valid_transition(from: State, to: State) -> bool:
	match from:
		State.MAIN_MENU:
			return to == State.ROUND_COUNTDOWN
		State.ROUND_COUNTDOWN:
			return to == State.PLAYING
		State.PLAYING:
			return to in [State.PAUSED, State.ROUND_COMPLETE, State.GAME_OVER]
		State.PAUSED:
			return to in [State.PLAYING, State.MAIN_MENU]
		State.ROUND_COMPLETE:
			return to in [State.ROUND_COUNTDOWN, State.VICTORY]
		State.GAME_OVER:
			return to == State.MAIN_MENU
		State.VICTORY:
			return to == State.MAIN_MENU
	return false
