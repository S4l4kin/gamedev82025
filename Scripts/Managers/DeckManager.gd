@tool
extends Node

class_name DeckManager

@export var deck_resource : Deck

@onready var card_manager : CardManager = $"/root/CardManager"
@export var resource_count : Dictionary[GlobalEnums.COST_COLORS, int] = {}

# card shuffler: see https://stormbound-kitty.com/drawing-mechanics

var hand : Array[Card] = []
@onready var hand_node = $Hand/HBoxContainer

var weights : Dictionary[String, float] = {}
const weight_multiplier : float = 1.6
const weight_constant : float = 100

func _ready() -> void:
	if not deck_resource:
		push_error("DeckManager requires a Deck resource to function properly.")
		return

	print("DeckManager initialized with deck: " + deck_resource.deck_name)
	
	_intialize_deck()
	draw_starting_hand()
	
	print("Player's starting hand: ", hand)

	GameManager.connect("turn_start", draw_hand)

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
		current_weight = current_weight * weight_multiplier + weight_constant
		print("New current_weight is: ", current_weight)
	pass

func reweight_deck() -> void:
	for card_id in deck_resource.card_list:
		var is_in_hand = false
		for card in hand:
			if card.id == card_id:
				is_in_hand = true
				break
		if not is_in_hand:
			update_weight(card_id)

func update_weight(card_id: String) -> void:
	if not weights[card_id]:
		return

	var weight = weights[card_id]
	weights[card_id] = weight * weight_multiplier + weight_constant
	pass

func _get_weighted_card() -> String:
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
			weights[card_id] = 1
			print("ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ %s"%card_id)
			return card_id
	
	# Fallback (This shoudln't happen if "weights" aren't empty.
	return weights.keys()[0]	

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER and event.pressed:
			print("draw card")
			draw_card()

func draw_card() -> Card:
	var card = card_manager.get_card_data(_get_weighted_card())
	hand.append(card)
	add_card_node(card)
	
	return card

func add_card_node(card: Card):
	var playable_card = card_manager.get_playable_card_scene(card)
	playable_card.deck_manager = self

	hand_node.add_child(playable_card)

func draw_starting_hand(hand_size: int=5):
	var hq_card = deck_resource.get_hq()
	hand.append(hq_card)
	add_card_node(hq_card)
	draw_hand(GameManager.player_name, hand_size)

func draw_hand(player_name: String, hand_size: int = 5) -> void:
	if player_name != GameManager.player_name:
		return
	for i in max(0, hand_size - len(hand)):
		draw_card()
