extends Resource
class_name r_building

enum ALIGNMENT {NEUTRAL, ALPHA, BETA, GAMMA}

@export var SPRITE: Texture2D

@export var CODE: String
@export var DISPLAY_NAME: String
@export var TYPE: ALIGNMENT
@export var MAX_HP: int
@export var ENERGY_COST: int # energy cost requirement to run building (per day)

# dimensions
@export_category("Dimensions")
@export var PIVOT_0: Vector2 = Vector2.ZERO
@export var PIVOT_90: Vector2 = Vector2.ZERO
@export var PIVOT_180: Vector2 = Vector2.ZERO
@export var PIVOT_270: Vector2 = Vector2.ZERO
@export var WIDTH: int = 1
@export var HEIGHT: int = 1

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
@export var BUILD_TIME: int = 1
@export var BUILD_ENERGY: int
@export var ANY_MATTER: int
@export var BUILD_ALPHA: int
@export var BUILD_BETA: int
@export var BUILD_GAMMA: int
