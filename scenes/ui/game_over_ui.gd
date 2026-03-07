## GameOverUI – game over and victory screen.
## Shows final score (Markah Akhir) and prompts kids to play again (Main Semula).
## Replaces Unity's GameOverUI MonoBehaviour.
class_name GameOverUI
extends CanvasLayer

@export var game_over_panel: Control
@export var victory_panel: Control
@export var final_score_label: Label
@export var high_score_label: Label
@export var main_semula_button: Button   # Play again
@export var balik_menu_button: Button    # Back to main menu

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	if game_over_panel:
		game_over_panel.hide()
	if victory_panel:
		victory_panel.hide()
	if main_semula_button:
		main_semula_button.pressed.connect(_on_play_again)
	if balik_menu_button:
		balik_menu_button.pressed.connect(_on_back_to_menu)
	GameManager.game_over.connect(show_game_over)
	GameManager.victory.connect(show_victory)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func show_game_over(score: int) -> void:
	if game_over_panel:
		game_over_panel.show()
	if final_score_label:
		final_score_label.text = "Markah Akhir: %d" % score
	_show_high_score()

func show_victory(score: int) -> void:
	if victory_panel:
		victory_panel.show()
	if final_score_label:
		final_score_label.text = "Tahniah! Markah: %d" % score
	_show_high_score()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _show_high_score() -> void:
	if high_score_label:
		high_score_label.text = "Tertinggi: %d" % ScoreManager.get_high_score()

func _on_play_again() -> void:
	GameManager.return_to_main_menu()
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_back_to_menu() -> void:
	GameManager.return_to_main_menu()
