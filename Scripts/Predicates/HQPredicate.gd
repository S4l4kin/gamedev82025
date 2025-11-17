extends Predicate

const min_distance : int = 5
func can_play(coord) -> bool:
	if coord:
		var board = GameManager.board_manager
		var cube_coord = board.coord_to_cube(coord.x, coord.y)
		for _coord in board.hexes:
			var actors = board.get_actors(_coord.x, _coord.y)
			if actors.has("structure"):
				if is_instance_of(actors.structure, HQ):
					if cube_distance(cube_coord, board.coord_to_cube(_coord.x, _coord.y)) < min_distance:
						return false
		return true
	else:
		return GameManager.game_state == GameManager.GAME_STATE.Setup

func cube_subtract(a, b):
	return {"q":a.q - b.q, "r": a.r - b.r, "s":a.s - b.s}

func cube_distance(a, b):
	var vec = cube_subtract(a, b)
	return (abs(vec.q) + abs(vec.r) + abs(vec.s)) / 2
