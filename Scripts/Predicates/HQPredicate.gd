extends StructurePredicate

const min_distance : int = 5
func can_play(coord) -> bool:
	if coord:
		var board = GameManager.board_manager
		var cube_coord = HexGridUtil.coord_to_cube(coord.x, coord.y, board.orientation)
		for _coord in board.hexes:
			var actors = board.get_actors(_coord.x, _coord.y)
			if actors.has("structure"):
				if is_instance_of(actors.structure, HQ):
					if HexGridUtil.cube_distance(cube_coord, HexGridUtil.coord_to_cube(_coord.x, _coord.y, board.orientation)) < min_distance:
						return false
		return not played_on_feature(coord)
	else:
		return is_setup_phase()
