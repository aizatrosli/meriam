# Meriam Raya – Architecture Reference

This document is the authoritative technical reference for the Meriam Raya codebase.
It covers every major system, how they wire together, every signal, the state machine,
the data-resource graph, design decisions, and directions for future work.

**Engine:** Godot 4.3 · **Language:** GDScript · **Date:** 2026-03-08

---

## Table of Contents

1. [Project Layout](#1-project-layout)
2. [Autoloads – Persistent Singletons](#2-autoloads--persistent-singletons)
3. [Game State Machine](#3-game-state-machine)
4. [Cannon Module](#4-cannon-module)
5. [Player Input Module](#5-player-input-module)
6. [Target Module](#6-target-module)
7. [Round & Game Flow](#7-round--game-flow)
8. [Data Resource Graph](#8-data-resource-graph)
9. [UI System](#9-ui-system)
10. [Online Networking](#10-online-networking)
11. [Signal Flow Reference](#11-signal-flow-reference)
12. [Physics Collision Layers](#12-physics-collision-layers)
13. [Scene Graph: game.tscn](#13-scene-graph-gametscn)
14. [Malay Terminology Glossary](#14-malay-terminology-glossary)
15. [Architectural Decisions & Rationale](#15-architectural-decisions--rationale)
16. [Future Architectural Directions](#16-future-architectural-directions)

---

## 1. Project Layout

```
meriam/
├── autoloads/
│   ├── game_manager.gd       # Central event bus; owns LivesManager + GameState
│   └── score_manager.gd      # Score tracking + high-score persistence
│
├── resources/
│   ├── game_config.gd        # Resource class: top-level tuning data
│   ├── game_config.tres      # The actual game configuration asset
│   ├── round_config.gd       # Resource class: one round's data
│   ├── round_config_1.tres   # Round 1 asset
│   ├── round_config_2.tres   # Round 2 asset
│   ├── round_config_3.tres   # Round 3 asset
│   ├── target_config.gd      # Resource class: one target type's stats + scene ref
│   ├── target_config_pelita.tres
│   ├── target_config_kelapa.tres
│   ├── target_config_belon.tres
│   ├── target_spawn_entry.gd # Resource class: count + spacing for one spawn batch
│   └── (inline sub-resources in .tres files)
│
├── scenes/
│   ├── cannon/
│   │   ├── cannon.tscn / cannon.gd                   # Orchestrator; wires sub-components
│   │   ├── cannon_aimer.gd                           # Barrel rotation (Player 1)
│   │   ├── cannon_firer.gd                           # Fire logic (Player 2)
│   │   ├── cannon_loader.gd                          # Hold-to-load mechanic
│   │   ├── cannon_projectile.tscn / cannon_projectile.gd  # Bola meriam
│   │   └── cannon_reload_indicator.gd                # Progress bar + label updater
│   │
│   ├── game/
│   │   ├── game.tscn / game.gd                       # Root gameplay scene; wires all systems
│   │   └── round_manager.gd                          # Sequences rounds from GameConfig
│   │
│   ├── main_menu/
│   │   └── main_menu.tscn / main_menu.gd             # Mode selection + lobby UI
│   │
│   ├── network/
│   │   ├── lobby_manager.gd                          # Create/join online lobbies
│   │   └── network_game_manager.gd                   # Sync game state over network
│   │
│   ├── players/
│   │   ├── player1_controller.gd                     # Routes P1 aim input → CannonAimer
│   │   ├── player2_controller.gd                     # Routes P2 load/fire input
│   │   └── player_input_router.gd                    # Reads InputMap; dispatches to controllers
│   │
│   ├── targets/
│   │   ├── target_base.gd                            # Abstract base; "damageable" group
│   │   ├── target_pelita.tscn / target_pelita.gd     # Swinging oil lamp
│   │   ├── target_kelapa.tscn / target_kelapa.gd     # Rolling coconut (RigidBody2D)
│   │   ├── target_belon.tscn / target_belon.gd       # Floating balloon
│   │   └── target_spawner.gd                         # Async spawn coroutine
│   │
│   └── ui/
│       ├── hud.gd                                    # Score, lives, round, load bar
│       ├── game_over_ui.gd                           # Game-over and victory panels
│       ├── round_announcement.gd                     # Full-screen between-round overlay
│       └── tutorial_overlay.tscn / tutorial_overlay.gd  # Step-by-step How to Play (5 steps)
│
├── scripts/
│   ├── game_state_machine.gd                         # FSM (RefCounted, not a Node)
│   └── lives_manager.gd                              # Life tracking (RefCounted)
│
├── tests/
│   ├── .gutconfig.json                               # GUT scan config
│   ├── unit/                                         # Isolated logic tests
│   └── integration/                                  # Scene-based flow tests
│
├── addons/gut/                                       # GUT framework (installed by CI)
├── export_presets.cfg                                # Linux / Windows / Web export presets
└── .github/workflows/
    └── ci.yml                                        # Test + build pipeline
```

---

## 2. Autoloads – Persistent Singletons

Registered in `project.godot` under `[autoload]`. Accessible from any script via their node name.

### GameManager (`autoloads/game_manager.gd`)

The central game event bus and state coordinator.

**Owns:**
- `lives_manager: LivesManager` — instantiated in `_ready()`
- `state_machine: GameState` — instantiated in `_ready()`
- `round_manager: Node` — injected by `Game._ready()`

**Signals emitted:**

| Signal | When |
|---|---|
| `target_hit(score_value: int)` | A target was defeated |
| `life_lost(lives_remaining: int)` | A projectile missed (expired without hitting) |
| `round_complete(round_number: int)` | All targets in a round destroyed |
| `game_over(final_score: int)` | Lives reached zero |
| `victory(final_score: int)` | All rounds completed |
| `state_changed(from: State, to: State)` | State machine transitioned |

**Public API:**

```
start_game(config: GameConfig)         # Reset score; initialize lives; force-reset state
                                       # to MAIN_MENU then transition → ROUND_COUNTDOWN
on_target_defeated(score_value: int)   # Called by TargetBase._on_death()
on_projectile_missed()                 # Called by CannonProjectile._notification(PREDELETE)
                                       # No-op unless state == PLAYING (guards scene-change races)
on_round_complete(round_number: int)   # Called by RoundManager
on_all_rounds_complete()               # Called by RoundManager
pause_game() / resume_game()
return_to_main_menu()                  # Resets state to MAIN_MENU before changing scene
```

---

### ScoreManager (`autoloads/score_manager.gd`)

**State:** `current_score: int = 0`

**Persistence:** Reads/writes `user://meriam_raya_save.cfg` via `ConfigFile`.
Key: section `"MeriamRaya"`, key `"MeriamRaya_HighScore"`.

**Signals:**

| Signal | When |
|---|---|
| `score_changed(new_score: int)` | Score updated |

**Public API:**

```
get_current_score() -> int
get_high_score() -> int
add_score(points: int)     # Adds points; saves new high score if beaten; emits signal
reset_score()              # Resets to 0
```

---

## 3. Game State Machine

`GameState` (`scripts/game_state_machine.gd`) — extends `RefCounted` (not a Node; no scene lifecycle).

### States

```gdscript
enum State {
    MAIN_MENU,
    ROUND_COUNTDOWN,
    PLAYING,
    PAUSED,
    ROUND_COMPLETE,
    GAME_OVER,
    VICTORY
}
```

### Valid Transitions (ASCII)

```
                       ┌──────────────────────────────────────────┐
                       ▼                                          │
MAIN_MENU ──► ROUND_COUNTDOWN ──► PLAYING ──► ROUND_COMPLETE ──► ROUND_COUNTDOWN
                                     │              │
                                     │              └──► VICTORY ──► MAIN_MENU
                                     │
                                     ├──► PAUSED ──► PLAYING
                                     │         └──► MAIN_MENU
                                     │
                                     └──► GAME_OVER ──► MAIN_MENU
```

### Signal

```
state_changed(from_state: State, to_state: State)
```

`GameState.transition_to(new_state)` validates the transition against the table above and silently
returns (no error) if the transition is invalid — this prevents crashes on edge-case races such as
a projectile missing the instant a round completes.

---

## 4. Cannon Module

### Orchestrator Pattern

`Cannon` (`scenes/cannon/cannon.gd`) is the root node of the cannon scene. It does **not** contain
game logic; it wires four child nodes by injecting references in `_ready()`. Config is pushed down
via `Cannon.set_config(config: GameConfig)`, which fans out to all sub-components.

```
Cannon (Node2D)                      cannon.gd
├── BarrelPivot (Node2D)
│   └── MuzzlePoint (Marker2D)       ─── injected → CannonFirer.muzzle_point
├── CannonAimer (Node2D)             cannon_aimer.gd
├── CannonLoader (Node)              cannon_loader.gd
├── CannonFirer (Node)               cannon_firer.gd
├── ReloadIndicatorNode (Node)       cannon_reload_indicator.gd
│   └── (injected fill_bar, load_status_label from ReloadUI children)
└── AudioStreamPlayer2D              ─── injected → CannonFirer.audio_player
```

### CannonAimer (`cannon_aimer.gd`)

Controlled by **Player 1 (Anak Sulung)**.

- `current_angle: float` — current barrel angle in degrees
- `is_locked: bool` — set `true` by `CannonFirer` on fire; cleared after cooldown
- Angle clamped to `[config.min_aim_angle, config.max_aim_angle]` (default 0°–75°)
- `adjust_aim(delta_angle)` — increment by delta; ignored when locked
- `set_aim_angle(angle)` — absolute set; clamped; ignored when locked
- Applies rotation via `barrel_pivot.rotation_degrees`

### CannonLoader (`cannon_loader.gd`)

Controlled by **Player 2 (Anak Bongsu)** — hold to load.

- `load_progress: float` — 0.0 → 1.0, accumulated in `_process(delta)`
- `is_loaded: bool` — true when `load_progress >= 1.0`
- `load_duration: float` — from `config.cannon_load_duration` (default 2.0 s)
- `begin_loading()` — starts accumulation (no-op if already loaded)
- `cancel_loading()` — resets progress and state
- `force_load()` — debug helper; instantly completes load
- **Signal:** `load_complete()` — emitted at 100% (currently polled by `CannonReloadIndicator`
  and `CannonFirer.can_fire` computed property; signal available for VFX hooks)

### CannonFirer (`cannon_firer.gd`)

- `can_fire: bool` (computed) — `loader.is_loaded && !aimer.is_locked`
- `fire()`:
  1. Guards on `can_fire`
  2. Locks `aimer.is_locked = true`
  3. Instantiates `config.cannon_ball_scene` at `muzzle_point.global_position`
  4. Calls `projectile.launch(angle, speed, damage, lifetime)` from config values
  5. Calls `loader.cancel_loading()` (resets for next shot)
  6. Plays fire sound via `audio_player`
  7. Emits `fired()`
  8. Calls `_start_cooldown()` — async; waits `cooldown_duration`, unlocks aimer, emits `cooldown_complete()`
- **Signals:** `fired()`, `cooldown_complete()` — both available for VFX/SFX extension points

### CannonProjectile (`cannon_projectile.gd`) — extends `Area2D`

- `launch(angle_deg, speed, damage, lifetime)` — initializes velocity vector and starts a `Timer`
- `_physics_process(delta)` — applies gravity each frame (parabolic arc)
- Collision: `_on_body_entered` / `_on_area_entered` → `_try_damage(node)`
  - Checks `node.is_in_group("damageable") && node.has_method("take_damage")`
  - Calls `node.take_damage(_damage)`, marks `_hit = true`, destroys self
- `_notification(NOTIFICATION_PREDELETE)` — if `!_hit`, calls `GameManager.on_projectile_missed()`
  (covers both lifetime expiry and out-of-bounds cleanup)

### CannonReloadIndicator (`cannon_reload_indicator.gd`)

Polls `loader.load_progress` and `loader.is_loaded` every `_process()` frame:

```
fill_bar.value           = loader.load_progress * 100
load_status_label.text   = "Sedia!" if loader.is_loaded else "Isi..."
```

---

## 5. Player Input Module

### Input Actions (project.godot)

| Action | Default Key | Player |
|---|---|---|
| `p1_aim_up` | W | Player 1 |
| `p1_aim_down` | S | Player 1 |
| `p2_load` | Space | Player 2 |
| `p2_fire` | Enter | Player 2 |
| `p2_load_gamepad` | *(unassigned)* | Player 2 gamepad stub |

### Dispatch Chain

```
PlayerInputRouter
│  _process(delta)          continuous input
│    Input.is_action_pressed("p1_aim_up")   → player1.on_aim_input(+speed * delta)
│    Input.is_action_pressed("p1_aim_down") → player1.on_aim_input(-speed * delta)
│
│  _input(event)            discrete events
│    p2_load  pressed        → player2.on_load_pressed()
│    p2_load  released       → player2.on_load_released()
│    p2_fire  pressed        → player2.on_fire_pressed()
│
├── Player1Controller
│     on_aim_input(delta_angle) → aimer.adjust_aim(delta_angle)
│
└── Player2Controller
      on_load_pressed()    → loader.begin_loading()
      on_load_released()   → loader.cancel_loading()   (only if not yet loaded)
      on_fire_pressed()    → firer.fire()
```

**Network routing:** `PlayerInputRouter` has `only_player1_local: bool` and
`only_player2_local: bool` export flags. When playing online, the host sets
`only_player1_local = true` (only routes P1 input), the client sets
`only_player2_local = true` (only routes P2 input). Both flags `false` = local co-op.

---

## 6. Target Module

### Inheritance

```
TargetBase (Node2D)            scripts/target_base.gd
├── TargetPelita (Node2D)      scenes/targets/target_pelita.gd   – swinging oil lamp
└── TargetBelon (Node2D)       scenes/targets/target_belon.gd    – floating balloon

TargetKelapa (RigidBody2D)     scenes/targets/target_kelapa.gd   – rolling coconut
```

`TargetKelapa` does **not** extend `TargetBase` because it requires a `RigidBody2D` parent for
physics simulation. It reimplements the same public interface (`take_damage`, `initialize`,
group membership) manually.

### TargetBase API

```gdscript
@export var config: TargetConfig

func initialize(health_multiplier: float = 1.0)   # called by TargetSpawner after instancing
func take_damage(amount: int)                      # duck-typed IDamageable entry point

# Virtual hooks — override in subclasses:
func _on_hit()                  # called every time damage is taken (VFX, feedback)
func _on_death()                # called when health reaches 0; awards score; queues_free
func _spawn_death_effect()      # instantiate VFX PackedScene at death position
```

**Group:** All targets add themselves to `"damageable"` in `_ready()`. This is how
`CannonProjectile` discovers them without a direct reference.

### Target Behaviours

| Target | Base Class | Behaviour |
|---|---|---|
| `TargetPelita` | `TargetBase` | Sinusoidal swing (`sin(Time.get_ticks_msec())` rotation); flame dim on hit; smoke VFX on death |
| `TargetKelapa` | `RigidBody2D` | Frozen until hit; applies impulse + torque on `_on_hit()`; delayed `queue_free` after death |
| `TargetBelon` | `TargetBase` | Drifts upward + sinusoidal side sway each `_process(delta)`; confetti VFX on death |

### TargetSpawner (`target_spawner.gd`)

`spawn_round(round_config: RoundConfig)` launches an `async` coroutine `_spawn_routine()`:

```
await get_tree().create_timer(round_cfg.round_start_delay).timeout

for entry in round_cfg.targets:           # TargetSpawnEntry array
    for i in entry.count:
        instance = entry.config.scene.instantiate()
        instance.position = target_zone_center.position + Vector2(i * entry.spacing, entry.height_offset)
        add_child(instance)
        if instance.has_method("initialize"):
            instance.initialize()
        await get_tree().create_timer(round_cfg.time_between_spawns).timeout
```

---

## 7. Round & Game Flow

### RoundManager (`scenes/game/round_manager.gd`)

Sequences rounds from `GameConfig.rounds[]`. Wired by `Game._ready()`.

**State:**
- `current_round_index: int` — 0-based index into `config.rounds`
- `targets_remaining_in_round: int` — decremented by `_on_target_hit()`

**Signals:**

| Signal | When |
|---|---|
| `round_started(round_number: int)` | A round begins (1-based number) |
| `round_complete(round_number: int)` | All targets defeated |
| `all_rounds_complete()` | Last round finished |

**Flow:**

```
Game._ready()
  ├─► GameManager.start_game(config)      [initializes lives; state → ROUND_COUNTDOWN]
  ├─► hud.refresh_lives(lives)            [syncs HUD before tutorial is visible]
  └─► tutorial_overlay.show_tutorial()   [pauses tree; shows 5 How-to-Play steps]
        └─ [player clicks Seterusnya → / Langkau]
             └─ tutorial_completed signal → Game._on_tutorial_completed()
                  └─► round_manager.start_round(0)
                        ├─ count targets in round_cfg
                        ├─ target_spawner.spawn_round(round_cfg)    [async, fire-and-forget]
                        ├─ emit round_started(1)
                        └─ GameManager.state_machine → PLAYING

  [each target defeated]
  GameManager.on_target_defeated(score)
    ├─ ScoreManager.add_score(score)
    └─ emit target_hit(score)
         └─ RoundManager._on_target_hit()
              └─ register_target_defeated()
                   └─ [when targets_remaining == 0] advance_round()
                         ├─ [if last round] GameManager.on_all_rounds_complete() → VICTORY
                         └─ [else] GameManager.on_round_complete() → start_round(next_index)
```

### Lives Flow

```
  [projectile expires without hit]
  CannonProjectile._notification(PREDELETE)
    └─ GameManager.on_projectile_missed()
         ├─ [if state != PLAYING] return  ← guard: no-op during tutorial / scene change
         └─ lives_manager.lose_life()
              ├─ emit life_lost(lives_remaining)
              └─ [if is_game_over] GameManager triggers GAME_OVER
                    └─ emit game_over(final_score)
```

---

## 8. Data Resource Graph

All configuration is expressed as Godot `Resource` assets (`.tres` files) with explicit
`script = ExtResource(...)` references. This ensures correct loading in headless (CI) export.

```
game_config.tres  (GameConfig)
│
│   cannon_aim_speed: float = 60.0         degrees/second
│   min_aim_angle: float = 0.0
│   max_aim_angle: float = 75.0
│   cannon_load_duration: float = 2.0      seconds to fully load
│   cannon_cooldown_duration: float = 1.5  post-fire lock duration
│   projectile_speed: float = 15.0
│   projectile_lifetime: float = 4.0
│   projectile_damage: int = 1
│   cannon_ball_scene: PackedScene         → cannon_projectile.tscn
│   starting_lives: int = 3
│   round_count: int = 3
│
└── rounds: Array[RoundConfig]
     │
     ├── round_config_1.tres  (RoundConfig)
     │    │   round_number: int = 1
     │    │   round_announcement_malay: String
     │    │   round_start_delay: float = 3.0
     │    │   time_between_spawns: float = 1.5
     │    │   completion_bonus_score: int = 500
     │    │   time_limit: float = 60.0
     │    │
     │    └── targets: Array[TargetSpawnEntry]
     │         └── TargetSpawnEntry (inline sub-resource)
     │              │   count: int = 3
     │              │   spacing: float = 1.5
     │              │   height_offset: float = 0.0
     │              └── config: TargetConfig → target_config_pelita.tres
     │                   │   target_id: String
     │                   │   display_name_malay: String
     │                   │   base_health: int = 1
     │                   │   score_value: int = 100
     │                   │   type: TargetType (enum)
     │                   └── scene: PackedScene → target_pelita.tscn
     │
     ├── round_config_2.tres  ...
     └── round_config_3.tres  ...
```

### TargetConfig Fields

```gdscript
enum TargetType { STATIONARY, SWINGING, ROLLING, FLOATING }

@export var target_id: String
@export var display_name_malay: String
@export var base_health: int = 1
@export var score_value: int = 100
@export var scene: PackedScene
@export var type: TargetType
@export var is_swinging: bool
@export var is_moving: bool
@export var move_speed: float = 1.0
```

---

## 9. UI System

All UI scripts extend `CanvasLayer` and connect to `GameManager` signals in `_ready()`.

### HUD (`scenes/ui/hud.gd`)

Displays: Markah (score) · Nyawa (lives) · Pusingan (round) · reload progress bar.

- `cannon_loader: CannonLoader` — injected by `Game._ready()` after both nodes exist
- `_process()` — polls `cannon_loader.load_progress` and `is_loaded` each frame (same as `CannonReloadIndicator`)
- Listens to `GameManager.target_hit` → `_on_target_hit(score)` → calls `ScoreManager.get_current_score()`
- Listens to `GameManager.life_lost` → `_on_life_lost(lives)` → updates nyawa label
- `update_round(round_number: int)` — called by `RoundManager.round_started` signal
- `refresh_lives(lives: int)` — public method; called by `Game._ready()` after `start_game()` to set
  the initial lives display (HUD `_ready()` runs before lives are initialized, so it would otherwise
  show 0 until the first miss)

### GameOverUI (`scenes/ui/game_over_ui.gd`)

Two panels on the same `CanvasLayer`: `game_over_panel` and `victory_panel`.

- `show_game_over(score)` — shows game-over panel; reads `ScoreManager.get_high_score()`
- `show_victory(score)` — shows victory panel
- **Play Again** button → `SceneTree.change_scene_to_file("res://scenes/game/game.tscn")`
- **Back to Menu** button → `GameManager.return_to_main_menu()`

### RoundAnnouncementUI (`scenes/ui/round_announcement.gd`)

Full-screen overlay shown between rounds. `display_duration: float = 2.5`.

```gdscript
show_round_announcement(round_number: int, malay_text: String = "")
# Sets: "Pusingan {n} / Round {n}"
# Sets subtitle (default: "Meriam siap! / Ready the cannon!")
# Shows panel → awaits timer → hides panel
```

Called by `Game._on_round_started()` with the `RoundConfig.round_announcement_malay` text.

### TutorialOverlayUI (`scenes/ui/tutorial_overlay.gd`)

Bilingual (Malay/English) step-by-step "How to Play" overlay shown automatically when the game
scene loads, before the first round starts.

- `layer = 10`, `process_mode = ALWAYS` — renders on top of everything; responds to input even
  when the scene tree is paused
- `show_tutorial()` — resets to step 1, fades in background + panel, calls `get_tree().paused = true`
- **Seterusnya → / Next** button — advances one step; final step shows **Mula! / Start!**
- **Langkau / Skip** button — skips directly to completion from any step
- On completion: fades out, unpauses tree, emits `tutorial_completed` signal
- `Game._on_tutorial_completed()` calls `round_manager.start_round(0)` in response

**5 steps:**

| Step | Title | Content |
|------|-------|---------|
| 1 | Selamat Datang! / Welcome! | Introduction — two players cooperate |
| 2 | Pemain 1 – Anak Sulung | W to aim up, S to aim down |
| 3 | Pemain 2 – Anak Bongsu (Mengisi) | Hold Space to load |
| 4 | Pemain 2 – Anak Bongsu (Menembak) | Press Enter to fire when loaded |
| 5 | Sasaran & Nyawa / Targets & Lives | Point values (100 / 150 / 200) and 3-life system |

**Placeholder visual pattern.** All game object scripts (`cannon.gd`, `cannon_projectile.gd`,
`target_pelita.gd`, `target_kelapa.gd`, `target_belon.gd`) include private static helpers
`_make_rect_texture(w, h, color)` and/or `_make_circle_texture(radius, color)` that generate a
solid-colour `ImageTexture` via `Image.create()` at runtime. These are used as fallbacks in
`_ready()` when the `@export var ..._texture: Texture2D` is `null`. Assigning a real texture in
the Inspector always overrides the placeholder.

### MainMenu (`scenes/main_menu/main_menu.gd`)

- **Main Tempatan** → `SceneTree.change_scene_to_file("res://scenes/game/game.tscn")`
- **Main Dalam Talian** → shows `online_panel`
- **Create Lobby** → `lobby_manager.create_lobby()` → displays join code from `join_code_ready` signal
- **Join Lobby** → `lobby_manager.join_lobby(join_code_input.text)` → loads game on `joined` signal
- Displays `ScoreManager.get_high_score()` on the high score label

---

## 10. Online Networking

Stubs exist in `scenes/network/`. The architecture is designed for Godot's built-in multiplayer API.

### LobbyManager (`scenes/network/lobby_manager.gd`)

**Signals:** `join_code_ready(code: String)`, `joined()`, `error_occurred(message: String)`

**API:** `create_lobby()`, `join_lobby(code: String)`

Intended implementation: Godot ENet or WebRTC peer-to-peer with a lightweight relay/matchmaker.
The join code is a short alphanumeric string identifying the ENet session.

### NetworkGameManager (`scenes/network/network_game_manager.gd`)

Injected into `Game` via `@onready`. Responsible for syncing game state (fire events, target
health, score) over the network. Not yet fully implemented.

**Design intent:** Authoritative server model — the host (Player 1) runs `GameManager` and
`RoundManager` as authoritative; `NetworkGameManager` relays `target_hit`, `life_lost`, and
`round_complete` events to the client (Player 2). Client only sends input events upstream.

---

## 11. Signal Flow Reference

Complete table of all inter-system signal connections at runtime.

| Emitter | Signal | Receiver | Handler Method |
|---|---|---|---|
| `GameManager` | `target_hit(score)` | `HUD` | `_on_target_hit` |
| `GameManager` | `target_hit(score)` | `RoundManager` | `_on_target_hit` |
| `GameManager` | `life_lost(lives)` | `HUD` | `_on_life_lost` |
| `GameManager` | `life_lost(lives)` | `Game` | lambda → `camera.shake(10.0, 0.35)` |
| `GameManager` | `game_over(score)` | `GameOverUI` | `show_game_over` |
| `GameManager` | `victory(score)` | `GameOverUI` | `show_victory` |
| `GameManager.state_machine` | `state_changed(from, to)` | `GameManager` | `_on_state_changed` |
| `RoundManager` | `round_started(n)` | `HUD` | `update_round` |
| `RoundManager` | `round_started(n)` | `Game` | `_on_round_started` |
| `TutorialOverlayUI` | `tutorial_completed` | `Game` | `_on_tutorial_completed` |
| `CannonFirer` | `fired()` | `Game` | lambda → `camera.shake(6.0, 0.2)` |
| `CannonFirer` | `fired()` | *(none — extension point)* | muzzle flash via `muzzle_flash.restart()` in cannon.gd |
| `CannonFirer` | `cooldown_complete()` | *(none)* | available for VFX/SFX extension |
| `CannonLoader` | `load_complete()` | *(none)* | polled via `is_loaded` property |
| `LobbyManager` | `join_code_ready(code)` | `MainMenu` | `_on_join_code_ready` |
| `LobbyManager` | `joined()` | `MainMenu` | `_on_lobby_joined` |
| `LobbyManager` | `error_occurred(msg)` | `MainMenu` | `_on_lobby_error` |
| `LivesManager` | `life_lost()` | `GameManager` | `_on_lives_manager_life_lost` |
| `LivesManager` | `game_over()` | `GameManager` | `_on_lives_manager_game_over` |
| `ScoreManager` | `score_changed(score)` | *(none)* | available; HUD currently polls directly |

---

## 12. Physics Collision Layers

Defined in `ProjectSettings → Physics → 2D → Layer Names`.

| Layer # | Name | Used By |
|---|---|---|
| 1 | `world` | Static environment (ground, walls) |
| 2 | `cannon_projectile` | `CannonProjectile` (Area2D) |
| 3 | `target` | Target Area2D / RigidBody2D collision shapes |
| 4 | `ground` | Floor collider (TargetKelapa landing reference) |

`CannonProjectile` listens on layers 3 (target area) and 1 (world body) via `_on_area_entered`
and `_on_body_entered`. It does **not** collide with layer 2 (prevents projectiles hitting each
other) or layer 4 separately.

---

## 13. Scene Graph: game.tscn

`Game` (Node2D, `game.gd`) is the root of the gameplay scene. All subsystem wiring happens in
`Game._ready()`. The order matters — nodes must exist before references are injected.

```
Game (Node2D)
├── Background (ColorRect)
├── Ground (StaticBody2D)
├── Cannon (cannon.tscn instance)
│     └── [wired internally by cannon.gd._ready()]
├── TargetZoneCenter (Marker2D)          ← spawn anchor for targets at Vector2(700, 520)
├── TargetSpawner (Node2D)
├── RoundManager (Node)
├── Player1Controller (Node)
├── Player2Controller (Node)
├── PlayerInputRouter (Node)
├── NetworkGameManager (Node)
├── CameraShake (Camera2D)
├── HUD (CanvasLayer)
├── RoundAnnouncementUI (CanvasLayer)
├── GameOverUI (CanvasLayer)
└── TutorialOverlayUI (CanvasLayer)      ← layer=10, process_mode=ALWAYS
```

**Wiring sequence in `Game._ready()`:**

1. `cannon.set_config(config)` — fans config to all cannon sub-components
2. `p1.aimer = cannon.aimer` — connects Player1Controller to CannonAimer
3. `p2.loader = cannon.loader`, `p2.firer = cannon.firer`
4. `player_input_router.player1 = p1`, `.player2 = p2`, `.config = config`
5. `network_manager.cannon = cannon`, `.player_input_router = player_input_router` → `assign_local_role()`
6. `target_spawner.target_zone_center = $TargetZoneCenter` — wires spawn anchor
7. `round_manager.config = config`, `.target_spawner = target_spawner`
8. `hud.cannon_loader = cannon.loader`
9. `round_manager.round_started.connect(hud.update_round)`
10. `round_manager.round_started.connect(_on_round_started)`
11. `GameManager.round_manager = round_manager`; camera shake lambdas connected
12. `GameManager.start_game(config)` + `hud.refresh_lives(lives)` — initializes lives, syncs HUD
13. `tutorial_overlay.show_tutorial()` — pauses tree; `tutorial_completed` → `_on_tutorial_completed()` → `round_manager.start_round(0)`

---

## 14. Malay Terminology Glossary

All display strings in UI use Malay. Code identifiers use English.

| Code Identifier | Malay Display | English Translation |
|---|---|---|
| `score` / `markah` | Markah | Score |
| `lives` / `nyawa` | Nyawa | Lives |
| `round` / `pusingan` | Pusingan | Round |
| `cannon` | Meriam | Cannon |
| `projectile` | Bola Meriam | Cannonball |
| Player 1 role | Anak Sulung | Elder Child (Aimer) |
| Player 2 role | Anak Bongsu | Younger Child (Loader/Firer) |
| Target: pelita | Pelita | Traditional oil lamp |
| Target: kelapa | Kelapa | Coconut |
| Target: belon | Belon | Balloon |
| Loader state — loaded | Sedia! | Ready! |
| Loader state — loading | Isi... | Loading... |
| Local play button | Main Tempatan | Play Local |
| Online play button | Main Dalam Talian | Play Online |
| Play again button | Main Semula | Play Again |
| Back to menu button | Balik Menu | Back to Menu |

Round announcement bilingual format: `"Pusingan {n} / Round {n}"` with subtitle
`"Meriam siap! / Ready the cannon!"` (or the `RoundConfig.round_announcement_malay` override).

| Code Identifier | Malay Display | English Translation |
|---|---|---|
| Tutorial button — next | Seterusnya → | Next |
| Tutorial button — skip | Langkau | Skip |
| Tutorial button — final step | Mula! | Start! |
| Main menu how-to-play | Cara Main | How to Play |

---

## 15. Architectural Decisions & Rationale

### Dependency Injection over `@export` in Cannon

`Cannon._ready()` injects node references into its children (`aimer`, `loader`, `firer`,
`reload_indicator`) at runtime rather than using `@export` NodePath pointers.

**Why:** All sub-components need the **same** `GameConfig` instance. Injecting in `_ready()`
guarantees the scene tree is fully initialised before wiring begins, and keeps sub-components
self-contained: they declare `var aimer: CannonAimer = null` and work with whatever is provided,
making them individually testable with mocks.

### TargetKelapa Extends RigidBody2D Directly

`TargetKelapa` reimplements the `take_damage` / `initialize` interface from scratch instead of
inheriting `TargetBase`.

**Why:** `TargetBase` extends `Node2D`, which has no physics body. The coconut rolling behaviour
requires `RigidBody2D` for `apply_impulse` and `apply_torque`. GDScript does not support multiple
inheritance, so replication of the thin interface was the only option. An alternative would be to
make `TargetBase` extend `Node` (engine-agnostic) and require all scenes to provide their own
visual root — this is a viable refactor (see §16).

### Duck-Typed `take_damage` Instead of an Interface

`CannonProjectile._try_damage(node)` checks `node.is_in_group("damageable") && node.has_method("take_damage")`.

**Why:** GDScript 4 has no `interface` keyword. The group + `has_method` pattern is the idiomatic
Godot approach and avoids hard coupling between the projectile and every target type. New target
types become hittable simply by adding themselves to the `"damageable"` group and implementing
`take_damage(int)`.

### LivesManager and GameState as RefCounted

Both are instantiated by `GameManager._ready()` and held as member variables — they are not nodes
and never enter the scene tree.

**Why:** They contain pure logic (state enum + transition table; life counter + game-over flag).
`RefCounted` is the correct base class for non-node logic objects: it provides automatic memory
management, no process loop overhead, and prevents accidental `add_child()` calls that would
pollute the scene tree.

### Resource `.tres` Files Use Explicit `script = ExtResource(...)`

Every custom Resource `.tres` file specifies the script via an `[ext_resource]` block with a
`path=` and `type="Script"`, then references it with `script = ExtResource(n)` in the
`[resource]` block.

**Why:** The alternative — `[gd_resource type="TargetConfig"]` without an explicit script
ext_resource — relies on Godot's class database being pre-populated. In a headless export
environment (CI runners, `--headless --import`) the class database may not be ready when resources
load, causing null-script errors. Explicit script references bypass the class DB entirely.

---

## 16. Future Architectural Directions

These are concrete, prioritised steps with enough detail to begin implementation.

### 1. Gamepad Support (Low effort)

`p2_load_gamepad` is already declared in `project.godot` but has no `JoypadButton` event assigned.

**Steps:**
1. Open `project.godot` → Input Map → `p2_load_gamepad` → add `JoypadButton 0` (South/A)
2. Add `p2_fire_gamepad` action → `JoypadButton 2` (East/B)
3. In `PlayerInputRouter._input(event)`, handle the gamepad actions alongside keyboard
4. Consider splitting `only_player2_local` into `player2_device: int` (keyboard device -1 vs. gamepad device 0)
5. Test with GUT: `test_player_input_router.gd` mock events for both device types

### 2. Additional Target Types (Medium effort)

The target module is designed for extension. See [docs/development.md](docs/development.md#adding-a-new-target-type)
for the step-by-step guide.

**Architecture note:** Consider refactoring `TargetBase` to extend `Node` instead of `Node2D`.
This would allow `TargetKelapa` to inherit properly — the script contains no transform logic
itself; the physics comes from `RigidBody2D` at the scene root, which is a separate node.

### 3. Difficulty Scaling via RoundConfig (Low effort)

`TargetBase.initialize(health_multiplier: float = 1.0)` already accepts a multiplier, but
`TargetSpawner` always calls `initialize()` with no argument (default 1.0).

**Steps:**
1. Add `health_multiplier: float = 1.0` to `RoundConfig`
2. Pass it through `TargetSpawner._spawn_routine()` → `instance.initialize(health_multiplier)`
3. Update `.tres` files: set increasing multipliers across rounds (e.g. 1.0, 1.5, 2.0)

### 4. Network Multiplayer (High effort)

Foundation already exists: `LobbyManager`, `NetworkGameManager`, and `PlayerInputRouter`
routing flags are in place.

**Recommended approach — Authoritative Host:**
- Host runs `GameManager`, `RoundManager`, `TargetSpawner` as server authority
- Client sends input RPC upstream: `@rpc("any_peer") func send_p2_input(action: String)`
- Host applies the action and sends state back: `@rpc("authority") func sync_game_state(...)`
- Use `MultiplayerSpawner` to replicate target nodes to the client

**Networking layer options:**
- `ENetMultiplayerPeer` — peer-to-peer, works for LAN/direct IP; requires NAT punch-through or relay for internet
- `WebRTCMultiplayerPeer` — browser-compatible; works with Web export; requires signalling server
- Godot Relay (open source) — lightweight relay server for ENet; avoids NAT issues

### 5. Save System Expansion (Low effort)

`ScoreManager` currently saves one value. `ConfigFile` supports arbitrary sections/keys.

**Steps:**
1. Add `save_per_round_best(round_number: int, score: int)` to `ScoreManager`
2. Key: section `"RoundBests"`, key `"round_{n}"`
3. Expose `get_round_best(n) -> int` for a round-select or level-replay screen
4. Optionally add unlock flags: `section "Unlocks"`, key `"belon_unlocked"` (bool)

### 6. Audio Manager Autoload (Medium effort)

`CannonFirer` plays a single fire SFX. There is no ambient audio, UI sounds, or music.

**Steps:**
1. Create `autoloads/audio_manager.gd` extending `Node` (follow `GameManager` singleton pattern)
2. Register in `project.godot [autoload]`
3. Preload ambient loop, UI click, round-start fanfare, game-over sting as `AudioStreamPlayer` children
4. Expose `play_sfx(stream: AudioStream)`, `play_music(stream: AudioStream)`, `stop_music()`
5. Hook `GameManager.game_over` → `AudioManager.play_music(game_over_sting)`
6. Connect `CannonFirer.fired` → `AudioManager.play_sfx(fire_sound)` (remove `audio_player` injection from Cannon)

### 7. CannonFirer / CannonLoader Signal Consumers (Low effort)

`CannonFirer.fired`, `CannonFirer.cooldown_complete`, and `CannonLoader.load_complete` are
declared but have no listeners. They are clean extension points:

- `fired` → camera shake, muzzle flash particle burst
- `cooldown_complete` → brief HUD flash or sound cue indicating "ready to fire"
- `load_complete` → satisfying click SFX; brief barrel glow

Connect these in `Game._ready()` to VFX nodes without coupling the cannon to specific effects.
