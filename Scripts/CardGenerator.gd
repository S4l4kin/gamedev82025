class_name CardGenerator
var base_card : PackedScene = preload("res://Scenes/Bases/CardBase.tscn") 
var base_actor : PackedScene = preload("res://Scenes/Bases/ActorBase.tscn") 
var cost_symbol_color : Dictionary[GlobalEnums.COST_COLORS, SymbolColorPair]

#Generates a prefab of the card that can be initalized
func generate_card(data:Card) -> PackedScene:
	var base = base_card.instantiate()
	var card = base.get_node("Card")
	

	#Changes the card objects data to refelct the cards internal data
	card.get_node("Name").text = data.name
	card.get_node("Description").text = parse_card_description(data.description)
	
	card.get_node("Image").texture = data.card_image
	
	#Only show Power / Health in cards that actually use it 
	if data.type == Card.CARD_TYPE.HQ or data.type == Card.CARD_TYPE.Unit or data.type == Card.CARD_TYPE.Structure:
		card.get_node("Power").show()
		
	#Only show Speed in cards that actually use it 
		card.get_node("Power/Numb").text = str(data.health)
	if data.type == Card.CARD_TYPE.Unit:
		card.get_node("Speed").show()
		card.get_node("Speed/Numb").text = str(data.speed)
		card.get_node("UnitType").show()
		card.get_node("UnitType").text = GlobalEnums.UNIT_TYPES.keys()[data.unit_type]

	#Only show cost in cards that actually use it 
	if data.type != Card.CARD_TYPE.HQ:
		var cost_node = card.get_node("Cost/Base")
		card.get_node("Cost").show()
		
		for cost in data.cost:
			var value = data.cost[cost]
			if value >= 0:
				var new_cost = cost_node.duplicate()
				new_cost.name = GlobalEnums.COST_COLORS.keys()[cost]

				new_cost.texture = cost_symbol_color[cost].symbol
				new_cost.self_modulate = cost_symbol_color[cost].color

				new_cost.get_node("Numb").text = str(value)
				# Needs to add the duplicated cost symbol to a child, and additionally add their owner being the generated card for them to be saved.
				card.get_node("Cost").add_child(new_cost)
				new_cost.owner = base
				new_cost.get_node("Numb").owner = base
				new_cost.show()
		
	

	var packed_card : PackedScene = PackedScene.new()
	packed_card.pack(base)

	return packed_card

func generate_actor(data: Card) -> PackedScene:
	var actor : Actor = base_actor.instantiate()

	actor.set_script(data.custom_script)
	actor.card_id = data.id
	actor.renderer.model = data.model
	var packed_actor : PackedScene = PackedScene.new()
	packed_actor.pack(actor)

	return packed_actor

func update_actor(actor: Actor, data: Card):
	if data.type == Card.CARD_TYPE.HQ or data.type == Card.CARD_TYPE.Unit or data.type == Card.CARD_TYPE.Structure:
		actor.health = data.health
	if data.type == Card.CARD_TYPE.Unit:
		actor.max_speed = data.speed

func update_card_from_actor(actor: Actor, card: Node , data: Card):
	card = card.get_node("Card")
	if data.type == Card.CARD_TYPE.HQ or data.type == Card.CARD_TYPE.Unit or data.type == Card.CARD_TYPE.Structure:
		card.get_node("Power/Numb").text = str(actor.health)
		if actor.health > data.health:
			card.get_node("Power/Numb").self_modulate = Color.GREEN
		#elif actor.health < data.health:
		#	card.get_node("Power/Numb").self_modulate = Color.RED
		else:
			card.get_node("Power/Numb").self_modulate = Color.WHITE

	if data.type == Card.CARD_TYPE.Unit:
		card.get_node("Speed/Numb").text = str(actor.max_speed)
		if actor.max_speed > data.speed:
			card.get_node("Speed/Numb").self_modulate = Color.GREEN
		elif actor.max_speed < data.speed:
			card.get_node("Speed/Numb").self_modulate = Color.RED
		else:
			card.get_node("Speed/Numb").self_modulate = Color.WHITE

#Parses the description of special tags and changes them to the right BBCode syntaxes
func parse_card_description(description:String) -> String:
	return description


func _init(symbol_colors: Dictionary[GlobalEnums.COST_COLORS, SymbolColorPair]) -> void:
	cost_symbol_color = symbol_colors
