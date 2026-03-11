# Meriam Raya

A 2-player cooperative bamboo-cannon game set in a kampung (village) yard during the Hari Raya
celebration. One player aims, the other loads and fires. Both must work together to clear each round
of floating lanterns, coconuts, and balloons.

[![CI – Meriam Raya (Godot 4)](https://github.com/aizatrosli/meriam/actions/workflows/ci.yml/badge.svg)](https://github.com/aizatrosli/meriam/actions/workflows/ci.yml)

---

## Controls

| Role | Player | Keys |
|---|---|---|
| **Anak Sulung** (Elder – Aimer) | Player 1 | `W` aim up · `S` aim down |
| **Anak Bongsu** (Younger – Loader/Firer) | Player 2 | Hold `Space` to load · `Enter` to fire |

Both players share a single keyboard. The cannon cannot fire unless Player 2 has fully loaded it,
and the barrel is locked during the post-shot cooldown so Player 1 cannot over-aim.

---

## Quick Start

**Requirements:** Godot Engine 4.3 stable, Git with LFS.

```bash
git clone https://github.com/aizatrosli/meriam.git
cd meriam
git lfs pull
```

1. Open **Godot 4.3** → **Import** → select `project.godot`
2. Press **F5** (or **Run Project**) — entry scene is `res://scenes/main_menu/main_menu.tscn`
3. Choose **Main Tempatan** (Local co-op) to play on one keyboard
4. A **How to Play** tutorial appears automatically — click **Seterusnya →** to step through it or **Langkau / Skip** to jump straight into the game

> **No art assets required.** Placeholder coloured shapes are generated at runtime for all
> game objects. Replace them by assigning textures to the `@export` vars in the Inspector.

---

## Game Modes

| Mode | Description |
|---|---|
| **Main Tempatan** | Local co-op — both players on one keyboard |
| **Main Dalam Talian** | Online co-op — host creates a lobby, client joins with a code |

---

## Build Targets

Export presets are defined in `export_presets.cfg`:

| Platform | Preset Name |
|---|---|
| Linux x86\_64 | `Linux/X11` |
| Windows x86\_64 | `Windows Desktop` |
| Web (HTML5) | `Web` |

Builds are produced by the CI pipeline on every push to `main`. See
[docs/development.md](docs/development.md#ci-pipeline) for details.

---

## Documentation

| Document | Contents |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Full system architecture, signal flow, state machine, patterns, future directions |
| [docs/development.md](docs/development.md) | Setup, running tests, coding conventions, extending the game |

---

## Project Structure (top-level)

```
meriam/
├── autoloads/          # Persistent singletons (GameManager, ScoreManager)
├── resources/          # Data Resources (.tres): GameConfig, RoundConfig, TargetConfig
├── scenes/
│   ├── cannon/         # Cannon sub-system (Aimer, Loader, Firer, Projectile)
│   ├── game/           # Root gameplay scene + RoundManager
│   ├── main_menu/      # Main menu scene
│   ├── network/        # Online lobby and network game manager
│   ├── players/        # Player controllers + input router
│   ├── targets/        # Target types (Pelita, Kelapa, Belon) + spawner
│   └── ui/             # HUD, GameOverUI, RoundAnnouncementUI, TutorialOverlayUI
├── scripts/            # Pure-logic classes (GameState, LivesManager)
├── tests/
│   ├── unit/           # GUT unit tests (no scene required)
│   └── integration/    # GUT integration tests (scene-based)
├── addons/gut/         # GUT test framework (installed by CI)
└── .github/workflows/  # CI: test + build pipelines
```

---

## Malay Glossary

| Displayed | Meaning |
|---|---|
| Meriam | Cannon |
| Bola Meriam | Cannonball |
| Pusingan | Round |
| Nyawa | Lives |
| Markah | Score |
| Sedia! | Ready! |
| Isi... | Loading... |
| Pelita | Oil lamp (target) |
| Kelapa | Coconut (target) |
| Belon | Balloon (target) |
| Cara Main | How to Play |
| Seterusnya → | Next (tutorial) |
| Langkau | Skip (tutorial) |
| Mula! | Start! (begin game from tutorial) |
