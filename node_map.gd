class_name NodeMap
extends Node2D

#@onready var game_contoller: GameController = get_tree().get_root().get_node("game_controller")
@onready var cam: Camera2D = get_node("pan_cam/cam")
@onready var select: Sprite2D = get_node("select")

@onready var t_ground: TileMapLayer = get_node("t_ground")
@onready var t_walls: TileMapLayer = get_node("t_walls")
@onready var t_hills: TileMapLayer = get_node("t_hills")

var node_id: int = 0
var node_data: Dictionary
var tilemap_data: Dictionary

func load_node() -> void:
	t_ground.clear()
	t_walls.clear()
	t_hills.clear()
	
	var ground_tile_data = tilemap_data["ground_tiles"]
	for tile in ground_tile_data:
		t_ground.set_cell(tile, 0, ground_tile_data[tile], 0)
	
	var wall_tile_data = tilemap_data["wall_tiles"]
	for tile in wall_tile_data:
		t_walls.set_cell(tile, 0, wall_tile_data[tile], 0)

	var hill_tile_data = tilemap_data["hill_tiles"]
	for tile in hill_tile_data:
		t_hills.set_cell(tile, 0, hill_tile_data[tile], 0)
		
func _physics_process(_delta: float) -> void:
	# selection sprite
	var mouse_position = get_global_mouse_position()
	var cell_position = t_ground.local_to_map(mouse_position)
	var snapped_position = t_ground.map_to_local(cell_position)
	select.position = snapped_position
	
	if t_ground.get_used_cells().has(cell_position):
		select.visible = true
	else:
		select.visible = false
