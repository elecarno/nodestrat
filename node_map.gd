class_name NodeMap
extends Node2D

@onready var cam: Camera2D = get_node("pan_cam/cam")
@onready var t_ground: TileMapLayer = get_node("t_ground")

var node_id: int = 0
var node_data: Dictionary

func load_node() -> void:
	t_ground.clear()
	
	var ground_tile_data = node_data["ground_tiles"]
	for tile in ground_tile_data:
		t_ground.set_cell(tile, 0, ground_tile_data[tile], 0)
