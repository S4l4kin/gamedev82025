extends Node3D
class_name Actor

@export var health: int = 1:
	set(s):
		health = s
		if health <= 0:
			on_death()
			GameManager.board_manager.remove_actor(self)
		elif renderer:
			renderer.call_deferred("render_amount", s)

@export var damage_modifier: int

@export var card_id : String
var actor_id : String
@export var player : String

var tween : Tween

@onready var renderer : ObjectRenderer = $Model:
	get():
		return $Model

signal done_attacking

var color : Color

var x : int
var y : int


func _ready() -> void:
	damage_modifier = 0

	call_deferred("setup_renderer")
	GameManager.connect("turn_start", func(player_turn): if player_turn == GameManager.player_name: on_turn_start())
	GameManager.connect("turn_end",  func(player_turn): if player_turn == GameManager.player_name: on_turn_end())

func setup_renderer():
	renderer.add_mask(Color.WHITE, color)
	renderer.set_numeric_label_color(color)
	renderer.call_deferred("render_amount", health)

func get_actions() -> Dictionary[String, Dictionary]:

	return {}

func on_play():
	pass

func on_turn_start():
	pass

func on_turn_end():
	pass

func on_pre_defend(_enemy: Actor):
	#print(player)
	#print("Actor pre defend")
	pass

func on_post_defend(_enemy: Actor):
	pass

func on_death():
	pass

func get_attack_damage():
	return 0

func damage(amount: int):
	health -= amount
func heal(amount: int):
	health += amount
