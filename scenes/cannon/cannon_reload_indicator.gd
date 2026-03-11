## CannonReloadIndicator – visual feedback for Player 2's loading progress.
## Displayed as a progress bar above the meriam in the kampung scene.
## Injected by Cannon._ready(). Replaces Unity's CannonReloadIndicator.
class_name CannonReloadIndicator
extends Node

## Injected by Cannon._ready() – setter wires the load_complete flash.
var loader: CannonLoader = null:
	set(value):
		if loader != null and loader.load_complete.is_connected(_on_load_complete):
			loader.load_complete.disconnect(_on_load_complete)
		loader = value
		if loader != null:
			loader.load_complete.connect(_on_load_complete)

var fill_bar: ProgressBar = null
var loaded_icon: Control = null
var load_status_label: Label = null

# ---------------------------------------------------------------------------
# Process
# ---------------------------------------------------------------------------

func _process(_delta: float) -> void:
	if not loader:
		return
	if fill_bar:
		fill_bar.value = loader.load_progress * 100.0
	if loaded_icon:
		loaded_icon.visible = loader.is_loaded
	if load_status_label:
		load_status_label.text = "Sedia!" if loader.is_loaded else "Isi..."

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _on_load_complete() -> void:
	if not fill_bar:
		return
	var tw := create_tween()
	tw.tween_property(fill_bar, "modulate", Color.GOLD, 0.15)
	tw.tween_property(fill_bar, "modulate", Color.WHITE, 0.3)
