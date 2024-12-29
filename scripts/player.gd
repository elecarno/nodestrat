class_name Player
extends Node

@onready var lobby: Control = get_node("../../canvas_layer/lobby/lobby_container/lobby_vbox")
@onready var main: Node = get_tree().get_root().get_node("main")
@onready var world: Node3D = get_parent().get_parent().get_node("world_map/world")
@onready var ui: Control = get_parent().get_parent().get_node("canvas_layer/ui")

var client_id: int = 0
var is_client: bool = false
@export var player_name: String = "Player"
@export var faction_name: String = "PLAYER FACTION"
@export var faction_colour: Color = Color(0.8, 0.8, 0.8, 1)
var has_lobby_entry: bool = false
var is_ready: bool = false

# init functions
func _ready() -> void:
	var name_edit: LineEdit = main.get_node("canvas_layer/menu/name")
	
	name = str(client_id)
	if is_multiplayer_authority():
		is_client = true
		get_parent().get_parent().client_id = client_id
		if name_edit.text == "":
			player_name = "Player"
		else:
			player_name = name_edit.text
		
	for i in range(0, lobby.get_child_count()):
		if lobby.get_child(i).client_id == 0 and not has_lobby_entry:
			lobby.get_child(i).client_id = client_id
			lobby.get_child(i).player_name = player_name
			lobby.get_child(i).visible = true
			lobby.get_child(i).init_entry()
			has_lobby_entry = true
	
func update_faction_label():
	if is_multiplayer_authority():
		main.get_node("game_controller/canvas_layer/ui/faction_info/name").text = faction_name
		main.get_node("game_controller/canvas_layer/ui/faction_info/name").set("theme_override_colors/font_color", faction_colour)

# game functions
func update_player_data():
	ui_refresh_resources(
		get_total_resources(), 
		get_total_storage(),
	 	get_total_production()
	)

# get combined storage totals for all resources
func get_total_storage():
	var total_storage: Dictionary = {
		"MAX_ENERGY": 0,
		"MAX_ALPHA": 0,
		"MAX_BETA": 0,
		"MAX_GAMMA": 0
	}
	
	for node in world.get_children():
		if node.node_data["faction"] == faction_name:
			var objects = node.get_node("objects").get_children()
			for object in objects:
				if object is Building:
					total_storage["MAX_ENERGY"] += object.MAX_ENERGY
					total_storage["MAX_ALPHA"] += object.MAX_ALPHA
					total_storage["MAX_BETA"] += object.MAX_BETA
					total_storage["MAX_GAMMA"] += object.MAX_GAMMA
	
	return total_storage
	
func get_total_production():
	var total_prod: Dictionary = {
		"PROD_ENERGY": 0,
		"PROD_ALPHA": 0,
		"PROD_BETA": 0,
		"PROD_GAMMA": 0
	}
	
	for node in world.get_children():
		if node.node_data["faction"] == faction_name:
			var objects = node.get_node("objects").get_children()
			for object in objects:
				if object is Building:
					total_prod["PROD_ENERGY"] += object.PROD_ENERGY
					total_prod["PROD_ALPHA"] += object.PROD_ALPHA
					total_prod["PROD_BETA"] += object.PROD_BETA
					total_prod["PROD_GAMMA"] += object.PROD_GAMMA
	
	return total_prod
	
func get_total_resources():
	var total_res: Dictionary = {
		"stored_energy": 0,
		"stored_alpha": 0,
		"stored_beta": 0,
		"stored_gamma": 0
	}
	
	for node in world.get_children():
		if node.node_data["faction"] == faction_name:
			var objects = node.get_node("objects").get_children()
			for object in objects:
				if object is Building:
					total_res["stored_energy"] += object.stored_energy
					total_res["stored_alpha"] += object.stored_alpha
					total_res["stored_beta"] += object.stored_beta
					total_res["stored_gamma"] += object.stored_gamma
	
	return total_res
	
# ui update functions
func ui_refresh_resources(total_res, total_storage, total_prod):
	ui.get_node("faction_info/energy").text = "%s / %s (+%s)" % [
		format_suffix(total_res["stored_energy"]),
		format_suffix(total_storage["MAX_ENERGY"]),
		format_suffix(total_prod["PROD_ENERGY"])]
	ui.get_node("faction_info/alpha").text = "%s / %s (+%s)" % [
		format_suffix(total_res["stored_alpha"]),
		format_suffix(total_storage["MAX_ALPHA"]),
		format_suffix(total_prod["PROD_ALPHA"])]
	ui.get_node("faction_info/beta").text = "%s / %s (+%s)" % [
		format_suffix(total_res["stored_beta"]),
		format_suffix(total_storage["MAX_BETA"]),
		format_suffix(total_prod["PROD_BETA"])]
	ui.get_node("faction_info/gamma").text = "%s / %s (+%s)" % [
		format_suffix(total_res["stored_gamma"]),
		format_suffix(total_storage["MAX_GAMMA"]),
		format_suffix(total_prod["PROD_GAMMA"])]
	
# util function
func format_suffix(number: float) -> String:
	if number >= 1_000_000:
		return str(round(number / 1_000_000)) + "M"
	elif number >= 1_000:
		return str(round(number / 1_000)) + "K"
	else:
		return str(number)
