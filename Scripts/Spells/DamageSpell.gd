extends Spell
class_name DamagingSpell

func play():
    var board = GameManager.board_manager
    var unit = board.get_hex(coord.x, coord.y).unit
    unit.damage(3)
    call_deferred("spell_finished")
