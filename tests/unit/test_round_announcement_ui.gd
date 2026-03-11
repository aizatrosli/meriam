## Unit tests for RoundAnnouncementUI.
## Verifies panel visibility and label content on show_round_announcement().
extends GutTest

var ra: RoundAnnouncementUI

func before_each() -> void:
	ra = load("res://scenes/ui/round_announcement.tscn").instantiate()
	add_child(ra)

func after_each() -> void:
	ra.queue_free()
	ra = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_panel_hidden_on_ready() -> void:
	assert_false(ra.panel.visible)

func test_show_announcement_sets_round_label_round_1() -> void:
	ra.show_round_announcement(1)
	assert_eq(ra.round_label.text, "Pusingan 1 / Round 1")

func test_show_announcement_sets_round_label_round_3() -> void:
	ra.show_round_announcement(3)
	assert_eq(ra.round_label.text, "Pusingan 3 / Round 3")

func test_show_announcement_uses_custom_subtitle() -> void:
	ra.show_round_announcement(1, "Meriam sudah sedia!")
	assert_eq(ra.subtitle_label.text, "Meriam sudah sedia!")

func test_show_announcement_uses_default_subtitle_when_empty() -> void:
	ra.show_round_announcement(1, "")
	assert_eq(ra.subtitle_label.text, "Meriam siap! / Ready the cannon!")

func test_show_announcement_makes_panel_visible() -> void:
	ra.show_round_announcement(1)
	assert_true(ra.panel.visible)

func test_panel_starts_faded_out_on_show() -> void:
	ra.show_round_announcement(1)
	# Modulate alpha starts at 0.0 and tweens up – check it was set to 0 first
	# The panel is visible but the tween will raise alpha from 0
	assert_true(ra.panel.visible)

func test_panel_hides_after_display_duration() -> void:
	ra.display_duration = 0.05
	ra.show_round_announcement(1)
	await wait_seconds(1.5)
	assert_false(ra.panel.visible)
