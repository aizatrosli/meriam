## HUD – heads-up display for Meriam Raya.
## Shows: Markah (score), Nyawa (lives), Pusingan (round), load progress.
## Bilingual Malay / English text.
## Replaces Unity's HUDController MonoBehaviour.
class_name HUD
extends CanvasLayer

## Injected by game.gd after scene is ready
var cannon_loader: CannonLoader = null

## Assign in Inspector (game.tscn) so hit score labels spawn correctly
@export var score_popup_scene: PackedScene

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
		var p := cannon_loader.load_progress
		load_progress_bar.value = p * 100.0
		if cannon_loader.is_loaded:
			load_progress_bar.modulate = Color.GOLD
		else:
			# Red at 0% → orange/yellow at 50% → green-gold at 100%
			load_progress_bar.modulate = Color(1.0 - p * 0.5, 0.5 + p * 0.5, 0.1 + p * 0.3)
	if load_status_label:
		load_status_label.text = "Sedia!" if cannon_loader.is_loaded else "Isi..."

# ---------------------------------------------------------------------------
# Signal handlers
# ---------------------------------------------------------------------------

func _on_target_hit(score_value: int) -> void:
	_refresh_score(ScoreManager.get_current_score())
	_pulse_score_label()
	_spawn_score_popup(score_value)

func _on_life_lost(lives_remaining: int) -> void:
	_refresh_lives(lives_remaining)
	_flash_lives_label()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func update_round(round_number: int) -> void:
	if pusingan_label:
		pusingan_label.text = "Pusingan %d / Round %d" % [round_number, round_number]

func refresh_lives(lives: int) -> void:
	_refresh_lives(lives)

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _refresh_score(score: int) -> void:
	if markah_label:
		markah_label.text = "Markah: %d" % score

func _refresh_lives(lives: int) -> void:
	if nyawa_label:
		nyawa_label.text = "Nyawa: %d" % lives

func _pulse_score_label() -> void:
	if not markah_label:
		return
	markah_label.pivot_offset = markah_label.size / 2.0
	var tw := create_tween()
	tw.tween_property(markah_label, "scale", Vector2(1.3, 1.3), 0.1)
	tw.parallel().tween_property(markah_label, "modulate", Color.GOLD, 0.1)
	tw.tween_property(markah_label, "scale", Vector2.ONE, 0.2)
	tw.parallel().tween_property(markah_label, "modulate", Color.WHITE, 0.2)

func _flash_lives_label() -> void:
	if not nyawa_label:
		return
	var tw := create_tween()
	tw.tween_property(nyawa_label, "modulate", Color.RED, 0.1)
	tw.tween_property(nyawa_label, "modulate", Color.WHITE, 0.4)

func _spawn_score_popup(score_value: int) -> void:
	if not score_popup_scene:
		return
	var popup: ScorePopup = score_popup_scene.instantiate()
	get_tree().get_root().add_child(popup)
	# Spawn near the target zone center (adjust via score_popup_scene if needed)
	popup.launch(score_value, Vector2(700.0, 400.0))
