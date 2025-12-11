extends Structure
class_name HQ

func get_actions() -> Dictionary[String, Dictionary]:
	return {"Activate" = {"callable" = print.bind("HQ activated"), "active" = true}}

func on_play():
	$"/root/Player/EndTurn".disabled = GameManager.current_turn != GameManager.player_name
	super.on_play()

func on_death():
	GameManager.remove_player(player)