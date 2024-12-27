class_name WorldNode
extends StaticBody3D

@onready var mesh: MeshInstance3D = get_node("mesh")
@onready var select: MeshInstance3D = get_node("mesh/select")
@onready var col: CollisionShape3D = get_node("col")
@onready var game_contoller: GameController = get_tree().get_root().get_node("main/game_controller")
@onready var world_map: WorldMap = get_parent().get_parent()
@onready var node_map: NodeMap = get_parent().get_parent().get_parent().get_node("node_map")

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
	"owner": null,
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

var object_data: Array = []
var entity_data: Array = []

func init_node() -> void:
	var scale_fac = 2*log(node_data["size"] / 32) + 1
	mesh.scale = Vector3(scale_fac, scale_fac, scale_fac)
	col.scale = Vector3(scale_fac, scale_fac, scale_fac)
	
	node_data["n_alpha"] = world_map.rng.randi()
	node_data["n_beta"] = world_map.rng.randi()
	node_data["n_gamma"] = world_map.rng.randi()
	node_data["n_walls"] = world_map.rng.randi()
	node_data["n_hills"] = world_map.rng.randi()
	
	position = node_data["position"]
	
	#if node_data["owner"] == "PLAYER":
		#node_data["status"] = STATUS.owned
		#var mat: StandardMaterial3D = mesh.material_override.duplicate()
		#mat.albedo_color = Color(0, 1, 0, 1)
		#mesh.material_override = mat
	
	n_alpha.seed = node_data["n_alpha"]
	n_beta.seed = node_data["n_beta"]
	n_gamma.seed = node_data["n_gamma"]
	n_walls.seed = node_data["n_walls"]
	n_hills.seed = node_data["n_hills"]
	
	#var center = Vector2i(0, 0)
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
				
				if hills > 0.9 and hills < 2:
					tilemap_data["hill_tiles"][tile_pos] = hill_tile
				#else:
					#if walls > 0.5 and walls < 0.85:
						#tilemap_data["wall_tiles"][tile_pos] = wall_tile

func load_node_map():
	game_contoller.node_map.node_id = id
	game_contoller.node_map.load_node()
	game_contoller.switch_cams()
	game_contoller.toggle_node_info("N/A", node_data, false)

#func _physics_process(_delta: float) -> void:
	#if randf() > 0.999 and is_multiplayer_authority():
		#node_data["owner"] = "NEW PLAYER"
		#node_data["status"] = STATUS.owned
	#
	#if node_data["status"] == STATUS.owned:
		#var mat: StandardMaterial3D = mesh.material_override.duplicate()
		#mat.albedo_color = Color(0, 1, 0, 1)
		#mesh.material_override = mat


@rpc("any_peer", "call_local")
func add_building(pos: Vector2):
	var building: Dictionary = {
		"type": "test_building",
		"pos": pos
	}
	object_data.append(building)
	if node_map.node_id == id:
		node_map.load_objects()

func _on_mouse_entered() -> void:
	var node_name = str(id) + "-" + node_data["name"].to_upper()
	game_contoller.toggle_node_info(node_name, node_data, true)
	select.visible = true

func _on_mouse_exited() -> void:
	game_contoller.toggle_node_info("N/A", node_data, false)
	select.visible = false
