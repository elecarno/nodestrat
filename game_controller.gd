class_name GameController
extends Node

@export var player_scene: PackedScene
var peer = ENetMultiplayerPeer.new()
var port = 6868

@onready var players: Node = get_node("players")
@onready var world_map: Node3D = get_node("world_map")
@onready var node_map: Node2D = get_node("node_map")

@onready var orbit_cam: Camera3D = get_node("world_map/cam_gimbal/pivot/cam")
@onready var pan_cam: Camera2D = get_node("node_map/pan_cam/cam")
@onready var timestamp: Label = get_node("canvas_layer/ui/time_control/timestamp")
@onready var speedstamp: Label = get_node("canvas_layer/ui/time_control/speedstamp")
@onready var node_info: Control = get_node("canvas_layer/ui/node_info")
@onready var ui: Control = get_node("canvas_layer/ui")
@onready var menu: Control = get_node("canvas_layer/menu")

@export var tick: int = 24 # used for game calculations
var last_day_tick: int = floor(tick/24)
var current_day_tick: int # used for day based game calculations
var time: float = 24 # used to add to tick
@export var time_multiplier: float = 1 # game speed, 1.0 = 1 tick per second
var stage: int = 1
const time_max: float = 30
const time_min: float = 0.5
@export var paused: bool = false

func _ready() -> void:
	get_node("canvas_layer/crt").visible = true
	ui.visible = false
	menu.visible = true

func _process(delta: float) -> void:
	if paused:
		speedstamp.text = "||"
	else:
		speedstamp.text = str(time_multiplier) + "x"
	
	timestamp.text = format_time()
	ui.get_node("mp/playercount").text = "CONNECTED PEERS: " + str(players.get_child_count())
	
	if not is_multiplayer_authority():
		ui.get_node("time_control/speed_up").visible = false
		ui.get_node("time_control/speed_down").visible = false
	
	if Input.is_action_just_pressed("pause") and is_multiplayer_authority():
		paused = !paused
	
	if not paused:
		time += (delta * time_multiplier)
		tick = floor(time)
		current_day_tick = floor(tick/24)
		#nation_day_tick()
	
	if Input.is_action_just_pressed("map"):
		switch_cams()
		
	if Input.is_action_just_pressed("esc"):
		world_map.visible = true
		node_map.visible = false
		orbit_cam.current = true
		pan_cam.enabled = false

func switch_cams():
	world_map.visible = !world_map.visible
	node_map.visible = !node_map.visible
	orbit_cam.current = !orbit_cam.current
	pan_cam.enabled = !pan_cam.enabled
	
	pan_cam.position = Vector2.ZERO
	pan_cam.zoom = Vector2.ONE
	
func format_time():
	var hours = tick % 24
	var days = int(tick/24)
	return "S%01d / %02d : %02d" % [stage, days, hours]
	
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
	
#func nation_day_tick():
	#if current_day_tick > last_day_tick:
		#for n in nations:
			#n._add_gains()
		#emit_signal("daytick")
		#last_day_tick = current_day_tick

func toggle_node_info(name, node_data, vis):
	node_info.visible = vis
	node_info.get_node("name").text = name
	node_info.get_node("info").text = "Radius: %02d" % [node_data["size"]]
	if node_data["status"] == 0:
		node_info.get_node("info").text += "\nUnowned"
	elif node_data["status"] == 1:
		node_info.get_node("info").text += "\nOwned by " + node_data["owner"]
	elif node_data["status"] == 2:
		node_info.get_node("info").text += "\nContested"

func _on_speed_up_pressed() -> void:
	increase_speed()

func _on_speed_down_pressed() -> void:
	decrease_speed()


func _on_host_pressed() -> void:
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	ui.visible = true
	menu.visible = false
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	players.call_deferred("add_child", player)

func _on_join_pressed() -> void:
	peer.create_client("localhost", port)
	multiplayer.multiplayer_peer = peer
	ui.visible = true
	menu.visible = false
