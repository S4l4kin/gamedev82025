@tool
extends Node
class_name CardManager

@export var cost_symbol_color : Dictionary[GlobalEnums.COST_COLORS, SymbolColorPair] = {}

var card_data : Dictionary[String, Card]
var card_object : Dictionary
var actor_object : Dictionary

@onready var card_generator : CardGenerator = preload("res://Scripts/CardGenerator.gd").new(cost_symbol_color)


func _ready() -> void:
	load_cards_in_folder("res://Cards")
	
# Loads an individual card in path
func load_card(path) -> void:
	var file = ResourceLoader.load(path, "Card")
	if file is Card:
		file.set_defaults()
		card_data.set(file.id, file)
	else:
		push_warning("Found a non Card Resource in Cards folders: "+ path)

#Tries to load every card in path, works recursevly to read subfolders.
func load_cards_in_folder(path) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				load_cards_in_folder(path+"/"+file_name)
			else:
				load_card(path+"/"+file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

#Returns the prefab of the card, generates only the cards that are needed.
func get_card_scene(card_name:String) -> PackedScene:
	if not card_data.has(card_name):
		push_error("Tried to acess non-existant card " + card_name)
		return null
	if card_object.has(card_name):
		return card_object[card_name]
	else:
		var card = card_generator.generate_card(card_data[card_name])
		card_object[card_name] = card
		return card

func get_playable_card_scene(card: Card) -> Node:
	var card_base = get_card_scene(card.id).instantiate()
	var raycast = RayCast3D.new()
	raycast.name = "Raycast"
	card_base.add_child(raycast)
	card_base.set_script(preload("res://Scripts/PlayableCard.gd"))
	if card.type == Card.CARD_TYPE.HQ or card.type == Card.CARD_TYPE.Structure or card.type == Card.CARD_TYPE.Unit:
		card_base.play_callable = (func (coord: Vector2i): GameManager.network.send_messages({
			"type":"create_actor",
			"player": GameManager.player_name,
			"coord":{"x":coord.x,"y":coord.y}, 
			"unit":{"id": card.id, "power":card.health, "speed":card.speed}}
			))
	card_base.card = card
	return card_base

func get_card_actor(card: Card) -> Actor:
	if not card_data.has(card.id):
		push_error("Tried to acess non-existant card " + card.id)
		return null
	

	if not actor_object.has(card.id):
		actor_object[card.id] = preload("res://Scenes/Bases/ActorBase.tscn")
	
	var actor_node = actor_object[card.id].instantiate()
	actor_node.card_id = card.id
	actor_node.health = card.health
	actor_node.max_speed = card.speed
	actor_node.start_color = card.color
	return actor_node

#Return all the loaded card ids
func get_cards() -> Array[String]:
	return card_data.keys()

#Returns the card data of a specific card
func get_card_data(card_name:String) -> Card:
	if not card_data.has(card_name):
		push_error("Tried to acess non-existant card " + card_name)
		return null
	return card_data[card_name]

func _get_property_list():
	if Engine.is_editor_hint():
		var ret = []
		ret.append({
			"name": &"cost",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_DICTIONARY_TYPE,
			"hint_string": "%d/%d:%s;%d" % [TYPE_INT, PROPERTY_HINT_ENUM,",".join(GlobalEnums.COST_COLORS.keys()),PROPERTY_HINT_RESOURCE_TYPE]
			})
		
		return ret
