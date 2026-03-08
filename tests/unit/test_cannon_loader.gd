## Unit tests for CannonLoader.
## Mirrors Unity's CannonLoaderTests (EditMode NUnit with FakeTimeProvider).
extends GutTest

var loader: CannonLoader
var config: GameConfig

func before_each() -> void:
	config = GameConfig.new()
	config.cannon_load_duration = 2.0
	loader = CannonLoader.new()
	loader.set_config(config)
	add_child(loader)

func after_each() -> void:
	loader.queue_free()
	loader = null
	config = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_initial_state_not_loaded() -> void:
	assert_false(loader.is_loaded)

func test_initial_load_progress_is_zero() -> void:
	assert_eq(loader.load_progress, 0.0)

func test_begin_loading_starts_progress() -> void:
	loader.begin_loading()
	await wait_seconds(0.1)
	assert_gt(loader.load_progress, 0.0)

func test_cancel_loading_resets_progress() -> void:
	loader.begin_loading()
	await wait_seconds(0.5)
	loader.cancel_loading()
	assert_eq(loader.load_progress, 0.0)
	assert_false(loader.is_loaded)

func test_force_load_completes_immediately() -> void:
	loader.force_load()
	assert_true(loader.is_loaded)
	assert_eq(loader.load_progress, 1.0)

func test_force_load_emits_load_complete() -> void:
	watch_signals(loader)
	loader.force_load()
	assert_signal_emitted(loader, "load_complete")

func test_begin_loading_when_already_loaded_is_no_op() -> void:
	loader.force_load()
	loader.begin_loading()
	assert_true(loader.is_loaded)

func test_cancel_loading_clears_loaded_state() -> void:
	loader.force_load()
	loader.cancel_loading()
	assert_false(loader.is_loaded)
	assert_eq(loader.load_progress, 0.0)

func test_full_load_cycle_via_time() -> void:
	loader.begin_loading()
	await wait_seconds(2.1)
	assert_true(loader.is_loaded)
	assert_eq(loader.load_progress, 1.0)

func test_load_complete_signal_emitted_after_full_load() -> void:
	watch_signals(loader)
	loader.begin_loading()
	await wait_seconds(2.1)
	assert_signal_emitted(loader, "load_complete")
