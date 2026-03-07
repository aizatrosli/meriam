## TargetSpawner – spawns targets in the kampung yard according to a RoundConfig.
## Positions them horizontally across the scene's target zone.
## Replaces Unity's TargetSpawner MonoBehaviour.
class_name TargetSpawner
extends Node2D

@export var target_zone_center: Marker2D

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func spawn_round(round_config: RoundConfig) -> void:
	_spawn_routine(round_config)

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _spawn_routine(round_cfg: RoundConfig) -> void:
	await get_tree().create_timer(round_cfg.round_start_delay).timeout

	var zone_x: float = target_zone_center.position.x - 3.0 if target_zone_center else -3.0
	var zone_y: float = target_zone_center.position.y if target_zone_center else 0.0

	for entry: TargetSpawnEntry in round_cfg.targets:
		for i: int in entry.count:
			var spawn_pos := Vector2(
				zone_x,
				zone_y + entry.height_offset
			)
			if entry.config and entry.config.scene:
				var obj := entry.config.scene.instantiate()
				get_tree().get_root().add_child(obj)
				obj.global_position = global_position + spawn_pos
				if obj.has_method("initialize"):
					obj.initialize()

			zone_x += entry.spacing
			await get_tree().create_timer(round_cfg.time_between_spawns).timeout
