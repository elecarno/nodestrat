extends Node3D

@onready var cam: Camera3D = get_node("pivot/cam")
@onready var pivot: Node3D = get_node("pivot")

@export var sensitivity: float = 0.5
@export var zoom_speed: float = 2.0
@export var zoom_min: float = 2.0
@export var zoom_max: float = 48

var active: bool = false

func _input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion and active:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if cam.position.z > zoom_min:
				cam.position.z -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if cam.position.z < zoom_max:
				cam.position.z += zoom_speed

func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and cam.current:
		active = true
	else:
		active = false
	
	if Input.is_action_just_pressed("lmb"):
		raycast()

func raycast():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1024
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	print(raycast_result)

	if raycast_result.has("collider"):
		if raycast_result["collider"] is WorldNode:
			raycast_result["collider"].load_node_map()
