extends Control

@onready var node_map: NodeMap = $"../../../node_map"
@onready var world_map: WorldMap = $"../../../world_map"
@onready var game_contoller: GameController = $"../../.."

var unit_code: String

func _on_alpha_pressed() -> void:
	node_map.unit_type = unit_code
	node_map.unit_alignment = "ALPHA"

func _on_beta_pressed() -> void:
	node_map.unit_type = unit_code
	node_map.unit_alignment = "BETA"

func _on_gamma_pressed() -> void:
	node_map.unit_type = unit_code
	node_map.unit_alignment = "GAMMA"
