## Game – root script for the main gameplay scene.
## Wires together GameManager, RoundManager, cannon, players, and UI.
class_name Game
extends Node2D

@export var config: GameConfig
@export var round_manager: RoundManager
@export var cannon: Cannon
@export var hud: HUD
@export var round_announcement: RoundAnnouncementUI
@export var game_over_ui: GameOverUI
@export var network_manager: NetworkGameManager

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Wire round manager to HUD
	if round_manager and hud:
		round_manager.round_started.connect(hud.update_round)
		round_manager.round_started.connect(_on_round_started)

	# Wire GameManager signals
	GameManager.round_manager = round_manager

	# Start the game
	GameManager.start_game(config)
	round_manager.start_round(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if GameManager.state_machine.current_state == GameState.State.PLAYING:
			GameManager.pause_game()
		elif GameManager.state_machine.current_state == GameState.State.PAUSED:
			GameManager.resume_game()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _on_round_started(round_number: int) -> void:
	if round_announcement and config and config.rounds.size() >= round_number:
		var round_cfg: RoundConfig = config.rounds[round_number - 1]
		round_announcement.show_round_announcement(round_number, round_cfg.round_announcement_malay)
