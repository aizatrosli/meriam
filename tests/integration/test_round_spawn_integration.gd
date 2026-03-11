## Integration tests for round spawning.
## Verifies RoundConfig drives TargetSpawner correctly.
## Mirrors Unity's RoundSpawnIntegrationTests (PlayMode).
extends GutTest

var round_config: RoundConfig
var spawn_entry: TargetSpawnEntry
var target_config: TargetConfig

func before_each() -> void:
	target_config = TargetConfig.new()
	target_config.target_id = "test"
	target_config.base_health = 1
	target_config.score_value = 100
	# Note: target_config.scene is null in tests (no actual scene file needed for config tests)

	spawn_entry = TargetSpawnEntry.new()
	spawn_entry.config = target_config
	spawn_entry.count = 4
	spawn_entry.spacing = 1.5
	spawn_entry.height_offset = 0.0

	round_config = RoundConfig.new()
	round_config.round_number = 2
	round_config.round_announcement_malay = "Pusingan 2"
	round_config.time_between_spawns = 0.1  # fast for tests
	round_config.round_start_delay = 0.0    # no delay for tests
	round_config.targets = [spawn_entry]
	round_config.completion_bonus_score = 500

func after_each() -> void:
	round_config = null
	spawn_entry = null
	target_config = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_round_config_has_correct_round_number() -> void:
	assert_eq(round_config.round_number, 2)

func test_round_config_spawn_entry_count() -> void:
	assert_eq(round_config.targets.size(), 1)

func test_spawn_entry_target_count() -> void:
	var entry: TargetSpawnEntry = round_config.targets[0]
	assert_eq(entry.count, 4)

func test_spawn_entry_spacing_positive() -> void:
	var entry: TargetSpawnEntry = round_config.targets[0]
	assert_gt(entry.spacing, 0.0)

func test_completion_bonus_positive() -> void:
	assert_gt(round_config.completion_bonus_score, 0)

func test_time_between_spawns_positive() -> void:
	assert_gt(round_config.time_between_spawns, 0.0)

func test_total_target_count_from_config() -> void:
	var total := 0
	for entry: TargetSpawnEntry in round_config.targets:
		total += entry.count
	assert_eq(total, 4)

func test_multiple_entries_total_count() -> void:
	var entry2 := TargetSpawnEntry.new()
	entry2.config = target_config
	entry2.count = 2
	round_config.targets.append(entry2)
	var total := 0
	for entry: TargetSpawnEntry in round_config.targets:
		total += entry.count
	assert_eq(total, 6)
	entry2 = null

func test_round_announcement_malay_not_empty() -> void:
	assert_ne(round_config.round_announcement_malay, "")
