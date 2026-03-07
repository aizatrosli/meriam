## CannonFirer – controlled by Player 2 (Anak Bongsu).
## When the meriam is loaded, Player 2 presses fire to launch the bola meriam.
## Locks the barrel (CannonAimer) during the post-shot cooldown.
## Plays a loud BOOM – the signature Raya night sound.
## Replaces Unity's CannonFirer MonoBehaviour.
class_name CannonFirer
extends Node

@export var config: GameConfig
@export var aimer: CannonAimer
@export var loader: CannonLoader
@export var muzzle_point: Marker2D
@export var audio_player: AudioStreamPlayer2D
@export var fire_sound: AudioStream

var can_fire: bool:
	get: return loader != null and loader.is_loaded and not aimer.is_locked

var cooldown_duration: float:
	get: return config.cannon_cooldown_duration if config else 1.5

## Emitted immediately when the cannon fires.
signal fired()
## Emitted when the post-shot cooldown ends.
signal cooldown_complete()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func fire() -> void:
	if not can_fire:
		return
	aimer.is_locked = true

	# Spawn bola meriam (cannonball)
	if config and config.cannon_ball_scene and muzzle_point:
		var projectile_node = config.cannon_ball_scene.instantiate()
		muzzle_point.get_tree().get_root().add_child(projectile_node)
		projectile_node.global_position = muzzle_point.global_position
		projectile_node.rotation_degrees = aimer.current_angle

		if projectile_node.has_method("launch"):
			projectile_node.launch(
				aimer.current_angle,
				config.projectile_speed,
				config.projectile_damage,
				config.projectile_lifetime
			)

	loader.cancel_loading()

	if audio_player and fire_sound:
		audio_player.stream = fire_sound
		audio_player.play()

	fired.emit()
	_start_cooldown()

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _start_cooldown() -> void:
	await get_tree().create_timer(cooldown_duration).timeout
	aimer.is_locked = false
	cooldown_complete.emit()
