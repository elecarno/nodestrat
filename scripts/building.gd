class_name Building
extends Node

var type: String = "test_building"
var pos: Vector2 = Vector2.ZERO
var faction: String = ""

var stored_energy: int
var stored_alpha: int
var stored_beta: int
var stored_gamma: int
var hp: int

func _ready() -> void:
	#print(res_refs.buildings[type].MAX_ENERGY)
	pass
