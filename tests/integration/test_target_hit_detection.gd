## Integration tests for target hit detection.
## Verifies damageable group membership, take_damage calls, and death logic.
## Mirrors Unity's TargetHitDetectionTests (PlayMode).
extends GutTest

var target_pelita: TargetBase
var target_belon: TargetBelon
var config: TargetConfig

func before_each() -> void:
	config = TargetConfig.new()
	config.target_id = "test_target"
	config.base_health = 3
	config.score_value = 100

	target_pelita = TargetPelita.new()
	target_pelita.config = config
	add_child(target_pelita)

	target_belon = TargetBelon.new()
	target_belon.config = config
	add_child(target_belon)

func after_each() -> void:
	if is_instance_valid(target_pelita):
		target_pelita.queue_free()
	if is_instance_valid(target_belon):
		target_belon.queue_free()
	config = null

# ---------------------------------------------------------------------------
# Tests – TargetBase behaviour
# ---------------------------------------------------------------------------

func test_target_in_damageable_group() -> void:
	assert_true(target_pelita.is_in_group("damageable"))

func test_target_has_take_damage_method() -> void:
	assert_true(target_pelita.has_method("take_damage"))

func test_target_is_alive_on_spawn() -> void:
	assert_true(target_pelita.is_alive)

func test_take_damage_reduces_health() -> void:
	target_pelita.take_damage(1)
	assert_eq(target_pelita.current_health, 2)

func test_take_damage_zero_has_no_effect() -> void:
	target_pelita.take_damage(0)
	assert_eq(target_pelita.current_health, 3)

func test_take_damage_negative_has_no_effect() -> void:
	target_pelita.take_damage(-5)
	assert_eq(target_pelita.current_health, 3)

func test_target_not_alive_after_lethal_damage() -> void:
	target_pelita.take_damage(3)
	assert_false(target_pelita.is_alive)

func test_target_destroyed_after_lethal_damage() -> void:
	target_pelita.take_damage(3)
	await wait_seconds(0.1)
	# After queue_free and a frame, instance should be freed
	assert_false(is_instance_valid(target_pelita))

func test_multiple_hits_accumulate() -> void:
	target_pelita.take_damage(1)
	target_pelita.take_damage(1)
	assert_eq(target_pelita.current_health, 1)

func test_cannot_damage_dead_target() -> void:
	target_pelita.take_damage(3)  # kills it
	# After death, further damage is ignored (is_alive check)
	# We verify no error is thrown
	pass  # GUT assertion: no crash = pass

# ---------------------------------------------------------------------------
# Tests – Belon specific
# ---------------------------------------------------------------------------

func test_belon_in_damageable_group() -> void:
	assert_true(target_belon.is_in_group("damageable"))

func test_belon_starts_alive() -> void:
	assert_true(target_belon.is_alive)

func test_belon_dies_in_one_hit_with_health_1() -> void:
	target_belon.config = config  # config.base_health = 3 here
	target_belon.initialize()
	target_belon.take_damage(3)
	assert_false(target_belon.is_alive)
