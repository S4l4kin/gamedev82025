extends Spell
class_name HealingSpell

func play():
    var board = GameManager.board_manager
    var unit = board.get_hex(coord.x, coord.y).unit
    unit.heal(3)