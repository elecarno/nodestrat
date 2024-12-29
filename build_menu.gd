extends Control

@onready var node_map: NodeMap = $"../../../node_map"
@onready var game_contoller: GameController = $"../../.."

var n_build_res: r_building
var a_build_res: r_building
var b_build_res: r_building
var g_build_res: r_building

func _on_build_pressed() -> void:
	node_map.build_type = n_build_res.CODE
	visible = false

func _on_alpha_pressed() -> void:
	node_map.build_type = a_build_res.CODE
	visible = false

func _on_beta_pressed() -> void:
	node_map.build_type = b_build_res.CODE
	visible = false

func _on_gamma_pressed() -> void:
	node_map.build_type = g_build_res.CODE
	visible = false
