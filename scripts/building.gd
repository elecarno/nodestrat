class_name Building
extends Node

@onready var objects: Node = get_parent()

enum DESIGNATION {PRODUCTION, STORAGE, PIPELINE}
enum ALIGNMENT {NEUTRAL, ALPHA, BETA, GAMMA}

var id: int = randi()
var type: String = "test_building"
var pos: Vector2 = Vector2.ZERO
var faction: String = ""

var PURPOSE: DESIGNATION
var TERRAIN_ALIGNMENT: ALIGNMENT

var stored_energy: int = 0
var stored_alpha: int = 0
var stored_beta: int = 0
var stored_gamma: int = 0
var hp: int = 25

var connections: Array = [] # stores object ids

# assignments from resource
var MAX_HP: int
var ENERGY_COST: int
var MAX_ENERGY: int
var MAX_ALPHA: int
var MAX_BETA: int
var MAX_GAMMA: int
var PROD_ENERGY: int
var PROD_ALPHA: int
var PROD_BETA: int
var PROD_GAMMA: int
var TRANSFER_PRIORITY: int
var TRANSFER_RADIUS: int

func _ready() -> void:
	name = type + " (%s)" % [id]
	
	MAX_HP = res_refs.buildings[type].MAX_HP
	PURPOSE = res_refs.buildings[type].PURPOSE
	TERRAIN_ALIGNMENT = res_refs.buildings[type].TYPE
	ENERGY_COST = res_refs.buildings[type].ENERGY_COST
	MAX_ENERGY = res_refs.buildings[type].MAX_ENERGY
	MAX_ALPHA = res_refs.buildings[type].MAX_ALPHA
	MAX_BETA = res_refs.buildings[type].MAX_BETA
	MAX_GAMMA = res_refs.buildings[type].MAX_GAMMA
	PROD_ENERGY = res_refs.buildings[type].PROD_ENERGY
	PROD_ALPHA = res_refs.buildings[type].PROD_ALPHA
	PROD_BETA = res_refs.buildings[type].PROD_BETA
	PROD_GAMMA = res_refs.buildings[type].PROD_GAMMA
	TRANSFER_PRIORITY = res_refs.buildings[type].TRANSFER_PRIORITY
	TRANSFER_RADIUS = res_refs.buildings[type].TRANSFER_RADIUS
	
	hp = MAX_HP
	
	if type == "fortress":
		stored_energy = 500
	
func day_tick():
	print("---")
	print("running daytick on building " + str(id))
	if use_energy():
		if PURPOSE == DESIGNATION.PRODUCTION:
			add_production()
		elif PURPOSE == DESIGNATION.STORAGE:
			pass
		elif PURPOSE == DESIGNATION.PIPELINE:
			pass
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
		print(transfers)
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
		print(transfers)
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
		print(transfers)
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
		print(transfers)
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
