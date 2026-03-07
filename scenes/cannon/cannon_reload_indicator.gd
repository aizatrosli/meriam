## CannonReloadIndicator – visual feedback for Player 2's loading progress.
## Displayed as a progress bar above the meriam in the kampung scene.
## Replaces Unity's CannonReloadIndicator MonoBehaviour.
class_name CannonReloadIndicator
extends Node

@export var loader: CannonLoader
@export var fill_bar: ProgressBar
@export var loaded_icon: Control
@export var load_status_label: Label  # Shows "Isi..." / "Sedia!"

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
