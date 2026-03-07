## HUD – heads-up display for Meriam Raya.
## Shows: Markah (score), Nyawa (lives), Pusingan (round), load progress.
## Bilingual Malay / English text.
## Replaces Unity's HUDController MonoBehaviour (TextMeshPro + Image).
class_name HUD
extends CanvasLayer

@export var markah_label: Label      # "Markah: 0"
@export var nyawa_label: Label       # "Nyawa: 3"
@export var pusingan_label: Label    # "Pusingan 1 / Round 1"
@export var load_progress_bar: ProgressBar
@export var load_status_label: Label # "Isi..." / "Sedia!"
@export var cannon_loader: CannonLoader

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	GameManager.target_hit.connect(_on_target_hit)
	GameManager.life_lost.connect(_on_life_lost)
	_refresh_score(ScoreManager.get_current_score())
	_refresh_lives(GameManager.lives_manager.lives_remaining if GameManager.lives_manager else 3)

func _process(_delta: float) -> void:
	if cannon_loader and load_progress_bar:
		load_progress_bar.value = cannon_loader.load_progress * 100.0
	if cannon_loader and load_status_label:
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
