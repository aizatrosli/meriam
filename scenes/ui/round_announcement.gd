## RoundAnnouncementUI – full-screen overlay shown between rounds.
## Bilingual: "Pusingan 2 / Round 2" + Malay subtitle.
## Replaces Unity's RoundAnnouncementUI MonoBehaviour.
class_name RoundAnnouncementUI
extends CanvasLayer

@export var display_duration: float = 2.5

@onready var panel: Control = $Panel
@onready var round_label: Label = $Panel/VBoxContainer/RoundLabel
@onready var subtitle_label: Label = $Panel/VBoxContainer/SubtitleLabel

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	panel.hide()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func show_round_announcement(round_number: int, malay_text: String = "") -> void:
	round_label.text = "Pusingan %d / Round %d" % [round_number, round_number]
	subtitle_label.text = malay_text if not malay_text.is_empty() \
		else "Meriam siap! / Ready the cannon!"
	_show_then_hide()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _show_then_hide() -> void:
	panel.show()
	await get_tree().create_timer(display_duration).timeout
	panel.hide()
