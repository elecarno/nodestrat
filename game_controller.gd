class_name GameController
extends Node

@onready var world_map: Node3D = get_node("world_map")
@onready var node_map: Node2D = get_node("node_map")
@onready var orbit_cam: Camera3D = get_node("world_map/cam_gimbal/pivot/cam")
@onready var pan_cam: Camera2D = get_node("node_map/pan_cam/cam")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("map"):
		switch_cams()
		
	if Input.is_action_just_pressed("esc"):
		world_map.visible = true
		node_map.visible = false
		orbit_cam.current = true
		pan_cam.enabled = false

func switch_cams():
	world_map.visible = !world_map.visible
	node_map.visible = !node_map.visible
	orbit_cam.current = !orbit_cam.current
	pan_cam.enabled = !pan_cam.enabled
