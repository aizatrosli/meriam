## Unit tests for CannonReloadIndicator.
## Verifies fill bar updates, load_complete signal connection, and flash handler.
extends GutTest

var indicator: CannonReloadIndicator
var loader: CannonLoader
var fill_bar: ProgressBar

func before_each() -> void:
	var config := GameConfig.new()
	config.cannon_load_duration = 0.1

	loader = CannonLoader.new()
	loader.set_config(config)
	add_child(loader)

	fill_bar = ProgressBar.new()
	fill_bar.min_value = 0.0
	fill_bar.max_value = 100.0
	add_child(fill_bar)

	indicator = CannonReloadIndicator.new()
	indicator.fill_bar = fill_bar
	add_child(indicator)
	# Set loader AFTER add_child so tween in _on_load_complete can run
	indicator.loader = loader

func after_each() -> void:
	indicator.queue_free()
	fill_bar.queue_free()
	loader.queue_free()
	indicator = null
	fill_bar = null
	loader = null

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func test_fill_bar_is_zero_initially() -> void:
	indicator._process(0.0)
	assert_almost_eq(fill_bar.value, 0.0, 0.01)

func test_fill_bar_is_100_when_loader_is_full() -> void:
	loader.force_load()
	indicator._process(0.0)
	assert_almost_eq(fill_bar.value, 100.0, 0.01)

func test_load_complete_signal_is_connected() -> void:
	assert_true(
		loader.load_complete.is_connected(indicator._on_load_complete),
		"load_complete should be connected to _on_load_complete"
	)

func test_loader_setter_disconnects_old_loader() -> void:
	var config2 := GameConfig.new()
	config2.cannon_load_duration = 0.1
	var loader2 := CannonLoader.new()
	loader2.set_config(config2)
	add_child(loader2)

	# Replace loader – old loader should be disconnected
	indicator.loader = loader2

	assert_false(
		loader.load_complete.is_connected(indicator._on_load_complete),
		"Old loader should be disconnected after replacement"
	)
	assert_true(
		loader2.load_complete.is_connected(indicator._on_load_complete),
		"New loader should be connected"
	)
	loader2.queue_free()

func test_on_load_complete_does_not_crash() -> void:
	# fill_bar is set; calling _on_load_complete while in scene tree is safe
	indicator._on_load_complete()
	assert_true(true, "No crash when _on_load_complete called with fill_bar set")

func test_on_load_complete_with_null_fill_bar_does_not_crash() -> void:
	indicator.fill_bar = null
	indicator._on_load_complete()
	assert_true(true, "No crash when fill_bar is null")

func test_status_label_shows_isi_when_not_loaded() -> void:
	var label := Label.new()
	add_child(label)
	indicator.load_status_label = label
	indicator._process(0.0)
	assert_eq(label.text, "Isi...")
	label.queue_free()

func test_status_label_shows_sedia_when_loaded() -> void:
	var label := Label.new()
	add_child(label)
	indicator.load_status_label = label
	loader.force_load()
	indicator._process(0.0)
	assert_eq(label.text, "Sedia!")
	label.queue_free()
