extends Resource
class_name r_building

enum ALIGNMENT {NEUTRAL, ALPHA, BETA, GAMMA}

@export var TYPE: ALIGNMENT
@export var MAX_HP: int
@export var ENERGY_COST: int # energy cost requirement per turn to run building

@export var MAX_ENERGY: int
@export var MAX_ALPHA: int
@export var MAX_BETA: int
@export var MAX_GAMMA: int
