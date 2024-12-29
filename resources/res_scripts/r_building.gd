extends Resource
class_name r_building

enum ALIGNMENT {NEUTRAL, ALPHA, BETA, GAMMA}

@export var CODE: String
@export var DISPLAY_NAME: String
@export var TYPE: ALIGNMENT
@export var MAX_HP: int
@export var ENERGY_COST: int # energy cost requirement to run building (per day)

# storage
@export_category("Storage")
@export var MAX_ENERGY: int
@export var MAX_ALPHA: int
@export var MAX_BETA: int
@export var MAX_GAMMA: int

# production (per day)
@export_category("Production (Per Day)")
@export var PROD_ENERGY: int
@export var PROD_ALPHA: int
@export var PROD_BETA: int
@export var PROD_GAMMA: int

# build costs
@export_category("Build Costs")
@export var BUILD_ENERGY: int
@export var ANY_MATTER: int
@export var BUILD_ALPHA: int
@export var BUILD_BETA: int
@export var BUILD_GAMMA: int
