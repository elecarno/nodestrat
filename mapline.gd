extends Line2D

@export var pos1: Vector3
@export var pos2: Vector3

var cam: Node3D

func _process(_delta):
	if cam.is_position_behind(pos1) or cam.is_position_behind(pos2):
		visible = false
	else:
		visible = true
		set_point_position(0, cam.unproject_position(pos1))
		set_point_position(1, cam.unproject_position(pos2))
