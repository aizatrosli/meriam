## NetworkGameManager – server-authoritative network layer for online co-op.
## Host = Anak Sulung (Player 1, aims). Client = Anak Bongsu (Player 2, loads+fires).
## All game-state changes go through RPCs to prevent desync.
## Replaces Unity's NetworkGameManager (Unity Netcode NetworkBehaviour + ServerRpc/ClientRpc).
##
## Godot 4 RPC decorators replace Unity's [ServerRpc] / [ClientRpc]:
##   @rpc("any_peer")   = [ServerRpc(RequireOwnership=false)]
##   @rpc("authority")  = [ClientRpc]
class_name NetworkGameManager
extends Node

@export var cannon: Cannon
@export var player_input_router: PlayerInputRouter

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	_assign_local_role()

# ---------------------------------------------------------------------------
# Role assignment (host = P1 aimer, client = P2 loader/firer)
# ---------------------------------------------------------------------------

func _assign_local_role() -> void:
	if not multiplayer.has_multiplayer_peer():
		# Local co-op: both roles active
		player_input_router.only_player1_local = false
		player_input_router.only_player2_local = false
		return
	if multiplayer.is_server():
		# Host is Anak Sulung (Player 1)
		player_input_router.only_player1_local = true
		player_input_router.only_player2_local = false
		print("[NetworkGameManager] Host: Anak Sulung (Player 1, aims)")
	else:
		# Client is Anak Bongsu (Player 2)
		player_input_router.only_player1_local = false
		player_input_router.only_player2_local = true
		print("[NetworkGameManager] Client: Anak Bongsu (Player 2, loads+fires)")

# ---------------------------------------------------------------------------
# RPCs – aim sync (any_peer -> authority = client -> host validated)
# ---------------------------------------------------------------------------

## Client (P2) requests the server to update the aim angle.
@rpc("any_peer", "call_local", "reliable")
func aim_cannon_rpc(angle: float) -> void:
	if not multiplayer.is_server():
		return
	var aimer := cannon.aimer
	var clamped := clampf(angle, aimer.min_angle, aimer.max_aim_angle)
	aimer.set_aim_angle(clamped)
	_sync_aim_rpc.rpc(clamped)

## Server broadcasts validated aim angle to all clients.
@rpc("authority", "call_local", "reliable")
func _sync_aim_rpc(angle: float) -> void:
	if not multiplayer.is_server():
		cannon.aimer.set_aim_angle(angle)

# ---------------------------------------------------------------------------
# RPCs – fire (client requests fire; server validates and executes)
# ---------------------------------------------------------------------------

## Client (P2) requests the server to fire the cannon.
@rpc("any_peer", "call_local", "reliable")
func fire_cannon_rpc(angle: float) -> void:
	if not multiplayer.is_server():
		return
	var aimer := cannon.aimer
	if angle < aimer.min_angle or angle > aimer.max_aim_angle:
		push_warning("[NetworkGameManager] Rejected fire: angle out of range.")
		return
	aimer.set_aim_angle(angle)
	cannon.firer.fire()
	_notify_fire_rpc.rpc(angle)

## Server notifies all clients that the cannon was fired.
@rpc("authority", "call_local", "reliable")
func _notify_fire_rpc(angle: float) -> void:
	print("[NetworkGameManager] Cannon fired at angle %.1f" % angle)

# ---------------------------------------------------------------------------
# RPCs – game state sync (server -> all clients)
# ---------------------------------------------------------------------------

@rpc("authority", "call_local", "reliable")
func sync_game_state_rpc(state_index: int) -> void:
	GameManager.state_machine.transition_to(state_index as GameState.State)

@rpc("authority", "call_local", "reliable")
func sync_score_rpc(score: int, lives: int) -> void:
	print("[NetworkGameManager] Synced: score=%d lives=%d" % [score, lives])

# ---------------------------------------------------------------------------
# Peer events
# ---------------------------------------------------------------------------

func _on_peer_connected(id: int) -> void:
	print("[NetworkGameManager] Peer connected: %d" % id)
	if multiplayer.is_server():
		var state := GameManager.state_machine.current_state as int
		sync_game_state_rpc.rpc_id(id, state)
		sync_score_rpc.rpc_id(id,
			ScoreManager.get_current_score(),
			GameManager.lives_manager.lives_remaining
		)

func _on_peer_disconnected(id: int) -> void:
	print("[NetworkGameManager] Peer disconnected: %d" % id)
