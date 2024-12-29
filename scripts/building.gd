class_name Building
extends Node

@onready var objects: Node = get_parent()

var id: int = randi()
var type: String = "test_building"
var pos: Vector2 = Vector2.ZERO
var faction: String = ""

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
	MAX_HP = res_refs.buildings[type].MAX_HP
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
	add_production()
	print("---")
	
func add_production():
	#if stored_energy == MAX_ENERGY:
		#var to_transfer = PROD_ENERGY
		#while to_transfer > 0:
			#var nearest_transfer_idx = get_nearest_transfer("ENERGY")
			#var transfer_object = objects.get_child(nearest_transfer_idx)
			#var transferable_amount: int = transfer_object.MAX_ENERGY - transfer_object.stored_energy
			#if transferable_amount > to_transfer:
				#objects.get_child(nearest_transfer_idx).stored_energy += to_transfer
				#to_transfer = 0
			#else:
				#objects.get_child(nearest_transfer_idx).stored_energy += transferable_amount
				#to_transfer -= transferable_amount
	#else:
		#print("added energy prod")
		#stored_energy += PROD_ENERGY
		#if stored_energy > MAX_ENERGY: stored_energy = MAX_ENERGY
	
	print("added energy prod " + str(PROD_ENERGY))
	stored_energy += PROD_ENERGY
	if stored_energy > MAX_ENERGY: stored_energy = MAX_ENERGY
	
	print("added alpha prod " + str(PROD_ALPHA))
	stored_alpha += PROD_ALPHA
	if stored_alpha > MAX_ALPHA: stored_alpha = MAX_ALPHA
	
	print("added beta prod " + str(PROD_BETA))
	stored_beta += PROD_BETA
	if stored_beta > MAX_BETA: stored_beta = MAX_BETA
	
	print("added gamma prod " + str(PROD_GAMMA))
	stored_gamma += PROD_GAMMA
	if stored_gamma > MAX_GAMMA: stored_gamma = MAX_GAMMA
	
func get_nearest_transfer(res: String):
	var highest_priority_object_idx: int = 0
	
	for i in range(0, connections.size()):
		var conn_object
		for object in objects.get_children():
			if object.id == connections[i]:
				conn_object == object
			
		if conn_object.TRANSFER_PRIORITY > highest_priority_object_idx:
			if res == "ENERGY":
				if conn_object.stored_energy < conn_object.MAX_ENERGY:
					highest_priority_object_idx = i
			if res == "ALPHA":
				if conn_object.stored_alpha < conn_object.MAX_ALPHA:
					highest_priority_object_idx = i
			if res == "BETA":
				if conn_object.stored_beta < conn_object.MAX_BETA:
					highest_priority_object_idx = i
			if res == "GAMMA":
				if conn_object.stored_gamma < conn_object.MAX_GAMMA:
					highest_priority_object_idx = i
	
	return highest_priority_object_idx
