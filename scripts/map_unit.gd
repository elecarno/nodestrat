class_name MapUnit
extends Area2D

var id: int
var type: String

func _ready() -> void:
	name = type + " (%s)" % [id]
	position *= 16
	position += Vector2(8, 8)
