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


@export var card_id : String
var actor_id : String
@export var player : String

var tween : Tween
@onready var renderer : ActorRenderer:
	get():
		return $Model

signal done_attacking

var color : Color:
	set(s):
		color = s
		$Model.color = s

var x : int
var y : int


func get_actions() -> Dictionary[String, Dictionary]:

	return {}

func on_play():
	pass

func on_pre_defend(_enemy: Actor):
	pass

func on_post_defend(_enemy: Actor):
	pass

func on_death():
	pass

func get_attack_damage():
	return 0

func damage(damage):
	health -= damage
