extends Predicate

func can_play(coord) -> bool:
	if coord:
		var played_on_conqured_hex : bool = false
		var played_on_unit : bool = false

		var board : BoardManager = GameManager.board_manager
		var actors = board.get_actors(coord.x, coord.y)

		if actors.has("structure"):
			return false

		if board.conqured_hexes.has(coord):
			played_on_conqured_hex = board.conqured_hexes[coord] == GameManager.player_name
		if actors.has("unit"):
			played_on_unit = actors.unit.player == GameManager.player_name 
		
		return played_on_conqured_hex or played_on_unit
	else: 
		return GameManager.game_state != GameManager.GAME_STATE.Setup
