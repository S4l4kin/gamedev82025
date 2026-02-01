class_name TileGenerator
enum HEX_ROTATION {Flat_Top, Pointy_Top}

var hex_tile = preload("res://Scenes/HexTile.tscn")

var grid_scale : float = 1

var horiz_spacing : float
var vert_spacing : float
var orientation : HEX_ROTATION
var board_manager : BoardManager
var map_data : Dictionary[Vector2i, Dictionary]

var parent : Node
var tile_basis : Basis
func _init(_board_manager, _parent, _orientation, _scale, _data) -> void:
	board_manager = _board_manager
	orientation = _orientation
	grid_scale = _scale
	map_data = _data
	parent = _parent
	tile_basis = HexGridUtil.get_tile_basis(orientation)
	if orientation == HEX_ROTATION.Flat_Top:
		horiz_spacing = grid_scale * 3/2
		vert_spacing = sqrt(3) * grid_scale
	elif orientation == HEX_ROTATION.Pointy_Top:
		horiz_spacing = sqrt(3) * grid_scale
		vert_spacing = grid_scale * 3/2

func get_tile_pos(x:int, y:int) -> Vector3:
	if orientation == HEX_ROTATION.Pointy_Top:
		if posmod(y,2) == 0:
			return Vector3(horiz_spacing*x+horiz_spacing/2,0,vert_spacing*y)
		else:
			return Vector3(horiz_spacing*x,0,vert_spacing*y)

	elif orientation == HEX_ROTATION.Flat_Top:
		if posmod(x,2) == 0:
			return Vector3(horiz_spacing * x, 0 ,vert_spacing * y + vert_spacing / 2)
		else:
			return Vector3(horiz_spacing * x, 0 ,vert_spacing * y)
	return Vector3.ZERO

func create_hex_tile(x:int, y:int) -> Hex:
	var coord = Vector2i(x,y)
	var hex = Hex.new()

	var hex_position : Vector3 = get_tile_pos(x,y)
	

	#Create Tile object
	if map_data[coord].biome != "sea":
		var tile : Node3D = hex_tile.instantiate()
		parent.add_child(tile)

		tile.name = str(x) + " , " + str(y)

		tile.scale = Vector3.ONE * grid_scale

		tile.connect("pressed", board_manager.emit_signal.bind("hex_pressed", x, y))
		tile.connect("mouse_entered", board_manager.emit_signal.bind("mouse_entered_hex", x, y))
		tile.connect("mouse_exited", board_manager.emit_signal.bind("mouse_exited_hex", x, y))

		tile.global_basis = tile_basis

		#if orientation == HEX_ROTATION.Flat_Top:
		#	tile.rotation_degrees = Vector3(-90,90,0)
			
		tile.position = hex_position
		hex.tile = tile
	
	#Set Hex Data
	hex.position = hex_position
	hex.passable = true if map_data[coord].biome != "sea" else false
	hex.coord = coord
	
	return hex
