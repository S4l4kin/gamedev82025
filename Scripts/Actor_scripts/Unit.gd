extends Actor
class_name Unit

@export var max_speed : int
@onready var speed :int = max_speed 


func _ready():

	super._ready()

#Returns true if the unit survived the attack
func attack(enemy:Actor) -> bool:
	#Activate pre attack and defend abilities
	print(player + " före pre attack")
	on_pre_attack(enemy)
	print(player + " före enemy pre defend")
	enemy.on_pre_defend(self)

	#Deal damage to both attacker and defender
	var current_attack = get_attack_damage()
	damage(enemy.get_attack_damage())
	enemy.damage(current_attack)


	#If either attacker or defender survived actiave post attack and defend abilities
	if health > 0:
		on_post_attack(enemy)
	print(enemy.player + str(enemy.health))
	if enemy.health > 0:
		enemy.on_post_defend(self)
	emit_signal("done_attacking")
	return health > 0


func on_pre_attack(_enemy: Actor):
	#print(player)
	#print("Unit pre attack")
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

func on_turn_start():
	speed = max_speed
	
	#If Unit is ontop of boulder feature on turn start give player temporary resources
	if GameManager.is_mine(self):
		var board = GameManager.board_manager
		var hex = board.get_hex(x, y)
		if hex.feature is OreFeature:
			GameManager.player.add_resource(hex.feature.color)


func get_move_range():
	var press_check = (func(_x: int, _y:int):
		return x ==_x and y == _y
		)
	var path_check = (func(path: Array[Vector2i]):
		if len(path) == 0:
			return true
		var coord = path[-1]
		var hex = GameManager.board_manager.get_hex(coord.x, coord.y)
		if hex.unit:
			return hex.unit.player != player or hex.unit.actor_id == actor_id
		return true
		)
	GameManager.board_manager.add_hex_selector(PathHexSelect.new(speed, move, press_check, path_check))
	

func get_speed():
	return speed

func move(path : Array):
	if len(path) > 1:
		path.pop_front()
		var move_path = []
		for next_hex in path:
			move_path.append({"x": next_hex.x, "y": next_hex.y})
		GameManager.network.send_messages({
			"type":"move_unit",
			"unit": actor_id,
			"path": move_path
		})
