extends Node3D

@onready var world_node: PackedScene = preload("res://world_node.tscn")
@onready var mapline: PackedScene = preload("res://mapline.tscn")

@onready var world: Node3D = get_node("world")
@onready var world_ui: Node3D = get_node("world_ui")
@onready var cam: Node3D = get_node("cam_gimbal/pivot/cam")
@onready var cam_controller = get_node("cam_gimbal")

@export var world_size: int = 32
@export var world_radius: float = 16
@export var max_connections_per_node: int = 4
@export var connection_threshold: float = 8

var world_nodes: Array = []

func _ready() -> void:
	cam.position = Vector3(0, 0, world_radius*2)
	cam_controller.zoom_max = world_radius*3
	
	# create nodes
	for node_id in range(0, world_size):
		var new_node: WorldNode = world_node.instantiate()
		new_node.id = node_id
		new_node.name = str(node_id)
		if node_id != 0:
			new_node.position = sample_point_in_sphere(world_radius)
		world.add_child(new_node)
		world_nodes.append(node_id)
		
	# establish starting connections between nodes
	for node_id in range(0, world_nodes.size()):
		var valid_connections: Array = []
		var node_pos = world.get_child(node_id).get_global_position()
		for conn_node_id in range(0, world_nodes.size()):
			var other_node_pos = world.get_child(conn_node_id).get_global_position()
			if node_pos.distance_to(other_node_pos) <= connection_threshold:
				valid_connections.append(conn_node_id)
				
		var number_of_connections = randi_range(1, max_connections_per_node)
		for i in range(0, number_of_connections):
			if i <= valid_connections.size()-1:
				world.get_child(node_id).connections.append(valid_connections[i])
		
	# draw connections between nodes
	for node_id in range(0, world_nodes.size()):
		var connections = world.get_child(node_id).connections
		for i in range (0, connections.size()):
			var new_mapline = mapline.instantiate()
			new_mapline.pos1 = world.get_child(node_id).position
			new_mapline.pos2 = world.get_child(connections[i]).get_global_position()
			new_mapline.cam = cam
			world_ui.add_child(new_mapline)

func sample_point_in_sphere(radius: float) -> Vector3:
	# Random angles
	var phi = randf() * TAU # TAU is 2 * PI in Godot
	var cos_theta = randf() * 2.0 - 1.0 # Uniform distribution for cos(theta)
	var theta = acos(cos_theta)

	# Random radius within the sphere
	var u = randf()
	var r = radius * u ** (1.0 / 3.0)

	# Convert to Cartesian coordinates
	var x = r * sin(theta) * cos(phi)
	var y = r * sin(theta) * sin(phi)
	var z = r * cos(theta)

	return Vector3(x, y, z)
	
func randi_range_exclude(min_value: int, max_value: int, exclude: Array) -> int:
	if min_value > max_value:
		return min_value
		
	# Filter the range to exclude the specified values
	var valid_values = []
	for i in range(min_value, max_value + 1):
		if i not in exclude:
			valid_values.append(i)
			
	# If no valid values are left, return an error
	if valid_values == []:
		return min_value
		
	# Return a random choice from the valid values
	return valid_values[randi() % valid_values.size()]
