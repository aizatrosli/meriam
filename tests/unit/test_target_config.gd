## Unit tests for TargetConfig resource.
## Mirrors Unity's TargetConfigTests.
extends GutTest

var config: TargetConfig

func before_each() -> void:
	config = TargetConfig.new()
	config.target_id = "pelita"
	config.display_name_malay = "Pelita"
	config.base_health = 2
	config.score_value = 150
	config.type = TargetConfig.TargetType.SWINGING
	config.is_swinging = true
	config.is_moving = false
	config.move_speed = 0.0

func after_each() -> void:
	config = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_target_id_set_correctly() -> void:
	assert_eq(config.target_id, "pelita")

func test_display_name_malay_set_correctly() -> void:
	assert_eq(config.display_name_malay, "Pelita")

func test_base_health_positive() -> void:
	assert_gt(config.base_health, 0)

func test_score_value_positive() -> void:
	assert_gt(config.score_value, 0)

func test_type_correct() -> void:
	assert_eq(config.type, TargetConfig.TargetType.SWINGING)

func test_is_swinging_flag() -> void:
	assert_true(config.is_swinging)

func test_is_moving_flag_false_for_pelita() -> void:
	assert_false(config.is_moving)

func test_kelapa_config_is_rolling() -> void:
	var kelapa := TargetConfig.new()
	kelapa.target_id = "kelapa"
	kelapa.type = TargetConfig.TargetType.ROLLING
	kelapa.is_moving = true
	kelapa.move_speed = 1.0
	assert_eq(kelapa.type, TargetConfig.TargetType.ROLLING)
	assert_true(kelapa.is_moving)
	kelapa = null

func test_belon_config_is_floating() -> void:
	var belon := TargetConfig.new()
	belon.target_id = "belon"
	belon.type = TargetConfig.TargetType.FLOATING
	belon.base_health = 1
	belon.score_value = 250
	assert_eq(belon.type, TargetConfig.TargetType.FLOATING)
	assert_gt(belon.score_value, 100)  # bonus target
	belon = null
