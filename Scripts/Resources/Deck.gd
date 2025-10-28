extends Resource
class_name Deck

@export var card_list : Array[String]
@export var deck_name : String

func _init():
    card_list = []
    deck_name = "Default Deck"
    add_placeholder_cards()

func add_placeholder_cards():
    for i in range(1, 11):
        card_list.append("Placeholder Card " + str(i))
