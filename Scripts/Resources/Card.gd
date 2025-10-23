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

#Variables unique for HQ, Unit and Structures
var health : int
var model : PackedScene

#Variables unique for Units
var unit_type : int = 0
var speed : int = 1

#Instantiates the card, set unused variables to null (or empty for string and -1 for int)
# and empty needed variables to their default values.
func set_defaults() -> void:
	print("load card: " + id)
	if type == CARD_TYPE.HQ or type == CARD_TYPE.Structure:
		unit_type = -1
		speed = -1
	elif type == CARD_TYPE.Spell or type == CARD_TYPE.Equipment:
		unit_type = -1
		speed = -1
		health = -1
		model = null

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
