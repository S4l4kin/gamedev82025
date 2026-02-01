extends BaseGenerator
class_name  BigLandmassGenerator
var land_amount : int

func _init(_land_amount):
	land_amount = _land_amount

func generate_base() -> Dictionary[Vector2i, bool]:  
	var map_data : Dictionary[Vector2i, bool] = {}
	var board = GameManager.board_manager
	var land_left = land_amount
	var current_hex = Vector2i.ZERO  #Vector2i(rng.randi_range(0, grid_size.x-1), rng.randi_range(0, grid_size.x-1))
	while (land_left > 0):
		var neighbours = HexGridUtil.get_neighbours_coord(current_hex.x, current_hex.y, board.orientation)
		neighbours.append(current_hex)
		for n in neighbours:
			if not map_data.get_or_add(n, false):
				map_data[n] = true
				land_left -= 1
		
		current_hex = neighbours[rng.randi_range(0, len(neighbours)-1)]

	return map_data

func find_coastline(base, top_left : Vector2i, bottom_right : Vector2i) -> Array[Vector2i]:
	var hexes_to_check : Array[Vector2i] = []
	var checked_hexes : Array[Vector2i] = []
	var coastline_hexes : Array[Vector2i] = []
	var hex_orientation = GameManager.board_manager.orientation

	#Extend the boundaries by one
	top_left = top_left - Vector2i.ONE
	bottom_right = bottom_right + Vector2i.ONE

	# Adds all the edges to the coast checklist, if they are not ground already
	for x in range(top_left.x, bottom_right.x):
		for y in [top_left.y, bottom_right.y]:
			var coord = Vector2i(x, y)
			if base.has(coord):
				if not base[coord]:
					hexes_to_check.append(coord)
			else:
				hexes_to_check.append(coord)
	for y in range(top_left.y, bottom_right.y):
		for x in [top_left.x, bottom_right.x]:
			var coord = Vector2i(x, y)
			if base.has(coord):
				if not base[coord]:
					hexes_to_check.append(coord)
			else:
				hexes_to_check.append(coord)
	
	while not hexes_to_check.is_empty():
		var coord = hexes_to_check.pop_back()
		checked_hexes.append(coord)
		var neighbours = HexGridUtil.get_neighbours_coord(coord.x, coord.y, hex_orientation)
		var neighbours_out_of_bound : Array[Vector2i]

		#Remove neighbours that are out of bound
		for neighbour in neighbours:
			if neighbour.x < top_left.x or neighbour.x > bottom_right.x or neighbour.y < top_left.y or neighbour.y > bottom_right.y:
					neighbours_out_of_bound.append(neighbour)
		for neighbour in neighbours_out_of_bound:
			neighbours.erase(neighbour)

		for neighbour in neighbours:
			if base.has(neighbour):
				if not base[neighbour] and not checked_hexes.has(neighbour):
					hexes_to_check.append(neighbour)
				else:
					if not coastline_hexes.has(neighbour):
						coastline_hexes.append(neighbour)
			elif not checked_hexes.has(neighbour):
				hexes_to_check.append(neighbour)

	#Reoder the list so that the coastline is in adjecency order
	var coastline_hexes_ordered : Array[Vector2i] = []
	var current = coastline_hexes[0]
	coastline_hexes_ordered.append(current)
	while not coastline_hexes.is_empty():
		coastline_hexes.erase(current)
		var neighbours = HexGridUtil.get_neighbours_coord(current.x, current.y, hex_orientation)
		for neighbour in neighbours:
			if coastline_hexes.has(neighbour):
				coastline_hexes_ordered.append(neighbour)
				current = neighbour
				continue

	return coastline_hexes_ordered
