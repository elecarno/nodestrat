extends Button

@export var unit: String

func _on_pressed() -> void:
	$"../..".unit_code = unit
	$"../../info".visible = true
