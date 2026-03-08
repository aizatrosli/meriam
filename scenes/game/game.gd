## Game – root script for the main gameplay scene.
## Wires all sub-systems together at runtime after the scene tree is ready.
class_name Game
extends Node2D

@export var config: GameConfig

@onready var cannon: Cannon = $Cannon
@onready var target_spawner: TargetSpawner = $TargetSpawner
@onready var round_manager: RoundManager = $RoundManager
@onready var p1: Player1Controller = $Player1Controller
@onready var p2: Player2Controller = $Player2Controller
@onready var player_input_router: PlayerInputRouter = $PlayerInputRouter
@onready var network_manager: NetworkGameManager = $NetworkGameManager
@onready var hud: HUD = $HUD
@onready var round_announcement: RoundAnnouncementUI = $RoundAnnouncementUI
@onready var camera: CameraShake = $CameraShake

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	assert(config != null, "Game: config must be assigned in Inspector")

	# Push config down into cannon sub-components
	cannon.set_config(config)

	# Wire player controllers to cannon
	p1.aimer = cannon.aimer
	p2.loader = cannon.loader
	p2.firer = cannon.firer

	# Wire input router
	player_input_router.player1 = p1
	player_input_router.player2 = p2
	player_input_router.config = config

	# Wire network manager
	network_manager.cannon = cannon
	network_manager.player_input_router = player_input_router

	# Wire target spawner to round manager
	round_manager.config = config
	round_manager.target_spawner = target_spawner

	# Wire HUD reload indicator
	hud.cannon_loader = cannon.loader

	# Wire round manager events
	round_manager.round_started.connect(hud.update_round)
	round_manager.round_started.connect(_on_round_started)

	# Register round manager with GameManager
	GameManager.round_manager = round_manager

	# Wire camera shake
	cannon.firer.fired.connect(func(): camera.shake(6.0, 0.2))
	GameManager.life_lost.connect(func(_l): camera.shake(10.0, 0.35))

	# Start the game
	GameManager.start_game(config)
	round_manager.start_round(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match GameManager.state_machine.current_state:
			GameState.State.PLAYING:
				GameManager.pause_game()
			GameState.State.PAUSED:
				GameManager.resume_game()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _on_round_started(round_number: int) -> void:
	if config and config.rounds.size() >= round_number:
		var round_cfg: RoundConfig = config.rounds[round_number - 1]
		round_announcement.show_round_announcement(
			round_number,
			round_cfg.round_announcement_malay
		)
