## Cannon – root node for the Meriam Buluh prefab.
## Provides a single access point to cannon sub-components.
## Replaces Unity's CannonController MonoBehaviour.
class_name Cannon
extends Node2D

@export var aimer: CannonAimer
@export var loader: CannonLoader
@export var firer: CannonFirer
@export var reload_indicator: CannonReloadIndicator
