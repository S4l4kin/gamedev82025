@tool
extends Resource
class_name Card

enum CARD_TYPE {HQ, Unit, Structure, Spell, Equipment}

#Variables for all card types
var name : String = "New Card":
	set(s):
		if id == generate_id(name):
			id = generate_id(s)
		name = s
var id : String = "":
	set(s):
		if s != "":
			id = generate_id(s)
		else:
			id = generate_id(name)
var type : CARD_TYPE:
	set(s):
		type = s
		notify_property_list_changed()
var cost : Dictionary
var description : String = "This is a card"

var card_image : Texture2D
var hide_in_collection

var custom_script : Script
var play_predicate : Script
var play_callable : Callable
#Variables unique for HQ, Unit and Structures
var health : int
var model : PackedScene

#Variables unique for Units
var unit_type : int = 0
var speed : int = 1
@export var color : Color
#Instantiates the card, set unused variables to null (or empty for string and -1 for int)
# and empty needed variables to their default values.
func set_defaults():
	#var card = self.duplicate()

	print("load card: " + id)
	if type == CARD_TYPE.HQ or type == CARD_TYPE.Structure:
		unit_type = -1
		speed = -1
	elif type == CARD_TYPE.Spell or type == CARD_TYPE.Equipment:
		unit_type = -1
		speed = -1
		health = -1
		model = null
	
	if type != CARD_TYPE.HQ:
		if len(cost) == 0:
			cost[GlobalEnums.COST_COLORS.Generic] = 0

	match type:
		CARD_TYPE.HQ:
			if not custom_script:
				custom_script = preload("res://Scripts/Actor_scripts/Headquarter.gd")
			elif not is_instance_of(custom_script.new(), HQ):
				custom_script = preload("res://Scripts/Actor_scripts/Headquarter.gd")
				push_error("Card " + id + " custom script does not extend HQ as it should")
				print("Card " + id + " custom script does not extend HQ as it should, changed it base HQ")
			play_predicate = preload("res://Scripts/Predicates/HQPredicate.gd")
		CARD_TYPE.Unit:
			if not custom_script:
				custom_script = preload("res://Scripts/Actor_scripts/Unit.gd")
			elif not is_instance_of(custom_script.new(), Unit):	
				custom_script = preload("res://Scripts/Actor_scripts/Unit.gd")
				push_error("Card " + id + " custom script does not extend Unit as it should")
				print("Card " + id + " custom script does not extend Unit as it should, changed it base Unit")
			if not play_predicate:
				play_predicate = preload("res://Scripts/Predicates/UnitPredicate.gd")
		CARD_TYPE.Structure:
			if not custom_script:
				custom_script = preload("res://Scripts/Actor_scripts/Structure.gd")
			if not play_predicate:
				play_predicate = preload("res://Scripts/Predicates/StructurePredicate.gd")
			elif not is_instance_of(custom_script.new(), Structure):
				custom_script = preload("res://Scripts/Actor_scripts/Structure.gd")
				push_error("Card " + id + " custom script does not extend Structure as it should")
				print("Card " + id + " custom script does not extend Structure as it should, changed it base Structure")
		_:
			push_error("Card " + id + " custom script is not assinged as it should")
			print("Card " + id + " custom script is not assinged as it should")
			play_predicate = preload("res://Scripts/Predicates/BasePredicate.gd")
	
	if type != CARD_TYPE.Spell:
		play_callable = func (coord: Vector2i): GameManager.network.send_messages({
				"type":"create_actor",
				"player": GameManager.player_name,
				"coord":{"x":coord.x,"y":coord.y}, 
				"unit":{"id": id, "power":health, "speed":speed}}
				)
	#Placeholder fix for placeholder cards that have the type Spell
	else :
		play_callable = func (_coord: Vector2i): GameManager.deck.draw_card();

	#return card
func generate_id(_name:String) -> String:
	return _name.to_lower().replace(' ', '_')

func _get_property_list():
	if Engine.is_editor_hint():
		var ret = []
		ret.append({
			  "name": &"name", 
			  "type": TYPE_STRING,
			  "usage": PROPERTY_USAGE_DEFAULT
		 	  })
		ret.append({
			  "name": &"id", 
			  "type": TYPE_STRING,
			  "usage": PROPERTY_USAGE_DEFAULT
		 	  })
		ret.append({
			  "name": &"type", # Note the g0_ here. It's ugly, but meh.
			  "type": TYPE_INT,
			  "usage": PROPERTY_USAGE_DEFAULT,
			  "hint": PROPERTY_HINT_ENUM,
			  "hint_string": ",".join(CARD_TYPE.keys())
		 	  })
		if type != CARD_TYPE.HQ:	
			ret.append({
				"name": &"cost", # Note the g0_ here. It's ugly, but meh.
				"type": TYPE_DICTIONARY,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_DICTIONARY_TYPE,
				"hint_string": "%d/%d:%s;int" % [TYPE_INT, PROPERTY_HINT_ENUM,",".join(GlobalEnums.COST_COLORS.keys())]
				})
		ret.append({
			"name": &"card_image",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string" : "Texture2D"
		 	})
		ret.append({
			"name": &"description",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_MULTILINE_TEXT
		 	})
		if type == CARD_TYPE.HQ or type == CARD_TYPE.Structure:
			ret.append({
			  "name": &"health", # Note the g0_ here. It's ugly, but meh.
			  "type": TYPE_INT,
			  "usage": PROPERTY_USAGE_DEFAULT
		 	  })
			ret.append({
			  "name": &"model",
			  "type": TYPE_OBJECT,
			  "hint": PROPERTY_HINT_RESOURCE_TYPE,
			  "hint_string" : "PackedScene"
		 	  })
		elif type == CARD_TYPE.Unit:
			ret.append({
			  "name": &"unit_type", # Note the g0_ here. It's ugly, but meh.
			  "type": TYPE_INT,
			  "usage": PROPERTY_USAGE_DEFAULT,
			  "hint": PROPERTY_HINT_ENUM,
			  "hint_string": ",".join(GlobalEnums.UNIT_TYPES.keys())
		 	  })
			ret.append({
			  "name": &"health", # Note the g0_ here. It's ugly, but meh.
			  "type": TYPE_INT,
			  "usage": PROPERTY_USAGE_DEFAULT
		 	  })
			ret.append({
			  "name": &"speed",
			  "type": TYPE_INT,
			  "usage": PROPERTY_USAGE_DEFAULT
		 	  })
			ret.append({
			  "name": &"model",
			  "type": TYPE_OBJECT,
			  "hint": PROPERTY_HINT_RESOURCE_TYPE,
			  "hint_string" : "PackedScene"
		 	  })
		ret.append({
		  "name": &"custom_script",
		  "type": TYPE_OBJECT,
		  "hint": PROPERTY_HINT_RESOURCE_TYPE,
		  "hint_string" : "Script"
		  })
		ret.append({
		  "name": &"play_predicate",
		  "type": TYPE_OBJECT,
		  "hint": PROPERTY_HINT_RESOURCE_TYPE,
		  "hint_string" : "Script"
		  })
		return ret
