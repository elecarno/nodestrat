class_name Building
extends Node

@onready var objects: Node = get_parent()
@onready var world_node: WorldNode = get_parent().get_parent()

enum ALIGNMENT {NEUTRAL, ALPHA, BETA, GAMMA}

var id: int = randi()
var type: String = "test_building"
var pos: Vector2 = Vector2.ZERO
var rot: int = 0
var faction: String = ""

var TERRAIN_ALIGNMENT: ALIGNMENT
var production_efficiency: float = 1.0

var stored_energy: int = 0
var stored_alpha: int = 0
var stored_beta: int = 0
var stored_gamma: int = 0
var hp: int = 25

var connections: Array = [] # stores object ids

# assignments from resource
var MAX_HP: int
var ENERGY_COST: int
var WIDTH: int
var HEIGHT: int
var MAX_ENERGY: int
var MAX_ALPHA: int
var MAX_BETA: int
var MAX_GAMMA: int
var PROD_ENERGY: int
var PROD_ALPHA: int
var PROD_BETA: int
var PROD_GAMMA: int

func _ready() -> void:
	name = type + " (%s)" % [id]
	
	MAX_HP = res_refs.buildings[type].MAX_HP
	TERRAIN_ALIGNMENT = res_refs.buildings[type].TYPE
	WIDTH = res_refs.buildings[type].WIDTH
	HEIGHT = res_refs.buildings[type].HEIGHT
	ENERGY_COST = res_refs.buildings[type].ENERGY_COST
	MAX_ENERGY = res_refs.buildings[type].MAX_ENERGY
	MAX_ALPHA = res_refs.buildings[type].MAX_ALPHA
	MAX_BETA = res_refs.buildings[type].MAX_BETA
	MAX_GAMMA = res_refs.buildings[type].MAX_GAMMA
	PROD_ENERGY = res_refs.buildings[type].PROD_ENERGY
	PROD_ALPHA = res_refs.buildings[type].PROD_ALPHA
	PROD_BETA = res_refs.buildings[type].PROD_BETA
	PROD_GAMMA = res_refs.buildings[type].PROD_GAMMA
	
	world_node.subtract_resource("ENERGY", res_refs.buildings[type].BUILD_ENERGY)
	world_node.subtract_resource("ALPHA", res_refs.buildings[type].BUILD_ALPHA)
	world_node.subtract_resource("BETA", res_refs.buildings[type].BUILD_BETA)
	world_node.subtract_resource("GAMMA", res_refs.buildings[type].BUILD_GAMMA)
	
	hp = MAX_HP
	
	if type == "fortress":
		stored_energy = 500
		#stored_alpha = 250 # DEBUG
	
func day_tick():
	print("---")
	print("running daytick on building " + str(id))
	if use_energy():
		add_production()
		#var on_terrain: Vector2 = world_node.tilemap_data["ground_tiles"][pos]
		#if TERRAIN_ALIGNMENT == ALIGNMENT.NEUTRAL:
			#add_production()
		#if TERRAIN_ALIGNMENT == ALIGNMENT.ALPHA and on_terrain == Vector2(1, 0):
			#add_production()
		#if TERRAIN_ALIGNMENT == ALIGNMENT.BETA and on_terrain == Vector2(2, 0):
			#add_production()
		#if TERRAIN_ALIGNMENT == ALIGNMENT.GAMMA and on_terrain == Vector2(3, 0):
			#add_production()
	else:
		print("building %s cannot get enough energy to function" % [id])
	print("---")

func use_energy():
	var to_take: int = ENERGY_COST
	
	if PROD_ENERGY > 0:
		return true
	
	var conn_object: Building = null
	for j in range(0, objects.get_child_count()):
		conn_object = objects.get_child(j)
			
		if conn_object.stored_energy > 0:
			if conn_object.stored_energy >= to_take:
				objects.get_child(j).stored_energy -= to_take
				to_take = 0
			elif conn_object.stored_energy < to_take:
				to_take -= objects.get_child(j).stored_energy
				objects.get_child(j).stored_energy = 0
	
	if to_take == 0:
		return true
	else:
		return false
	
func add_production():
	if stored_energy == MAX_ENERGY:
		var transfers = get_transfers("ENERGY", PROD_ENERGY)
		print("added energy prod " + str(PROD_ENERGY) + " (transfer)")
		if transfers != {}:
			for id in transfers:
				for i in range(0, objects.get_child_count()):
					if objects.get_child(i).id == id:
						objects.get_child(i).stored_energy += transfers[id]
	else:
		print("added energy prod "  + str(PROD_ENERGY))
		stored_energy += PROD_ENERGY
		if stored_energy > MAX_ENERGY: stored_energy = MAX_ENERGY
	
	if stored_alpha == MAX_ALPHA:
		var transfers = get_transfers("ALPHA", PROD_ALPHA)
		print("added alpha prod " + str(PROD_ALPHA) + " (transfer)")
		if transfers != {}:
			for id in transfers:
				for i in range(0, objects.get_child_count()):
					if objects.get_child(i).id == id:
						objects.get_child(i).stored_alpha += transfers[id]
	else:
		print("added alpha prod " + str(PROD_ALPHA))
		stored_alpha += PROD_ALPHA
		if stored_alpha > MAX_ALPHA: stored_alpha = MAX_ALPHA
	
	if stored_beta == MAX_BETA:
		var transfers = get_transfers("BETA", PROD_BETA)
		print("added beta prod " + str(PROD_BETA) + " (transfer)")
		if transfers != {}:
			for id in transfers:
				for i in range(0, objects.get_child_count()):
					if objects.get_child(i).id == id:
						objects.get_child(i).stored_beta += transfers[id]
	else:
		print("added beta prod " + str(PROD_BETA))
		stored_beta += PROD_BETA
		if stored_beta > MAX_BETA: stored_beta = MAX_BETA
	
	if stored_gamma == MAX_GAMMA:
		var transfers = get_transfers("BETA", PROD_GAMMA)
		print("added gamma prod " + str(PROD_GAMMA) + " (transfer)")
		if transfers != {}:
			for id in transfers:
				for i in range(0, objects.get_child_count()):
					if objects.get_child(i).id == id:
						objects.get_child(i).stored_gamma += transfers[id]
	else:
		print("added gamma prod " + str(PROD_GAMMA))
		stored_gamma += PROD_GAMMA
		if stored_gamma > MAX_GAMMA: stored_gamma = MAX_GAMMA
	
func get_transfers(res: String, amount: int):
	var to_transfer = amount
	var transfers: Dictionary = {}
	
	# get reference to connection object
	var conn_object: Building = null
	for j in range(0, objects.get_child_count()):
		#print(str(objects.get_child(j).id) + " : " + str(connections[i]))
		conn_object = objects.get_child(j)
			
		# check for resource type
		var free_space
		if res == "ENERGY":
			free_space = conn_object.MAX_ENERGY - conn_object.stored_energy
		elif res == "ALPHA":
			free_space = conn_object.MAX_ALPHA - conn_object.stored_alpha
		elif res == "BETA":
			free_space = conn_object.MAX_BETA - conn_object.stored_beta
		elif res == "GAMMA":
			free_space == conn_object.MAX_GAMMA - conn_object.stored_gamma
			
		if free_space == 0:
			transfers[conn_object.id] = 0
		elif free_space < to_transfer:
			transfers[conn_object.id] = abs(free_space - to_transfer)
			to_transfer -= free_space
		elif free_space >= to_transfer:
			transfers[conn_object.id] = to_transfer
			to_transfer = 0
				
	return transfers
