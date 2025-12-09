extends Control

func _ready():
	$EndTurn.connect("pressed", (func ():
		GameManager.network.send_messages({"type":"next_turn"})
	))
