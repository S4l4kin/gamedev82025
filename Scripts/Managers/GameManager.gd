extends Node

var card_manager_scene = preload("res://Scenes/card_manager.tscn")
var board_manager_scene = preload("res://Scenes/board.tscn")
var player_scene = preload("res://Scenes/player.tscn")

var card_manager : CardManager
var board_manager : BoardManager
var player : DeckManager

func _ready():
	card_manager = card_manager_scene.instantiate()
	board_manager = board_manager_scene.instantiate()
	player = player_scene.instantiate()

	get_tree().root.add_child.call_deferred(card_manager)
	get_tree().root.add_child.call_deferred(board_manager)
	get_tree().root.add_child.call_deferred(player)
