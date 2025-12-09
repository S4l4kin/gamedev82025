extends Actor
class_name Unit

@export var max_speed : int
@onready var speed :int = max_speed 


func _ready():
	GameManager.connect("turn_start", func(): speed = max_speed)

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
	emit_signal("done_attacking")
	return health > 0

func on_pre_attack(_enemy: Actor):
	pass
func on_post_attack(_enemy: Actor):
	pass


func get_attack_damage():
	return health

func on_pre_move():
	print("X:%s, Y:%s"%[x,y])
func on_post_move():
	pass

func get_actions() -> Dictionary[String, Dictionary]:
	return {"Move" = {"callable" = get_move_range, "active" = (speed > 0)}}


func get_move_range():
	$"/root/Board".add_hex_selector(PathHexSelect.new(x,y, speed, move))
	

func move(path : Array):
	if len(path) > 1:
		var from = path.pop_front()
		var move_path = []
		for next_hex in path:
			move_path.append({"x": next_hex.x, "y": next_hex.y})
		GameManager.network.send_messages({
			"type":"move_unit",
			"from": {"x": from.x, "y": from.y},
			"path": move_path
		})
