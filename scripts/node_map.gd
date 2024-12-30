class_name NodeMap
extends Node2D

@onready var connection_line: PackedScene = preload("res://scenes/connection.tscn")

@onready var game_contoller: GameController = get_tree().get_root().get_node("main/game_controller")
@onready var world_map: WorldMap = get_parent().get_node("world_map")
@onready var world: Node3D = get_parent().get_node("world_map/world")
@onready var cam: Camera2D = get_node("pan_cam/cam")
@onready var select: Sprite2D = get_node("select")

@onready var t_ground: TileMapLayer = get_node("t_ground")
@onready var t_walls: TileMapLayer = get_node("t_walls")
@onready var t_hills: TileMapLayer = get_node("t_hills")
@onready var c_objects: Node2D = get_node("objects")
@onready var c_entities: Node2D = get_node("entities")
@onready var c_ui: Node2D = get_node("ui")

@onready var buildings: Dictionary = {
	"test_building": preload("res://scenes/buildings/b_test.tscn"),
	"fortress": preload("res://scenes/buildings/b_fortress.tscn"),
	"pylon": preload("res://scenes/buildings/b_pylon.tscn"),
	"battery": preload("res://scenes/buildings/b_battery.tscn"),
	"powerplant": preload("res://scenes/buildings/b_powerplant.tscn"),
	"harvester_a": preload("res://scenes/buildings/b_harvester_a.tscn"),
	"harvester_b": preload("res://scenes/buildings/b_harvester_b.tscn"),
	"harvester_g": preload("res://scenes/buildings/b_harvester_g.tscn"),
}

var node_id: int = 0

var build_type: String = ""

func load_node() -> void:
	print("-----")
	print("loading node_map for node " + str(node_id))
	
	# clear tilemaps
	t_ground.clear()
	t_walls.clear()
	t_hills.clear()
	
	# get tilemap data
	var node: WorldNode = world.get_child(node_id) 
	var tilemap_data: Dictionary =  node.tilemap_data
	
	# load tilemap data
	print("generating ground tiles")
	var ground_tile_data = tilemap_data["ground_tiles"]
	for tile in ground_tile_data:
		t_ground.set_cell(tile, 0, ground_tile_data[tile], 0)
	
	print("generating wall tiles")
	var wall_tile_data = tilemap_data["wall_tiles"]
	for tile in wall_tile_data:
		t_walls.set_cell(tile, 0, wall_tile_data[tile], 0)

	print("generating hill tiles")
	var hill_tile_data = tilemap_data["hill_tiles"]
	for tile in hill_tile_data:
		t_hills.set_cell(tile, 0, hill_tile_data[tile], 0)
	
	# refresh objects
	load_objects()
	print("-----")
		
func _physics_process(_delta: float) -> void:
	if world_map.visible:
		return
	
	var node: WorldNode = world.get_child(node_id)
	var client_faction = game_contoller.get_faction(multiplayer.get_unique_id())
	
	# selection sprite
	var mouse_position = get_global_mouse_position()
	var cell_position = t_ground.local_to_map(mouse_position)
	var snapped_position = t_ground.map_to_local(cell_position)
	select.position = snapped_position
	
	# check if cursor is on terrain
	if t_ground.get_used_cells().has(cell_position):
		select.visible = true
		# check for mouse click and check if node is owned by client's faction
		if Input.is_action_just_pressed("lmb") and node.node_data["faction"] == client_faction and build_type != "":
			world.get_child(node_id).add_building.rpc(multiplayer.get_unique_id(), build_type, snapped_position)
			build_type = ""
	else:
		select.visible = false

func load_objects():
	print("refreshing objects")
	# clear all objects
	for object in c_objects.get_children():
		c_objects.remove_child(object)
		object.queue_free()
		
	for entity in c_entities.get_children():
		c_entities.remove_child(entity)
		entity.queue_free()
		
	for ui in c_ui.get_children():
		c_ui.remove_child(ui)
		ui.queue_free()

	var objects = world.get_child(node_id).get_node("objects")
	# spawn objects
	for i in range(0, objects.get_child_count()):
		var type = objects.get_child(i).type
		var pos = objects.get_child(i).pos
		var connections = objects.get_child(i).connections
		var object_id = objects.get_child(i).id
		var object_node: MapBuilding = buildings[type].instantiate()
		object_node.id = object_id
		object_node.connections = connections
		object_node.position = pos
		object_node.type = type
		c_objects.add_child(object_node)
		print("spawned object " + str(objects.get_child(i).id) + " on node_map")
		
