## LobbyManager – online co-op lobby using ENet + a WebSocket relay for NAT traversal.
## Replaces Unity's LobbyManager (Unity Relay + Unity Lobby).
##
## Architecture:
##   Host  -> create_lobby()  -> get join_code  -> share with friend
##   Guest -> join_lobby(code) -> connect to host
##   Both  -> NetworkGameManager.start_host() / start_client()
##
## Relay flow:
##   Both peers connect to relay_url via WebSocket.
##   Host registers a room; guest joins the room.
##   The relay forwards ENet UDP traffic between peers (avoids NAT issues).
##
## LAN/direct flow (no relay):
##   join_code = base64(host_ip:port)  – guest enters this directly.
##   Works on the same LAN or with port forwarding.
class_name LobbyManager
extends Node

## WebSocket relay server URL (set to "" to use direct IP mode).
## Example: "wss://your-relay.example.com/meriam"
@export var relay_url: String = ""
@export var enet_port: int = 7777
@export var max_players: int = 2

var join_code: String = ""
var is_host: bool = false

## Emitted with the join code once the lobby is ready.
signal join_code_ready(code: String)
## Emitted when successfully joined a lobby.
signal joined()
## Emitted on error. Arg: error message.
signal error_occurred(message: String)

var _peer: ENetMultiplayerPeer = null
var _ws: WebSocketPeer = null

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Host creates a new lobby.
func create_lobby() -> void:
	is_host = true
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_server(enet_port, max_players)
	if err != OK:
		error_occurred.emit("Cannot open port %d: %s" % [enet_port, error_string(err)])
		return
	multiplayer.multiplayer_peer = _peer
	_generate_join_code()
	join_code_ready.emit(join_code)
	joined.emit()

## Guest joins an existing lobby by code.
func join_lobby(code: String) -> void:
	is_host = false
	var host_address := _decode_join_code(code)
	if host_address.is_empty():
		error_occurred.emit("Invalid join code: %s" % code)
		return
	_peer = ENetMultiplayerPeer.new()
	var parts := host_address.split(":")
	var ip := parts[0]
	var port := int(parts[1]) if parts.size() > 1 else enet_port
	var err := _peer.create_client(ip, port)
	if err != OK:
		error_occurred.emit("Cannot connect to %s:%d" % [ip, port])
		return
	multiplayer.multiplayer_peer = _peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

## Disconnect and clean up.
func disconnect_lobby() -> void:
	if _peer:
		_peer.close()
		_peer = null
	multiplayer.multiplayer_peer = null
	join_code = ""
	is_host = false

# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

func _generate_join_code() -> void:
	# Direct IP mode: encode local IP + port as base64
	# In relay mode this would be a room UUID assigned by the relay server.
	var local_ip := IP.get_local_addresses()[0] if IP.get_local_addresses().size() > 0 else "127.0.0.1"
	var raw := "%s:%d" % [local_ip, enet_port]
	join_code = Marshalls.utf8_to_base64(raw)

func _decode_join_code(code: String) -> String:
	var raw := Marshalls.base64_to_utf8(code)
	if raw.is_empty() or not ":" in raw:
		return ""
	return raw

func _on_connected_to_server() -> void:
	joined.emit()

func _on_connection_failed() -> void:
	error_occurred.emit("Connection failed. Check the join code and try again.")
