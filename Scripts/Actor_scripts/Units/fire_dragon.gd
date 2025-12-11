extends Unit



func on_pre_attack(enemy: Actor):
	apply_burn(enemy)

func on_pre_defend(enemy: Actor):
	apply_burn(enemy)

func apply_burn(enemy: Actor):
	var burn = BurnEffect.new()
	enemy.add_child(burn)