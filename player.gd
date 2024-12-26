extends Node

var faction_name: String = "PLAYER FACTION"

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
