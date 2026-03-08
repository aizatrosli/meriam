## ScorePopup – floating "+N" label that rises and fades after a target kill.
## Add to scene tree first, then call launch() to animate.
class_name ScorePopup
extends Node2D

@onready var label: Label = $Label

func launch(points: int, world_pos: Vector2) -> void:
	label.text = "+%d" % points
	global_position = world_pos
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 80.0, 0.85)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.55).set_delay(0.3)
	await tw.finished
	queue_free()
