## RoundAnnouncementUI – full-screen overlay shown between rounds.
## Displays bilingual round announcement, e.g.:
##   "Pusingan 2 / Round 2"
##   "Selamat Raya! Meriam siap?" / "Happy Raya! Ready the cannon?"
## Replaces Unity's RoundAnnouncementUI MonoBehaviour.
class_name RoundAnnouncementUI
extends CanvasLayer

@export var panel: Control
@export var round_label: Label
@export var subtitle_label: Label
@export var display_duration: float = 2.5

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	if panel:
		panel.hide()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func show_round_announcement(round_number: int, malay_text: String = "") -> void:
	if round_label:
		round_label.text = "Pusingan %d / Round %d" % [round_number, round_number]
	if subtitle_label:
		subtitle_label.text = malay_text if not malay_text.is_empty() else "Meriam siap! / Ready the cannon!"
	_show_then_hide()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _show_then_hide() -> void:
	if panel:
		panel.show()
	await get_tree().create_timer(display_duration).timeout
	if panel:
		panel.hide()
