extends StructurePredicate
class_name MinePredicate

func can_play(coord) -> bool:
	if coord:
		var board = GameManager.board_manager
		var hex = board.get_hex(coord.x, coord.y)

		if hex.feature:
			if hex.feature is OreFeature:
				return ((played_on_conqured_hex(coord) or played_on_unit(coord))) and can_afford()
		return false
	else: 
		return GameManager.game_state != GameManager.GAME_STATE.Setup
