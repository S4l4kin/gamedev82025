extends Control
class_name Player

var temporary_resource : Dictionary[GlobalEnums.COST_COLORS, int]
var persistent_resource : Dictionary[GlobalEnums.COST_COLORS, int]

@onready var temporary_resource_list : Control = $ResourceLists/HBoxContainer/Etheral/List
@onready var persistent_resource_list : Control = $ResourceLists/HBoxContainer/Persisten/List
@onready var deck : DeckManager = GameManager.deck

var hovered_card : PlayableCard 
@onready var hand = $Deck/Hand
@onready var redraw = $"Deck/Redraw Card"
@onready var card_line : ParabolaLine = $ParabolaLine
@onready var play_threshold_line : Marker2D = $PlayThreshold
@onready var reading_marker : Marker2D = $ReadingCenter

@onready var hex_raycast : RayCast3D = $HexRaycast

@onready var outline : Outline = GameManager.board_manager.outline

var drag_start
var constant_drag_start
var drag_offset
var hovering_hex : Hex
enum MouseState {NONE, DRAGGING, SELECTING, REDRAW, READING}

var mouse_state : MouseState
func _input(event):
	if event is InputEventMouseButton:
		if hovered_card:
			if event.pressed and mouse_state == MouseState.READING:
				mouse_state = MouseState.NONE
				hovered_card.reset_card()
				return
			
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				drag_start = event.position
				constant_drag_start = drag_start
				drag_offset = constant_drag_start - (hovered_card.global_position * Vector2(1/hand.scale.x, 1/hand.scale.y))
				mouse_state = MouseState.DRAGGING
				hovered_card.drag_start()
			elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				#PLAY CARD
				if mouse_state == MouseState.SELECTING and hovering_hex:
					if hovered_card.predicate.can_play(hovering_hex.coord):
						play_card()
				#REDRAW CARD
				elif mouse_state == MouseState.REDRAW:
					hovered_card.call_deferred("free")
					GameManager.deck.call_deferred("draw_card")
					GameManager.deck.reweight_deck()
					GameManager.deck.hand.erase(hovered_card.card)
					has_redrawn = true
				
				mouse_state = MouseState.NONE
				outline_hex(null)
				hovered_card.reset_card()
				stop_redraw()
			
			if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				mouse_state = MouseState.READING
				hovered_card.start_reading()
				print("start reading")
				

	if event is InputEventMouseMotion:
		if mouse_state == MouseState.DRAGGING:	
			var card_position = hovered_card.card_node.global_position
			
			if event.position.y <= play_threshold_line.global_position.y and hovered_card.predicate.can_play(null):
				hovered_card.selecting_start()
				var tween = create_tween()
				var tween_time = 0.1
				constant_drag_start = constant_drag_start - drag_offset
				tween.tween_property(self, "drag_start", constant_drag_start, tween_time)
				mouse_state = MouseState.SELECTING
				stop_redraw()
			
			var hover_padding = 30
			var card_index = hovered_card.get_index()
			var hand_size = hand.get_child_count()
			var next_card : PlayableCard = hand.get_child(card_index+1)
			var previous_card : PlayableCard = hand.get_child(card_index-1)

			if card_index < hand_size and next_card:
				if card_position.x > next_card.card_node.global_position.x - hover_padding:
					hand.move_child(next_card, card_index)
					next_card.set_hand_pos() 
			if card_index > 0:
				if previous_card:
					if card_position.x < previous_card.card_node.global_position.x + hover_padding:
						hand.move_child(previous_card, card_index)
						previous_card.set_hand_pos()
			else:
				if card_position.x < redraw.global_position.x + hover_padding and can_redraw():
					start_redraw()
					mouse_state = MouseState.REDRAW
				

		elif mouse_state == MouseState.SELECTING:	
			if event.position.y >= play_threshold_line.global_position.y:
				mouse_state = MouseState.DRAGGING
				outline_hex(null)
				var tween = create_tween()
				var tween_time = 0.2
				constant_drag_start = constant_drag_start + drag_offset
				tween.tween_property(self, "drag_start", constant_drag_start, tween_time)
				hovered_card.selecting_stop()
				return

			var camera : Camera3D = get_viewport().get_camera_3d()
			var from = camera.project_ray_origin(event.position)
			var to = from + (camera.project_ray_normal(event.position) * 10000)
			hex_raycast.global_position = from
			hex_raycast.target_position = to
			var ray_collider = hex_raycast.get_collider()
			if ray_collider != null:
				var hex_tile = ray_collider.get_parent()
				var current_hex = GameManager.board_manager.get_hex_from_tile(hex_tile)
				outline_hex(current_hex)
			else:
				outline_hex(null)
		elif mouse_state == MouseState.REDRAW:
			var card_position = hovered_card.card_node.global_position
			var hover_padding = Vector2(30, 300)
			if card_position.x > redraw.global_position.x + hover_padding.x or card_position.y < redraw.global_position.y - hover_padding.y:
				stop_redraw()
				mouse_state = MouseState.DRAGGING
				

func play_card():
	hovered_card.play_card(hovering_hex)
	$Deck/PlayedCard.add_child(hovered_card)
	hovered_card.call_deferred("free")
	call_deferred("reoder_cards")

func reoder_cards():
	if hand:
		for card in hand.get_children():
			card.set_hand_pos()

func outline_hex (hex):
	if hex:
		if hex != hovering_hex:
			outline.set_hex_outline("ui",hex, get_color(hovered_card.predicate.can_play(hex.coord)))
			if hovering_hex:
				outline.set_hex_outline("ui", hovering_hex, Color.TRANSPARENT)
				pass
			hovering_hex = hex
	else:
		if hovering_hex:
			outline.set_hex_outline("ui", hovering_hex, Color.TRANSPARENT)
		hovering_hex = null

func get_color(flag : bool) -> Color:
	return Color.LIME if flag else Color.RED

func _process(delta):
	if mouse_state != MouseState.NONE and mouse_state != MouseState.READING:
		var mouse_position = get_viewport().get_mouse_position()
		if not hovered_card.predicate.can_play(null) or mouse_state == MouseState.REDRAW:
			mouse_position.y = max(mouse_position.y, play_threshold_line.global_position.y)
		hovered_card.card_node.position = hovered_card.rest_position + ((mouse_position - drag_start) * Vector2(1/hand.scale.x, 1/hand.scale.y))

func start_redraw():
	var tween = redraw.create_tween()
	tween.tween_property(redraw, "modulate", Color.WHITE, 0.1)

func stop_redraw():
	var tween = redraw.create_tween()
	tween.tween_property(redraw, "modulate", Color(0.5,0.5,0.5,1), 0.1)

func _ready():
	$EndTurn.connect("pressed", (func ():
		if GameManager.my_turn():
			AudioManager.play_global_sfx("click")
		GameManager.network.send_messages({"type":"next_turn"})
	))
	GameManager.connect("turn_start", turn_start)

var turn_number : int = -1

func turn_start(player_name):
	if player_name != GameManager.player_name:
		return
	for resource in temporary_resource.keys():
		temporary_resource[resource] = 0
	turn_number += 1
	has_redrawn = false
	GameManager.deck.draw_hand(GameManager.player_name)
	add_resource(GlobalEnums.COST_COLORS.Generic, false, min(turn_number, 10))

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
	for symbol in cost.keys():
		var total = 0
		if temporary_resource.has(symbol):
			total += temporary_resource[symbol]
		if persistent_resource.has(symbol):
			total += persistent_resource[symbol]
		if cost[symbol] > total:
			return false
	return true

func pay_cost(cost: Dictionary):
	for symbol in cost.keys():
		var to_pay = cost[symbol]
		print("COST TO PAY%s"%to_pay)
		if temporary_resource.has(symbol):
			var has_resource = temporary_resource[symbol]
			temporary_resource[symbol] = max(temporary_resource[symbol]-to_pay, 0)
			to_pay = max(to_pay-has_resource, 0)
		if persistent_resource.has(symbol):
				var has_resource = persistent_resource[symbol]
				persistent_resource[symbol] = max(persistent_resource[symbol]-to_pay, 0)
				to_pay = max(to_pay-has_resource, 0)
	update_resource_list()
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


var has_redrawn : bool = false
func can_redraw() -> bool:
	if hovered_card.card.type == Card.CARD_TYPE.HQ:
		return false
	return not has_redrawn

func calculate_position(card_index: int):
	if deck:
		return card_line.get_point_weight(float(card_index+1)/(len(deck.hand)+1))
	return card_line.get_point_weight(1/2.)
func calculate_rotation(card_index: int):
	if deck:
		return card_line.get_perpendicular_weight(float(card_index+1)/(len(deck.hand)+1))
	return card_line.get_perpendicular_weight(1/2.)
