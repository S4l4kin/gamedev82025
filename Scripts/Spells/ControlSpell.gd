extends Spell
class_name MindControlSpell

func play():
	var board = GameManager.board_manager
	var unit = board.get_hex(coord.x, coord.y).unit
	unit.player = player
	unit.color = board.player_colors[player]
	unit.renderer.add_mask(Color.WHITE, unit.color)
	unit.renderer.set_numeric_label_color(unit.color)
	call_deferred("spell_finished")
