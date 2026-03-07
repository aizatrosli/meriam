## HUD – heads-up display for Meriam Raya.
## Shows: Markah (score), Nyawa (lives), Pusingan (round), load progress.
## Bilingual Malay / English text.
## Replaces Unity's HUDController MonoBehaviour.
class_name HUD
extends CanvasLayer

## Injected by game.gd after scene is ready
var cannon_loader: CannonLoader = null

@onready var markah_label: Label = $Control/TopBar/MarkahLabel
@onready var pusingan_label: Label = $Control/TopBar/PusinganLabel
@onready var nyawa_label: Label = $Control/TopBar/NyawaLabel
@onready var load_status_label: Label = $Control/BottomBar/LoadStatusLabel
@onready var load_progress_bar: ProgressBar = $Control/BottomBar/LoadProgressBar

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	GameManager.target_hit.connect(_on_target_hit)
	GameManager.life_lost.connect(_on_life_lost)
	_refresh_score(ScoreManager.get_current_score())
	var lm := GameManager.lives_manager
	_refresh_lives(lm.lives_remaining if lm else 3)

func _process(_delta: float) -> void:
	if not cannon_loader:
		return
	if load_progress_bar:
		load_progress_bar.value = cannon_loader.load_progress * 100.0
	if load_status_label:
		load_status_label.text = "Sedia!" if cannon_loader.is_loaded else "Isi..."

# ---------------------------------------------------------------------------
# Signal handlers
# ---------------------------------------------------------------------------

func _on_target_hit(_score_value: int) -> void:
	_refresh_score(ScoreManager.get_current_score())

func _on_life_lost(lives_remaining: int) -> void:
	_refresh_lives(lives_remaining)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func update_round(round_number: int) -> void:
	if pusingan_label:
		pusingan_label.text = "Pusingan %d / Round %d" % [round_number, round_number]

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _refresh_score(score: int) -> void:
	if markah_label:
		markah_label.text = "Markah: %d" % score

func _refresh_lives(lives: int) -> void:
	if nyawa_label:
		nyawa_label.text = "Nyawa: %d" % lives
