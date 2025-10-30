extends Node
class_name Actor

@export var health: int


@export var card_id : String
@export var player : String
@export var start_color : Color
var color : Color:
	set(s):
		color = s
		for child in get_node("Models").get_children():
			print(child.name)
			child.modulate = color
var x : int
var y : int

func _ready() -> void:
	color = start_color

func get_actions() -> Dictionary[String, Dictionary]:

	return {}


func on_pre_defend(_enemy: Actor):
	pass

func on_post_defend(_enemy: Actor):
	pass

func on_death():
	call_deferred("queue_free")

func get_attack_damage():
	return 0


func set_health(new_health: int):
	health = new_health
	if health <=0:
		on_death()
