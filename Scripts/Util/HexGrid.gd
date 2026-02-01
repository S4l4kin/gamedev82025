class_name  HexGridUtil

static func cube_to_coord(q:int,r:int, orientation: TileGenerator.HEX_ROTATION) -> Vector2i:
	var parity : int
	var col :int
	var row : int
	if orientation == TileGenerator.HEX_ROTATION.Pointy_Top:
		parity = r&1
		col = q + (r + parity) / 2
		row = r
	else:
		parity = q&1
		col = q
		row = r + (q + parity) / 2
	return Vector2i(col, row)

static func cube_subtract(a, b):
	return {"q": a.q - b.q, "r": a.r - b.r, "s": a.s - b.s}

static func cube_multiplication(a, n):
	return {"q": a.q * n, "r": a.r * n, "s": a.s * n}

static func cube_equal(a, b):
	return a.q == b.q and a.r == b.r and a.q == b.q

static func cube_distance(a, b):
	var vec = cube_subtract(a, b)
	return (abs(vec.q) + abs(vec.r) + abs(vec.s)) / 2


static func coord_to_cube(x:int,y:int, orientation: TileGenerator.HEX_ROTATION):
	var parity : int
	var q :int
	var r : int
	if orientation == TileGenerator.HEX_ROTATION.Pointy_Top:
		parity = y&1
		q = x - (y + parity) / 2
		r = y
	else:
		parity = x&1
		q = x	
		r = y - (x + parity) / 2
	return {"q":q, "r":r, "s":-q-r}

static func get_neighbours_coord(x: int, y:int, orientation: TileGenerator.HEX_ROTATION) -> Array[Vector2i]:
	var neighbours : Array[Vector2i] = []
	var cube = coord_to_cube(x,y, orientation)
	var cube_neighbours = [{"q":cube.q+1,"r":cube.r},{"q":cube.q+1,"r":cube.r-1},{"q":cube.q,"r":cube.r-1},{"q":cube.q-1,"r":cube.r},{"q":cube.q-1,"r":cube.r+1},{"q":cube.q,"r":cube.r+1}]

	for neighbour in cube_neighbours:
		var coord = cube_to_coord(neighbour.q,neighbour.r, orientation)
		neighbours.append(coord)

	return neighbours

static func get_tile_basis(orientation: TileGenerator.HEX_ROTATION) -> Basis:
	if orientation == TileGenerator.HEX_ROTATION.Pointy_Top:
		return Basis.from_euler(Vector3(-TAU / 4, 0, 0))
	else:
		return Basis.from_euler(Vector3(-TAU / 4, TAU / 4,0))


#enum Directions {NORTH, SOUTH, EAST, WEST, NORHT_EAST, NORHT_WEST, SOUTH_EAST, SOUTH_WEST, NONE}
#static func get_direction_neighbour(a : Vector2i, b : Vector2i, orientation: TileGenerator.HEX_ROTATION) -> Directions:
#	if get_neighbours_coord(a.x, a.y, orientation).has(b):
#		var a_cube = coord_to_cube(a.x, a.y, orientation)
#		var b_cube = coord_to_cube(b.x, b.y, orientation)
#		var origin = cube_subtract(a_cube, b_cube)
#
#		if orientation == TileGenerator.HEX_ROTATION.Pointy_Top:
#			#North East
#			if origin.q == 0 and origin.s == 1 and origin.r == -1:
#				return Directions.NORHT_EAST
#			#Norht West
#			if origin.q == 1 and origin.s == 0 and origin.r == -1:
#				return Directions.NORHT_WEST
#			#West
#			if origin.q == 1 and origin.s == -1 and origin.r == 0:
#				return Directions.WEST
#			#South West
#			if origin.q == 0 and origin.s == -1 and origin.r == 1:
#				return Directions.SOUTH_WEST
#			#South East
#			if origin.q == -1 and origin.s == 0 and origin.r == 1:
#				return Directions.SOUTH_EAST
#			#East
#			if origin.q == -1 and origin.s == 1 and origin.r == 0:
#				return Directions.EAST
#		else: #Flat Tops
#			#North
#			if origin.q == 0 and origin.s == 1 and origin.r == -1:
#				return Directions.NORTH
#			#Norht West
#			if origin.q == 1 and origin.s == 0 and origin.r == -1:
#				return Directions.NORHT_WEST
#			#South West
#			if origin.q == 1 and origin.s == -1 and origin.r == 0:
#				return Directions.SOUTH_WEST
#			#South
#			if origin.q == 0 and origin.s == -1 and origin.r == 1:
#				return Directions.SOUTH
#			#South East
#			if origin.q == -1 and origin.s == 0 and origin.r == 1:
#				return Directions.SOUTH_EAST
#			#Norht East
#			if origin.q == -1 and origin.s == 1 and origin.r == 0:
#				return Directions.NORHT_EAST
#			pass
#
#	return Directions.NONE
