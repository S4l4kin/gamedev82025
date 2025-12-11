extends Predicate

func can_play(coord) -> bool:
	if coord:
		var board : BoardManager = GameManager.board_manager

		var actors = board.get_actors(coord.x, coord.y)

		if actors.has("unit"):
			return false

		if board.conqured_hexes.has(coord):
			return board.conqured_hexes[coord] == GameManager.player_name
		return false
	else: 
		return GameManager.game_state != GameManager.GAME_STATE.Setup and can_afford()
