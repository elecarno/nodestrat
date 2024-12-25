extends Node3D

@onready var cam: Camera3D = get_node("pivot/cam")
@onready var pivot: Node3D = get_node("pivot")

@export var sensitivity: float = 0.5

var active: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and active:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		
func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		active = true
	else:
		active = false
