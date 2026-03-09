## Game – root script for the main gameplay scene.
## Wires all sub-systems together at runtime after the scene tree is ready.
class_name Game
extends Node2D

@export var config: GameConfig

## Use get_node_or_null for instanced PackedScenes (Cannon, HUD, RoundAnnouncementUI,
## GameOverUI). Without .godot/uid_cache.bin these silently fail to instantiate —
## see Godot issue #96126. load() by res:// path bypasses the uid cache entirely,
## so _ready() recovers them programmatically when missing (see below).
@onready var cannon: Cannon                       = get_node_or_null("Cannon") as Cannon
@onready var hud: HUD                             = get_node_or_null("HUD") as HUD
@onready var round_announcement: RoundAnnouncementUI = get_node_or_null("RoundAnnouncementUI") as RoundAnnouncementUI

@onready var target_spawner: TargetSpawner        = $TargetSpawner
@onready var round_manager: RoundManager          = $RoundManager
@onready var p1: Player1Controller                = $Player1Controller
@onready var p2: Player2Controller                = $Player2Controller
@onready var player_input_router: PlayerInputRouter = $PlayerInputRouter
@onready var network_manager: NetworkGameManager  = $NetworkGameManager
@onready var camera: CameraShake                  = $CameraShake

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	assert(config != null, "Game: config must be assigned in Inspector")

	# Fallback: if instanced PackedScenes are null (Godot issue #96126 —
	# uid_cache.bin missing without .godot/), load them by res:// path which
	# bypasses the uid cache and always works on any machine.
	if cannon == null:
		cannon = (load("res://scenes/cannon/cannon.tscn") as PackedScene).instantiate() as Cannon
		cannon.position = Vector2(100, 580)
		add_child(cannon)
	if hud == null:
		hud = (load("res://scenes/ui/hud.tscn") as PackedScene).instantiate() as HUD
		hud.score_popup_scene = load("res://scenes/ui/score_popup.tscn") as PackedScene
		add_child(hud)
	if round_announcement == null:
		round_announcement = \
			(load("res://scenes/ui/round_announcement.tscn") as PackedScene).instantiate() \
			as RoundAnnouncementUI
		add_child(round_announcement)
	if not has_node("GameOverUI"):
		var gou := (load("res://scenes/ui/game_over_ui.tscn") as PackedScene).instantiate()
		gou.name = "GameOverUI"
		add_child(gou)

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
	network_manager.assign_local_role()

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
