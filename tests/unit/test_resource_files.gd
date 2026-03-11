## Regression test: verify every .tres resource file can be loaded from disk
## and resolves to the correct custom Resource subclass with non-default data.
##
## This catches the "Cannot get class 'X'" export failure that occurs when
## .tres files use bare type="ClassName" headers instead of explicit script
## references (type="Resource" script_class="ClassName" + script property).
extends GutTest

# ---------------------------------------------------------------------------
# TargetConfig files
# ---------------------------------------------------------------------------

func test_target_config_pelita_loads_as_correct_type() -> void:
	var res = load("res://resources/target_config_pelita.tres")
	assert_not_null(res, "target_config_pelita.tres failed to load")
	assert_true(res is TargetConfig, "expected TargetConfig, got: %s" % res.get_class())

func test_target_config_pelita_data() -> void:
	var res: TargetConfig = load("res://resources/target_config_pelita.tres")
	assert_eq(res.target_id, "pelita")
	assert_eq(res.type, TargetConfig.TargetType.SWINGING)
	assert_true(res.is_swinging)

func test_target_config_kelapa_loads_as_correct_type() -> void:
	var res = load("res://resources/target_config_kelapa.tres")
	assert_not_null(res, "target_config_kelapa.tres failed to load")
	assert_true(res is TargetConfig, "expected TargetConfig, got: %s" % res.get_class())

func test_target_config_kelapa_data() -> void:
	var res: TargetConfig = load("res://resources/target_config_kelapa.tres")
	assert_eq(res.target_id, "kelapa")
	assert_eq(res.type, TargetConfig.TargetType.ROLLING)
	assert_true(res.is_moving)

func test_target_config_belon_loads_as_correct_type() -> void:
	var res = load("res://resources/target_config_belon.tres")
	assert_not_null(res, "target_config_belon.tres failed to load")
	assert_true(res is TargetConfig, "expected TargetConfig, got: %s" % res.get_class())

func test_target_config_belon_data() -> void:
	var res: TargetConfig = load("res://resources/target_config_belon.tres")
	assert_eq(res.target_id, "belon")
	assert_eq(res.type, TargetConfig.TargetType.FLOATING)

# ---------------------------------------------------------------------------
# TargetSpawnEntry file
# ---------------------------------------------------------------------------

func test_target_spawn_entry_pelita_loads_as_correct_type() -> void:
	var res = load("res://resources/target_spawn_entry_pelita.tres")
	assert_not_null(res, "target_spawn_entry_pelita.tres failed to load")
	assert_true(res is TargetSpawnEntry, "expected TargetSpawnEntry, got: %s" % res.get_class())

func test_target_spawn_entry_pelita_data() -> void:
	var res: TargetSpawnEntry = load("res://resources/target_spawn_entry_pelita.tres")
	assert_gt(res.count, 0)
	assert_not_null(res.config)
	assert_true(res.config is TargetConfig)

# ---------------------------------------------------------------------------
# RoundConfig files
# ---------------------------------------------------------------------------

func test_round_config_1_loads_as_correct_type() -> void:
	var res = load("res://resources/round_config_1.tres")
	assert_not_null(res, "round_config_1.tres failed to load")
	assert_true(res is RoundConfig, "expected RoundConfig, got: %s" % res.get_class())

func test_round_config_1_data() -> void:
	var res: RoundConfig = load("res://resources/round_config_1.tres")
	assert_eq(res.round_number, 1)
	assert_false(res.targets.is_empty())
	assert_true(res.targets[0] is TargetSpawnEntry)

func test_round_config_2_loads_as_correct_type() -> void:
	var res = load("res://resources/round_config_2.tres")
	assert_not_null(res, "round_config_2.tres failed to load")
	assert_true(res is RoundConfig, "expected RoundConfig, got: %s" % res.get_class())

func test_round_config_2_data() -> void:
	var res: RoundConfig = load("res://resources/round_config_2.tres")
	assert_eq(res.round_number, 2)
	assert_eq(res.targets.size(), 2)
	for entry in res.targets:
		assert_true(entry is TargetSpawnEntry)

func test_round_config_3_loads_as_correct_type() -> void:
	var res = load("res://resources/round_config_3.tres")
	assert_not_null(res, "round_config_3.tres failed to load")
	assert_true(res is RoundConfig, "expected RoundConfig, got: %s" % res.get_class())

func test_round_config_3_data() -> void:
	var res: RoundConfig = load("res://resources/round_config_3.tres")
	assert_eq(res.round_number, 3)
	assert_eq(res.targets.size(), 3)
	for entry in res.targets:
		assert_true(entry is TargetSpawnEntry)

# ---------------------------------------------------------------------------
# GameConfig (root resource – loads the full graph)
# ---------------------------------------------------------------------------

func test_game_config_loads_as_correct_type() -> void:
	var res = load("res://resources/game_config.tres")
	assert_not_null(res, "game_config.tres failed to load")
	assert_true(res is GameConfig, "expected GameConfig, got: %s" % res.get_class())

func test_game_config_rounds_are_round_configs() -> void:
	var res: GameConfig = load("res://resources/game_config.tres")
	assert_false(res.rounds.is_empty())
	for round in res.rounds:
		assert_true(round is RoundConfig,
			"expected RoundConfig entry, got: %s" % round.get_class())

func test_game_config_round_count_matches_rounds_array() -> void:
	var res: GameConfig = load("res://resources/game_config.tres")
	assert_eq(res.round_count, res.rounds.size())
