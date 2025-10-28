extends Node
class_name BoardManager



var hexes = []

@export var conqured_hexes : Dictionary[String,Array]


@export var orientation : BoardGenerator.HEX_ROTATION
@export var grid_width : int = 8
@export var grid_height : int = 8
@export var grid_scale : float = 1

@onready var board_generator : BoardGenerator = BoardGenerator.new(orientation, grid_scale)
@onready var outline : Outline = Outline.new()

func init_tiles():
	for i in grid_width:
		var array : Array[Hex] = []
		hexes.append(array)
		for j in grid_height:
			var hex_instance = board_generator.create_hex_tile(i,j)
			add_child(hex_instance)
			var hex = Hex.new()
			hex.passable = true
			hex.tile = hex_instance

			hexes[i].append(hex)
			print(hexes[i][j].resource_name)

@onready var test_unit : Unit = $Sprite3D
var old_x 
var old_y

@onready var neighbour_mat = outline.get_outline(Color.ORANGE_RED)
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			var rng : RandomNumberGenerator = RandomNumberGenerator.new()
			var cube = coord_to_cube(old_x,old_y)
			var cube_neighbours = [{"q":cube.q+1,"r":cube.r},{"q":cube.q+1,"r":cube.r-1},{"q":cube.q,"r":cube.r-1},{"q":cube.q-1,"r":cube.r},{"q":cube.q-1,"r":cube.r+1},{"q":cube.q,"r":cube.r+1}]
			var dir = rng.randf_range(0,6)
			var new_pos = cube_to_coord(cube_neighbours[dir].q,cube_neighbours[dir].r)
			if get_hex(new_pos.x,new_pos.y) != null:
				move_unit(old_x, old_y, new_pos.x, new_pos.y)

				for hex in get_neighbours(old_x,old_y):
					hex.tile.material_overlay = null
				
				for hex in get_neighbours(new_pos.x,new_pos.y):
					hex.tile.material_overlay = neighbour_mat
				
				old_x = new_pos.x
				old_y = new_pos.y
					

func _ready():

	init_tiles()
	var hex = get_hex(0,0)
	hex.unit = test_unit
	test_unit.global_position = hex.tile.global_position
	old_x = 0
	old_y = 0

func get_hex(x:int, y:int) -> Hex:
	var hex : Hex = null
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		hex = hexes[x][y]
	return hex

func test(x:int, y:int):
	var neighbour_mat = outline.get_outline(Color.ORANGE_RED)
	
	for hex in get_neighbours(x,y):
		hex.tile.material_overlay = neighbour_mat
		pass

func cube_to_coord(q:int,r:int):
	var parity : int
	var col :int
	var row : int
	if orientation == BoardGenerator.HEX_ROTATION.Pointy_Top:
		parity = r&1
		col = q + (r + parity) / 2
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
		q = x - (y + parity) / 2
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
		var hex = get_hex(coord.x,coord.y)
		if hex != null:
			neighbours.append(hex)
	
	
	return neighbours

func move_unit(from_x:int, from_y:int, to_x:int, to_y:int) -> void:
	var from_hex = get_hex(from_x, from_y)
	var to_hex = get_hex(to_x, to_y)
	var unit = from_hex.unit
	if unit == null:
		push_warning("tried to move a non-existant unit")
		return

	if not to_hex.passable:
		return

	unit.on_pre_move()

	var defender : Actor = to_hex.structure if to_hex.unit == null else to_hex.unit
	var move : bool = true
	if defender != null:
		move = unit.attack(defender)

	if move:
		unit.x = to_x
		unit.y = to_y
		to_hex.unit = unit
		from_hex.unit = null
		unit.global_position = to_hex.tile.global_position
		unit.on_post_move()
	pass


func get_unit(x:int, y:int) -> Unit:
	var unit : Unit = null
	unit = get_hex(x,y).unit
	return unit
