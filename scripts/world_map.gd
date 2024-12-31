class_name WorldMap
extends Node3D

@onready var world_node: PackedScene = preload("res://scenes/world_node.tscn")
@onready var mapline: PackedScene = preload("res://scenes/mapline.tscn")

@onready var players: Node = get_node("../players")

@onready var world: Node3D = get_node("world")
@onready var world_ui: Node3D = get_node("world_ui")
@onready var cam: Node3D = get_node("cam_gimbal/pivot/cam")
@onready var cam_controller = get_node("cam_gimbal")

@export var world_seed: int
@export var world_size: int = 32
@export var world_radius: float = 16
@export var max_connections_per_node: int = 4
@export var connection_threshold: float = 8
@export var min_node_size: int = 32
@export var max_node_size: int = 64

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var generated: bool = false

var world_nodes: Dictionary = {}

# set phys process to false so that it doesn't check for the seed yet
func _ready() -> void:
	set_physics_process(false)

# initialise world
func init_world():
	print("world initialising with seed: " + str(world_seed))
	
	# ensure camera starts far enough out to show the whole map
	cam.position = Vector3(0, 0, world_radius*2)
	cam_controller.zoom_max = world_radius*3
	
	# allow physics process to wait for seed
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	rng.seed = world_seed
	
	# wait until the game has recieved the seed before generating world
	if world_seed != 0 and not generated:
		generate_nodes()
		generated = true

func generate_nodes():
	print("-----")
	print("generating nodes")
	
	# create nodes
	for node_id in range(0, world_size):
		var new_node: WorldNode = world_node.instantiate()
		new_node.id = node_id
		new_node.name = str(node_id)
		new_node.node_data["size"] = rng.randi_range(min_node_size, max_node_size)
		new_node.node_data["name"] = "Tower"
		if node_id != 0:
			new_node.node_data["position"] = sample_point_in_sphere(world_radius)
			new_node.node_data["name"] = node_names[rng.randi() % node_names.size()]
		world.get_child(node_id).id = node_id
		world.get_child(node_id).node_data = new_node.node_data
		world.get_child(node_id).init_node()
		world_nodes[node_id] = new_node.node_data
		print("created node " + str(node_id))
		
	# establish starting connections between nodes
	for node_id in range(0, world_nodes.size()):
		var valid_connections: Array = []
		var node_pos = world.get_child(node_id).get_global_position()
		for conn_node_id in range(0, world_nodes.size()):
			var other_node_pos = world.get_child(conn_node_id).get_global_position()
			if node_pos.distance_to(other_node_pos) <= connection_threshold:
				valid_connections.append(conn_node_id)
				#print("found valid connections for " + str(node_id) + ": " + str(valid_connections))
				
		var number_of_connections = rng.randi_range(1, max_connections_per_node)
		for i in range(0, number_of_connections):
			if i <= valid_connections.size()-1:
				world.get_child(node_id).node_data["connections"].append(valid_connections[i])
				print("connected node " + str(node_id) + " to " + str(valid_connections[i]))
	
	# draw connections between nodes
	for node_id in range(0, world_nodes.size()):
		var connections = world.get_child(node_id).node_data["connections"]
		for i in range (0, connections.size()):
			var new_mapline = mapline.instantiate()
			new_mapline.pos1 = world.get_child(node_id).position
			new_mapline.pos2 = world.get_child(connections[i]).get_global_position()
			new_mapline.cam = cam
			world_ui.add_child(new_mapline)
		print("spawned connection lines for " + str(node_id))
			
	create_player_factions()
	get_parent().update_player_data()
	print("-----")

func create_player_factions():
	for i in range(0, players.get_child_count()):
		var starting_node = get_random_key_exclude(world_nodes, 0)
		players.get_child(i).faction_name = world_nodes[starting_node]["name"]
		print(str(players.get_child(i).player_name) + " set to start in node " + str(starting_node))
		var colour_idx = rng.randi() % faction_colours.size()
		players.get_child(i).faction_colour = faction_colours[colour_idx]
		faction_colours.remove_at(colour_idx)
		players.get_child(i).update_faction_label()
		var fortress_pos = sample_point_in_circle(min_node_size - 2)
		world.get_child(starting_node).add_building(players.get_child(i).client_id, "fortress", fortress_pos)
		world.get_child(starting_node).refresh_status()

# utility functions
func generate_random_color() -> Color:
	return Color(rng.randf(), rng.randf(), rng.randf(), 1.0)  # Alpha is set to 1.0 (fully opaque)

func sample_point_in_sphere(radius: float) -> Vector3:
	# Random angles
	var phi = rng.randf() * TAU # TAU is 2 * PI in Godot
	var cos_theta = rng.randf() * 2.0 - 1.0 # Uniform distribution for cos(theta)
	var theta = acos(cos_theta)

	# Random radius within the sphere
	var u = rng.randf()
	var r = radius * u ** (1.0 / 3.0)

	# Convert to Cartesian coordinates
	var x = r * sin(theta) * cos(phi)
	var y = r * sin(theta) * sin(phi)
	var z = r * cos(theta)

	return Vector3(x, y, z)
	
func sample_point_in_circle(radius: float) -> Vector2:
	# Generate a random angle in radians
	var angle = rng.randf() * TAU  # TAU is 2 * PI

	# Generate a random radius with uniform distribution over the circle's area
	var r = sqrt(rng.randf()) * radius

	# Convert polar coordinates to Cartesian coordinates
	var x = r * cos(angle)
	var y = r * sin(angle)

	return Vector2(floor(x), floor(y))

	
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
	return valid_values[rng.randi() % valid_values.size()]

func get_random_key_exclude(dictionary: Dictionary, exclude_key):
	# Get all keys from the dictionary
	var keys = dictionary.keys()
	
	# Remove the excluded key if it exists
	if exclude_key in keys:
		keys.erase(exclude_key)
	
	# Check if there are any remaining keys
	if keys.size() == 0:
		return null # Return null if no valid keys are left
	
	# Return a random key from the remaining list
	return keys[rng.randi() % keys.size()]
	

# data arrays
var node_names: Array = [
	"Lytir", "Noctuae", "Oynyena", "Carcharoth", "Metri", "Gori", "Panacea",
	"Rosae", "Maja", "Keni", "Namo", "Vaire", "Inin", "Bracko", "Anat",
	"Anin", "Reeni", "Satet", "Eridani", "Zori", "Pegasi", "Goll", "Durin",
	"Alkonost", "Scorpii", "Ledi", "Capricorni", "Tresi", "Artemis", "Hebe",
	"Essid", "Xani", "Mova"
]

var faction_colours: Array = [
	Color(0.745, 0.290, 0.184, 1.0), # #be4a2f
	Color(0.843, 0.463, 0.263, 1.0), # #d77643
	Color(0.635, 0.149, 0.200, 1.0), # #a22633
	Color(0.894, 0.231, 0.267, 1.0), # #e43b44
	Color(0.969, 0.463, 0.133, 1.0), # #f77622
	Color(0.996, 0.906, 0.380, 1.0), # #fee761
	Color(0.388, 0.780, 0.302, 1.0), # #63c74d
	Color(0.243, 0.537, 0.282, 1.0), # #3e8948
	Color(0.149, 0.361, 0.259, 1.0), # #265c42
	Color(0.071, 0.306, 0.537, 1.0), # #124e89
	Color(0.000, 0.600, 0.859, 1.0), # #0099db
	Color(0.173, 0.909, 0.961, 1.0), # #2ce8f5
	Color(1.000, 0.000, 0.267, 1.0), # #ff0044
	Color(0.408, 0.216, 0.424, 1.0), # #68386c
	Color(0.710, 0.314, 0.533, 1.0), # #b55088
	Color(0.965, 0.459, 0.478, 1.0)  # #f6757a
]
