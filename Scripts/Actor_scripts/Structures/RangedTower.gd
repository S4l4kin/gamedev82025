extends Structure
var shot_fire : bool = true
var shot_range : int = 3
var shot_damage : int = 2

func on_turn_start():
	if GameManager.is_mine(self):
		shot_fire = true
	super.on_turn_start()

func get_actions() -> Dictionary[String, Dictionary]:
	var actions : Dictionary[String, Dictionary] = {"Fire" = {"callable" = get_fire_range, "active" = shot_fire}}
	actions.merge(super.get_actions())
	return actions

func get_fire_range():
	var board = GameManager.board_manager
	var press_check : Callable = (func(_x: int, _y: int) -> bool:
		var actors = board.get_actors(_x, _y)
		var flag = false
		for actor in actors.values():
			if actor.player != player:
				flag = true
		return flag
		)
	board.add_hex_selector(RangeHexSelect.new([Vector2i(x, y)], shot_range, 0, get_target, press_check))

func get_target(target_x: int, target_y: int):
	shot_fire = false
	GameManager.network.send_messages({"type": "actor_ability", "id": actor_id, "method":"shoot_ability", "args":[target_x, target_y]})

func shoot_ability(target_x: int, target_y: int):
	var actors = GameManager.board_manager.get_actors(target_x, target_y)
	AudioManager.play_3d_sfx_for_all("ranged_fight", global_position)

	for actor : Actor in actors.values():
		if actor.player != player:
			actor.damage(shot_damage)
