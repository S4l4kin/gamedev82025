extends Structure
class_name HQ


func on_play():
	$"/root/Player/EndTurn".disabled = GameManager.current_turn != GameManager.player_name
	super.on_play()

func on_death():
	GameManager.remove_player(player)
