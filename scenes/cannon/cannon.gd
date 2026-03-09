## Cannon – root node for the Meriam Buluh prefab.
## Wires sub-components together after they are ready.
## Config is injected by game.gd after the scene tree is ready.
## Replaces Unity's CannonController MonoBehaviour.
class_name Cannon
extends Node2D

# ---------------------------------------------------------------------------
# Visual Asset Replacements
# ---------------------------------------------------------------------------
## REPLACE ME: Assign a Sprite2D texture for the meriam (cannon body).
## Suggested: a painted bamboo or wooden cannon base image aligned to origin,
## approx 80×40 px (e.g. res://assets/cannon_body.png).
@export var cannon_body_texture: Texture2D

## REPLACE ME: Assign a Sprite2D texture for the barrel (laras meriam).
## Suggested: a horizontal bamboo pipe image, approx 80×20 px, tip pointing
## to the right so it aligns with the muzzle at x=80 (e.g. res://assets/barrel.png).
@export var barrel_texture: Texture2D

## REPLACE ME: Assign an AudioStream for the cannon fire sound (bunyi meriam).
## Suggested: a loud traditional meriam buluh BOOM clip in OGG format
## (e.g. res://assets/audio/cannon_fire.ogg).
@export var fire_sound: AudioStream

# ---------------------------------------------------------------------------
# Internal nodes
# ---------------------------------------------------------------------------
@onready var aimer: CannonAimer = $CannonAimer
@onready var loader: CannonLoader = $CannonLoader
@onready var firer: CannonFirer = $CannonFirer
@onready var reload_indicator: CannonReloadIndicator = $ReloadIndicatorNode
@onready var muzzle_flash: CPUParticles2D = $BarrelPivot/MuzzlePoint/MuzzleFlash

func _ready() -> void:
	# Apply exported textures to sprite placeholders when provided by the artist.
	# Falls back to a solid-colour ImageTexture so the cannon is visible during
	# development even when no art assets have been assigned.
	var cannon_body := get_node_or_null("CannonBody") as Sprite2D
	if cannon_body:
		if cannon_body_texture == null:
			cannon_body_texture = _make_rect_texture(80, 40, Color(0.55, 0.35, 0.15))
		cannon_body.texture = cannon_body_texture

	var barrel_sprite := get_node_or_null("BarrelPivot/BarrelSprite") as Sprite2D
	if barrel_sprite:
		if barrel_texture == null:
			barrel_texture = _make_rect_texture(80, 16, Color(0.35, 0.20, 0.08))
		barrel_sprite.texture = barrel_texture

	# Wire sub-components together (no config yet; set_config() called by game.gd)
	firer.aimer = aimer
	firer.loader = loader
	firer.muzzle_point = $BarrelPivot/MuzzlePoint
	firer.audio_player = $AudioStreamPlayer2D
	firer.fire_sound = fire_sound  # pass exported audio asset into firer
	aimer.barrel_pivot = $BarrelPivot
	reload_indicator.loader = loader
	reload_indicator.fill_bar = $ReloadUI/FillBar
	reload_indicator.load_status_label = $ReloadUI/LoadStatusLabel
	firer.fired.connect(func(): muzzle_flash.restart())

## Called by game.gd once the GameConfig resource is available.
func set_config(config: GameConfig) -> void:
	aimer.config = config
	loader.config = config
	firer.config = config

# ---------------------------------------------------------------------------
# Placeholder texture helpers (used when no art assets are assigned)
# ---------------------------------------------------------------------------

static func _make_rect_texture(w: int, h: int, color: Color) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
