extends Predicate

func can_play(coord) -> bool:
	var mushroom_network = MushroomNetworkUtil.instance
	if coord:
		var board = GameManager.board_manager
		var unit = board.get_hex(coord.x, coord.y).unit
		if unit:
			if GameManager.is_mine(unit):
				return true
			else:
				return GameManager.player.can_afford(CostUtil.add_costs(card.cost, MushroomTeleport.extra_cost))

	elif mushroom_network:
		return super.can_play(coord) or len(mushroom_network.teleport_locations) > 0
	
	return false
