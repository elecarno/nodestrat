class_name GameController
extends Node

var client_id = 0

@onready var players: Node = get_node("players")
@onready var world_map: WorldMap = get_node("world_map")
@onready var node_map: NodeMap = get_node("node_map")

@onready var orbit_cam: Camera3D = get_node("world_map/cam_gimbal/pivot/cam")
@onready var pan_cam: Camera2D = get_node("node_map/pan_cam/cam")
@onready var timestamp: Label = get_node("canvas_layer/ui/time_control/timestamp")
@onready var speedstamp: Label = get_node("canvas_layer/ui/time_control/speedstamp")
@onready var node_info: Control = get_node("canvas_layer/ui/node_info")
@onready var ui: Control = get_node("canvas_layer/ui")
@onready var lobby: Control = get_node("canvas_layer/lobby")

@export var tick: int = 24 # used for game calculations
var last_day_tick: int = floor(tick/24)
var current_day_tick: int # used for day based game calculations
var time: float = 24 # used to add to tick
@export var time_multiplier: float = 1 # game speed, 1.0 = 1 tick per second
var stage: int = 1
const time_max: float = 30
const time_min: float = 0.5
@export var paused: bool = true

var build_button_group: ButtonGroup = ButtonGroup.new()

func _ready() -> void:
	# set ui element starting visibilities
	get_node("canvas_layer/crt").visible = true
	ui.visible = false
	lobby.visible = true
	get_node("canvas_layer/ui/build").visible = false
	
	# set build buttons 
	for button in range(0, $canvas_layer/ui/build/vbox.get_child_count()):
		$canvas_layer/ui/build/vbox.get_child(button).button_group = build_button_group
	
	# set starting condition line edits to defaults from world_map
	$canvas_layer/lobby/settings/seed/edit.text = str(randi())
	$canvas_layer/lobby/settings/size/edit.text = str(world_map.world_size)
	$canvas_layer/lobby/settings/radius/edit.text = str(world_map.world_radius)
	$canvas_layer/lobby/settings/max_conn/edit.text = str(world_map.max_connections_per_node)
	$canvas_layer/lobby/settings/conn_thres/edit.text = str(world_map.connection_threshold)
	$canvas_layer/lobby/settings/min_node/edit.text = str(world_map.min_node_size)
	$canvas_layer/lobby/settings/max_node/edit.text = str(world_map.max_node_size)
	
	# disable start button for everyone but host
	if multiplayer.get_unique_id() != 1:
		$canvas_layer/lobby/start.visible = false
		
	# disable speed buttons for everyone but host
	if multiplayer.get_unique_id() != 1:
		ui.get_node("time_control/speed_up").visible = false
		ui.get_node("time_control/speed_down").visible = false
	
func _process(delta: float) -> void:
	# handle speedstamp and timestamp text
	timestamp.text = format_time()
	if paused:
		speedstamp.text = "||"
	else:
		speedstamp.text = str(time_multiplier) + "x"
	
	# handle pausing
	if Input.is_action_just_pressed("pause"):
		toggle_pause.rpc()
	
	# run tick
	if not paused:
		run_tick.rpc(delta)
		
	# handle crt effect toggle
	if Input.is_action_just_pressed("crt_toggle"):
		get_node("canvas_layer/crt").visible = !get_node("canvas_layer/crt").visible

	# handle camera switching between world and node maps
	if Input.is_action_just_pressed("map"):
		switch_cams()
	
	if Input.is_action_just_pressed("esc"):
		world_map.visible = true
		node_map.visible = false
		orbit_cam.current = true
		pan_cam.enabled = false
		
	# handle toggle build menu
	if Input.is_action_just_pressed("build") and node_map.visible:
		get_node("canvas_layer/ui/build").visible = !get_node("canvas_layer/ui/build").visible

# run tick on all clients
@rpc("any_peer", "call_local")
func run_tick(delta):
	time += (delta * time_multiplier)
	tick = floor(time)
	current_day_tick = floor(tick/24)
	day_tick()

func day_tick():
	if current_day_tick > last_day_tick:
		print("running daytick " + str(current_day_tick))
		
		var world = world_map.get_node("world")
		for node in range(0, world.get_child_count()):
			world_map.get_node("world").get_child(node).day_tick()
		
		update_player_data()
		
		last_day_tick = current_day_tick

# handle pause on all clients
@rpc("any_peer", "call_local")
func toggle_pause():
	paused = !paused
	print("pause set to " + str(paused))

# handle camera switching between world and node maps
# bundled into a function because it is sometimes called by other nodes
func switch_cams():
	world_map.visible = !world_map.visible
	node_map.visible = !node_map.visible
	orbit_cam.current = !orbit_cam.current
	pan_cam.enabled = !pan_cam.enabled
	
	pan_cam.position = Vector2.ZERO
	pan_cam.zoom = Vector2.ONE
	
# format timestamp text
func format_time():
	var hours = tick % 24
	var days = int(tick/24)
	return "S%01d / %02d : %02d" % [stage, days, hours]
	
# handle time speed multiplier on all clients
@rpc("any_peer", "call_local")
func increase_speed():
	if time_multiplier < time_max:
		time_multiplier = floor(time_multiplier)
		if time_multiplier < 1:
			time_multiplier = 1
		elif time_multiplier < 10:
			time_multiplier += 9
		else:
			time_multiplier += 10
	
	if not paused:
		speedstamp.text = str(time_multiplier) + "x"
		
	print("increased speed to " + str(time_multiplier))
	
@rpc("any_peer", "call_local")
func decrease_speed():
	if time_multiplier > time_min:
		if time_multiplier == 1:
			time_multiplier = 0.5
		elif time_multiplier > 10:
			time_multiplier -= 10
		else:
			time_multiplier -= 9
			
	if not paused:
		speedstamp.text = str(time_multiplier) + "x"
	
	print("decreased speed to " + str(time_multiplier))

func _on_speed_up_pressed() -> void:
	increase_speed.rpc()

func _on_speed_down_pressed() -> void:
	decrease_speed.rpc()

# get faction info functions for other nodes to use
func get_faction(peer_id):
	for player in range(0, players.get_child_count()):
		if players.get_child(player).client_id == peer_id:
			return players.get_child(player).faction_name
			
func get_faction_colour(peer_id):
	for player in range(0, players.get_child_count()):
		if players.get_child(player).client_id == peer_id:
			return players.get_child(player).faction_colour
			
func get_faction_peer_id(faction):
	for player in range(0, players.get_child_count()):
		if players.get_child(player).faction_name == faction:
			return players.get_child(player).client_id

# player update calls
func update_player_data():
	for player in range(0, players.get_child_count()):
		if players.get_child(player).client_id == multiplayer.get_unique_id():
			players.get_child(player).update_player_data()

# toggle node infobox 
func toggle_node_info(node_name, node_data, res_info, vis):
	node_info.visible = vis
	node_info.get_node("name").text = node_name
	node_info.get_node("info").text = "Radius: %02d" % [node_data["size"]]
	if node_data["status"] == 0:
		node_info.get_node("info").text += "\nUnowned"
	elif node_data["status"] == 1:
		node_info.get_node("info").text += "\nOwned by " + node_data["faction"]
	elif node_data["status"] == 2:
		node_info.get_node("info").text += "\nContested"
	
	if get_faction_peer_id(node_data["faction"]) == multiplayer.get_unique_id() and vis:
		node_info.get_node("energy").text = res_info["energy"]
		node_info.get_node("alpha").text = res_info["alpha"] 
		node_info.get_node("beta").text = res_info["beta"]
		node_info.get_node("gamma").text = res_info["gamma"]
	else:
		node_info.get_node("energy").text = "E: ???"
		node_info.get_node("alpha").text = "α: ???"
		node_info.get_node("beta").text = "β: ???"
		node_info.get_node("gamma").text = "γ: ???"
		
# ui text formatting
func ui_format_resource_texts(total_res, total_storage, total_prod):
	var texts: Dictionary = {
		"energy": "",
		"alpha": "",
		"beta": "",
		"gamma": ""
	}
	
	texts["energy"] = "E:%s/%s(+%s)" % [
		format_suffix(total_res["stored_energy"]),
		format_suffix(total_storage["MAX_ENERGY"]),
		format_suffix(total_prod["PROD_ENERGY"])]
	texts["alpha"] = "α:%s/%s(+%s)" % [
		format_suffix(total_res["stored_alpha"]),
		format_suffix(total_storage["MAX_ALPHA"]),
		format_suffix(total_prod["PROD_ALPHA"])]
	texts["beta"] = "β:%s/%s(+%s)" % [
		format_suffix(total_res["stored_beta"]),
		format_suffix(total_storage["MAX_BETA"]),
		format_suffix(total_prod["PROD_BETA"])]
	texts["gamma"] = "γ:%s/%s(+%s)" % [
		format_suffix(total_res["stored_gamma"]),
		format_suffix(total_storage["MAX_GAMMA"]),
		format_suffix(total_prod["PROD_GAMMA"])]
		
	return texts

func format_suffix(number: float) -> String:
	if number >= 1_000_000:
		return str(round(number / 1_000_000)) + "M"
	elif number >= 1_000:
		return str(round(number / 1_000)) + "K"
	else:
		return str(number)

# handle starting game
@rpc("any_peer", "call_local")
func start_game():
	# check if all players are ready
	var all_players_ready: bool = true
	for i in range(0, players.get_child_count()):
		if !players.get_child(i).is_ready:
			all_players_ready = false
	
	# start game if all players are ready
	if all_players_ready:
		print("starting game")
		world_map.world_seed = int($canvas_layer/lobby/settings/seed/edit.text)
		world_map.world_size = int($canvas_layer/lobby/settings/size/edit.text)
		world_map.world_radius = int($canvas_layer/lobby/settings/radius/edit.text)
		world_map.max_connections_per_node = int($canvas_layer/lobby/settings/max_conn/edit.text)
		world_map.connection_threshold = int($canvas_layer/lobby/settings/conn_thres/edit.text)
		world_map.min_node_size = int($canvas_layer/lobby/settings/min_node/edit.text)
		world_map.max_connections_per_node = int($canvas_layer/lobby/settings/max_node/edit.text)
		lobby.visible = false
		ui.visible = true
		world_map.init_world()
		update_player_data()
	
func _on_start_pressed() -> void:
	start_game.rpc()
