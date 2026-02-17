extends Node
class_name MushroomNetworkUtil

static var instance : MushroomNetworkUtil

var teleport_locations : Array[Vector2i]
var teleport_radius : int = 0
@onready var board = GameManager.board_manager

func _ready():
	instance = self

func add_teleport_location(coord: Vector2i):
	teleport_locations.append(coord)

func remove_teleport_location(coord: Vector2i):
	teleport_locations.erase(coord)

func teleport(unit: Unit, from_hex: Hex, to_hex: Hex):
	to_hex.unit = unit
	from_hex.unit = null
	unit.global_position = to_hex.position
	unit.x = to_hex.coord.x
	unit.y = to_hex.coord.y
