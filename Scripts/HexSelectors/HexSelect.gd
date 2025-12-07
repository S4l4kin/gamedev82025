extends Node
class_name HexSelect

var origin : Vector2i
var hex_range: int

var callable : Callable

func done_selecting():
    GameManager.board_manager.inspect_card.get_node("3DControl").active = true
    GameManager.board_manager.actor_actions.get_node("3DControl").active = true
    call_deferred("free")