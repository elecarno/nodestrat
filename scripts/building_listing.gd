extends Button

@export var neutral: bool = true
@export var n_build_res: r_building
@export var a_build_res: r_building
@export var b_build_res: r_building
@export var g_build_res: r_building

func _on_pressed() -> void:
	$"../..".neutral = neutral
	$"../..".n_build_res = n_build_res
	$"../..".a_build_res = a_build_res
	$"../..".b_build_res = b_build_res
	$"../..".g_build_res = g_build_res
	$"../..".has_res = true
	
	$"../..".refresh_info()
	$"../../info".visible = true
