extends Predicate
class_name StructurePredicate
func can_play(coord) -> bool:
	if coord:
		return (played_on_conqured_hex(coord) or played_on_unit(coord)) and not played_on_feature(coord) and can_afford()
	else: 
		return GameManager.game_state != GameManager.GAME_STATE.Setup

func played_on_unit(coord : Vector2i) -> bool:
	var board : BoardManager = GameManager.board_manager
	var actors = board.get_actors(coord.x, coord.y)
	if actors.has("unit"):
			return actors.unit.player == GameManager.player_name 
	return false

func played_on_conqured_hex(coord: Vector2i) -> bool:
	var board : BoardManager = GameManager.board_manager
	if board.conqured_hexes.has(coord):
		return board.conqured_hexes[coord] == GameManager.player_name
	return false

func played_on_feature(coord: Vector2i) -> bool:
	var board : BoardManager = GameManager.board_manager
	var hex = board.get_hex(coord.x, coord.y)
	return not is_instance_of(hex.feature, NoneFeature)
	