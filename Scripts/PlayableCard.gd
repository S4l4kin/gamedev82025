extends Control
class_name PlayableCard

var card : Card

var hovered : bool
var hover_height = -10
var deck_manager : DeckManager
var rest_position : Vector2

@onready var raycast_node : RayCast3D = $Raycast
@onready var outline : Outline = GameManager.board_manager.outline
@onready var predicate : Predicate = card.play_predicate.new()
@onready var player = GameManager.player
@onready var card_node : Control = $Card

func _ready():


	card_node.mouse_entered.connect(func(): hovered = true)
	card_node.mouse_exited.connect(func(): hovered = false)

	$Card.connect("mouse_entered", hover_start)
	$Card.connect("mouse_exited", reset_card)


	predicate.card = card
	rest_position = card_node.position
	call_deferred("set_start_pos")
	call_deferred("set_hand_pos")

func set_start_pos():
	global_position = player.card_line.get_point_weight(1.5)

func hover_start():
	AudioManager.play_global_sfx("hover_card")
	
	if player.mouse_state == Player.MouseState.NONE:
		var tween = create_tween()
		
		var tween_speed = 0.1
		tween.tween_property(card_node, "position:y", rest_position.y+hover_height, tween_speed)
		
		z_index = 10
		player.hovered_card = self

func drag_start():
	var tween = create_tween()
	var tween_speed = 0.1
	tween.tween_property(self, "rotation", 0, tween_speed)

func reset_card():
	if player.mouse_state == Player.MouseState.NONE:
		var tween = create_tween().set_parallel()
		var tween_speed = 0.1
		tween.tween_property(card_node, "position", rest_position if not hovered else Vector2(rest_position.x, rest_position.y+hover_height), tween_speed)
		tween.tween_property(card_node, "scale", Vector2.ONE, tween_speed)
		tween.tween_property(card_node, "modulate", Color.WHITE, tween_speed)
		tween.set_parallel(false)
		tween.tween_callback(func(): if hovered: hover_start())
		set_hand_pos()
		z_index = 0
		player.hovered_card = null
		

func selecting_start():
	var tween = create_tween().set_parallel()
		
	var tween_speed = 0.1
	var card_size = 0.1
	var card_alpha = 0.4
	tween.tween_property(card_node, "scale", Vector2.ONE * card_size, tween_speed)
	tween.tween_property(card_node, "modulate", Color(1,1,1,card_alpha), tween_speed)

func selecting_stop():
	var tween = create_tween().set_parallel()
		
	var tween_speed = 0.1
	tween.tween_property(card_node, "scale", Vector2.ONE, tween_speed)
	tween.tween_property(card_node, "modulate", Color.WHITE, tween_speed)

func set_hand_pos():
	var tween = create_tween()
	var tween_speed = 0.1
	var pos = player.calculate_position(get_index())
	var rot = player.calculate_rotation(get_index())
	tween.set_parallel()
	tween.tween_property(self, "global_position", pos, tween_speed)
	tween.tween_property(self, "rotation", rot, tween_speed)

func start_reading():
	var tween = create_tween().set_parallel()
		
	var tween_speed = 0.2
	var reading_scale = 1.5
	var offset = card_node.size
	tween.tween_property(self, "rotation", 0, tween_speed)
	tween.tween_property(card_node, "scale", Vector2.ONE * (reading_scale / player.hand.scale.x), tween_speed)
	tween.tween_property(card_node, "global_position", player.reading_marker.global_position - offset, tween_speed)
	z_index = 20

func play_card (hex: Hex):

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
	card.play_callable.call(hex.coord)
	GameManager.deck.reweight_deck()
	GameManager.deck.hand.erase(card)
	
