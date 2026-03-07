## TargetSpawnEntry – one entry in a round's target list.
## Defines what type of target to spawn, how many, and placement.
class_name TargetSpawnEntry
extends Resource

@export var config: TargetConfig
@export var count: int = 3
## Horizontal spacing between spawned targets (world units).
@export var spacing: float = 1.5
## Y position offset relative to the ground line.
@export var height_offset: float = 0.0
