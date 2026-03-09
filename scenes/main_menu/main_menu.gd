## MainMenu – main menu for Meriam Raya.
## Options:
##   Main Tempatan      – Local co-op (same device)
##   Main Dalam Talian  – Online co-op (ENet lobby)
##   Cara Main          – Expandable how-to-play panel
##   Tetapan            – Volume slider + fullscreen toggle (persisted)
##   Keluar             – Quit to desktop (no-op on Web)
class_name MainMenu
extends Control

const SETTINGS_PATH := "user://meriam_settings.cfg"

# ---------------------------------------------------------------------------
# Node references – game mode
# ---------------------------------------------------------------------------
@onready var main_tempatan_button: Button    = $CenterContainer/VBoxContainer/MainTempatanButton
@onready var main_dalam_talian_button: Button = $CenterContainer/VBoxContainer/MainDalamTalianButton
@onready var high_score_label: Label         = $CenterContainer/VBoxContainer/HighScoreLabel

# ---------------------------------------------------------------------------
# Node references – online panel
# ---------------------------------------------------------------------------
@onready var online_panel: Control           = $CenterContainer/VBoxContainer/OnlinePanel
@onready var create_lobby_button: Button     = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/CreateLobbyButton
@onready var join_lobby_button: Button       = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/JoinLobbyButton
@onready var join_code_input: LineEdit       = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/JoinCodeInput
@onready var join_code_display_label: Label  = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/JoinCodeDisplayLabel
@onready var close_online_button: Button     = $CenterContainer/VBoxContainer/OnlinePanel/OnlineVBox/CloseOnlineButton

# ---------------------------------------------------------------------------
# Node references – how-to-play panel
# ---------------------------------------------------------------------------
@onready var cara_main_button: Button        = $CenterContainer/VBoxContainer/CaraMainButton
@onready var how_to_play_panel: Control      = $CenterContainer/VBoxContainer/HowToPlayPanel
@onready var close_htp_button: Button        = $CenterContainer/VBoxContainer/HowToPlayPanel/HowToPlayVBox/CloseHTPButton

# ---------------------------------------------------------------------------
# Node references – settings panel
# ---------------------------------------------------------------------------
@onready var tetapan_button: Button          = $CenterContainer/VBoxContainer/TetapanButton
@onready var settings_panel: Control         = $CenterContainer/VBoxContainer/SettingsPanel
@onready var master_volume_slider: HSlider   = $CenterContainer/VBoxContainer/SettingsPanel/SettingsVBox/MasterVolumeSlider
@onready var fullscreen_toggle: CheckButton  = $CenterContainer/VBoxContainer/SettingsPanel/SettingsVBox/FullscreenRow/FullscreenToggle
@onready var close_settings_button: Button   = $CenterContainer/VBoxContainer/SettingsPanel/SettingsVBox/CloseSettingsButton

# ---------------------------------------------------------------------------
# Node references – quit
# ---------------------------------------------------------------------------
@onready var keluar_button: Button           = $CenterContainer/VBoxContainer/KeluarButton

@onready var lobby_manager: LobbyManager     = $LobbyManager

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Load saved settings before wiring sliders (avoids false change signals)
	_load_settings()

	high_score_label.text = "Markah Tertinggi: %d" % ScoreManager.get_high_score()
	_close_all_panels()

	# Game mode buttons
	main_tempatan_button.pressed.connect(_start_local)
	main_dalam_talian_button.pressed.connect(func(): _toggle_panel(online_panel))

	# Online panel
	create_lobby_button.pressed.connect(_create_lobby)
	join_lobby_button.pressed.connect(_join_lobby)
	close_online_button.pressed.connect(func(): online_panel.hide())

	# How-to-play panel
	cara_main_button.pressed.connect(func(): _toggle_panel(how_to_play_panel))
	close_htp_button.pressed.connect(func(): how_to_play_panel.hide())

	# Settings panel
	tetapan_button.pressed.connect(func(): _toggle_panel(settings_panel))
	master_volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	close_settings_button.pressed.connect(_close_and_save_settings)

	# Quit
	keluar_button.pressed.connect(_quit_game)
	# Hide Quit button on Web builds (cannot close a browser tab)
	if OS.has_feature("web"):
		keluar_button.hide()

	# Lobby callbacks
	lobby_manager.join_code_ready.connect(_on_join_code_ready)
	lobby_manager.joined.connect(_on_lobby_joined)
	lobby_manager.error_occurred.connect(_on_lobby_error)

# ---------------------------------------------------------------------------
# Panel management – only one expandable panel open at a time
# ---------------------------------------------------------------------------

func _toggle_panel(panel: Control) -> void:
	var was_visible := panel.visible
	_close_all_panels()
	if not was_visible:
		panel.show()

func _close_all_panels() -> void:
	online_panel.hide()
	how_to_play_panel.hide()
	settings_panel.hide()

# ---------------------------------------------------------------------------
# Game mode handlers
# ---------------------------------------------------------------------------

func _start_local() -> void:
	multiplayer.multiplayer_peer = null  # clear any leftover ENet peer from a previous online attempt
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

# ---------------------------------------------------------------------------
# Online lobby handlers
# ---------------------------------------------------------------------------

func _create_lobby() -> void:
	lobby_manager.create_lobby()

func _join_lobby() -> void:
	lobby_manager.join_lobby(join_code_input.text.strip_edges())

func _on_join_code_ready(code: String) -> void:
	join_code_display_label.text = "Kod: %s" % code
	join_code_display_label.show()

func _on_lobby_joined() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_lobby_error(message: String) -> void:
	push_warning("[MainMenu] Lobby error: %s" % message)
	join_code_display_label.text = "Ralat: %s" % message
	join_code_display_label.show()

# ---------------------------------------------------------------------------
# Settings handlers
# ---------------------------------------------------------------------------

func _on_volume_changed(value: float) -> void:
	# Convert linear 0–1 to decibels; mute completely at 0
	var db := linear_to_db(value) if value > 0.0 else -80.0
	AudioServer.set_bus_volume_db(0, db)

func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _close_and_save_settings() -> void:
	_save_settings()
	settings_panel.hide()

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return  # first run – keep defaults

	var vol: float = cfg.get_value("settings", "master_volume", 1.0)
	master_volume_slider.value = vol
	_on_volume_changed(vol)

	var fs: bool = cfg.get_value("settings", "fullscreen", false)
	fullscreen_toggle.button_pressed = fs
	_on_fullscreen_toggled(fs)

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "master_volume", master_volume_slider.value)
	cfg.set_value("settings", "fullscreen", fullscreen_toggle.button_pressed)
	cfg.save(SETTINGS_PATH)

# ---------------------------------------------------------------------------
# Quit
# ---------------------------------------------------------------------------

func _quit_game() -> void:
	get_tree().quit()
