# Meriam Raya – Game Mechanics Flowcharts

Visual reference for how every system in the game works and connects together.
For narrative descriptions see [ARCHITECTURE.md](../ARCHITECTURE.md).

**Engine:** Godot 4.3 · **Language:** GDScript · **Updated:** 2026-03-08

---

## Table of Contents

1. [Full Game Flow (Boot → End)](#1-full-game-flow-boot--end)
2. [Game State Machine](#2-game-state-machine)
3. [Scene Initialisation & Wiring](#3-scene-initialisation--wiring)
4. [Co-op Input Chain](#4-co-op-input-chain)
5. [Cannon Fire Sequence](#5-cannon-fire-sequence)
6. [Projectile Flight & Hit Detection](#6-projectile-flight--hit-detection)
7. [Target Damage & Death](#7-target-damage--death)
8. [Lives & Game-Over Flow](#8-lives--game-over-flow)
9. [Round Progression](#9-round-progression)
10. [Target Spawning](#10-target-spawning)
11. [Score Flow](#11-score-flow)
12. [Online Lobby & Network Sync](#12-online-lobby--network-sync)
13. [Signal Bus Reference](#13-signal-bus-reference)
14. [Data Resource Graph](#14-data-resource-graph)
15. [Visual Asset Replacement Map](#15-visual-asset-replacement-map)

---

## 1. Full Game Flow (Boot → End)

The top-level journey from application launch to a finished session.

```mermaid
flowchart TD
    BOOT([Game Launches]) --> MENU[Main Menu\nmain_menu.tscn]

    MENU --> LOCAL["Main Tempatan\n(Local Co-op)"]
    MENU --> ONLINE["Main Dalam Talian\n(Online Co-op)"]

    LOCAL --> LOAD_GAME[Load game.tscn]

    ONLINE --> CREATE{Host or Guest?}
    CREATE -->|Host| CREATE_LOBBY[create_lobby\nGenerate join code]
    CREATE -->|Guest| JOIN_LOBBY[join_lobby\nEnter join code]
    CREATE_LOBBY --> WAIT_GUEST[Display join code\nWait for guest]
    JOIN_LOBBY --> CONNECT[Connect to host\nENet peer]
    WAIT_GUEST --> ROLE_ASSIGN
    CONNECT --> ROLE_ASSIGN[Assign roles\nHost = P1 Aimer\nGuest = P2 Loader/Firer]
    ROLE_ASSIGN --> LOAD_GAME

    LOAD_GAME --> INIT[game.gd _ready\nWire all subsystems]
    INIT --> START_GAME[GameManager.start_game\nReset score · Init lives\nState → ROUND_COUNTDOWN]
    START_GAME --> TUTORIAL[TutorialOverlayUI\nshow_tutorial\nPauses tree · 5 steps\nSeterusnya → / Langkau]
    TUTORIAL -->|tutorial_completed| ROUND_LOOP

    subgraph ROUND_LOOP[Round Loop]
        direction TB
        START_ROUND[start_round index\nLoad RoundConfig] --> ANNOUNCE[Show round announcement\nPusingan N / Round N]
        ANNOUNCE --> SPAWN[Spawn targets\nasync staggered]
        SPAWN --> PLAYING_STATE[State → PLAYING\nPlayers cooperate]
        PLAYING_STATE --> SHOOT{Shot fired?}
        SHOOT -->|Miss| LOSE_LIFE[Lose a life\nCheck game over]
        SHOOT -->|Hit| DEFEAT_TARGET[Target defeated\nAdd score]
        DEFEAT_TARGET --> ALL_DEAD{All targets\ndefeated?}
        LOSE_LIFE --> GAME_OVER_CHECK{Lives == 0?}
        GAME_OVER_CHECK -->|Yes| GAME_OVER_STATE
        GAME_OVER_CHECK -->|No| PLAYING_STATE
        ALL_DEAD -->|No| PLAYING_STATE
        ALL_DEAD -->|Yes| ROUND_COMPLETE[State → ROUND_COMPLETE\nWait 1.5 s]
        ROUND_COMPLETE --> LAST_ROUND{Last round?}
        LAST_ROUND -->|No| START_ROUND
        LAST_ROUND -->|Yes| VICTORY_STATE
    end

    GAME_OVER_STATE([State → GAME_OVER\nShow final score]) --> MENU_RETURN
    VICTORY_STATE([State → VICTORY\nShow victory panel]) --> MENU_RETURN
    MENU_RETURN{Main Semula /\nBalik Menu?} -->|Play Again| LOAD_GAME
    MENU_RETURN -->|Menu| MENU
```

---

## 2. Game State Machine

`GameState` (`scripts/game_state_machine.gd`) is a `RefCounted` (not a Node).
It validates transitions against a fixed table; invalid moves are silently ignored.

```mermaid
stateDiagram-v2
    [*] --> MAIN_MENU : App start

    MAIN_MENU --> ROUND_COUNTDOWN : GameManager.start_game()

    ROUND_COUNTDOWN --> PLAYING : RoundManager.start_round()

    PLAYING --> PAUSED      : UI_Cancel pressed
    PLAYING --> ROUND_COMPLETE : All targets defeated
    PLAYING --> GAME_OVER   : Lives reach zero

    PAUSED --> PLAYING    : UI_Cancel pressed again
    PAUSED --> MAIN_MENU  : Return to menu selected

    ROUND_COMPLETE --> ROUND_COUNTDOWN : advance_round() — more rounds remain
    ROUND_COMPLETE --> VICTORY         : advance_round() — last round done

    GAME_OVER --> MAIN_MENU : Any end-screen button
    VICTORY   --> MAIN_MENU : Any end-screen button

    note right of PLAYING
        Projectile miss → GameManager.on_projectile_missed()
        Target hit → GameManager.on_target_defeated()
    end note

    note right of ROUND_COMPLETE
        1.5 s delay before advancing
        so VFX can finish playing
    end note
```

---

## 3. Scene Initialisation & Wiring

`game.gd._ready()` is the single wiring point for the entire gameplay scene.
Numbers show the sequence order. Steps 1–12 run synchronously; step 13 fires
deferred via `tutorial_completed` signal after the player dismisses the tutorial.

```mermaid
flowchart LR
    subgraph AUTOLOADS[Autoloads\nAlways available]
        GM[GameManager]
        SM[ScoreManager]
    end

    subgraph GAME_SCENE[game.tscn nodes]
        CANNON[Cannon\ncannon.tscn]
        AIMER[CannonAimer]
        LOADER[CannonLoader]
        FIRER[CannonFirer]
        MUZZLE[MuzzlePoint]
        AUDIO[AudioStreamPlayer2D]
        RELOAD_IND[ReloadIndicator]
        FILL_BAR[FillBar ProgressBar]
        STATUS_LBL[LoadStatusLabel]
        MUZZLE_FLASH[MuzzleFlash\nCPUParticles2D]

        P1[Player1Controller]
        P2[Player2Controller]
        ROUTER[PlayerInputRouter]

        RM[RoundManager]
        SPAWNER[TargetSpawner]
        NET[NetworkGameManager]
        CAM[CameraShake\nCamera2D]

        HUD[HUD]
        ANNOUNCE[RoundAnnouncementUI]
        GAME_OVER_UI[GameOverUI]
        TUTORIAL_UI[TutorialOverlayUI]
        TZ[TargetZoneCenter\nMarker2D]
    end

    %% Step 1 — cannon internal wiring (cannon.gd._ready)
    CANNON -->|"① firer.aimer"| AIMER
    CANNON -->|"① firer.loader"| LOADER
    CANNON -->|"① firer.muzzle_point"| MUZZLE
    CANNON -->|"① firer.audio_player"| AUDIO
    CANNON -->|"① aimer.barrel_pivot"| BARREL_PIVOT[BarrelPivot]
    CANNON -->|"① reload_ind.loader"| LOADER
    CANNON -->|"① fill_bar"| FILL_BAR
    CANNON -->|"① status_label"| STATUS_LBL

    %% Step 2 — game.gd wires players
    P1 -->|"② aimer"| AIMER
    P2 -->|"② loader"| LOADER
    P2 -->|"② firer"| FIRER
    ROUTER -->|"② player1"| P1
    ROUTER -->|"② player2"| P2

    %% Step 3 — network manager
    NET -->|"③ cannon"| CANNON
    NET -->|"③ player_input_router"| ROUTER

    %% Step 4 — target spawner zone anchor
    SPAWNER -->|"④ target_zone_center"| TZ

    %% Step 5 — round management
    RM -->|"⑤ target_spawner"| SPAWNER
    GM -->|"⑤ round_manager"| RM

    %% Step 6 — HUD gets loader for progress polling
    HUD -->|"⑥ cannon_loader"| LOADER

    %% Step 7 — signals
    GM -->|"⑦ target_hit"| HUD
    GM -->|"⑦ target_hit"| RM
    GM -->|"⑦ life_lost"| HUD
    GM -->|"⑦ life_lost"| CAM
    GM -->|"⑦ game_over"| GAME_OVER_UI
    GM -->|"⑦ victory"| GAME_OVER_UI
    RM -->|"⑦ round_started"| HUD
    RM -->|"⑦ round_started"| ANNOUNCE
    FIRER -->|"⑦ fired"| MUZZLE_FLASH
    FIRER -->|"⑦ fired"| CAM

    %% Steps 8-12 — start game & tutorial
    GM -->|"⑧ start_game → ROUND_COUNTDOWN"| GM
    HUD -->|"⑨ refresh_lives initial"| HUD
    TUTORIAL_UI -->|"⑩ show_tutorial\npause tree"| TUTORIAL_UI
    TUTORIAL_UI -->|"⑪ tutorial_completed\nunpause tree"| RM
    RM -->|"⑫ start_round 0\nstate → PLAYING"| SPAWNER
```

---

## 4. Co-op Input Chain

Two players share one cannon. Player 1 (Anak Sulung) aims; Player 2 (Anak Bongsu) loads and fires.

```mermaid
flowchart TD
    subgraph INPUT_SOURCES[Input Sources]
        KB_P1[Keyboard W / S\nor Gamepad-0 left-stick Y]
        KB_P2_LOAD[Keyboard Space\nor Gamepad-1 South button\nHold to load]
        KB_P2_FIRE[Keyboard Enter\nor Gamepad-1 East button\nPress to fire]
    end

    subgraph ROUTER[PlayerInputRouter\n_process + _input]
        ROUTE_P1{only_player1_local?\nonly_player2_local?}
        AIM_UP[p1_aim_up pressed\n→ +aim_speed × delta]
        AIM_DOWN[p1_aim_down pressed\n→ -aim_speed × delta]
        LOAD_PRESS[p2_load pressed]
        LOAD_RELEASE[p2_load released]
        FIRE_PRESS[p2_fire pressed]
    end

    KB_P1 --> AIM_UP & AIM_DOWN
    KB_P2_LOAD --> LOAD_PRESS & LOAD_RELEASE
    KB_P2_FIRE --> FIRE_PRESS

    AIM_UP & AIM_DOWN --> ROUTE_P1
    LOAD_PRESS & LOAD_RELEASE & FIRE_PRESS --> ROUTE_P1

    ROUTE_P1 -->|Local or host| P1C[Player1Controller\non_aim_input delta_angle]
    ROUTE_P1 -->|Local or guest| P2C[Player2Controller]

    P1C --> AIMER[CannonAimer\nadjust_aim delta_angle\nclamp to 0–75°]
    AIMER --> BARREL[BarrelPivot\nrotation_degrees = angle]

    P2C --> |on_load_pressed| LOADER[CannonLoader\nbegin_loading]
    P2C --> |on_load_released\nif not loaded| LOADER_CANCEL[CannonLoader\ncancel_loading\nreset progress]
    P2C --> |on_fire_pressed| FIRER[CannonFirer\nfire]

    subgraph ONLINE_NOTE[Online Mode]
        HOST_NOTE[Host runs P1 only\nonly_player1_local = true]
        GUEST_NOTE[Guest runs P2 only\nonly_player2_local = true]
        RPC_NOTE[P2 input RPCs\naim_cannon_rpc\nfire_cannon_rpc\nsent to host]
    end
```

---

## 5. Cannon Fire Sequence

Detailed step-by-step of what happens from "Space held" to cooldown complete.

```mermaid
sequenceDiagram
    actor P2 as Player 2\n(Anak Bongsu)
    participant ROUTER as PlayerInputRouter
    participant P2C as Player2Controller
    participant LOADER as CannonLoader
    participant INDICATOR as ReloadIndicator
    participant FIRER as CannonFirer
    participant AIMER as CannonAimer

    Note over P2,AIMER: Phase 1 – Loading (hold Space for load_duration seconds)

    P2->>ROUTER: Space pressed
    ROUTER->>P2C: on_load_pressed()
    P2C->>LOADER: begin_loading()

    loop Every frame while Space held
        LOADER->>LOADER: _load_timer += delta\nload_progress = timer / load_duration
        LOADER->>INDICATOR: (polled) fill_bar.value = progress × 100\nlabel = "Isi..."
    end

    LOADER->>LOADER: load_progress reaches 1.0\nis_loaded = true
    LOADER-->>LOADER: emit load_complete()
    INDICATOR->>INDICATOR: Flash bar gold → white

    Note over P2,AIMER: Phase 2 – Fire (press Arrow Right)

    P2->>ROUTER: Arrow Right pressed
    ROUTER->>P2C: on_fire_pressed()
    P2C->>FIRER: fire()

    alt can_fire = loader.is_loaded AND NOT aimer.is_locked
        FIRER->>AIMER: is_locked = true\n(P1 cannot aim during cooldown)
        FIRER->>FIRER: Instantiate cannon_ball_scene\nat muzzle_point.global_position
        FIRER->>PROJECTILE: launch(angle, speed, damage, lifetime)
        FIRER->>LOADER: cancel_loading()\n(reset for next shot)
        FIRER->>AUDIO: play fire_sound
        FIRER-->>FIRER: emit fired()
        Note right of FIRER: Signals: MuzzleFlash.restart()\nCameraShake.shake()
        FIRER->>FIRER: _start_cooldown()\nawait cooldown_duration seconds
        FIRER->>AIMER: is_locked = false
        FIRER-->>FIRER: emit cooldown_complete()
    else can_fire = false
        FIRER->>FIRER: return (no-op)
        Note right of FIRER: Guard: not loaded or\naimer still locked
    end
```

---

## 6. Projectile Flight & Hit Detection

Once launched, `CannonProjectile` (Area2D) travels in a parabolic arc.

```mermaid
flowchart TD
    LAUNCH[launch called\nangle_deg · speed · damage · lifetime] --> VELOCITY[Calculate velocity\ndirection = RIGHT.rotated -angle_deg\nvelocity = direction × speed]
    VELOCITY --> TIMER[Start lifetime timer\ndefault 4.0 s]
    VELOCITY --> FLIGHT

    subgraph FLIGHT[Every physics frame _physics_process]
        GRAVITY[velocity.y += gravity × delta\ndefault 980 px/s²]
        MOVE[position += velocity × delta]
        GRAVITY --> MOVE
    end

    MOVE --> COLLISION{Collision\ndetected?}
    TIMER --> EXPIRED{Lifetime\nexpired?}

    COLLISION -->|body_entered\nStaticBody2D| CHECK_DMG
    COLLISION -->|area_entered\nArea2D target| CHECK_DMG

    subgraph CHECK_DMG[_try_damage node]
        GUARD{_hit already\ntrue?}
        GUARD -->|Yes| SKIP[return — ignore\nno double damage]
        GUARD -->|No| GROUP{node in group\ndamageable AND\nhas take_damage?}
        GROUP -->|No| SKIP2[return — wrong object\ne.g. ground wall]
        GROUP -->|Yes| HIT_NODE[node.take_damage _damage\n_hit = true\nqueue_free self]
    end

    EXPIRED -->|_hit = false| PREDELETE[_notification PREDELETE\nGameManager.on_projectile_missed]
    EXPIRED -->|_hit = true| ALREADY_HIT[queue_free — normal cleanup\nno miss notification]

    HIT_NODE --> TARGET_SYSTEM[Target damage system\nsee Flowchart 7]
    PREDELETE --> LIVES_SYSTEM[Lives system\nsee Flowchart 8]

    style GRAVITY fill:#1a1a2e,color:#e0e0e0
    style MOVE fill:#1a1a2e,color:#e0e0e0
```

---

## 7. Target Damage & Death

All three target types share the same `take_damage` entry point via duck-typing.

```mermaid
flowchart TD
    HIT[Projectile calls\nnode.take_damage amount] --> ALIVE_CHECK{is_alive?}
    ALIVE_CHECK -->|No| NO_OP[return — no-op\ndead targets ignore hits]
    ALIVE_CHECK -->|Yes| DECREMENT[_current_health -= amount]

    DECREMENT --> ON_HIT[_on_hit virtual hook]
    DECREMENT --> DEAD_CHECK{health <= 0?}

    subgraph ON_HIT_TYPES[_on_hit per type]
        PELITA_HIT[TargetPelita\nHide flame 0.1 s\nflicker effect]
        KELAPA_HIT[TargetKelapa\nRelease physics freeze\nApply RIGHT impulse\nApply torque — rolls away]
        BELON_HIT[TargetBelon\nno extra hit effect]
    end
    ON_HIT --> PELITA_HIT & KELAPA_HIT & BELON_HIT

    DEAD_CHECK -->|No| SURVIVE[Target survives\nwaiting for next shot]
    DEAD_CHECK -->|Yes| ON_DEATH[_on_death]

    ON_DEATH --> SCORE[GameManager.on_target_defeated score_value]
    ON_DEATH --> DEATH_VFX[_spawn_death_effect virtual hook]
    ON_DEATH --> FREE[queue_free — remove from scene]

    subgraph DEATH_VFX_TYPES[_spawn_death_effect per type]
        PELITA_VFX[TargetPelita\nHide flame node\nSpawn smoke_puff.tscn\nCPUParticles2D gray smoke]
        KELAPA_VFX[TargetKelapa\nNo extra VFX\nqueue_free after 1.5 s\nlet physics settle]
        BELON_VFX[TargetBelon\nSpawn balloon_pop.tscn\nCPUParticles2D golden confetti]
    end
    DEATH_VFX --> PELITA_VFX & KELAPA_VFX & BELON_VFX

    SCORE --> SCORE_MANAGER[ScoreManager.add_score points\nUpdate current_score\nSave new high score if beaten]
    SCORE_MANAGER --> TARGET_HIT_SIG[GameManager emits\ntarget_hit score_value]
    TARGET_HIT_SIG --> HUD_SCORE[HUD refresh score label\nPulse animation\nSpawn score_popup floating +N]
    TARGET_HIT_SIG --> ROUND_MGR[RoundManager._on_target_hit\nregister_target_defeated]
```

---

## 8. Lives & Game-Over Flow

A life is lost whenever a projectile expires without hitting a damageable target.
`on_projectile_missed()` is guarded so it only counts during active gameplay.

```mermaid
flowchart TD
    PREDELETE[CannonProjectile\n_notification PREDELETE\n_hit = false] --> ON_MISSED[GameManager\non_projectile_missed]

    ON_MISSED --> STATE_CHECK{state ==\nPLAYING?}
    STATE_CHECK -->|No — tutorial / scene change| IGNORED[return early\nno effect]
    STATE_CHECK -->|Yes| LOSE_LIFE[LivesManager\nlose_life\nlives_remaining -= 1]
    LOSE_LIFE --> LIFE_SIGNAL[emit life_lost lives_remaining]

    LIFE_SIGNAL --> HUD_LIVES[HUD\n_on_life_lost\nUpdate nyawa label\nFlash label red]
    LIFE_SIGNAL --> CAM_SHAKE[CameraShake\nshake 8 strength\n0.4 s duration]

    LIFE_SIGNAL --> GAME_OVER_Q{lives_remaining\n== 0?}

    GAME_OVER_Q -->|No — continue| PLAYING[State stays PLAYING\nPlayers try again]
    GAME_OVER_Q -->|Yes — game over| TRIGGER_GO[GameManager\n_trigger_game_over]

    TRIGGER_GO --> STATE_GO[State → GAME_OVER]
    TRIGGER_GO --> GM_SIGNAL[GameManager emits\ngame_over final_score]

    GM_SIGNAL --> GAME_OVER_UI[GameOverUI\nshow_game_over score\nFade in panel]
    GAME_OVER_UI --> DISPLAY_SCORES[Show final score\nShow high score\nfrom ScoreManager]

    GAME_OVER_UI --> BUTTONS{Button pressed}
    BUTTONS -->|"Main Semula\n(Play Again)"| RELOAD_GAME[change_scene_to_file\ngame.tscn]
    BUTTONS -->|"Balik Menu\n(Return)"| RETURN_MENU[GameManager\nreturn_to_main_menu\nchange_scene → main_menu.tscn]
```

---

## 9. Round Progression

`RoundManager` sequences rounds and signals completion to `GameManager`.

```mermaid
flowchart TD
    INIT[game.gd\nround_manager.start_round 0] --> START_ROUND

    subgraph START_ROUND[start_round index]
        LOAD_CFG[Load config.rounds index\nRoundConfig resource]
        COUNT_TARGETS[Count total targets\nsum of entry.count for all TargetSpawnEntry]
        SET_REMAINING[targets_remaining_in_round = count]
        SPAWN_ASYNC[target_spawner.spawn_round round_cfg\nasync — fire and forget]
        EMIT_STARTED[emit round_started round_number]
        STATE_PLAYING[GameManager.state → PLAYING]

        LOAD_CFG --> COUNT_TARGETS --> SET_REMAINING --> SPAWN_ASYNC --> EMIT_STARTED --> STATE_PLAYING
    end

    STATE_PLAYING --> GAME_LOOP{Gameplay —\nwait for hits}

    GAME_LOOP -->|target_hit signal| DECREMENT_R[register_target_defeated\ntargets_remaining -= 1]
    DECREMENT_R --> REMAINING_CHECK{targets_remaining\n== 0?}
    REMAINING_CHECK -->|No| GAME_LOOP
    REMAINING_CHECK -->|Yes| WAIT[await 1.5 s timer\nVFX settles]

    WAIT --> ADVANCE[advance_round\ncurrent_round_index += 1]
    ADVANCE --> LAST_CHECK{current_round_index\n>= config.rounds.size?}

    LAST_CHECK -->|No — more rounds| EMIT_COMPLETE[emit round_complete round_number\nGameManager.on_round_complete\nState → ROUND_COMPLETE]
    EMIT_COMPLETE --> START_ROUND

    LAST_CHECK -->|Yes — all done| ALL_COMPLETE[emit all_rounds_complete\nGameManager.on_all_rounds_complete\nState → VICTORY]
    ALL_COMPLETE --> VICTORY_UI[GameOverUI\nshow_victory score]
```

---

## 10. Target Spawning

`TargetSpawner.spawn_round()` is an async coroutine that staggers target creation.

```mermaid
flowchart TD
    SPAWN_CALL[target_spawner.spawn_round\nround_config] --> ROUTINE[_spawn_routine\nasync coroutine]

    ROUTINE --> DELAY["await timer\nround_cfg.round_start_delay\n(default 3.0 s)"]

    DELAY --> ENTRY_LOOP

    subgraph ENTRY_LOOP[For each TargetSpawnEntry in round_cfg.targets]
        GET_ENTRY[entry = TargetSpawnEntry\nentry.config TargetConfig\nentry.count int\nentry.spacing float\nentry.height_offset float]

        subgraph COUNT_LOOP[Repeat entry.count times]
            CALC_POS[position = zone_center + Vector2\ni × entry.spacing\nentry.height_offset]
            INSTANCE[entry.config.scene.instantiate\nget target PackedScene from config]
            ADD_CHILD[add_child instance\nappend to scene tree]
            INIT_TARGET[instance.initialize\nif method exists\napply health_multiplier]
            SPAWN_WAIT["await timer\nround_cfg.time_between_spawns\n(default 1.5 s)"]

            CALC_POS --> INSTANCE --> ADD_CHILD --> INIT_TARGET --> SPAWN_WAIT
        end

        GET_ENTRY --> COUNT_LOOP
    end

    subgraph TARGET_TYPES[Possible target types per entry]
        TYPE_P[Pelita\ntarget_pelita.tscn\nSwinging oil lamp]
        TYPE_K[Kelapa\ntarget_kelapa.tscn\nRolling coconut]
        TYPE_B[Belon\ntarget_belon.tscn\nFloating balloon]
    end

    INSTANCE -.->|scene ref from TargetConfig| TARGET_TYPES
```

---

## 11. Score Flow

Score accumulates per target hit and persists the high score between sessions.

```mermaid
flowchart LR
    TARGET_DEATH[TargetBase._on_death\nscore_value from TargetConfig] --> GM_DEFEATED[GameManager\non_target_defeated score_value]

    GM_DEFEATED --> SM_ADD[ScoreManager\nadd_score points\ncurrent_score += points]
    SM_ADD --> HIGH_SCORE_CHECK{current_score\n> high_score?}
    HIGH_SCORE_CHECK -->|Yes| SAVE_HS[Save new high score\nConfigFile user://meriam_raya_save.cfg\nsection MeriamRaya\nkey MeriamRaya_HighScore]
    HIGH_SCORE_CHECK -->|No| EMIT_CHANGED
    SAVE_HS --> EMIT_CHANGED[emit score_changed new_score]

    GM_DEFEATED --> GM_EMIT[GameManager emits\ntarget_hit score_value]

    GM_EMIT --> HUD_UPDATE[HUD._on_target_hit\nread ScoreManager.get_current_score\nUpdate markah label\nScale pulse tween]
    GM_EMIT --> POPUP[Spawn score_popup\nfloating label +N\nRises 80 px · Fades out\nqueue_free when done]

    subgraph RESET[On new game start]
        RESET_SCORE[ScoreManager.reset_score\ncurrent_score = 0]
    end

    subgraph PERSIST[Persistent high score]
        LOAD_HS[Loaded at startup\nfrom save file\nDisplayed on Main Menu]
    end
```

---

## 12. Online Lobby & Network Sync

Online co-op uses ENet peer-to-peer with server-authoritative state.

```mermaid
sequenceDiagram
    actor HOST as Host\n(Player 1 / Anak Sulung)
    actor GUEST as Guest\n(Player 2 / Anak Bongsu)
    participant LM_H as LobbyManager\n(Host)
    participant LM_G as LobbyManager\n(Guest)
    participant NET_H as NetworkGameManager\n(Host / Authority)
    participant NET_G as NetworkGameManager\n(Guest / Peer)

    Note over HOST,GUEST: Lobby Phase

    HOST->>LM_H: create_lobby()
    LM_H->>LM_H: ENetMultiplayerPeer.create_server port\nGenerate join code\nbase64 encode local_ip:port
    LM_H-->>HOST: emit join_code_ready code
    HOST->>HOST: Display join code on UI

    GUEST->>LM_G: join_lobby code
    LM_G->>LM_G: Decode base64 → host_ip:port\nENetMultiplayerPeer.create_client
    LM_G-->>GUEST: emit joined
    GUEST->>GUEST: Load game.tscn

    Note over HOST,GUEST: Role Assignment

    NET_H->>NET_H: is_server = true\nAssign P1 role\nonly_player1_local = true\nonly_player2_local = false
    NET_G->>NET_G: is_server = false\nAssign P2 role\nonly_player1_local = false\nonly_player2_local = true

    Note over HOST,GUEST: Gameplay Sync Loop

    loop Guest aims/fires
        GUEST->>NET_G: P2 sends aim input
        NET_G->>NET_H: aim_cannon_rpc angle [any_peer → authority]
        NET_H->>NET_H: Validate clamp angle\nApply to local cannon
        NET_H->>NET_G: _sync_aim_rpc angle [authority → all]
        NET_H->>NET_H: fire_cannon_rpc [if fire pressed]
        NET_H->>NET_H: Validate · Execute firer.fire()
        NET_H->>NET_G: _notify_fire_rpc [broadcast result]
    end

    loop State & Score sync on peer connect
        NET_H->>NET_G: sync_game_state_rpc state_index
        NET_H->>NET_G: sync_score_rpc score lives
    end
```

---

## 13. Signal Bus Reference

Complete map of every signal connection at runtime.

```mermaid
flowchart LR
    subgraph EMITTERS[Signal Emitters]
        GM_SIG[GameManager]
        SM_SIG[ScoreManager]
        RM_SIG[RoundManager]
        FIRER_SIG[CannonFirer]
        LOADER_SIG[CannonLoader]
        LIVES_SIG[LivesManager]
        LBY_SIG[LobbyManager]
        STATE_SIG[GameState\nstate_machine]
    end

    subgraph RECEIVERS[Signal Receivers]
        HUD_R[HUD]
        GAME_OVER_R[GameOverUI]
        ANNOUNCE_R[RoundAnnouncementUI]
        CAM_R[CameraShake]
        MUZZLE_R[MuzzleFlash\nCPUParticles2D]
        ROUND_R[RoundManager]
        GM_R[GameManager]
        MENU_R[MainMenu]
    end

    GM_SIG -->|"target_hit score"| HUD_R
    GM_SIG -->|"target_hit score"| ROUND_R
    GM_SIG -->|"life_lost lives"| HUD_R
    GM_SIG -->|"life_lost lives"| CAM_R
    GM_SIG -->|"game_over final_score"| GAME_OVER_R
    GM_SIG -->|"victory final_score"| GAME_OVER_R
    GM_SIG -->|"state_changed from to"| GM_R

    RM_SIG -->|"round_started round_number"| HUD_R
    RM_SIG -->|"round_started round_number"| ANNOUNCE_R
    RM_SIG -->|"round_complete round_number"| GM_R
    RM_SIG -->|"all_rounds_complete"| GM_R

    FIRER_SIG -->|"fired"| MUZZLE_R
    FIRER_SIG -->|"fired"| CAM_R
    FIRER_SIG -.->|"cooldown_complete\n(extension point — unused)"| NOTE1[Available for\nSFX / HUD cue]
    LOADER_SIG -.->|"load_complete\n(extension point — polled)"| NOTE2[Available for\nclick SFX / glow VFX]

    LIVES_SIG -->|"life_lost"| GM_R
    LIVES_SIG -->|"game_over"| GM_R

    LBY_SIG -->|"join_code_ready code"| MENU_R
    LBY_SIG -->|"joined"| MENU_R
    LBY_SIG -->|"error_occurred msg"| MENU_R

    SM_SIG -.->|"score_changed\n(extension point — HUD polls directly)"| NOTE3[Available for\ndirect HUD binding]
```

---

## 14. Data Resource Graph

All game configuration is expressed as Godot `.tres` Resource files.
Scripts, scenes, and configs form a tree of references with no circular dependencies.

```mermaid
flowchart TD
    GC["game_config.tres\nGameConfig"] --> PARAMS["cannon_aim_speed 60°/s\nmin_aim_angle 0°\nmax_aim_angle 75°\ncannon_load_duration 2.0 s\ncannon_cooldown_duration 1.5 s\nprojectile_speed 15\nprojectile_lifetime 4.0 s\nprojectile_damage 1\nstarting_lives 3\nround_count 3"]

    GC --> BALL["cannon_ball_scene\nPackedScene → cannon_projectile.tscn"]

    GC --> ROUNDS["rounds: Array[RoundConfig]"]

    ROUNDS --> RC1["round_config_1.tres\nRoundConfig\nround_number = 1\nround_start_delay = 3.0 s\ntime_between_spawns = 1.5 s\ncompletion_bonus = 500\ntime_limit = 60 s"]
    ROUNDS --> RC2["round_config_2.tres\nRoundConfig\n..."]
    ROUNDS --> RC3["round_config_3.tres\nRoundConfig\n..."]

    RC1 --> TSE1["TargetSpawnEntry sub-resource\ncount: int\nspacing: float\nheight_offset: float"]
    TSE1 --> TC_P["target_config_pelita.tres\nTargetConfig\ntarget_id = pelita\nbase_health = 1\nscore_value = 100\ntype = SWINGING"]
    TSE1 --> TC_K["target_config_kelapa.tres\nTargetConfig\ntarget_id = kelapa\nbase_health = 1\nscore_value = 150\ntype = ROLLING"]

    RC2 & RC3 --> TSE_OTHER["TargetSpawnEntry\n..."]
    TSE_OTHER --> TC_B["target_config_belon.tres\nTargetConfig\ntarget_id = belon\nbase_health = 1\nscore_value = 200\ntype = FLOATING"]

    TC_P --> SCENE_P["scene: PackedScene\n→ target_pelita.tscn"]
    TC_K --> SCENE_K["scene: PackedScene\n→ target_kelapa.tscn"]
    TC_B --> SCENE_B["scene: PackedScene\n→ target_belon.tscn"]

    style GC fill:#2d4a22,color:#c8e6c9
    style RC1 fill:#1a237e,color:#c5cae9
    style RC2 fill:#1a237e,color:#c5cae9
    style RC3 fill:#1a237e,color:#c5cae9
    style TC_P fill:#4a1942,color:#f3e5f5
    style TC_K fill:#4a1942,color:#f3e5f5
    style TC_B fill:#4a1942,color:#f3e5f5
```

---

## 15. Visual Asset Replacement Map

All placeholder sprites (Sprite2D with no texture) that an artist should replace.
Each entry shows the script export variable to assign in the Godot Inspector.

```mermaid
flowchart LR
    subgraph CANNON_ASSETS[Cannon Assets\ncannon.gd]
        CA1["@export cannon_body_texture\nTarget: CannonBody Sprite2D\nSuggested: bamboo/wood base ~80×40 px\nFile: res://assets/cannon_body.png"]
        CA2["@export barrel_texture\nTarget: BarrelPivot/BarrelSprite Sprite2D\nSuggested: horizontal bamboo pipe\n~80×20 px tip pointing RIGHT\nFile: res://assets/barrel.png"]
        CA3["@export fire_sound\nTarget: AudioStreamPlayer2D\nSuggested: loud BOOM clip OGG\nFile: res://assets/audio/cannon_fire.ogg"]
    end

    subgraph BALL_ASSETS[Cannonball Assets\ncannon_projectile.gd]
        BA1["@export ball_texture\nTarget: Sprite2D on CannonProjectile\nSuggested: dark iron sphere ~32×32 px\nSprite pre-scaled 0.5× = 16 px effective\nFile: res://assets/cannonball.png"]
    end

    subgraph PELITA_ASSETS[Pelita Oil Lamp\ntarget_pelita.gd]
        PA1["@export body_texture\nTarget: Sprite2D at position 0 -10\nSuggested: clay glass lamp ~24×40 px\npivot at top-centre for swing\nFile: res://assets/pelita_body.png"]
        PA2["@export flame_texture\nTarget: FlameNode/FlameSpriteD Sprite2D\nSuggested: 16×24 px orange flame\nor AnimatedTexture 3-4 frames\nFile: res://assets/flame.png"]
        PA3["@export flame_light_texture\nTarget: FlameNode/PointLight2D texture\nSuggested: soft radial gradient blob\nFile: res://assets/light_blob.png"]
    end

    subgraph KELAPA_ASSETS[Kelapa Coconut\ntarget_kelapa.gd]
        KA1["@export body_texture\nTarget: Sprite2D on TargetKelapa\nSuggested: top-view coconut ~40×40 px\nmatches circular collider radius 20\nFile: res://assets/kelapa.png"]
        KA2["@export hit_sound\nTarget: AudioStreamPlayer2D child\nSuggested: wooden knock OGG\nFile: res://assets/audio/kelapa_hit.ogg"]
    end

    subgraph BELON_ASSETS[Belon Balloon\ntarget_belon.gd]
        BL1["@export balloon_texture\nTarget: Sprite2D on TargetBelon\nSuggested: round balloon ~32×40 px\npivot at bottom-centre knot\nFile: res://assets/belon.png"]
        BL2["@export balloon_color\nType: Color default Color 1 0.2 0.5 1\nChange per-instance in Inspector\nfor red blue yellow green variety"]
    end

    subgraph VFX_ASSETS[VFX — CPUParticles2D\nNo texture required — colour only]
        VX1["MuzzleFlash\ncannon.tscn\nOrange-yellow burst\ncolor Color 1 0.7 0.1 1"]
        VX2["SmokePuff\nsmoke_puff.tscn\nGray smoke drifts upward\ncolor Color 0.6 0.6 0.6 0.8"]
        VX3["BalloonPop\nballoon_pop.tscn\nGolden confetti falls down\ncolor Color 1 0.8 0.1 1"]
    end
```

---

## Quick Reference: Key Timing Values

| Parameter | Default | Configured in |
|---|---|---|
| Cannon load duration | 2.0 s | `game_config.tres → cannon_load_duration` |
| Post-fire cooldown | 1.5 s | `game_config.tres → cannon_cooldown_duration` |
| Projectile lifetime | 4.0 s | `game_config.tres → projectile_lifetime` |
| Projectile speed | 15 px/frame | `game_config.tres → projectile_speed` |
| Barrel aim range | 0° – 75° | `game_config.tres → min/max_aim_angle` |
| Barrel aim speed | 60°/s | `game_config.tres → cannon_aim_speed` |
| Starting lives | 3 | `game_config.tres → starting_lives` |
| Round start delay | 3.0 s | `round_config_N.tres → round_start_delay` |
| Spawn stagger delay | 1.5 s | `round_config_N.tres → time_between_spawns` |
| Between-round pause | 1.5 s | Hard-coded in `round_manager.gd → advance_round` |
| Round announcement | 2.5 s | Hard-coded in `round_announcement.gd → display_duration` |
| Pelita swing | 15° · 0.8 Hz | `target_pelita.gd → swing_amplitude · swing_frequency` |
| Belon drift speed | 0.3 px/s | `target_belon.gd → drift_speed` |
| Kelapa roll force | 200 N | `target_kelapa.gd → roll_force` |
| Kelapa death delay | 1.5 s | Hard-coded in `target_kelapa.gd → _on_death` |

---

## Quick Reference: Physics Collision Layers

| Layer | Name | Used by |
|---|---|---|
| 1 | `world` | Ground / walls (StaticBody2D) |
| 2 | `cannon_projectile` | CannonProjectile Area2D |
| 3 | `target` | All target Area2D / RigidBody2D shapes |
| 4 | `ground` | Floor reference for TargetKelapa landing |

`CannonProjectile` collision_layer = 2, collision_mask = 4 (targets on layer 3 + world on layer 1).
Targets do not collide with layer 2, so projectiles cannot hit each other.

---

*See also: [ARCHITECTURE.md](../ARCHITECTURE.md) for narrative descriptions · [docs/development.md](development.md) for setup and extension guides.*
