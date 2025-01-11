extends Button

@export var unit: String

func _on_pressed() -> void:
	$"../../info".visible = true
