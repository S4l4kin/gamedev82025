extends Node
class_name HexSelect


var callable : Callable
var cancel_callable : Callable
@onready var board : BoardManager = GameManager.board_manager
@onready var outline : Outline = GameManager.board_manager.outline
var empty_callable : Callable = (func():pass)

func done_selecting():
    GameManager.board_manager.inspect_card.get_node("3DControl").active = true
    GameManager.board_manager.actor_actions.get_node("3DControl").active = true
    call_deferred("free")