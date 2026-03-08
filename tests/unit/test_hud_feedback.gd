## Unit tests for HUD visual feedback additions.
## Covers loading bar colour, score label update, lives label update.
extends GutTest

var hud: HUD
var loader: CannonLoader

func before_each() -> void:
	var config := GameConfig.new()
	config.cannon_load_duration = 2.0
	loader = CannonLoader.new()
	loader.set_config(config)
	add_child(loader)

	hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)
	hud.cannon_loader = loader

func after_each() -> void:
	hud.queue_free()
	loader.queue_free()
	hud = null
	loader = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_score_label_updated_on_target_hit() -> void:
	ScoreManager.reset_score()
	ScoreManager.add_score(100)
	hud._on_target_hit(100)
	assert_eq(hud.markah_label.text, "Markah: 100")

func test_score_label_accumulates_on_multiple_hits() -> void:
	ScoreManager.reset_score()
	ScoreManager.add_score(100)
	hud._on_target_hit(100)
	ScoreManager.add_score(250)
	hud._on_target_hit(250)
	assert_eq(hud.markah_label.text, "Markah: 350")

func test_lives_label_updated_on_life_lost() -> void:
	hud._on_life_lost(2)
	assert_eq(hud.nyawa_label.text, "Nyawa: 2")

func test_lives_label_reflects_zero() -> void:
	hud._on_life_lost(0)
	assert_eq(hud.nyawa_label.text, "Nyawa: 0")

func test_loading_bar_value_at_zero_when_idle() -> void:
	hud._process(0.0)
	assert_almost_eq(hud.load_progress_bar.value, 0.0, 0.01)

func test_loading_bar_value_at_100_when_loaded() -> void:
	loader.force_load()
	hud._process(0.0)
	assert_almost_eq(hud.load_progress_bar.value, 100.0, 0.01)

func test_loading_bar_modulate_is_gold_when_loaded() -> void:
	loader.force_load()
	hud._process(0.0)
	assert_eq(hud.load_progress_bar.modulate, Color.GOLD)

func test_loading_bar_has_red_tint_at_zero_progress() -> void:
	# At 0% load, red channel should dominate (close to 1.0)
	hud._process(0.0)
	var c: Color = hud.load_progress_bar.modulate
	assert_gt(c.r, 0.7, "Red channel should be high at 0% progress")

func test_load_status_label_shows_isi_when_not_loaded() -> void:
	hud._process(0.0)
	assert_eq(hud.load_status_label.text, "Isi...")

func test_load_status_label_shows_sedia_when_loaded() -> void:
	loader.force_load()
	hud._process(0.0)
	assert_eq(hud.load_status_label.text, "Sedia!")

func test_spawn_score_popup_does_not_crash_when_scene_is_null() -> void:
	# score_popup_scene is null by default in unit tests – should be a no-op
	hud._spawn_score_popup(100)
	assert_true(true, "No crash when score_popup_scene is null")
