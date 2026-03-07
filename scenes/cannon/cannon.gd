## Cannon – root node for the Meriam Buluh prefab.
## Wires sub-components together after they are ready.
## Config is injected by game.gd after the scene tree is ready.
## Replaces Unity's CannonController MonoBehaviour.
class_name Cannon
extends Node2D

@onready var aimer: CannonAimer = $CannonAimer
@onready var loader: CannonLoader = $CannonLoader
@onready var firer: CannonFirer = $CannonFirer
@onready var reload_indicator: CannonReloadIndicator = $ReloadIndicatorNode

func _ready() -> void:
	# Wire sub-components together (no config yet; set_config() called by game.gd)
	firer.aimer = aimer
	firer.loader = loader
	firer.muzzle_point = $BarrelPivot/MuzzlePoint
	firer.audio_player = $AudioStreamPlayer2D
	aimer.barrel_pivot = $BarrelPivot
	reload_indicator.loader = loader
	reload_indicator.fill_bar = $ReloadUI/FillBar
	reload_indicator.load_status_label = $ReloadUI/LoadStatusLabel

## Called by game.gd once the GameConfig resource is available.
func set_config(config: GameConfig) -> void:
	aimer.config = config
	loader.config = config
	firer.config = config
