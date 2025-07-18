extends Node
class_name Connection

signal server_created
signal connected
signal disconnected

static var is_peer_connected: bool

@export var port: int
@export var max_clients: int
@export var host: String
@export var use_localhost_in_editor: bool


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start_server"):
		start_server()
	if event.is_action_pressed("connect_client"):
		start_client()


func start_server() -> void:
	if max_clients == 0:
		max_clients = 32
	
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_clients)
	if err != OK:
		print("Cannot start server. Err: " + str(err))
		disconnected.emit()
		return
	else:
		print("Server started")
		connected.emit()
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	server_created.emit()


func start_client() -> void:
	var address = host
	if OS.has_feature("editor") and use_localhost_in_editor:
		address = "localhost"
	
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, port)
	if err != OK:
		print("Cannot start client. Err: " + str(err))
		disconnected.emit()
		return
	else: print("Connecting to server...")
	
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(server_connection_failure)
	multiplayer.connection_failed.connect(server_connection_failure)


func connected_to_server() -> void:
	print("Connected to server")
	connected.emit()


func server_connection_failure() -> void:
	print("Disconnected")
	disconnected.emit()


func peer_connected(id: int) -> void:
	print("Peer connected: " + str(id))


func peer_disconnected(id: int) -> void:
	print("Peer disconnected: " + str(id))


func disconnect_all() -> void:
	multiplayer.peer_connected.disconnect(peer_connected)
	multiplayer.peer_disconnected.disconnect(peer_disconnected)
	multiplayer.connected_to_server.disconnect(connected_to_server)
	multiplayer.server_disconnected.disconnect(server_connection_failure)
	multiplayer.connection_failed.disconnect(server_connection_failure)
