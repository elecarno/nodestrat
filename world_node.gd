class_name WorldNode
extends StaticBody3D

@onready var mesh: MeshInstance3D = get_node("mesh")
@onready var select: MeshInstance3D = get_node("mesh/select")
@onready var col: CollisionShape3D = get_node("col")
@onready var node_map: NodeMap = get_tree().get_root().get_node("game_controller/node_map")
@onready var game_contoller: GameController = get_tree().get_root().get_node("game_controller")

var id: int = 0
var connections: Array = []

var node_data: Dictionary = {
	"size": 16,
	"n_moisture": randi(),
	"n_temperature": randi(),
	"n_altitude": randi()
}

func _ready() -> void:
	var scale_fac = log(node_data["size"] / 16) + 1
	mesh.scale = Vector3(scale_fac, scale_fac, scale_fac)
	col.scale = Vector3(scale_fac, scale_fac, scale_fac)

func load_node_map():
	node_map.node_id = id
	node_map.node_data = node_data
	node_map.load_node()
	game_contoller.switch_cams()

func _on_mouse_entered() -> void:
	select.visible = true

func _on_mouse_exited() -> void:
	select.visible = false
