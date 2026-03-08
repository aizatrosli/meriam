## CameraShake – Camera2D that applies randomised offset for impact feedback.
## Call shake(strength, duration) in response to cannon fire or target death.
## Wire in game.gd: cannon.firer.fired.connect(func(): camera.shake(6.0, 0.2))
class_name CameraShake
extends Camera2D

var _shake_duration: float = 0.0
var _shake_strength: float = 0.0

func shake(strength: float, duration: float) -> void:
	_shake_strength = maxf(strength, 0.0)
	_shake_duration = maxf(duration, 0.0)

func _process(delta: float) -> void:
	if _shake_duration > 0.0:
		_shake_duration -= delta
		if _shake_duration > 0.0:
			offset = Vector2(
				randf_range(-_shake_strength, _shake_strength),
				randf_range(-_shake_strength, _shake_strength)
			)
		else:
			_shake_duration = 0.0
			offset = Vector2.ZERO
	else:
		offset = Vector2.ZERO
