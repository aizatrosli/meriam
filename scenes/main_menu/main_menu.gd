## MainMenu – main menu for Meriam Raya.
## Shows game title, high score, and mode selection:
##   Main Tempatan  (Local co-op, same device)
##   Main Dalam Talian (Online co-op)
## Replaces Unity's MainMenuController MonoBehaviour.
class_name MainMenu
extends Control

@export var main_tempatan_button: Button    # Local co-op
@export var main_dalam_talian_button: Button # Online co-op
@export var high_score_label: Label
@export var title_label: Label
@export var online_panel: Control           # Panel for join/create lobby UI
@export var join_code_input: LineEdit
@export var join_code_display_label: Label
@export var create_lobby_button: Button
@export var join_lobby_button: Button
@export var lobby_manager: LobbyManager

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	if main_tempatan_button:
		main_tempatan_button.pressed.connect(_start_local)
	if main_dalam_talian_button:
		main_dalam_talian_button.pressed.connect(_show_online_panel)
	if create_lobby_button:
		create_lobby_button.pressed.connect(_create_lobby)
	if join_lobby_button:
		join_lobby_button.pressed.connect(_join_lobby)

	if high_score_label:
		high_score_label.text = "Markah Tertinggi: %d" % ScoreManager.get_high_score()
	if online_panel:
		online_panel.hide()

	if lobby_manager:
		lobby_manager.join_code_ready.connect(_on_join_code_ready)
		lobby_manager.joined.connect(_on_lobby_joined)
		lobby_manager.error_occurred.connect(_on_lobby_error)

# ---------------------------------------------------------------------------
# Button handlers
# ---------------------------------------------------------------------------

func _start_local() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _show_online_panel() -> void:
	if online_panel:
		online_panel.show()

func _create_lobby() -> void:
	if lobby_manager:
		lobby_manager.create_lobby()

func _join_lobby() -> void:
	if lobby_manager and join_code_input:
		lobby_manager.join_lobby(join_code_input.text.strip_edges())

# ---------------------------------------------------------------------------
# Lobby signal handlers
# ---------------------------------------------------------------------------

func _on_join_code_ready(code: String) -> void:
	if join_code_display_label:
		join_code_display_label.text = "Kod: %s" % code
		join_code_display_label.show()

func _on_lobby_joined() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_lobby_error(message: String) -> void:
	push_warning("[MainMenu] Lobby error: %s" % message)
	if join_code_display_label:
		join_code_display_label.text = "Ralat: %s" % message
		join_code_display_label.show()
