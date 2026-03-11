## GameManager – top-level autoload singleton that wires subsystems together.
## Replaces Unity's GameManager MonoBehaviour singleton.
##
## Scene: kampung yard at night, Ramadan / Raya celebration.
## Two kids co-operate:
##   Anak Sulung (Player 1) – aims the meriam barrel.
##   Anak Bongsu (Player 2) – loads and fires.
extends Node

# ---------------------------------------------------------------------------
# Signals (replaces Unity's GameEventSO event bus)
# ---------------------------------------------------------------------------
signal target_hit(score_value: int)
signal round_complete(round_number: int)
signal game_over(final_score: int)
signal victory(final_score: int)
signal life_lost(lives_remaining: int)
signal state_changed(from_state: GameState.State, to_state: GameState.State)

# ---------------------------------------------------------------------------
# Sub-systems (created here, not MonoBehaviours)
# ---------------------------------------------------------------------------
var lives_manager: LivesManager
var state_machine: GameState

# ---------------------------------------------------------------------------
# References (set by the game scene on load)
# ---------------------------------------------------------------------------
var round_manager: Node = null  # set by game.gd

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	lives_manager = LivesManager.new()
	state_machine = GameState.new()
	state_machine.state_changed.connect(_on_state_changed)

# ---------------------------------------------------------------------------
# Game Flow API
# ---------------------------------------------------------------------------

func start_game(config: GameConfig) -> void:
	ScoreManager.reset_score()
	lives_manager.initialize(config.starting_lives)
	# Force-reset state so re-plays work (GAME_OVER/VICTORY → MAIN_MENU → ROUND_COUNTDOWN)
	state_machine.current_state = GameState.State.MAIN_MENU
	_transition(GameState.State.ROUND_COUNTDOWN)

func on_target_defeated(score_value: int) -> void:
	ScoreManager.add_score(score_value)
	target_hit.emit(score_value)

func on_projectile_missed() -> void:
	if state_machine.current_state != GameState.State.PLAYING:
		return
	lives_manager.lose_life()
	life_lost.emit(lives_manager.lives_remaining)
	if lives_manager.is_game_over:
		_trigger_game_over()

func on_round_complete(round_number: int) -> void:
	_transition(GameState.State.ROUND_COMPLETE)
	round_complete.emit(round_number)

func on_all_rounds_complete() -> void:
	_transition(GameState.State.VICTORY)
	victory.emit(ScoreManager.get_current_score())

func pause_game() -> void:
	_transition(GameState.State.PAUSED)
	get_tree().paused = true

func resume_game() -> void:
	_transition(GameState.State.PLAYING)
	get_tree().paused = false

func return_to_main_menu() -> void:
	get_tree().paused = false
	# Transition state to MAIN_MENU so the state machine is clean for the next game.
	# Force it directly since GAME_OVER/VICTORY → MAIN_MENU is the only valid path.
	state_machine.current_state = GameState.State.MAIN_MENU
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

func _trigger_game_over() -> void:
	_transition(GameState.State.GAME_OVER)
	game_over.emit(ScoreManager.get_current_score())

func _transition(new_state: GameState.State) -> void:
	state_machine.transition_to(new_state)

func _on_state_changed(from: GameState.State, to: GameState.State) -> void:
	state_changed.emit(from, to)
