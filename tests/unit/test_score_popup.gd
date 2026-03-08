## Unit tests for ScorePopup.
## Verifies launch() sets label text and world position correctly.
extends GutTest

var popup_scene: PackedScene
var popup: ScorePopup

func before_each() -> void:
	popup_scene = load("res://scenes/ui/score_popup.tscn")
	popup = popup_scene.instantiate()
	add_child(popup)

func after_each() -> void:
	if is_instance_valid(popup):
		popup.queue_free()
	popup = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_popup_has_label_child() -> void:
	assert_not_null(popup.label)

func test_launch_sets_positive_score_text() -> void:
	popup.launch(250, Vector2(640, 360))
	assert_eq(popup.label.text, "+250")

func test_launch_sets_zero_score_text() -> void:
	popup.launch(0, Vector2.ZERO)
	assert_eq(popup.label.text, "+0")

func test_launch_sets_large_score_text() -> void:
	popup.launch(9999, Vector2(640, 360))
	assert_eq(popup.label.text, "+9999")

func test_launch_sets_world_position_x() -> void:
	popup.launch(100, Vector2(300.0, 400.0))
	assert_almost_eq(popup.global_position.x, 300.0, 0.01)

func test_launch_sets_world_position_y() -> void:
	popup.launch(100, Vector2(300.0, 400.0))
	assert_almost_eq(popup.global_position.y, 400.0, 0.01)

func test_launch_center_of_screen() -> void:
	popup.launch(500, Vector2(640, 360))
	assert_almost_eq(popup.global_position.x, 640.0, 0.01)
	assert_almost_eq(popup.global_position.y, 360.0, 0.01)
