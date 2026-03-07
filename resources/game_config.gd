## GameConfig – top-level tuning data for Meriam Raya.
## Replaces Unity's GameConfigSO ScriptableObject.
## Edit values in the Godot Inspector via game_config.tres.
class_name GameConfig
extends Resource

# ---------------------------------------------------------------------------
# Game Rules
# ---------------------------------------------------------------------------
@export var starting_lives: int = 3
@export var round_count: int = 5

# ---------------------------------------------------------------------------
# Cannon – Aiming (Player 1 / Anak Sulung)
# ---------------------------------------------------------------------------
## Degrees per second Player 1 can rotate the cannon barrel.
@export var cannon_aim_speed: float = 60.0
@export var min_aim_angle: float = 0.0
@export var max_aim_angle: float = 75.0

# ---------------------------------------------------------------------------
# Cannon – Loading (Player 2 / Anak Bongsu)
# ---------------------------------------------------------------------------
## Seconds Player 2 must hold the load button to fully pack the meriam.
@export var cannon_load_duration: float = 2.0
## Seconds after firing before the cannon can be loaded again.
@export var cannon_cooldown_duration: float = 1.5

# ---------------------------------------------------------------------------
# Projectile (Bola Meriam)
# ---------------------------------------------------------------------------
@export var projectile_speed: float = 15.0
@export var projectile_lifetime: float = 4.0
@export var projectile_damage: int = 1
@export var cannon_ball_scene: PackedScene

# ---------------------------------------------------------------------------
# Rounds
# ---------------------------------------------------------------------------
@export var rounds: Array[RoundConfig] = []
