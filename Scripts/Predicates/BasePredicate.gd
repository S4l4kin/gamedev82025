class_name Predicate

var card : Card

func can_play(coord) -> bool:
	return can_afford()

func can_afford() -> bool:
	return GameManager.player.can_afford(card.cost)
