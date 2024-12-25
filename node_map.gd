extends Node2D

@onready var cam: Camera2D = get_node("cam")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("map"):
		cam.enabled = !cam.enabled
