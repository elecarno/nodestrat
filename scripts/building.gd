class_name Building
extends Node

var type: String = "test_building"
var pos: Vector2 = Vector2.ZERO
var faction: String = ""

var stored_energy: int = 0
var stored_alpha: int = 0
var stored_beta: int = 0
var stored_gamma: int = 0
var hp: int = 25

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
	
func day_tick():
	add_production()
	
func add_production():
	stored_energy += PROD_ENERGY
	if stored_energy > MAX_ENERGY: stored_energy = MAX_ENERGY
	stored_alpha += PROD_ALPHA
	if stored_energy > PROD_ALPHA: stored_alpha = PROD_ALPHA
	stored_beta += PROD_BETA
	if stored_beta > MAX_BETA: stored_beta = MAX_BETA
	stored_gamma += PROD_GAMMA
	if stored_gamma > MAX_GAMMA: stored_gamma = MAX_GAMMA
