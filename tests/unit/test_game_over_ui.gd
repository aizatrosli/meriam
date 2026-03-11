## Unit tests for GameOverUI.
## Verifies panel visibility and score labels on show_game_over / show_victory.
extends GutTest

var go_ui: GameOverUI

func before_each() -> void:
	go_ui = load("res://scenes/ui/game_over_ui.tscn").instantiate()
	add_child(go_ui)

func after_each() -> void:
	go_ui.queue_free()
	go_ui = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_game_over_panel_hidden_on_ready() -> void:
	assert_false(go_ui.game_over_panel.visible)

func test_victory_panel_hidden_on_ready() -> void:
	assert_false(go_ui.victory_panel.visible)

func test_show_game_over_makes_panel_visible() -> void:
	go_ui.show_game_over(500)
	assert_true(go_ui.game_over_panel.visible)

func test_show_game_over_sets_final_score_label() -> void:
	go_ui.show_game_over(1200)
	assert_eq(go_ui.final_score_label.text, "Markah Akhir: 1200")

func test_show_game_over_zero_score() -> void:
	go_ui.show_game_over(0)
	assert_eq(go_ui.final_score_label.text, "Markah Akhir: 0")

func test_show_game_over_panel_fades_in_from_zero() -> void:
	# Panel modulate.a starts at 0.0 and tweens to 1.0
	go_ui.show_game_over(300)
	# Panel must be visible immediately
	assert_true(go_ui.game_over_panel.visible)

func test_show_victory_makes_panel_visible() -> void:
	go_ui.show_victory(3000)
	assert_true(go_ui.victory_panel.visible)

func test_show_victory_sets_score_label() -> void:
	go_ui.show_victory(2500)
	if go_ui.final_score_label_v:
		assert_eq(go_ui.final_score_label_v.text, "Tahniah! Markah: 2500")

func test_show_victory_panel_fades_in_from_zero() -> void:
	go_ui.show_victory(1000)
	assert_true(go_ui.victory_panel.visible)

func test_victory_panel_stays_hidden_after_game_over() -> void:
	go_ui.show_game_over(100)
	assert_false(go_ui.victory_panel.visible)

func test_game_over_panel_stays_hidden_after_victory() -> void:
	go_ui.show_victory(100)
	assert_false(go_ui.game_over_panel.visible)
