# Meriam Raya – Developer Guide

This document covers everything needed to set up, run, test, and extend the project locally.
For the system architecture, see [ARCHITECTURE.md](../ARCHITECTURE.md).

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Local Setup](#2-local-setup)
3. [Running the Game](#3-running-the-game)
4. [Running Tests](#4-running-tests)
5. [Project Structure Conventions](#5-project-structure-conventions)
6. [GDScript Coding Conventions](#6-gdscript-coding-conventions)
7. [Resource File Conventions](#7-resource-file-conventions)
8. [Adding a New Target Type](#8-adding-a-new-target-type)
9. [Adding a New Round](#9-adding-a-new-round)
10. [CI Pipeline](#10-ci-pipeline)
11. [Export Builds](#11-export-builds)
12. [Debugging Tips](#12-debugging-tips)

---

## 1. Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Godot Engine | **4.3 stable** | Must match CI image (`barichello/godot-ci:4.3`) |
| Git | Any recent | — |
| Git LFS | Any recent | Assets (audio, textures) are stored in LFS |

**Install Godot 4.3:** Download from [godotengine.org/download](https://godotengine.org/download)
or via a package manager. The `godot` binary must be on your `$PATH` to run headless commands.

```bash
# Verify versions
godot --version   # should print 4.3.x.stable
git lfs version
```

---

## 2. Local Setup

```bash
git clone https://github.com/aizatrosli/meriam.git
cd meriam
git lfs pull          # pulls audio/texture assets from LFS storage
```

**Open in editor:**
1. Launch Godot 4.3
2. **Import** → navigate to the cloned `meriam/` folder → select `project.godot`
3. Wait for the import to complete (first open takes ~30 s while Godot imports all assets)

**Install GUT (test framework):**

CI installs GUT automatically. For local development, install it manually:

```bash
# Download GUT v9.4.0 and extract into addons/
curl -L https://github.com/bitwes/Gut/releases/download/v9.4.0/gut_v9.4.0.zip -o gut.zip
unzip gut.zip -d addons/
rm gut.zip
```

Or enable the `gut` addon in the Godot editor: **Project → Project Settings → Plugins → GUT → Enable**.

---

## 3. Running the Game

**From editor:** Press **F5** or click the play button. The main scene is
`res://scenes/main_menu/main_menu.tscn`.

**Headless (no display):**
```bash
godot --headless --path /path/to/meriam --quit
# (import-only; does not run gameplay)
```

**Play directly from CLI (requires display):**
```bash
godot --path . res://scenes/main_menu/main_menu.tscn
```

---

## 4. Running Tests

The test suite uses [GUT (Godot Unit Test)](https://github.com/bitwes/Gut) v9.4.0.
Tests live in `tests/unit/` and `tests/integration/`. GUT config: `tests/.gutconfig.json`.

### Headless — matches CI exactly

```bash
# Step 1: import the project (builds .godot/ cache, registers class names)
godot --headless --path . --import --quit

# Step 2: run all tests
godot --headless --path . \
  -s res://addons/gut/gut_cmdln.gd \
  -gconfig=res://tests/.gutconfig.json \
  -gexit
```

Exit code `0` = all tests passed. Exit code `1` = failures (check stdout for details).

### In the Godot Editor

1. Open the **GUT** panel in the bottom dock (or **Project → Tools → GUT**)
2. Click **Run All** — results appear in the GUT panel output
3. To run a single test file: select it in the GUT file list and click **Run**

### Test Output (JUnit XML)

The headless command writes `test-results/results.xml` in JUnit format. CI uploads this to
GitHub as a check-run annotation via `mikepenz/action-junit-report`.

### Test File Naming

| Convention | Example |
|---|---|
| Unit test | `tests/unit/test_cannon_aimer.gd` |
| Integration test | `tests/integration/test_coop_fire_sequence.gd` |

All test files must:
- Be named with the `test_` prefix
- Extend `GutTest` (`extends GutTest`)
- Contain test methods prefixed with `test_`

```gdscript
# tests/unit/test_cannon_aimer.gd
extends GutTest

func test_adjust_aim_clamps_to_max_angle() -> void:
    var aimer = CannonAimer.new()
    aimer.barrel_pivot = Node2D.new()
    aimer.set_aim_angle(999.0)
    assert_eq(aimer.current_angle, aimer.max_aim_angle)
    aimer.barrel_pivot.free()
    aimer.free()
```

---

## 5. Project Structure Conventions

### Where does new code go?

| What | Where |
|---|---|
| New autoload singleton | `autoloads/<name>.gd` + register in `project.godot [autoload]` |
| New scene with its own logic | `scenes/<module>/<name>.tscn` + `scenes/<module>/<name>.gd` |
| Pure logic class (no Node) | `scripts/<name>.gd` using `extends RefCounted` |
| New resource data class | `resources/<name>.gd` + corresponding `resources/<name>.tres` assets |
| Unit test | `tests/unit/test_<system>.gd` |
| Integration test | `tests/integration/test_<flow>.gd` |

### Scene ↔ Script co-location

Each `.tscn` file sits next to its root script in the same directory.
`cannon.tscn` → `cannon.gd` in `scenes/cannon/`.

---

## 6. GDScript Coding Conventions

### File header

Every file with a class must declare `class_name` and a brief comment block:

```gdscript
## Brief description of the class and its role.
## Second line if needed.
class_name MyClass
extends Node
```

### Naming

| Item | Convention | Example |
|---|---|---|
| Classes | PascalCase | `CannonAimer`, `TargetBase` |
| Signals | `signal snake_case(param: type)` | `signal round_started(round_number: int)` |
| Public methods | `snake_case` | `begin_loading()`, `set_config()` |
| Private methods | `_underscore_prefix` | `_apply_rotation()`, `_start_cooldown()` |
| Private variables | `_underscore_prefix` | `_current_health`, `_is_loading` |
| Export variables | `snake_case`, no underscore | `@export var config: GameConfig` |
| Constants | `ALL_CAPS_SNAKE` | `const SAVE_PATH = "user://..."` |

### Typing

Always use static types on:
- Signal parameters
- Function parameters and return types
- `@export` variables
- Any variable whose type is non-obvious

```gdscript
func take_damage(amount: int) -> void:
    _current_health -= amount
```

### Signals vs. polling

Prefer **signals** for event-driven state changes (target defeated, round complete, game over).
Only **poll** in `_process()` when the value changes every frame (load progress bar, aim angle
display). This avoids missed signals during heavy frame drops.

### Async / coroutines

Use `await get_tree().create_timer(duration).timeout` for delays inside async functions.
Do not use `OS.delay_msec()` — it blocks the main thread.

```gdscript
func _spawn_routine() -> void:
    await get_tree().create_timer(round_cfg.round_start_delay).timeout
    for entry in round_cfg.targets:
        # ... spawn logic ...
        await get_tree().create_timer(round_cfg.time_between_spawns).timeout
```

### UI strings

All strings displayed to the player must be in **Malay**. Code comments, identifiers, signal
names, and git commit messages are in **English**. See [Malay Glossary](../ARCHITECTURE.md#14-malay-terminology-glossary).

---

## 7. Resource File Conventions

All custom Resource `.tres` files must follow this format to work in headless export:

```
[gd_resource type="Resource" script_class="TargetConfig" load_steps=2 format=3 uid="uid://..."]

[ext_resource type="Script" path="res://resources/target_config.gd" id="1_xxxxx"]

[resource]
script = ExtResource("1_xxxxx")
target_id = "pelita"
display_name_malay = "Pelita"
base_health = 1
score_value = 100
```

**Critical rules:**

1. **Always** include `script = ExtResource(...)` in the `[resource]` block
2. **Never** use bare `type="TargetConfig"` on the `[gd_resource]` header — this relies on the
   class database which is not populated during `--headless --import` on first run
3. `load_steps` must equal the number of `[ext_resource]` blocks
4. Use `uid="uid://..."` — generate with Godot editor; do not invent UIDs manually
5. Sub-resources (e.g. `TargetSpawnEntry` inside `RoundConfig`) may be inline
   (`[sub_resource type="Resource" id="..."]`) or external; prefer external for reusability

---

## 8. Adding a New Target Type

This is the most common extension task. Follow these steps exactly to wire a new target correctly.

### Step 1 — Create the TargetConfig resource script (if needed)

If the new target needs new fields beyond the base `TargetConfig` class, create a subclass:

```gdscript
# resources/target_config_layang.gd
class_name TargetConfigLayang
extends TargetConfig

@export var glide_speed: float = 2.0
@export var max_height: float = 300.0
```

If no new fields are needed, reuse `TargetConfig` directly (skip this step).

### Step 2 — Create the .tres asset

Copy an existing config as a template:

```bash
cp resources/target_config_belon.tres resources/target_config_layang.tres
```

Edit `target_config_layang.tres`:
- Update `uid` (generate in editor or leave for editor to assign on import)
- Update `script` ext_resource path to point to the new `.gd` (or keep `target_config.gd` if reusing base)
- Set `target_id`, `display_name_malay`, `base_health`, `score_value`, `type`
- Leave `scene` empty for now — fill in after Step 4

### Step 3 — Create the scene and script

```bash
# In Godot editor: Scene → New Scene → Node2D (or RigidBody2D for physics targets)
# Save as scenes/targets/target_layang.tscn
```

Create `scenes/targets/target_layang.gd`:

```gdscript
## Layang-layang (kite) target. Drifts sideways on the wind.
class_name TargetLayang
extends TargetBase   # or RigidBody2D if physics needed

@export var drift_speed: float = 1.0

func _process(delta: float) -> void:
    position.x += drift_speed * delta

func _on_hit() -> void:
    # Brief colour flash
    modulate = Color.RED
    await get_tree().create_timer(0.1).timeout
    modulate = Color.WHITE

func _spawn_death_effect() -> void:
    if config and config.death_vfx_scene:
        var vfx = config.death_vfx_scene.instantiate()
        get_parent().add_child(vfx)
        vfx.global_position = global_position
```

Attach the script to the root node of `target_layang.tscn`.
Add a `CollisionShape2D` to the scene (required for the `"damageable"` group hit detection).

### Step 4 — Link scene to config

In the Godot editor, open `resources/target_config_layang.tres` and drag
`scenes/targets/target_layang.tscn` into the `scene` field.

### Step 5 — Add to a RoundConfig

Open `resources/round_config_3.tres` (or create a new round; see §9).
In the `targets` array, add a new `TargetSpawnEntry` sub-resource:

```
config = ExtResource("path/to/target_config_layang.tres")
count = 4
spacing = 2.0
height_offset = -50.0
```

### Step 6 — Write tests

**Unit test** (`tests/unit/test_target_layang.gd`):

```gdscript
extends GutTest

func test_target_loads_from_resource() -> void:
    var cfg = load("res://resources/target_config_layang.tres")
    assert_not_null(cfg, "TargetConfig resource loaded")
    assert_is(cfg, TargetConfig)
    assert_eq(cfg.target_id, "layang")

func test_take_damage_reduces_health() -> void:
    var target = preload("res://scenes/targets/target_layang.tscn").instantiate()
    add_child(target)
    target.initialize()
    var initial_health = target.current_health
    target.take_damage(1)
    assert_eq(target.current_health, initial_health - 1)
    target.queue_free()
```

**Integration test** (`tests/integration/test_target_hit_detection.gd`):
Verify `CannonProjectile` successfully damages the new target via the `"damageable"` group.

### Step 7 — Verify

```bash
godot --headless --path . --import --quit
godot --headless --path . -s res://addons/gut/gut_cmdln.gd \
  -gconfig=res://tests/.gutconfig.json -gexit
```

---

## 9. Adding a New Round

### Step 1 — Copy an existing round config

```bash
cp resources/round_config_3.tres resources/round_config_4.tres
```

### Step 2 — Edit the new .tres

Update these fields in `round_config_4.tres`:

```
round_number = 4
round_announcement_malay = "Pusingan Terakhir!"
round_start_delay = 2.0
time_between_spawns = 1.0
completion_bonus_score = 1000
targets = [...]          # update TargetSpawnEntry array
```

**Important:** Update the `uid` header to a unique value. The Godot editor will do this
automatically on next import; if editing by hand, generate a UID with:

```bash
python3 -c "import random, string; print('uid://' + ''.join(random.choices(string.ascii_lowercase + string.digits, k=12)))"
```

Also update `load_steps` in the header to equal the number of `[ext_resource]` blocks.

### Step 3 — Register in GameConfig

Open `resources/game_config.tres`. Add a new `[ext_resource]` block near the top:

```
[ext_resource type="Resource" path="res://resources/round_config_4.tres" id="N_xxxxx"]
```

Append it to the `rounds` array:

```
rounds = [ExtResource("1_xxxxx"), ExtResource("2_xxxxx"), ExtResource("3_xxxxx"), ExtResource("N_xxxxx")]
```

Increment `round_count`:

```
round_count = 4
```

Update `load_steps` in the `game_config.tres` header to match the new total number of ext_resources.

### Step 4 — Test

Run the game locally and play through to round 4. Check that `RoundManager.start_round(3)`
(0-based index 3) correctly loads the new config.

---

## 10. CI Pipeline

Defined in `.github/workflows/ci.yml`. Triggered on:
- Push to `main`, `master`, `claude/**`
- Pull request targeting `main` or `master`

### Job 1: GUT Tests

```yaml
permissions:
  checks: write

steps:
  - Install GUT v9.4.0 into addons/gut/
  - godot --headless --import --quit          # build .godot/ cache
  - godot --headless ... -gconfig=... -gexit  # run tests
  - mikepenz/action-junit-report             # annotate PR with failures
```

**If tests fail:** Check the raw log for the failing `test_*` method name and assertion.
Reproduce locally with the headless command from §4.

### Job 2: Build (depends on Job 1 passing)

Matrix: `[Linux, Windows, Web]`

```yaml
steps:
  - Cache .godot/ (keyed on hash of *.tscn, *.tres, *.gd)
  - Copy export templates (CI runner HOME differs from /root)
  - godot --headless --import --quit
  - godot --headless --export-release "<preset>" <output path>
  - Upload artifact (7-day retention)
```

Export presets are read from `export_presets.cfg`. Preset names must match exactly:
- `"Linux/X11"` → binary output
- `"Windows Desktop"` → `.exe`
- `"Web"` → `.html` + `.wasm`

**If export fails with "Template not found":**
The export templates for Godot 4.3 must match the engine version exactly. The CI image
`barichello/godot-ci:4.3` includes them pre-installed under
`/root/.local/share/godot/export_templates/4.3.stable/`. If the HOME mismatch issue arises,
the CI script copies them to `~/.local/share/godot/export_templates/4.3.stable/`.

---

## 11. Export Builds

Export presets are configured in `export_presets.cfg` and managed via:
**Project → Export** in the Godot editor.

### Local export

```bash
# Linux
godot --headless --export-release "Linux/X11" ./dist/meriam.x86_64

# Windows
godot --headless --export-release "Windows Desktop" ./dist/meriam.exe

# Web
godot --headless --export-release "Web" ./dist/meriam.html
```

All three require export templates for Godot 4.3 to be installed:
**Editor → Manage Export Templates → Download** (or install manually).

### Web build notes

The Web export produces `meriam.html`, `meriam.js`, `meriam.wasm`, and `meriam.pck`.
Serve from a static file server with `SharedArrayBuffer` headers enabled:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

---

## 12. Debugging Tips

### Autoload not found at runtime

If a script calls `GameManager.something` and Godot prints `"Node not found: GameManager"`:
- Check `project.godot` has the correct `[autoload]` entries
- Ensure the script path in `[autoload]` matches the actual file location

### Resource fails to load in headless export

Symptom: `ERROR: res://resources/round_config_1.tres: Script not found.`

Fix: The `.tres` file must have `script = ExtResource(...)` in its `[resource]` block.
See [Resource File Conventions](#7-resource-file-conventions).

### Target not taking damage

1. Confirm the target scene has a `CollisionShape2D` node
2. Confirm the target script calls `add_to_group("damageable")` in `_ready()`
3. Confirm the collision layer/mask allows `CannonProjectile` (layer 2) to intersect targets (layer 3)
4. Add a temporary `print()` in `CannonProjectile._try_damage()` to see what nodes are being tested

### GUT test hangs

GUT integration tests that `await` signals can hang indefinitely if the signal is never emitted.
Always pair awaited signals with a timeout:

```gdscript
# Bad — hangs if signal never fires
await GameManager.game_over

# Good
var result = await wait_for_signal(GameManager.game_over, 5.0)
assert_not_null(result, "game_over signal received within 5s")
```

### Scene works in editor but crashes headless

Run `godot --headless --import --quit` first to build the class database. Then run the scene.
Skipping the import step causes `class_name` lookups to fail.
