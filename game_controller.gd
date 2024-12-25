extends Node

@onready var world_map: Node3D = get_node("world_map")
@onready var node_map: Node2D = get_node("node_map")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("map"):
		world_map.visible = !world_map.visible
		node_map.visible = !node_map.visible
