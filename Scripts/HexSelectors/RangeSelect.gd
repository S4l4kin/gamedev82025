extends HexSelect
class_name RangeHexSelect

var max_range : int
var min_range : int
var origin : Vector2i
var accepted_distance : Array[Vector2i]

var press_check : Callable
var default_press_check : Callable = (func (_x: int, _y: int) -> bool: return true )

func _init(_x:int, _y:int, _max_range:int, _min_range:int, _callable: Callable, _press_check: Callable = default_press_check) -> void:
	origin.x = _x
	origin.y = _y
	max_range = _max_range
	min_range = _min_range
	callable = _callable
	press_check = _press_check

func _ready():
	board.connect("hex_pressed", pressed)
	board.connect("mouse_entered_hex", hex_entered)
	board.connect("mouse_exited_hex", hex_exited)
	outline.add_layer("range_select", 1.25)

	var neighbours = get_distant_neighbours([board.get_hex(origin.x, origin.y)], max_range)
	for hex in neighbours:
		var origin_cube = HexGridUtil.coord_to_cube(origin.x, origin.y, board.orientation)
		var hex_cube = HexGridUtil.coord_to_cube(hex.coord.x, hex.coord.y,  board.orientation)
		if HexGridUtil.cube_distance(origin_cube, hex_cube) <= max_range and HexGridUtil.cube_distance(origin_cube, hex_cube) >= min_range:
			accepted_distance.append(hex.coord) 
	
	set_accepted_distance_color(Color.BLUE)

func hex_entered(hex_x : int, hex_y : int):
	if accepted_distance.has(Vector2i(hex_x, hex_y)) and press_check.call(hex_x, hex_y):
		outline.set_hex_coord_outline("range_select", Vector2i(hex_x, hex_y),Color.GREEN)
	else:
		outline.set_hex_coord_outline("range_select", Vector2i(hex_x, hex_y), Color.RED)


func hex_exited(hex_x : int, hex_y : int):
	outline.set_hex_coord_outline("range_select",  Vector2i(hex_x, hex_y),Color.TRANSPARENT)

func pressed(pressed_x: int, pressed_y:int):
	done_selecting()
	outline.set_hex_coord_outline("range_select", Vector2i(pressed_x, pressed_y),Color.TRANSPARENT)
	set_accepted_distance_color(Color.TRANSPARENT)
	if accepted_distance.has(Vector2i(pressed_x, pressed_y)) and press_check.call(pressed_x, pressed_y):
		callable.call(pressed_x, pressed_y)


func get_distant_neighbours(check_neihbours: Array[Hex], distance: int, all_neighbours: Array[Hex] = check_neihbours.duplicate()) -> Array[Hex]:
	if distance <= 0:
		return all_neighbours
	print("Distance %s"%distance)
	print("Check Neightbours len %s"%len(check_neihbours))
	var new_check_neighbours : Array[Hex] = []
	for hex in check_neihbours:
		var local_neighbours = board.get_neighbours(hex.coord.x, hex.coord.y)
		print("Neigbour Count %s"%len(local_neighbours))
		for neighbour in local_neighbours:
			if not all_neighbours.has(neighbour):
				new_check_neighbours.append(neighbour)
				all_neighbours.append(neighbour)
	
	return get_distant_neighbours(new_check_neighbours, distance-1, all_neighbours)

func set_accepted_distance_color(color: Color):
	for coord in accepted_distance:
		outline.set_hex_coord_outline("ui", coord, color)
