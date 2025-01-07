extends Node

var buildings: Dictionary = {
	"test_building": preload("res://resources/buildings/b_test.tres"),
	"fortress": preload("res://resources/buildings/b_fortress.tres"),
	"battery": preload("res://resources/buildings/b_battery.tres"),
	"tank": preload("res://resources/buildings/b_tank.tres"),
	"pylon": preload("res://resources/buildings/b_pylon.tres"),
	"powerplant": preload("res://resources/buildings/b_powerplant.tres"),
	"harvester_a": preload("res://resources/buildings/b_harvester_a.tres"),
	"harvester_b": preload("res://resources/buildings/b_harvester_b.tres"),
	"harvester_g": preload("res://resources/buildings/b_harvester_g.tres"),
	"factory_a": preload("res://resources/buildings/b_factory_a.tres"),
	"factory_b": preload("res://resources/buildings/b_factory_b.tres"),
	"factory_g": preload("res://resources/buildings/b_factory_g.tres")
}

var entities: Dictionary = {
	"scout_drone": preload("res://resources/entities/scout_drone.tres")
}

# defines defaults
var units: Dictionary = {
	# code: [entity_1, entity_2, entity_3, ...]
	"scout_party": 
		["scout_drone", "scout_drone", 
		"scout_drone", "scout_drone"]
}
