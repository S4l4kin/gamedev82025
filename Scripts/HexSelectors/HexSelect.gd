extends Node
class_name HexSelect


var callable : Callable
@onready var board : BoardManager = GameManager.board_manager
@onready var outline : Outline = GameManager.board_manager.outline

func done_selecting():
    GameManager.board_manager.inspect_card.get_node("3DControl").active = true
    GameManager.board_manager.actor_actions.get_node("3DControl").active = true
    call_deferred("free")