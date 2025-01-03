class_name MapBuilding
extends Area2D

@onready var connection_line: PackedScene = preload("res://scenes/connection.tscn")
@onready var c_objects: Node2D = get_parent()
@onready var node_map: NodeMap = get_tree().get_root().get_node("main/game_controller/node_map")

var id: int = 0
var type: String = ""
var connections: Array = []

func _ready() -> void:
	name = type + " (%s)" % [id]
	position *= 16
	position += Vector2(8, 8)
	
	#for i in range(0, connections.size()):
		#var conn_line: Line2D = connection_line.instantiate()
		#for object in c_objects.get_children():
			#if object.id == connections[i]:
				#conn_line.set_point_position(1, to_local(object.position))
		#add_child(conn_line)

func _on_mouse_entered() -> void:
	$select.visible = true
	node_map.building_selection = id
	node_map.building_selected = true

func _on_mouse_exited() -> void:
	$select.visible = false
	node_map.building_selected = false
	#node_map.building_selection = 0
