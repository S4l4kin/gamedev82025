extends Actor
class_name Unit

var move_distance
var attack_damage: int


func on_attack(enemy: Actor):
	enemy._on_defend(self)
	on_defend(enemy)

func get_attack_damage():
	return attack_damage
	
func set_attack_damage(damage_value: int):
	attack_damage = damage_value
