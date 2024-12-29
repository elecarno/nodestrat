extends Node

@onready var canvas_layer: CanvasLayer = get_node("canvas_layer")
@onready var m_spawner: MultiplayerSpawner = get_node("m_spawner")
@onready var crt: ColorRect = get_node("canvas_layer/crt")
@onready var lobby_vbox: VBoxContainer = get_node("canvas_layer/menu/lobby_list/lobby_container/lobby_vbox")

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

var peer_local = ENetMultiplayerPeer.new()

func _ready() -> void:
	m_spawner.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	open_lobby_list()
	
	crt.visible = true
	
func spawn_level(level_data):
	var level = (load(level_data) as PackedScene).instantiate()
	return level

func _on_host_pressed() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	m_spawner.spawn("res://game_controller.tscn") 
	canvas_layer.visible = false

func _on_lobby_created(connected, id):
	if connected:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print("created lobby with id: " + str(lobby_id))
		
func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	canvas_layer.visible = false

func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var member_count = Steam.getNumLobbyMembers(lobby)
		
		var button: Button = Button.new()
		button.set_text(str(lobby_name) + "| Players: " + str(member_count))
		button.set_size(Vector2(100, 5))
		button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		
		lobby_vbox.add_child(button)

func _on_refresh_pressed() -> void:
	if lobby_vbox.get_child_count() > 0:
		for n in lobby_vbox.get_children():
			n.queue_free()
			
	open_lobby_list()

func _on_host_local_pressed() -> void:
	peer_local.create_server(6868)
	multiplayer.multiplayer_peer = peer_local
	m_spawner.spawn("res://game_controller.tscn") 
	canvas_layer.visible = false

func _on_join_local_pressed() -> void:
	peer_local.create_client("127.0.0.1", 6868)
	multiplayer.multiplayer_peer = peer_local
	canvas_layer.visible = false
