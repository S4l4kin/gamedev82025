extends Node
class_name Actor

@export var health: int
var card_id
var x : int
var y : int

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
