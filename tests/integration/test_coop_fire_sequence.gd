## Integration tests for the full co-op fire sequence.
## Player 1 aims → Player 2 loads → Player 2 fires → signal emitted.
## Mirrors Unity's CoopFireSequenceTests (PlayMode).
extends GutTest

var config: GameConfig
var aimer: CannonAimer
var loader: CannonLoader
var firer: CannonFirer
var p1: Player1Controller
var p2: Player2Controller

func before_each() -> void:
	config = GameConfig.new()
	config.min_aim_angle = 0.0
	config.max_aim_angle = 75.0
	config.cannon_aim_speed = 60.0
	config.cannon_load_duration = 0.1  # short for tests
	config.cannon_cooldown_duration = 0.1
	config.projectile_speed = 600.0
	config.projectile_lifetime = 0.5
	config.projectile_damage = 1

	aimer = CannonAimer.new()
	aimer.set_config(config)
	add_child(aimer)

	loader = CannonLoader.new()
	loader.set_config(config)
	add_child(loader)

	firer = CannonFirer.new()
	firer.set_config(config)
	firer.aimer = aimer
	firer.loader = loader
	add_child(firer)

	p1 = Player1Controller.new()
	p1.aimer = aimer
	add_child(p1)

	p2 = Player2Controller.new()
	p2.loader = loader
	p2.firer = firer
	add_child(p2)

func after_each() -> void:
	p1.queue_free()
	p2.queue_free()
	firer.queue_free()
	loader.queue_free()
	aimer.queue_free()
	p1 = null
	p2 = null
	firer = null
	loader = null
	aimer = null
	config = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_p1_aim_input_rotates_barrel() -> void:
	p1.on_aim_input(30.0)
	assert_almost_eq(aimer.current_angle, 30.0, 0.01)

func test_p2_load_begins_loading() -> void:
	p2.on_load_pressed()
	assert_true(loader._is_loading)

func test_p2_release_before_complete_cancels_load() -> void:
	p2.on_load_pressed()
	p2.on_load_released()
	assert_false(loader._is_loading)
	assert_false(loader.is_loaded)

func test_full_load_allows_fire() -> void:
	loader.force_load()
	assert_true(firer.can_fire)

func test_fire_without_load_is_blocked() -> void:
	watch_signals(firer)
	firer.fire()
	assert_signal_not_emitted(firer, "fired")

func test_fire_after_load_emits_fired_signal() -> void:
	loader.force_load()
	watch_signals(firer)
	firer.fire()
	assert_signal_emitted(firer, "fired")

func test_fire_locks_aimer() -> void:
	loader.force_load()
	firer.fire()
	assert_true(aimer.is_locked)

func test_aimer_unlocks_after_cooldown() -> void:
	loader.force_load()
	firer.fire()
	assert_true(aimer.is_locked)
	await wait_seconds(0.2)
	assert_false(aimer.is_locked)

func test_fire_clears_loaded_state() -> void:
	loader.force_load()
	firer.fire()
	assert_false(loader.is_loaded)

func test_p2_fire_press_calls_fire() -> void:
	loader.force_load()
	watch_signals(firer)
	p2.on_fire_pressed()
	assert_signal_emitted(firer, "fired")

func test_aim_then_load_then_fire_full_sequence() -> void:
	p1.on_aim_input(45.0)
	assert_almost_eq(aimer.current_angle, 45.0, 0.01)
	loader.force_load()
	assert_true(loader.is_loaded)
	watch_signals(firer)
	p2.on_fire_pressed()
	assert_signal_emitted(firer, "fired")
	assert_true(aimer.is_locked)
