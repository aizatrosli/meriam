## LivesManager – tracks the kids' remaining shots / lives.
## Replaces Unity's LivesManager pure C# class.
## Plain GDScript object (not a Node) – easily unit-tested.
class_name LivesManager
extends RefCounted

var lives_remaining: int = 0
var is_game_over: bool:
	get: return lives_remaining <= 0

## Emitted when a life is lost.
signal life_lost()
## Emitted when lives reach zero.
signal game_over()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func initialize(starting_lives: int) -> void:
	lives_remaining = starting_lives

func lose_life() -> void:
	if is_game_over:
		return
	lives_remaining -= 1
	life_lost.emit()
	if is_game_over:
		game_over.emit()
