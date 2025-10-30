class_name BoardGenerator
enum HEX_ROTATION {Flat_Top, Pointy_Top}

var hex_tile = preload("res://Scenes/HexTile.tscn")

var grid_scale : float = 1

var horiz_spacing : float
var vert_spacing : float
var orientation : HEX_ROTATION
var board_manager : BoardManager
	

func _init(_board_manager, _orientation, _scale) -> void:
	board_manager = _board_manager
	orientation = _orientation
	grid_scale = _scale
	
	if orientation == HEX_ROTATION.Flat_Top:
		horiz_spacing = grid_scale * 3/2
		vert_spacing = sqrt(3) * grid_scale
	elif orientation == HEX_ROTATION.Pointy_Top:
		horiz_spacing = sqrt(3) * grid_scale
		vert_spacing = grid_scale * 3/2

func create_hex_tile(x:int, y:int) -> MeshInstance3D:
	var tile = hex_tile.instantiate()

	tile.name = str(x) + " , " + str(y)

	var hex_position : Vector3
	tile.scale = Vector3.ONE * grid_scale

	tile.connect("pressed", board_manager.emit_signal.bind("hex_pressed", x, y))
	tile.connect("mouse_entered", board_manager.emit_signal.bind("mouse_entered_hex", x, y))
	tile.connect("mouse_exited", board_manager.emit_signal.bind("mouse_exited_hex", x, y))


	if orientation == HEX_ROTATION.Pointy_Top:
		tile.rotation_degrees = Vector3(-90,0,0)

		if posmod(y,2) == 0:
			hex_position = Vector3(horiz_spacing*x+horiz_spacing/2,0,vert_spacing*y)
		else:
			hex_position = Vector3(horiz_spacing*x,0,vert_spacing*y)

	elif orientation == HEX_ROTATION.Flat_Top:
		tile.rotation_degrees = Vector3(-90,90,0)

		if posmod(x,2) == 0:
			hex_position = Vector3(horiz_spacing * x, 0 ,vert_spacing * y + vert_spacing / 2)
		else:
			hex_position = Vector3(horiz_spacing * x, 0 ,vert_spacing * y)
		
	tile.position = hex_position
	return tile
