extends Control

func _ready():
	$EndTurn.connect("pressed", (func ():
		if GameManager.my_turn():
			audiomanager.play_global_sfx("click")
		GameManager.network.send_messages({"type":"next_turn"})
	))
