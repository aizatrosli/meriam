## Player2Controller – Anak Bongsu (Younger Child) loads and fires the meriam.
## Hold Load to pack gunpowder; tap Fire when loaded.
## Replaces Unity's Player2Controller MonoBehaviour.
class_name Player2Controller
extends Node

@export var loader: CannonLoader
@export var firer: CannonFirer

# ---------------------------------------------------------------------------
# Public API (called by PlayerInputRouter or NetworkGameManager)
# ---------------------------------------------------------------------------

func on_load_pressed() -> void:
	loader.begin_loading()

func on_load_released() -> void:
	if not loader.is_loaded:
		loader.cancel_loading()

func on_fire_pressed() -> void:
	firer.fire()
