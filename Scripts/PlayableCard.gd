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

func _ready():
	$Card.connect("gui_input", test)
	$Card.connect("mouse_entered", hover_start)
	$Card.connect("mouse_exited", hover_stop)
	predicate.card = card

func start_reading():
	var tween = create_tween()
	var center : Control = $"/root/Player/ReadingCenter"
	tween.tween_property($Card, "global_position", center.global_position-$Card.size/2, 0.2)
	tween.tween_property($Card, "scale", Vector2.ONE * 1.5, 0.2)
	z_index = 10

func hover_start():
	if not dragging and not reading:
		var tween = create_tween()
		tween.tween_property($Card, "position", Vector2.UP * 10, 0.2)
		audiomanager.play_global_sfx("hover_card")

func hover_stop():
	if not dragging:
		var tween = create_tween()
		tween.tween_property($Card, "position", Vector2.ZERO, 0.2)
		tween.tween_property($Card, "scale", Vector2.ONE, 0.2)
		reading = false
		z_index = 0

func treshold_exeeded():
	var tween = create_tween()
	tween.tween_property($Card, "scale", Vector2.ONE * 0.3, 0.2)	
	tween.tween_property($Card, "modulate", Color(1,1,1,0.5), 0.2)
	
	
func treshold_cancelled():
	var tween = create_tween()
	tween.tween_property($Card, "scale", Vector2.ONE * 1, 0.2)
	tween.tween_property($Card, "modulate", Color.WHITE, 0.2)
	if old_hex:
		outline.set_hex_outline("ui", old_hex, Color.TRANSPARENT)
		old_hex = null
	
var old_hex
var offset : Vector2 = Vector2(91.0,157.0)
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT == MOUSE_BUTTON_LEFT:
			if dragging:
				var card_node : Control = get_node("Card")
				if card_node.position.y <= play_threshold:
					if not threshold_met:
						treshold_exeeded()
						
						threshold_met = true
				else:
					if threshold_met:
						treshold_cancelled()
						threshold_met = false
				card_node.position = event.position - drag_start

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

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not threshold_met:
				dragging = false
				hover_stop()
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

func play_card ():
	#audiomanager.play_3d_sfx_for_all("click", Vector3(0,0,0), 10.0)
	GameManager.player.pay_cost(card.cost)
	card.play_callable.call(old_hex.coord)
	GameManager.deck.reweight_deck()
	GameManager.deck.hand.remove_at(get_index())

func test(event: InputEvent):
	if event is InputEventMouseButton:
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
