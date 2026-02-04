extends HexSelect
class_name PathHexSelect


var path : Array[Vector2i]
var selecting : bool = false
var path_length : int
var press_check : Callable
var default_press_check = ( func(_x: int, _y:int) -> bool: return true )
var path_check : Callable
var default_path_check = ( func(_path: Array[Vector2i]) -> bool: return true )

func _init(_range:int, _callable: Callable, _press_check: Callable = default_press_check, _path_check: Callable = default_path_check, _cancel_callable: Callable = empty_callable) -> void:
	path_length = _range
	callable = _callable
	cancel_callable = _cancel_callable
	press_check = _press_check
	path_check = _path_check

func _ready() -> void:
	board.connect("mouse_entered_hex", hex_entered)
	board.connect("mouse_exited_hex", hex_exited)
	board.connect("hex_pressed", hex_pressed)

func hex_exited(hex_x: int, hex_y: int):
	if len(path) == 0:
		outline.set_hex_coord_outline("ui", Vector2i(hex_x, hex_y), Color.TRANSPARENT)

func hex_entered(hex_x: int, hex_y: int):
	if len(path) == 0:
		if press_check.call(hex_x, hex_y):
			outline.set_hex_coord_outline("ui", Vector2i(hex_x, hex_y), Color.GREEN)
		else:
			outline.set_hex_coord_outline("ui", Vector2i(hex_x, hex_y), Color.RED)
		return

	#Check if path is adjecent to last hex in path
	var last_hex = path[-1]
	if not board.get_neighbours(last_hex.x, last_hex.y).has(board.get_hex(hex_x, hex_y)):
		return
	var coord = Vector2i(hex_x, hex_y)
	print(path[-1])
	
	if len(path) >= 2:
		if coord == path[-2]:
			var removed_hex = path.pop_back()
			outline.set_hex_coord_outline("ui", removed_hex, Color.TRANSPARENT)
			path_length += 1
		elif path_length > 0:
			path.append(coord)
			path_length -= 1
	elif path_length > 0:
		path.append(coord)
		path_length -= 1

	if path_check.call(path):
		set_path_color(Color.GREEN)
	else:
		set_path_color(Color.RED)

func hex_pressed(hex_x: int, hex_y: int):
	if press_check.call(hex_x, hex_y):
		path.append(Vector2i(hex_x, hex_y))
		set_path_color(Color.GREEN)
	else:
		done_selecting()
		outline.set_hex_coord_outline("ui", Vector2i(hex_x, hex_y), Color.TRANSPARENT)

func set_path_color(color: Color):
	for coord in path:
		outline.set_hex_coord_outline("ui", coord, color)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			set_path_color(Color.TRANSPARENT)
			if path_check.call(path):
				callable.call(path)
			else:
				cancel_callable.call()
			done_selecting()
