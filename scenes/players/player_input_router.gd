## PlayerInputRouter – routes raw Godot InputMap actions to player controllers.
## Supports two local input schemes:
##   Keyboard split: Player 1 W/S,  Player 2 Space (hold) + Enter (fire)
##   Two gamepads:   Player 1 Gamepad-0 left-stick Y,  Player 2 Gamepad-1 South + East
## In networked mode this node is only active on the local client.
## Replaces Unity's PlayerInputRouter (Unity Input System) MonoBehaviour.
class_name PlayerInputRouter
extends Node

@export var player1: Player1Controller
@export var player2: Player2Controller
@export var config: GameConfig

## When true, only local player 1 input is active (online host mode).
@export var only_player1_local: bool = false
## When true, only local player 2 input is active (online client mode).
@export var only_player2_local: bool = false

# ---------------------------------------------------------------------------
# Process
# ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	_handle_player1_aim(delta)

func _input(event: InputEvent) -> void:
	_handle_player2_events(event)

# ---------------------------------------------------------------------------
# Private – Player 1 (aim)
# ---------------------------------------------------------------------------

func _handle_player1_aim(delta: float) -> void:
	if only_player2_local or not player1:
		return
	var aim_value := 0.0
	if Input.is_action_pressed("p1_aim_up"):
		aim_value += 1.0
	if Input.is_action_pressed("p1_aim_down"):
		aim_value -= 1.0
	if abs(aim_value) > 0.05:
		var aim_speed := config.cannon_aim_speed if config else 60.0
		player1.on_aim_input(aim_value * aim_speed * delta)

# ---------------------------------------------------------------------------
# Private – Player 2 (load + fire)
# ---------------------------------------------------------------------------

func _handle_player2_events(event: InputEvent) -> void:
	if only_player1_local or not player2:
		return
	if event.is_action_pressed("p2_load"):
		player2.on_load_pressed()
	elif event.is_action_released("p2_load"):
		player2.on_load_released()
	elif event.is_action_pressed("p2_fire"):
		player2.on_fire_pressed()
