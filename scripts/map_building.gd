class_name MapBuilding
extends Node2D

@onready var connection_line: PackedScene = preload("res://scenes/connection.tscn")
@onready var c_objects: Node2D = get_parent()

var id: int = 0
var type: String = ""
var connections: Array = []

func _ready() -> void:
	name += " (%s)" % [id]
	
	# spawn connection lines
	for i in range(0, connections.size()):
		var conn_line: Line2D = connection_line.instantiate()
		for object in c_objects.get_children():
			if object.id == connections[i]:
				conn_line.set_point_position(1, to_local(object.position))
		add_child(conn_line)
	
