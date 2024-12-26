extends Node2D

@onready var cam: Camera2D = get_node("cam")

var zoom_speed = 0.1
var pan_speed = 0.8
var min_zoom = Vector2(0.1, 0.1)
var max_zoom = Vector2(3, 3)

var dragging = false
var last_mouse_position = Vector2()

func _process(delta):
	if dragging and cam.enabled:
		var mouse_pos = get_viewport().get_mouse_position()
		var drag_delta = mouse_pos - last_mouse_position
		position -= drag_delta * pan_speed
		last_mouse_position = mouse_pos

func _input(event):
	if event is InputEventMouseButton and cam.enabled:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				dragging = true
				last_mouse_position = get_viewport().get_mouse_position()
			else:
				dragging = false
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(zoom_speed)

func zoom_camera(delta_zoom):
	var new_zoom = cam.zoom - Vector2(delta_zoom, delta_zoom)
	cam.zoom = new_zoom.clamp(min_zoom, max_zoom)
