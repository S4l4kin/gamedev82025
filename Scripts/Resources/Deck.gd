extends Resource
class_name Deck

@export var hq : String
@export var card_list : Array[String]
@export var deck_name : String

func get_cards() -> Array[Card]:
	var cards : Array[Card] = []
	if GameManager.card_manager:
		for card_name in card_list:
			cards.append(GameManager.card_manager.get_card_data(card_name))
	
	return cards

func get_hq() -> Card:
	if GameManager.card_manager:
		return GameManager.card_manager.get_card_data(hq)
	return null
