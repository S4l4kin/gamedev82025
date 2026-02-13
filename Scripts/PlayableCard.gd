extends Control
class_name PlayableCard

var card : Card
var dragging : bool

var drag_start : Vector2

var play_threshold : float = -100
var threshold_met : bool

var deck_manager : DeckManager
var reading : bool = false

@onready var raycast_node : RayCast3D = $Raycast
@onready var outline : Outline = GameManager.board_manager.outline
@onready var predicate = card.play_predicate.new()
@onready var player = GameManager.player
@onready var card_node = $Card
func _ready():
	$Card.connect("gui_input", test)
	$Card.connect("mouse_entered", hover_start)
	$Card.connect("mouse_exited", hover_stop)
	predicate.card = card
	set_hand_pos()

func start_reading():
	var tween = create_tween()
	var center : Control = $"/root/Player/ReadingCenter"
	tween.tween_property($Card, "global_position", center.global_position-$Card.size/2, 0.2)
	tween.tween_property($Card, "scale", Vector2.ONE * 1.5, 0.2)
	z_index = 10

func hover_start():
	if not dragging and not reading:
		if player.hovered_card:
			player.hovered_card.hover_stop()
		player.hovered_card = self
		z_index = 100
		var tween = create_tween()
		tween.tween_property($Card, "position", Vector2.UP * 10, 0.2)
		AudioManager.play_global_sfx("hover_card")

func hover_stop():
	if not dragging:
		if player.hovered_card:
			player.hovered_card = null
		var tween = create_tween()
		var card_pos = card_node.global_position
		position.x = calculate_position()
		card_node.global_position = card_pos
		
		tween.tween_property($Card, "position", Vector2.ZERO, 0.2)
		tween.tween_property($Card, "scale", Vector2.ONE, 0.2)
		
		reading = false
		dragging = false
		z_index = 0

func treshold_exeeded():
	var tween = create_tween()
	tween.tween_property($Card, "scale", Vector2.ONE * 0.3, 0.2)	
	tween.tween_property($Card, "modulate", Color(1,1,1,0.5), 0.2)
	
	
func treshold_cancelled():
	var tween = get_tree().create_tween()
	tween.tween_property($Card, "scale", Vector2.ONE * 1, 0.2)
	tween.tween_property($Card, "modulate", Color.WHITE, 0.2)
	if old_hex:
		outline.set_hex_outline("ui", old_hex, Color.TRANSPARENT)
		old_hex = null

var redraw : bool = false

func start_redraw():
	var tween = player.redraw.create_tween()
	tween.tween_property(player.redraw, "modulate", Color.WHITE, 0.1)
	redraw = true

func stop_redraw():
	var tween = player.redraw.create_tween()
	tween.tween_property(player.redraw, "modulate", Color(0.5,0.5,0.5,1), 0.1)
	redraw = false

func redraw_card():
	stop_redraw()
	call_deferred("free")
	GameManager.deck.hand.erase(card)
	player.has_redrawn = true
	GameManager.deck.draw_card()
	reorder_cards()

var old_hex
var offset : Vector2 = Vector2(91.0,157.0)
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT == MOUSE_BUTTON_LEFT:
			if dragging:
				if card_node.position.y <= play_threshold:
					if not threshold_met:
						treshold_exeeded()
						stop_redraw()
						threshold_met = true
				else:
					if threshold_met:
						treshold_cancelled()
						threshold_met = false
				
				card_node.position = (get_viewport().get_mouse_position() - drag_start) * (1/player.hand.scale.x)

				if threshold_met:
					var _camera : Camera3D = get_viewport().get_camera_3d()
					var from = _camera.project_ray_origin(event.position)
					var to = from + (_camera.project_ray_normal(event.position) * 10000)
					raycast_node.global_position = from
					raycast_node.target_position = to
					raycast_node.collide_with_areas = true
					if raycast_node.get_collider() != null:
						var hex_tile = raycast_node.get_collider().get_parent()
						var hex = $"/root/Board".get_hex_from_tile(hex_tile)

						
					
						if old_hex != null:
							if old_hex != hex:
								outline.set_hex_outline("ui",hex, get_color(predicate.can_play(hex.coord)))
								outline.set_hex_outline("ui", old_hex, Color.TRANSPARENT)
								old_hex = hex
						else:
							outline.set_hex_outline("ui",hex, get_color(predicate.can_play(hex.coord)))
							old_hex = hex
					#raycast.call_deferred("free")
				else:
					var hover_padding = 30
					var hand_position = get_index()
					var hand_size = player.hand.get_child_count()
					var next_card : PlayableCard = player.hand.get_child(hand_position+1)
					var previous_card : PlayableCard = player.hand.get_child(hand_position-1)
					if hand_position < hand_size and next_card:
						if card_node.global_position.x > next_card.card_node.global_position.x - hover_padding:
							player.hand.move_child(next_card, hand_position)
							next_card.set_hand_pos()
							
					if hand_position > 0:
						if previous_card:
							if card_node.global_position.x < previous_card.card_node.global_position.x + hover_padding:
								player.hand.move_child(previous_card, hand_position)
								previous_card.set_hand_pos()
					else:
						if card_node.global_position.x < player.redraw.global_position.x + hover_padding and player.can_redraw():
							start_redraw()
						elif redraw:
							stop_redraw()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not threshold_met:
				dragging = false
				if redraw:
					redraw_card()
			else:
				if old_hex:
					if predicate.can_play(old_hex.coord):
						outline.set_hex_outline("ui", old_hex, Color.TRANSPARENT)
						play_card()
						call_deferred("free")

				dragging = false
				threshold_met = false
				treshold_cancelled()

			hover_stop()
			if player.hovered_card:
				player.hovered_card.hover_stop()

func play_card ():

	match card.type:
		Card.CARD_TYPE.HQ:
			AudioManager.play_3d_sfx_for_all("play_HQ", Vector3(0,0,0))
		Card.CARD_TYPE.Spell:
			AudioManager.play_3d_sfx_for_all("play_spell", Vector3(0,0,0))
		Card.CARD_TYPE.Structure:
			AudioManager.play_3d_sfx_for_all("play_structure", Vector3(0,0,0))
		Card.CARD_TYPE.Unit:
			AudioManager.play_3d_sfx_for_all("play_unit", Vector3(0,0,0))
		Card.CARD_TYPE.Equipment:
			pass

	GameManager.player.pay_cost(card.cost)
	card.play_callable.call(old_hex.coord)
	GameManager.deck.reweight_deck()
	GameManager.deck.hand.erase(card)

	reorder_cards()
	

func test(event: InputEvent):
	if event is InputEventMouseButton:
		if player.hovered_card == self:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if not dragging and not reading and GameManager.my_turn() and predicate.can_play(null):
					dragging = true
					drag_start = get_viewport().get_mouse_position()
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if not reading:
					reading = true
					start_reading()
	
func get_color(flag : bool) -> Color:
	return Color.LIME if flag else Color.RED

func reorder_cards():
	for child in player.hand.get_children():
		if child is PlayableCard:
			if child.get_index() > get_index():
				player.hand.move_child(child, child.get_index()-1)
				child.set_hand_pos()

func set_hand_pos():
	var tween = create_tween()
	tween.tween_property(self, "position:x", calculate_position(), 0.1)


func calculate_position():
	var hand_index = get_index()
	return hand_index * 200
	
