class_name Predicate

var card : Card

func can_play(coord) -> bool:
	return can_afford()

func can_afford() -> bool:
	return GameManager.player.can_afford(card.cost)

func is_setup_phase() -> bool:
	return GameManager.game_state == GameManager.GAME_STATE.Setup
