extends Control

@onready var node_map: NodeMap = $"../../../node_map"
@onready var world_map: WorldMap = $"../../../world_map"
@onready var game_contoller: GameController = $"../../.."

var has_res: bool = false
var neutral: bool = true
var n_build_res: r_building
var a_build_res: r_building
var b_build_res: r_building
var g_build_res: r_building

func _ready() -> void:
	visible = false
	$info.visible = false
	
func _on_build_pressed() -> void:
	node_map.build_type = n_build_res.CODE
	visible = false

func _on_alpha_pressed() -> void:
	node_map.build_type = a_build_res.CODE
	visible = false

func _on_beta_pressed() -> void:
	node_map.build_type = b_build_res.CODE
	visible = false

func _on_gamma_pressed() -> void:
	node_map.build_type = g_build_res.CODE
	visible = false

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

func refresh_info():
	if not has_res:
		return
	
	if neutral:
		$"info/build".visible = true
		$"info/build_type".visible = false
		
		$"info/build".disabled = !check_if_buildable(n_build_res)
		
		$info/vbox/any_prod.visible = false
		$info/vbox/any_storage.visible = false
		$info/vbox/cost.visible = true
		$info/vbox/prod.visible = true
		$info/vbox/storage.visible = true
		# cost
		if n_build_res.ANY_MATTER > 0:
			$"info/vbox/any_cost".text = "α/β/γ: "+str(n_build_res.ANY_MATTER)
			$"info/vbox/cost".visible = false
			$"info/vbox/any_cost".visible = true
			$"info/vbox/e_cost".visible = false
			if n_build_res.BUILD_ENERGY > 0:
				$"info/vbox/e_cost".visible = true
				$"info/vbox/cost/energy".text = "E: "+str(n_build_res.BUILD_ENERGY)
		else:
			$"info/vbox/cost/energy".text = "E: "+str(n_build_res.BUILD_ENERGY)
			$"info/vbox/cost/alpha".text = "α: "+str(n_build_res.BUILD_ALPHA)
			$"info/vbox/cost/beta".text = "β: "+str(n_build_res.BUILD_BETA)
			$"info/vbox/cost/gamma".text = "γ: "+str(n_build_res.BUILD_GAMMA)
			
			$"info/vbox/cost".visible = true
			$"info/vbox/e_cost".visible = false
			
		# prod
		$"info/vbox/prod/energy".text = "E: "+str(n_build_res.PROD_ENERGY)
		$"info/vbox/prod/alpha".text = "α: "+str(n_build_res.PROD_ALPHA)
		$"info/vbox/prod/beta".text = "β: "+str(n_build_res.PROD_BETA)
		$"info/vbox/prod/gamma".text = "γ: "+str(n_build_res.PROD_GAMMA)
		# storage
		$"info/vbox/storage/energy".text = "E: "+str(n_build_res.MAX_ENERGY)
		$"info/vbox/storage/alpha".text = "α: "+str(n_build_res.MAX_ALPHA)
		$"info/vbox/storage/beta".text = "β: "+str(n_build_res.MAX_BETA)
		$"info/vbox/storage/gamma".text = "γ: "+str(n_build_res.MAX_GAMMA)
		# upkeep
		$"info/vbox/upkeep".text = "E: "+str(n_build_res.ENERGY_COST)
	else:
		$"info/build".visible = false
		$"info/build_type".visible = true
		
		$"info/build_type/alpha".disabled = !check_if_buildable(a_build_res)
		$"info/build_type/beta".disabled = !check_if_buildable(b_build_res)
		$"info/build_type/gamma".disabled = !check_if_buildable(g_build_res)
		
		$info/vbox/cost.visible = false
		$info/vbox/prod.visible = false
		$info/vbox/storage.visible = false
		$info/vbox/e_cost.visible = false
		$info/vbox/any_cost.visible = false
		$info/vbox/any_prod.visible = true
		$info/vbox/any_storage.visible = true
		
		$info/vbox/any_cost.text = "α·β·γ: "+str(a_build_res.BUILD_ALPHA)
		$info/vbox/any_prod.text = "α·β·γ: "+str(a_build_res.PROD_ALPHA)
		$info/vbox/any_storage.text = "α·β·γ: "+str(a_build_res.MAX_ALPHA)
		
		if a_build_res.BUILD_ALPHA > 0:
			$"info/vbox/any_cost".visible = true
			$"info/vbox/any_cost".text = "α·β·γ: "+str(a_build_res.BUILD_ALPHA)
		
		if a_build_res.BUILD_ENERGY > 0:
			$"info/vbox/e_cost".visible = true
			$"info/vbox/e_cost".text = "E: "+str(a_build_res.BUILD_ENERGY)
		
		$"info/vbox/upkeep".text = "E: "+str(a_build_res.ENERGY_COST)
func _on_visibility_changed() -> void:
	if has_res:
		refresh_info()
