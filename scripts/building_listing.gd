extends Button

@export var neutral: bool = true
@export var n_build_res: r_building
@export var a_build_res: r_building
@export var b_build_res: r_building
@export var g_build_res: r_building

@onready var world_map: WorldMap = $"../../../../../world_map"
@onready var node_map: NodeMap = $"../../../../../node_map"

func _on_pressed() -> void:
	$"../..".n_build_res = n_build_res
	$"../..".a_build_res = a_build_res
	$"../..".b_build_res = b_build_res
	$"../..".g_build_res = g_build_res
	
	$"../../info".visible = true
	refresh_info()
		
func check_if_buildable(build_res: r_building):
	var current_node_id = node_map.node_id
	var resources = world_map.get_node("world").get_child(current_node_id).get_total_resources()
	if build_res.ANY_MATTER > 0:
		if resources["stored_energy"] >= build_res.BUILD_ENERGY:
			if (resources["stored_alpha"] >= build_res.ANY_MATTER
			or resources["stored_beta"] >= build_res.ANY_MATTER
			or resources["stored_gamma"] >= build_res.ANY_MATTER):
				return true
			else:
				return false
	else:
		if (resources["stored_energy"] >= build_res.BUILD_ENERGY 
		and resources["stored_alpha"] >= build_res.BUILD_ALPHA
		and resources["stored_beta"] >= build_res.BUILD_BETA
		and resources["stored_gamma"] >= build_res.BUILD_GAMMA):
			return true
		else:
			return false

func _on_build_visibility_changed() -> void:
	if $"../../../../..".game_started:
		refresh_info()
	
func refresh_info():
	if neutral:
		$"../../info/build".visible = true
		$"../../info/build_type".visible = false
		
		$"../../info/build".disabled = !check_if_buildable(n_build_res)
	else:
		$"../../info/build".visible = false
		$"../../info/build_type".visible = true
		
		$"../../info/build_type/alpha".disabled = !check_if_buildable(a_build_res)
		$"../../info/build_type/beta".disabled = !check_if_buildable(b_build_res)
		$"../../info/build_type/gamma".disabled = !check_if_buildable(g_build_res)
