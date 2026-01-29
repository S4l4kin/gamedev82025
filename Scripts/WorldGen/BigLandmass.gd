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
		if not map_data.get_or_add(current_hex, false):
			map_data[current_hex] = true
			land_left -= 1
			#if land_left <= 0:
			#	break
		var neighbours = HexGridUtil.get_neighbours_coord(current_hex.x, current_hex.y, board.orientation)
		for n in neighbours:
			if not map_data.get_or_add(n, false):
				map_data[n] = true
				land_left -= 1
		
		current_hex = neighbours[rng.randi_range(0, len(neighbours)-1)]

	return map_data
