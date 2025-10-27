extends Node
class_name BoardManager



var hexes = []

@export var conqured_hexes : Dictionary[String,Array]

@onready var outline_material = preload("res://Scripts/Shaders/new_shader_material.tres")

@export var orientation : BoardGenerator.HEX_ROTATION
@export var grid_width : int = 8
@export var grid_height : int = 8
@export var grid_scale : float = 1

@onready var board_generator : BoardGenerator = BoardGenerator.new(orientation, grid_scale)

func init_tiles():
	for i in grid_width:
		hexes.append([Hex])
		for j in grid_height:
			var hex_instance = board_generator.create_hex_tile(i,j)
			add_child(hex_instance)
			var hex = Hex.new()
			hex.tile = hex_instance

			hexes[i].append(hex)

func _ready():

	init_tiles()
	test(3,3)
	test(6,7)

func get_hex(x:int, y:int) -> Hex:
	return hexes[x][y]

func test(x:int, y:int):
	var center_mat = StandardMaterial3D.new()
	var neighbour_mat = StandardMaterial3D.new()
	center_mat.albedo_color = Color.SKY_BLUE
	neighbour_mat.albedo_color = Color.ORANGE_RED
	get_hex(x,y).tile.material_overlay = outline_material
	get_hex(x,y).tile.material_override = center_mat
	for hex in get_neighbours(x,y):
		hex.tile.material_override = neighbour_mat
		hex.tile.material_overlay = outline_material

func cube_to_coord(q:int,r:int):
	var parity : int
	var col :int
	var row : int
	if orientation == BoardGenerator.HEX_ROTATION.Pointy_Top:
		parity = r&1
		col = q + (r - parity) / 2
		row = r
	else:
		parity = q&1
		col = q
		row = r + (q + parity) / 2
	return {"x":col, "y":row}

func coord_to_cube(x:int,y:int):
	var parity : int
	var q :int
	var r : int
	if orientation == BoardGenerator.HEX_ROTATION.Pointy_Top:
		parity = y&1
		q = x - (y - parity) / 2
		r = y
	else:
		parity = y&1
		q = x	
		r = y - (x + parity) / 2
	return {"q":q, "r":r, "s":-q-r}


func get_neighbours(x:int, y:int) -> Array[Hex]:
	var neighbours : Array[Hex] = []
	var cube = coord_to_cube(x,y)
	var cube_neighbours = [{"q":cube.q+1,"r":cube.r},{"q":cube.q+1,"r":cube.r-1},{"q":cube.q,"r":cube.r-1},{"q":cube.q-1,"r":cube.r},{"q":cube.q-1,"r":cube.r+1},{"q":cube.q,"r":cube.r+1}]

	for neighbour in cube_neighbours:
		var coord = cube_to_coord(neighbour.q,neighbour.r)
		neighbours.append(get_hex(coord.x,coord.y))
	
	
	return neighbours

func get_unit(x:int, y:int) -> String:
	var unit = ""
	unit = hexes[x][y].unit
	return unit
