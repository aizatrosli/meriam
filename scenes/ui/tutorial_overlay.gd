## TutorialOverlayUI – step-by-step "How to Play" shown when a new game starts.
## Pauses the scene tree until dismissed; emits tutorial_completed to let game.gd
## start the first round. Bilingual Malay / English, 5 steps.
class_name TutorialOverlayUI
extends CanvasLayer

signal tutorial_completed

const STEPS: Array[Dictionary] = [
	{
		"title": "Selamat Datang! / Welcome!",
		"body": "Dua pemain bekerjasama menembak sasaran!\nTwo players cooperate to hit targets!\n\nTekan Seterusnya untuk belajar cara bermain.\nPress Next to learn how to play."
	},
	{
		"title": "Pemain 1 – Anak Sulung (Menunjuk)",
		"body": "Tekan  W  →  Tunjuk ke ATAS\nTekan  S  →  Tunjuk ke BAWAH\n\nPlayer 1: Press W to aim UP, S to aim DOWN."
	},
	{
		"title": "Pemain 2 – Anak Bongsu (Mengisi)",
		"body": "Tahan  SPACE  untuk mengisi meriam.\nLepaskan untuk berhenti mengisi.\n\nPlayer 2: Hold SPACE to load the cannon."
	},
	{
		"title": "Pemain 2 – Anak Bongsu (Menembak)",
		"body": "Apabila meriam sudah sedia (bar penuh),\ntekan  ENTER  untuk menembak!\n\nPlayer 2: Press ENTER to fire when loaded!"
	},
	{
		"title": "Sasaran & Nyawa / Targets & Lives",
		"body": "Pelita  =  100 mata      Kelapa  =  150 mata      Belon  =  200 mata\n\nAnda ada 3 nyawa. Setiap tembakan gagal = –1 nyawa!\nYou have 3 lives. Each miss costs 1 life. Good luck!"
	},
]

var _current_step: int = 0

@onready var background: ColorRect        = $Background
@onready var panel: Control               = $Panel
@onready var step_label: Label            = $Panel/VBoxContainer/StepLabel
@onready var title_label: Label           = $Panel/VBoxContainer/TitleLabel
@onready var body_label: Label            = $Panel/VBoxContainer/BodyLabel
@onready var skip_button: Button          = $Panel/VBoxContainer/ButtonRow/SkipButton
@onready var next_button: Button          = $Panel/VBoxContainer/ButtonRow/NextButton

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	panel.hide()
	background.hide()
	skip_button.pressed.connect(_complete)
	next_button.pressed.connect(_on_next)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func show_tutorial() -> void:
	_current_step = 0
	_update_display()
	background.modulate.a = 0.0
	background.show()
	panel.modulate.a = 0.0
	panel.show()
	get_tree().paused = true
	var tw := create_tween()
	tw.tween_property(background, "modulate:a", 1.0, 0.3)
	tw.parallel().tween_property(panel, "modulate:a", 1.0, 0.3)

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _on_next() -> void:
	_current_step += 1
	if _current_step >= STEPS.size():
		_complete()
	else:
		_update_display()

func _complete() -> void:
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 0.0, 0.2)
	tw.parallel().tween_property(background, "modulate:a", 0.0, 0.2)
	await tw.finished
	panel.hide()
	background.hide()
	get_tree().paused = false
	tutorial_completed.emit()

func _update_display() -> void:
	var step: Dictionary = STEPS[_current_step]
	step_label.text = "%d / %d" % [_current_step + 1, STEPS.size()]
	title_label.text = step["title"]
	body_label.text = step["body"]
	next_button.text = "Mula! / Start!" if _current_step == STEPS.size() - 1 \
		else "Seterusnya →"
