extends Predicate

func can_play(coord) -> bool:
	if coord:
		var board = GameManager.board_manager
		var hex = board.get_hex(coord.x, coord.y)
		if hex.unit:
			if hex.unit.player != GameManager.player_name:
				return true
		return false
	else:
				return not is_setup_phase() and  can_afford()
