extends HexSelect
class_name RangeHexSelect

@onready var board : BoardManager = $"/root/Board"

func _init(_x:int, _y:int, _range:int, _callable: Callable) -> void:
	origin.x = _x
	origin.y = _y
	hex_range = _range
	callable = _callable

func _ready():
	board.connect("hex_pressed", pressed)

func pressed(pressed_x: int, pressed_y:int):
	var origin_cube = board.coord_to_cube(origin.x, origin.y)
	var pressed_cube = board.coord_to_cube(pressed_x, pressed_y)
	call_deferred("free")

	if cube_distance(origin_cube, pressed_cube) <= hex_range:
		
		callable.call(pressed_x, pressed_y)

func cube_subtract(a, b):
	return {"q": a.q - b.q, "r": a.r - b.r, "s": a.s - b.s}

func cube_distance(a, b):
	var vec = cube_subtract(a, b)
	return (abs(vec.q) + abs(vec.r) + abs(vec.s)) / 2
