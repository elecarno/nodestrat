class_name WorldNode
extends StaticBody3D

@onready var mesh: MeshInstance3D = get_node("mesh")
@onready var select: MeshInstance3D = get_node("mesh/select")
@onready var col: CollisionShape3D = get_node("col")
@onready var node_map: NodeMap = get_tree().get_root().get_node("game_controller/node_map")
@onready var game_contoller: GameController = get_tree().get_root().get_node("game_controller")

var id: int = 0
var connections: Array = []

var n_moisture: FastNoiseLite = FastNoiseLite.new()
var n_temperature: FastNoiseLite = FastNoiseLite.new()
var n_altitude: FastNoiseLite = FastNoiseLite.new()

var node_data: Dictionary = {
	"size": 16,
	"n_moisture": randi(),
	"n_temperature": randi(),
	"n_altitude": randi(),
	"ground_tiles": {}
}

func _ready() -> void:
	var scale_fac = log(node_data["size"] / 16) + 1
	mesh.scale = Vector3(scale_fac, scale_fac, scale_fac)
	col.scale = Vector3(scale_fac, scale_fac, scale_fac)
	
	n_moisture.seed = node_data["n_moisture"]
	n_temperature.seed = node_data["n_temperature"]
	n_altitude.seed = node_data["n_altitude"]
	
	var center = Vector2i(0, 0)
	var radius = (node_data["size"])
	
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			var tile_pos: Vector2 = Vector2(x,y )
			if tile_pos.length() < radius:
				var moist = n_moisture.get_noise_2d(x,y)*10
				var temp = n_temperature.get_noise_2d(x,y)*10
				var alt = n_altitude.get_noise_2d(x,y)*10
				var tile: Vector2 = Vector2(0, 0)
				
				if moist > 0.5:
					tile = Vector2(1, 0)
				elif temp > 0.5:
					tile = Vector2(2, 0)
					
				node_data["ground_tiles"][tile_pos] = tile

func load_node_map():
	node_map.node_id = id
	node_map.node_data = node_data
	node_map.load_node()
	game_contoller.switch_cams()

func _on_mouse_entered() -> void:
	select.visible = true

func _on_mouse_exited() -> void:
	select.visible = false
