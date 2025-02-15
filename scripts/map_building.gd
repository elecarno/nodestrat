class_name MapBuilding
extends Area2D

@onready var connection_line: PackedScene = preload("res://scenes/connection.tscn")
@onready var c_objects: Node2D = get_parent()
@onready var node_map: NodeMap = get_tree().get_root().get_node("main/game_controller/node_map")
@onready var world_map: WorldMap = get_tree().get_root().get_node("main/game_controller/world_map")
@onready var game_controller: GameController = get_tree().get_root().get_node("main/game_controller")

var id: int = 0
var type: String = ""
var connections: Array = []
var built: bool = false

func _ready() -> void:
	name = type + " (%s)" % [id]
	position *= 16
	position += Vector2(8, 8)
	
	if built:
		modulate = Color(1, 1, 1, 1)
	else:
		modulate = Color(1, 1, 1, 0.5)
	
	#for i in range(0, connections.size()):
		#var conn_line: Line2D = connection_line.instantiate()
		#for object in c_objects.get_children():
			#if object.id == connections[i]:
				#conn_line.set_point_position(1, to_local(object.position))
		#add_child(conn_line)

func _on_mouse_entered() -> void:
	if world_map.world.get_child(node_map.node_id).node_data["faction"] == game_controller.get_faction(multiplayer.get_unique_id()):
		$select.visible = true
		node_map.building_selection = id
		node_map.building_selected = true

func _on_mouse_exited() -> void:
	$select.visible = false
	node_map.building_selected = false
	#node_map.building_selection = 0
