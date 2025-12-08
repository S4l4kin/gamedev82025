extends Node3D
class_name Actor

@export var health: int
@export var damage_modifier: int

@export var card_id : String
@export var player : String
@export var start_color : Color

var tween : Tween
signal done_attacking

var color : Color:
	set(s):
		color = s
		$Model.color = s

var x : int
var y : int

func _ready() -> void:
	color = start_color
	damage_modifier = 0

func get_actions() -> Dictionary[String, Dictionary]:

	return {}

func on_play():
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

func set_damage_modifier(modifier: int):
	damage_modifier += modifier

func get_health():
	return health

func set_health(new_health: int):
	health = new_health
	#print(health)
	if health <=0:
		on_death()
		print(player + " dödens dö")
		$"/root/Board".remove_actor(self)
