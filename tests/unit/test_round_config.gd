## Unit tests for RoundConfig resource.
## Mirrors Unity's RoundConfigTests.
extends GutTest

var round_config: RoundConfig
var target_config: TargetConfig
var spawn_entry: TargetSpawnEntry

func before_each() -> void:
	target_config = TargetConfig.new()
	target_config.target_id = "pelita"
	target_config.base_health = 1
	target_config.score_value = 100

	spawn_entry = TargetSpawnEntry.new()
	spawn_entry.config = target_config
	spawn_entry.count = 3
	spawn_entry.spacing = 1.5
	spawn_entry.height_offset = 0.0

	round_config = RoundConfig.new()
	round_config.round_number = 1
	round_config.round_announcement_malay = "Pusingan 1"
	round_config.time_between_spawns = 1.5
	round_config.round_start_delay = 3.0
	round_config.targets = [spawn_entry]
	round_config.completion_bonus_score = 500
	round_config.time_limit = 60.0

func after_each() -> void:
	round_config.unreference()
	spawn_entry.unreference()
	target_config.unreference()

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_round_number_set_correctly() -> void:
	assert_eq(round_config.round_number, 1)

func test_round_announcement_malay() -> void:
	assert_eq(round_config.round_announcement_malay, "Pusingan 1")

func test_spawn_delay_set_correctly() -> void:
	assert_almost_eq(round_config.round_start_delay, 3.0, 0.01)

func test_targets_list_not_empty() -> void:
	assert_not_null(round_config.targets)
	assert_eq(round_config.targets.size(), 1)

func test_spawn_entry_count() -> void:
	var entry: TargetSpawnEntry = round_config.targets[0]
	assert_eq(entry.count, 3)

func test_spawn_entry_spacing() -> void:
	var entry: TargetSpawnEntry = round_config.targets[0]
	assert_almost_eq(entry.spacing, 1.5, 0.01)

func test_completion_bonus_score() -> void:
	assert_eq(round_config.completion_bonus_score, 500)

func test_time_limit_positive() -> void:
	assert_gt(round_config.time_limit, 0.0)
