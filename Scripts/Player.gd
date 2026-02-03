extends Control
class_name Player

var temporary_resource : Dictionary[GlobalEnums.COST_COLORS, int]
var persistent_resource : Dictionary[GlobalEnums.COST_COLORS, int]

@onready var temporary_resource_list : Control = $ResourceLists/HBoxContainer/Etheral/List
@onready var persistent_resource_list : Control = $ResourceLists/HBoxContainer/Persisten/List

func _ready():
	$EndTurn.connect("pressed", (func ():
		if GameManager.my_turn():
			AudioManager.play_global_sfx("click")
		GameManager.network.send_messages({"type":"next_turn"})
	))
	GameManager.connect("turn_start", turn_start)
	add_resource(GlobalEnums.COST_COLORS.Generic, true, 50)

var turn_number : int = -1

func turn_start(player_name):
	if player_name != GameManager.player_name:
		return
	for resource in temporary_resource.keys():
		temporary_resource[resource] = 0
	turn_number += 1

	add_resource(GlobalEnums.COST_COLORS.Generic, false, min(turn_number, 8))

func add_resource(resource: GlobalEnums.COST_COLORS, persistent : bool = false, amount = 1):
	var resource_list : Dictionary[GlobalEnums.COST_COLORS, int]
	if persistent:
		resource_list = persistent_resource
	else:
		resource_list = temporary_resource
	
	if not resource_list.has(resource):
		resource_list[resource] = 0
	resource_list[resource] += amount
	update_resource_list()

func can_afford(cost: Dictionary) -> bool:
	#for symbol in cost.keys():
	#	var total = 0
	#	if temporary_resource.has(symbol):
	#		total += temporary_resource[symbol]
	#	if persistent_resource.has(symbol):
	#		total += persistent_resource[symbol]
	#	if cost[symbol] > total:
	#		return false
	return true

func pay_cost(cost: Dictionary):
	#for symbol in cost.keys():
	#	var to_pay = cost[symbol]
	#	print("COST TO PAY%s"%to_pay)
	#	if temporary_resource.has(symbol):
	#		var has_resource = temporary_resource[symbol]
	#		temporary_resource[symbol] = max(temporary_resource[symbol]-to_pay, 0)
	#		to_pay = max(to_pay-has_resource, 0)
	#	if persistent_resource.has(symbol):
	#			var has_resource = persistent_resource[symbol]
	#			persistent_resource[symbol] = max(persistent_resource[symbol]-to_pay, 0)
	#			to_pay = max(to_pay-has_resource, 0)
	#update_resource_list()
	pass

func update_resource_list():
	for symbol in temporary_resource:
		var list_element = temporary_resource_list.get_node(str(symbol))
		if not list_element:
			list_element = TextureRect.new()
			list_element.custom_minimum_size = Vector2(50,50)
			list_element.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			list_element.texture = GameManager.card_manager.get_resource_symbol(symbol)
			list_element.modulate = GameManager.card_manager.get_resource_color(symbol)
			list_element.name = str(symbol)
			var numb := Label.new()
			list_element.add_child(numb)
			numb.set_anchors_preset(Control.PRESET_FULL_RECT)
			numb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			numb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			numb.self_modulate = Color8(131, 131, 131, 255)
			var text_material = ShaderMaterial.new()
			text_material.shader = preload("res://Scripts/Shaders/alpha_gain.gdshader")
			numb.material = text_material
			numb.add_theme_font_size_override("font_size", 30)
			numb.name = "Numb"
			temporary_resource_list.add_child(list_element)
		list_element.get_node("Numb").text = str(temporary_resource[symbol])
	for symbol in persistent_resource:
		var list_element = persistent_resource_list.get_node(str(symbol))
		if not list_element:
			list_element = TextureRect.new()
			list_element.custom_minimum_size = Vector2(50,50)
			list_element.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			list_element.texture = GameManager.card_manager.get_resource_symbol(symbol)
			list_element.modulate = GameManager.card_manager.get_resource_color(symbol)
			list_element.name = str(symbol)
			var numb := Label.new()
			list_element.add_child(numb)
			numb.set_anchors_preset(Control.PRESET_FULL_RECT)
			numb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			numb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			numb.self_modulate = Color8(131, 131, 131, 255)
			numb.add_theme_font_size_override("font_size", 30)
			numb.name = "Numb"
			persistent_resource_list.add_child(list_element)
		list_element.get_node("Numb").text = str(persistent_resource[symbol])
