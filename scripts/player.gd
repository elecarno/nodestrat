class_name Player
extends Node

@onready var lobby: Control = get_node("../../canvas_layer/lobby/lobby_container/lobby_vbox")
@onready var main: Node = get_tree().get_root().get_node("main")

var client_id: int = 0
var is_client: bool = false
@export var player_name: String = "Player"
@export var faction_name: String = "PLAYER FACTION"
var has_lobby_entry: bool = false
var is_ready: bool = false

func _ready() -> void:
	var name_edit: LineEdit = main.get_node("canvas_layer/menu/name")
	
	name = str(client_id)
	if is_multiplayer_authority():
		is_client = true
		get_parent().get_parent().client_id = client_id
		if name_edit.text == "":
			player_name = "Player"
		else:
			player_name = name_edit.text
		
	for i in range(0, lobby.get_child_count()):
		if lobby.get_child(i).client_id == 0 and not has_lobby_entry:
			lobby.get_child(i).client_id = client_id
			lobby.get_child(i).player_name = player_name
			lobby.get_child(i).visible = true
			lobby.get_child(i).init_entry()
			has_lobby_entry = true
	
