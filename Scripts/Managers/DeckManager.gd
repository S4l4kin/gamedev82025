@tool
extends Node

class_name DeckManager

@export var deck_resource : Deck

# card shuffler: see https://stormbound-kitty.com/drawing-mechanics

var hand : Array = []
var weights : Dictionary[String, float] = {}
const weight_multiplier : float = 1.6

func _ready() -> void:
	if not deck_resource:
		push_error("DeckManager requires a Deck resource to function properly.")
		return

	print("DeckManager initialized with deck: " + deck_resource.deck_name)
	
	_intialize_deck()
	hand = _deal_hand(5)
	
	print("Player's starting hand: ", hand)

func _intialize_deck() -> void:	
	hand.clear()
	weights.clear()
	_deck_shuffler()
	# Initialize the deck with cards from the deck resource

func _deck_shuffler() -> void:
	# Implement shuffling logic here
	var cards = deck_resource.card_list.duplicate(true)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var current_weight : float = 1.0
	weights.clear()

	while len(cards) > 0:
		# Randomly picks a card from the deck.
		var index = rng.randi_range(0, len(cards) - 1)
		var card_id = cards[index]
		print("Picked ", card_id, " at index: ", index)
		
		# Assigns the picked card its new weight.
		weights[card_id] = current_weight
		print("Gave ", card_id, " the weight of ", current_weight)		
		
		cards.remove_at(index)
		current_weight = current_weight * weight_multiplier + 100
		print("New current_weight is: ", current_weight)
	pass
	
func _draw_weighted_card(weights: Dictionary) -> String:
	var total_weight := 0.0
	for w in weights.values():
		total_weight += w
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random_pick = rng.randf_range(0, total_weight)
	
	var cumulative := 0.0
	for card_id in weights.keys():
		cumulative += weights[card_id]
		if random_pick <= cumulative:
			return card_id
	
	# Fallback (This shoudln't happen if "weights" aren't empty.
	return weights.keys()[0]	
	
func _deal_hand(hand_size: int = 5) -> Array:
	var hand: Array = []
	var available_weights = weights.duplicate()
	
	for i in range(hand_size):
		if available_weights.is_empty():
			break
		
		var drawn_card = _draw_weighted_card(available_weights)
		hand.append(drawn_card)	
		
		available_weights.erase(drawn_card)
	return hand
