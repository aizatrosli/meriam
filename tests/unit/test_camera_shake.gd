## Unit tests for CameraShake.
## Verifies shake() sets internal state and _process() clears offset when done.
extends GutTest

var camera: CameraShake

func before_each() -> void:
	camera = CameraShake.new()
	add_child(camera)

func after_each() -> void:
	camera.queue_free()
	camera = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_initial_shake_duration_is_zero() -> void:
	assert_almost_eq(camera._shake_duration, 0.0, 0.001)

func test_initial_shake_strength_is_zero() -> void:
	assert_almost_eq(camera._shake_strength, 0.0, 0.001)

func test_initial_offset_is_zero() -> void:
	assert_eq(camera.offset, Vector2.ZERO)

func test_shake_sets_strength() -> void:
	camera.shake(10.0, 0.3)
	assert_almost_eq(camera._shake_strength, 10.0, 0.001)

func test_shake_sets_duration() -> void:
	camera.shake(5.0, 0.5)
	assert_almost_eq(camera._shake_duration, 0.5, 0.001)

func test_shake_negative_strength_clamped_to_zero() -> void:
	camera.shake(-8.0, 0.3)
	assert_almost_eq(camera._shake_strength, 0.0, 0.001)

func test_shake_negative_duration_clamped_to_zero() -> void:
	camera.shake(5.0, -1.0)
	assert_almost_eq(camera._shake_duration, 0.0, 0.001)

func test_process_decrements_duration() -> void:
	camera.shake(5.0, 1.0)
	camera._process(0.4)
	assert_almost_eq(camera._shake_duration, 0.6, 0.01)

func test_process_clears_offset_after_duration_expires() -> void:
	camera.shake(5.0, 0.1)
	camera._process(0.2)
	assert_eq(camera.offset, Vector2.ZERO)

func test_process_clamps_duration_to_zero_when_expired() -> void:
	camera.shake(5.0, 0.1)
	camera._process(0.5)
	assert_almost_eq(camera._shake_duration, 0.0, 0.001)

func test_shake_can_be_called_multiple_times() -> void:
	camera.shake(5.0, 0.3)
	camera.shake(10.0, 0.8)
	assert_almost_eq(camera._shake_strength, 10.0, 0.001)
	assert_almost_eq(camera._shake_duration, 0.8, 0.001)
