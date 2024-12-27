class_name NodeMap
extends Node2D

#@onready var game_contoller: GameController = get_tree().get_root().get_node("main/game_controller")
@onready var world_map: WorldMap = get_parent().get_node("world_map")
@onready var world: Node3D = get_parent().get_node("world_map/world")
@onready var cam: Camera2D = get_node("pan_cam/cam")
@onready var select: Sprite2D = get_node("select")

@onready var t_ground: TileMapLayer = get_node("t_ground")
@onready var t_walls: TileMapLayer = get_node("t_walls")
@onready var t_hills: TileMapLayer = get_node("t_hills")
@onready var c_objects: Node2D = get_node("objects")
@onready var c_entities: Node2D = get_node("entities")

@onready var test_building: PackedScene = preload("res://scenes/test_building.tscn")

var node_id: int = 0

func load_node() -> void:
	t_ground.clear()
	t_walls.clear()
	t_hills.clear()
	
	var node: WorldNode = world.get_child(node_id) 
	var tilemap_data: Dictionary =  node.tilemap_data
	
	var ground_tile_data = tilemap_data["ground_tiles"]
	for tile in ground_tile_data:
		t_ground.set_cell(tile, 0, ground_tile_data[tile], 0)
	
	var wall_tile_data = tilemap_data["wall_tiles"]
	for tile in wall_tile_data:
		t_walls.set_cell(tile, 0, wall_tile_data[tile], 0)

	var hill_tile_data = tilemap_data["hill_tiles"]
	for tile in hill_tile_data:
		t_hills.set_cell(tile, 0, hill_tile_data[tile], 0)
	
	load_objects()
		
func _physics_process(_delta: float) -> void:
	if world_map.visible:
		return
	
	# selection sprite
	var mouse_position = get_global_mouse_position()
	var cell_position = t_ground.local_to_map(mouse_position)
	var snapped_position = t_ground.map_to_local(cell_position)
	select.position = snapped_position
	
	if t_ground.get_used_cells().has(cell_position):
		select.visible = true
		if Input.is_action_just_pressed("lmb"):
			world.get_child(node_id).add_building.rpc(snapped_position)
	else:
		select.visible = false
		
func load_objects():
	for object in c_objects.get_children():
		c_objects.remove_child(object)
		object.queue_free()
	
	var object_data = world.get_child(node_id).object_data
	for object in range(0, object_data.size()):
		var object_node = test_building.instantiate()
		object_node.position = object_data[object]["pos"]
		c_objects.add_child(object_node)
