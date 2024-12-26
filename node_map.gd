class_name NodeMap
extends Node2D

@onready var cam: Camera2D = get_node("pan_cam/cam")
@onready var t_ground: TileMapLayer = get_node("t_ground")

var n_moisture: FastNoiseLite = FastNoiseLite.new()
var n_temperature: FastNoiseLite = FastNoiseLite.new()
var n_altitude: FastNoiseLite = FastNoiseLite.new()

var node_id: int = 0
var node_data: Dictionary

func load_node() -> void:
	t_ground.clear()

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
				
				t_ground.set_cell(tile_pos, 0, tile, 0)
