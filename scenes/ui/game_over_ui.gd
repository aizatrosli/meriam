## GameOverUI – game over and victory screen.
## Shows final score (Markah Akhir) and prompts kids to play again (Main Semula).
## Replaces Unity's GameOverUI MonoBehaviour.
class_name GameOverUI
extends CanvasLayer

@onready var game_over_panel: Control = $GameOverPanel
@onready var victory_panel: Control = $VictoryPanel
@onready var final_score_label: Label = $GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var high_score_label: Label = $GameOverPanel/VBoxContainer/HighScoreLabel
@onready var final_score_label_v: Label = $VictoryPanel/VBoxContainer/FinalScoreLabelV
@onready var main_semula_button: Button = $GameOverPanel/VBoxContainer/MainSemulaButton
@onready var balik_menu_button: Button = $GameOverPanel/VBoxContainer/BalikMenuButton

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	game_over_panel.hide()
	victory_panel.hide()
	main_semula_button.pressed.connect(_on_play_again)
	balik_menu_button.pressed.connect(_on_back_to_menu)
	GameManager.game_over.connect(show_game_over)
	GameManager.victory.connect(show_victory)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func show_game_over(score: int) -> void:
	game_over_panel.show()
	final_score_label.text = "Markah Akhir: %d" % score
	high_score_label.text = "Tertinggi: %d" % ScoreManager.get_high_score()

func show_victory(score: int) -> void:
	victory_panel.show()
	if final_score_label_v:
		final_score_label_v.text = "Tahniah! Markah: %d" % score

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _on_play_again() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_back_to_menu() -> void:
	GameManager.return_to_main_menu()
