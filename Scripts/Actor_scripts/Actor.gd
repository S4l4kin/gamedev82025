extends Node
class_name Actor

var health: int


func on_defend(enemy: Actor):
	health -= enemy.get_attack_damage()
	if health <=0:
		on_death()

func on_death():
	queue_free()

func get_attack_damage():
	return 0

func set_health(healtValue: int):
	health = healtValue
