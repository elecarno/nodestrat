class_name WorldNode
extends StaticBody3D

@onready var building_node = preload("res://scenes/building.tscn")

@onready var mesh: MeshInstance3D = get_node("mesh")
@onready var select: MeshInstance3D = get_node("mesh/select")
@onready var col: CollisionShape3D = get_node("col")
@onready var game_contoller: GameController = get_tree().get_root().get_node("main/game_controller")
@onready var world_map: WorldMap = get_parent().get_parent()
@onready var node_map: NodeMap = get_parent().get_parent().get_parent().get_node("node_map")
#@onready var players: Node = get_parent().get_parent().get_parent().get_node("players")

@onready var c_objects: Node = get_node("objects")
@onready var c_entities: Node = get_node("entities")

var n_alpha: FastNoiseLite = FastNoiseLite.new()
var n_beta: FastNoiseLite = FastNoiseLite.new()
var n_gamma: FastNoiseLite = FastNoiseLite.new()
var n_walls: FastNoiseLite = FastNoiseLite.new()
var n_hills: FastNoiseLite = FastNoiseLite.new()

enum STATUS {unowned, owned, contested}

var id: int = 0 
@export var node_data: Dictionary = {
	"name": "NULLSEC",
	"size": 16,
	"position": Vector3.ZERO,
	"connections": [],
	"status": STATUS.unowned,
	"faction": null,
	"n_alpha": 0,
	"n_beta": 0,
	"n_gamma": 0,
	"n_walls": 0,
	"n_hills": 0,
}

var tilemap_data: Dictionary = {
	"ground_tiles": {}, # terrain type, walkable area
	"wall_tiles": {}, # build/destroy, can throw over
	"hill_tiles": {} # destroy, cannot throw over
}

#var object_data: Array = []
#var entity_data: Array = []

func init_node() -> void:
	# set scale based on node size
	# uses a logarithm so that they all remain big enough to click easily
	var scale_fac = 2*log(node_data["size"] / 32) + 1
	mesh.scale = Vector3(scale_fac, scale_fac, scale_fac)
	col.scale = Vector3(scale_fac, scale_fac, scale_fac)
	
	# set node position
	position = node_data["position"]
	
	# set noise seeds based on rng using the world seed
	node_data["n_alpha"] = world_map.rng.randi()
	node_data["n_beta"] = world_map.rng.randi()
	node_data["n_gamma"] = world_map.rng.randi()
	node_data["n_walls"] = world_map.rng.randi()
	node_data["n_hills"] = world_map.rng.randi()
	
	n_alpha.seed = node_data["n_alpha"]
	n_beta.seed = node_data["n_beta"]
	n_gamma.seed = node_data["n_gamma"]
	n_walls.seed = node_data["n_walls"]
	n_hills.seed = node_data["n_hills"]
	
	# calculate tiles
	var radius = (node_data["size"])
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			var tile_pos: Vector2 = Vector2(x,y )
			if tile_pos.length() < radius:
				var a = n_alpha.get_noise_2d(x,y)*10
				var b = n_beta.get_noise_2d(x,y)*10
				var c = n_gamma.get_noise_2d(x,y)*10
				var tile: Vector2 = Vector2(0, 0)
				var wall_tile: Vector2 = Vector2(0, 1)
				var hill_tile: Vector2 = Vector2(0, 2)
				
				if a > 0.5:
					tile = Vector2(1, 0)
					wall_tile = Vector2(1, 1)
				elif b > 0.5:
					tile = Vector2(2, 0)
					wall_tile = Vector2(2, 1)
				elif c > 0.5:
					tile = Vector2(3, 0)
					wall_tile = Vector2(3, 1)
					
				tilemap_data["ground_tiles"][tile_pos] = tile
				
				var walls = n_walls.get_noise_2d(x,y)*5
				var hills = n_hills.get_noise_2d(x,y)*5
				
				# temporarily disabled hill generation because it
				# adds too much extra stuff to account for
				#if hills > 0.9 and hills < 2:
					#tilemap_data["hill_tiles"][tile_pos] = hill_tile
				#else:
					#if walls > 0.5 and walls < 0.85:
						#tilemap_data["wall_tiles"][tile_pos] = wall_tile

# load node data into 2d node map and switch cameras
func load_node_map():
	game_contoller.node_map.node_id = id
	game_contoller.node_map.load_node()
	game_contoller.switch_cams()
	game_contoller.toggle_node_info("N/A", node_data, {}, false)

# add building to node on all peers
@rpc("any_peer", "call_local")
func add_building(peer_id, type, pos: Vector2):
	var building: Building = building_node.instantiate()
	building.id = world_map.rng.randi()
	building.type = type
	building.pos = pos
	building.faction = game_contoller.get_faction(peer_id)
	c_objects.add_child(building)
	if node_map.node_id == id:
		node_map.load_objects()
	
		if type == "fortress":
			refresh_status.rpc()
	
	game_contoller.update_player_data()

# refresh faction ownership status of node on all peers
@rpc("any_peer", "call_local")
func refresh_status():
	# establish number of fortresses on node
	var num_of_fortresses: int = 0
	var fortress_faction: String = ""
	for i in range(0, c_objects.get_child_count()):
		if c_objects.get_child(i).type == "fortress":
			num_of_fortresses += 1
			fortress_faction = c_objects.get_child(i).faction
	
	# set ownership based on fortresses
	if num_of_fortresses == 0:
		node_data["status"] = STATUS.unowned
		node_data["faction"] = null
	elif num_of_fortresses == 1:
		node_data["status"] = STATUS.owned
		node_data["faction"] = fortress_faction
	elif num_of_fortresses > 1:
		node_data["status"] = STATUS.contested
		node_data["faction"] = null
	
	# set color based on ownership
	if node_data["status"] == STATUS.owned:
		var mat: StandardMaterial3D = mesh.material_override.duplicate()
		var faction_peer_id = game_contoller.get_faction_peer_id(fortress_faction)
		mat.albedo_color = game_contoller.get_faction_colour(faction_peer_id)
		mesh.material_override = mat
	else:
		var mat: StandardMaterial3D = mesh.material_override.duplicate()
		mat.albedo_color = Color(1, 1, 1, 1)
		mesh.material_override = mat

# run day tick methods on all objects and entities
func day_tick():
	for object in range(0, c_objects.get_child_count()):
		if c_objects.get_child(object) is Building:
			c_objects.get_child(object).day_tick()

# get combined storage totals for all resources
func get_total_storage():
	var total_storage: Dictionary = {
		"MAX_ENERGY": 0,
		"MAX_ALPHA": 0,
		"MAX_BETA": 0,
		"MAX_GAMMA": 0
	}
	
	for object in c_objects.get_children():
		if object is Building:
			total_storage["MAX_ENERGY"] += object.MAX_ENERGY
			total_storage["MAX_ALPHA"] += object.MAX_ALPHA
			total_storage["MAX_BETA"] += object.MAX_BETA
			total_storage["MAX_GAMMA"] += object.MAX_GAMMA
	
	return total_storage
	
func get_total_production():
	var total_prod: Dictionary = {
		"PROD_ENERGY": 0,
		"PROD_ALPHA": 0,
		"PROD_BETA": 0,
		"PROD_GAMMA": 0
	}
	
	for object in c_objects.get_children():
		if object is Building:
			total_prod["PROD_ENERGY"] += object.PROD_ENERGY
			total_prod["PROD_ALPHA"] += object.PROD_ALPHA
			total_prod["PROD_BETA"] += object.PROD_BETA
			total_prod["PROD_GAMMA"] += object.PROD_GAMMA
	
	return total_prod

func get_total_resources():
	var total_res: Dictionary = {
		"stored_energy": 0,
		"stored_alpha": 0,
		"stored_beta": 0,
		"stored_gamma": 0
	}
	
	for object in c_objects.get_children():
		if object is Building:
			total_res["stored_energy"] += object.stored_energy
			total_res["stored_alpha"] += object.stored_alpha
			total_res["stored_beta"] += object.stored_beta
			total_res["stored_gamma"] += object.stored_gamma
	
	return total_res

# mouse hover checks
func _on_mouse_entered() -> void:
	var res_info_texts = game_contoller.ui_format_resource_texts(get_total_resources(), get_total_storage(), get_total_production())
	
	var node_name = str(id) + "-" + node_data["name"].to_upper()
	game_contoller.toggle_node_info(node_name, node_data, res_info_texts, true)
	select.visible = true

func _on_mouse_exited() -> void:
	game_contoller.toggle_node_info("N/A", node_data, {}, false)
	select.visible = false
