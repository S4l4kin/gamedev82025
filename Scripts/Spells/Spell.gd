class_name Spell

var player : String
var coord : Vector2i
var spell_id
var card : Card
func play():
	print(coord)

func spell_finished():
	var board : BoardManager = GameManager.board_manager
	board.active_spells.erase(self)  

func spell_canceled():
	var deck : DeckManager = GameManager.deck
	deck.add_card_to_hand(card)
