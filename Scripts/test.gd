extends Node

@onready var card_manager : CardManager = $"../CardManager"

func _ready():
	call_deferred("make_card")


func make_card():
	var card = card_manager.get_card_scene("test_card").instantiate()
	add_child(card)
