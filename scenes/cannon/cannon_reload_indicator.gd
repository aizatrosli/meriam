## CannonReloadIndicator – visual feedback for Player 2's loading progress.
## Displayed as a progress bar above the meriam in the kampung scene.
## Injected by Cannon._ready(). Replaces Unity's CannonReloadIndicator.
class_name CannonReloadIndicator
extends Node

## Injected by Cannon._ready()
var loader: CannonLoader = null
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
