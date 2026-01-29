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