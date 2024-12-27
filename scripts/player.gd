class_name Player
extends Node

var client_id: int = 0
var is_client: bool = false
@export var faction_name: String = "PLAYER FACTION"

func _ready() -> void:
	name = str(client_id)
	if is_multiplayer_authority():
		is_client = true
		get_parent().get_parent().client_id = client_id
