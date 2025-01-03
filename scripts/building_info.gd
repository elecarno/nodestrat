extends Control

var building: Building

func init_info():
	var res: r_building = res_refs.buildings[building.type]
	$title.text = res.DISPLAY_NAME
	
	$vbox/prod/energy.text = "E: +"+str(building.PROD_ENERGY)
	$vbox/prod/alpha.text = "α: +"+str(building.PROD_ALPHA)
	$vbox/prod/beta.text = "β: +"+str(building.PROD_BETA)
	$vbox/prod/gamma.text = "γ: +"+str(building.PROD_GAMMA)
	
	$vbox/storage/energy.text = "E: %s/%s" % [building.stored_energy, building.MAX_ENERGY]
	$vbox/storage/alpha.text = "α: %s/%s" % [building.stored_alpha, building.MAX_ALPHA]
	$vbox/storage/beta.text = "β: %s/%s" % [building.stored_beta, building.MAX_BETA]
	$vbox/storage/gamma.text = "γ: %s/%s" % [building.stored_gamma, building.MAX_GAMMA]
	
	$vbox/upkeep.text = "E: "+str(building.ENERGY_COST)
	
	var faction_peer_id = $"../../..".get_faction_peer_id(building.faction)
	var faction_colour = $"../../..".get_faction_colour(faction_peer_id)
	$vbox/faction.text = building.faction
	$vbox/faction.set("theme_override_colors/font_color", faction_colour)

func _on_exit_pressed() -> void:
	visible = false
