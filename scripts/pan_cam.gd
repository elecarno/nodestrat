extends Node2D

@onready var cam: Camera2D = get_node("cam")

const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 2.0
const ZOOM_INCREMENT: float = 0.1
const ZOOM_RATE: float = 8.0
var target_zoom: float = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
			if cam.zoom < Vector2.ONE:
				position -= event.relative * 1/cam.zoom
			else:
				position -= event.relative * cam.zoom
			
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_out()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_in()
				
func zoom_in():
	target_zoom = max(target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)
	
func zoom_out():
	target_zoom = max(target_zoom + ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)
	
func _physics_process(delta: float) -> void:
	cam.zoom = lerp(cam.zoom, target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	
	if cam.zoom.x < 0.5:
		position = lerp(position, Vector2.ZERO, 0.1)
	
	#set_physics_process(!is_equal_approx(cam.zoom.x, target_zoom))
