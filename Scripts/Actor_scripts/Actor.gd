extends Node3D
class_name Actor

@export var health: int


@export var card_id : String
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


func set_health(new_health: int):
	health = new_health
	renderer.render_amount(new_health)
	if health <=0:
		on_death()
		$"/root/Board".remove_actor(self)
