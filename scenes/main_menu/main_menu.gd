## MainMenu – main menu for Meriam Raya.
## Shows game title, high score, and mode selection:
##   Main Tempatan  (Local co-op, same device)
##   Main Dalam Talian (Online co-op)
## Replaces Unity's MainMenuController MonoBehaviour.
class_name MainMenu
extends Control

@onready var main_tempatan_button: Button = $CenterContainer/VBoxContainer/MainTempatanButton
@onready var main_dalam_talian_button: Button = $CenterContainer/VBoxContainer/MainDalamTalianButton
@onready var high_score_label: Label = $CenterContainer/VBoxContainer/HighScoreLabel
@onready var online_panel: Control = $CenterContainer/VBoxContainer/OnlinePanel
@onready var create_lobby_button: Button = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/CreateLobbyButton
@onready var join_lobby_button: Button = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/JoinLobbyButton
@onready var join_code_input: LineEdit = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/JoinCodeInput
@onready var join_code_display_label: Label = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/JoinCodeDisplayLabel
@onready var lobby_manager: LobbyManager = $LobbyManager

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	main_tempatan_button.pressed.connect(_start_local)
	main_dalam_talian_button.pressed.connect(_show_online_panel)
	create_lobby_button.pressed.connect(_create_lobby)
	join_lobby_button.pressed.connect(_join_lobby)

	high_score_label.text = "Markah Tertinggi: %d" % ScoreManager.get_high_score()
	online_panel.hide()
	join_code_display_label.hide()

	lobby_manager.join_code_ready.connect(_on_join_code_ready)
	lobby_manager.joined.connect(_on_lobby_joined)
	lobby_manager.error_occurred.connect(_on_lobby_error)

# ---------------------------------------------------------------------------
# Button handlers
# ---------------------------------------------------------------------------

func _start_local() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _show_online_panel() -> void:
	online_panel.show()

func _create_lobby() -> void:
	lobby_manager.create_lobby()

func _join_lobby() -> void:
	lobby_manager.join_lobby(join_code_input.text.strip_edges())

# ---------------------------------------------------------------------------
# Lobby signal handlers
# ---------------------------------------------------------------------------

func _on_join_code_ready(code: String) -> void:
	join_code_display_label.text = "Kod: %s" % code
	join_code_display_label.show()

func _on_lobby_joined() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_lobby_error(message: String) -> void:
	push_warning("[MainMenu] Lobby error: %s" % message)
	join_code_display_label.text = "Ralat: %s" % message
	join_code_display_label.show()
