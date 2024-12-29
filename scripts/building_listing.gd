extends Button

@export var neutral: bool = true
@export var n_build_res: r_building
@export var a_build_res: r_building
@export var b_build_res: r_building
@export var g_build_res: r_building

func _on_pressed() -> void:
	$"../..".n_build_res = n_build_res
	$"../..".a_build_res = a_build_res
	$"../..".b_build_res = b_build_res
	$"../..".g_build_res = g_build_res
	
	$"../../info".visible = true
	if neutral:
		$"../../info/build".visible = true
		$"../../info/build_type".visible = false
	else:
		$"../../info/build".visible = false
		$"../../info/build_type".visible = true
