extends Node

class_name DeckManager

@export var deck_resource : Deck

# card shuffler: see https://stormbound-kitty.com/drawing-mechanics

var hand : Array[String] = []
var weights : Dictionary[String, float] = {}

func _ready() -> void:
	if not deck_resource:
		push_error("DeckManager requires a Deck resource to function properly.")
		return

	print("DeckManager initialized with deck: " + deck_resource.deck_name)
	_intialize_deck()

func _intialize_deck() -> void:	
	hand.clear()
	# Initialize the deck with cards from the deck resource

func deck_shuffler() -> void:
	# Implement shuffling logic here
	var cards = deck_resource.cards(duplicate(true))
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	weights.clear()
	var current_weight : float = 1.6

	while len(cards) > 0:
		var index = rng.randi_range(0, len(cards) - 1)
		var card_id = cards[index]
		weights[card_id] = current_weight
		cards.remove_at(index)
		current_weight = current_weight * 1.6
	pass
