## Unit tests for CannonAimer.
## Mirrors Unity's CannonAimerTests (EditMode NUnit).
extends GutTest

var aimer: CannonAimer
var config: GameConfig

func before_each() -> void:
	config = GameConfig.new()
	config.min_aim_angle = 0.0
	config.max_aim_angle = 75.0
	config.cannon_aim_speed = 60.0
	aimer = CannonAimer.new()
	aimer.set_config(config)
	add_child(aimer)

func after_each() -> void:
	aimer.queue_free()
	aimer = null
	config = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_initial_angle_is_zero() -> void:
	assert_eq(aimer.current_angle, 0.0)

func test_set_aim_angle_within_bounds() -> void:
	aimer.set_aim_angle(30.0)
	assert_almost_eq(aimer.current_angle, 30.0, 0.01)

func test_set_aim_angle_clamps_to_max() -> void:
	aimer.set_aim_angle(100.0)
	assert_almost_eq(aimer.current_angle, 75.0, 0.01)

func test_set_aim_angle_clamps_to_min() -> void:
	aimer.set_aim_angle(-20.0)
	assert_almost_eq(aimer.current_angle, 0.0, 0.01)

func test_adjust_aim_increases_angle() -> void:
	aimer.set_aim_angle(20.0)
	aimer.adjust_aim(10.0)
	assert_almost_eq(aimer.current_angle, 30.0, 0.01)

func test_adjust_aim_decreases_angle() -> void:
	aimer.set_aim_angle(40.0)
	aimer.adjust_aim(-15.0)
	assert_almost_eq(aimer.current_angle, 25.0, 0.01)

func test_adjust_aim_respects_upper_clamp() -> void:
	aimer.set_aim_angle(70.0)
	aimer.adjust_aim(20.0)
	assert_almost_eq(aimer.current_angle, 75.0, 0.01)

func test_adjust_aim_respects_lower_clamp() -> void:
	aimer.set_aim_angle(5.0)
	aimer.adjust_aim(-20.0)
	assert_almost_eq(aimer.current_angle, 0.0, 0.01)

func test_locked_aimer_ignores_set_aim_angle() -> void:
	aimer.set_aim_angle(30.0)
	aimer.is_locked = true
	aimer.set_aim_angle(60.0)
	assert_almost_eq(aimer.current_angle, 30.0, 0.01)

func test_locked_aimer_ignores_adjust_aim() -> void:
	aimer.set_aim_angle(30.0)
	aimer.is_locked = true
	aimer.adjust_aim(10.0)
	assert_almost_eq(aimer.current_angle, 30.0, 0.01)

func test_unlocked_aimer_processes_input() -> void:
	aimer.set_aim_angle(20.0)
	aimer.is_locked = true
	aimer.is_locked = false
	aimer.set_aim_angle(50.0)
	assert_almost_eq(aimer.current_angle, 50.0, 0.01)

func test_min_angle_from_config() -> void:
	assert_almost_eq(aimer.min_angle, 0.0, 0.01)

func test_max_angle_from_config() -> void:
	assert_almost_eq(aimer.max_aim_angle, 75.0, 0.01)
