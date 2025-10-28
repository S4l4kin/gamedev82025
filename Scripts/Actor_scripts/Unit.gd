extends Actor
class_name Unit

var max_speed : int

#Returns true if the unit survived the attack
func attack(enemy:Actor) -> bool:
	#Activate pre attack and defend abilities
	on_pre_attack(enemy)
	enemy.on_pre_defend(self)

	#Deal damage to both attacker and defender
	var current_attack = get_attack_damage()
	set_health(health - enemy.get_attack_damage())
	enemy.set_health(enemy.health - current_attack)

	#If either attacker or defender survived actiave post attack and defend abilities
	if health > 0:
		on_post_attack(enemy)
	if enemy.health > 0:
		enemy.on_post_defend(self)

	return health > 0

func on_pre_attack(_enemy: Actor):
	pass
func on_post_attack(_enemy: Actor):
	pass


func get_attack_damage():
	return health

func on_pre_move():
	print("pre move")
	pass
func on_post_move():
	print("pos move")	
	pass