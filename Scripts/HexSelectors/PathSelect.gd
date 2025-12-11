extends HexSelect
class_name PathHexSelect


var path : Array[Vector2i]
var selecting : bool = false
@onready var board : BoardManager = GameManager.board_manager
@onready var outline : Outline = GameManager.board_manager.outline

func _init(_x:int, _y:int, _range:int, _callable: Callable) -> void:
	origin = Vector2i(_x, _y)
	hex_range = _range+1
	callable = _callable

func _ready() -> void:
	board.connect("mouse_entered_hex", move_selec)

func move_selec(new_x:int, new_y:int):
	if selecting :
		if len(path) >= 2:
			if path[-2].x == new_x and path[-2].y == new_y:
				remove_top_from_path()
			else:
				if (path[-1].x != new_x or path[-1].y != new_y) and hex_range > 0:
					add_to_path(new_x, new_y)
		elif hex_range > 0:
			add_to_path(new_x, new_y)

func add_to_path(hex_x:int, hex_y:int ):
	path.append(Vector2i(hex_x,hex_y))
	hex_range -= 1
	outline.set_hex_outline("ui",board.get_hex(hex_x,hex_y),Color.LIME_GREEN)


func remove_top_from_path():
	var removed = path.pop_back()
	hex_range += 1
	outline.set_hex_outline("ui",board.get_hex(removed.x, removed.y),Color.TRANSPARENT)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if board.current_hovered_hex.x == origin.x and board.current_hovered_hex.y == origin.y:
					selecting = true
					add_to_path(origin.x, origin.y)
			else:
				if selecting:
					callable.call(path.duplicate())

					selecting = false
					
					for hex in path:
						outline.set_hex_outline("ui",board.get_hex(hex.x, hex.y),Color.TRANSPARENT)
					done_selecting()
