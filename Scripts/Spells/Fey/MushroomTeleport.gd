extends Spell
class_name MushroomTeleport
const extra_cost : Dictionary = {}

var unit : Unit
var from_hex : Hex
var board : BoardManager
func play():
	board = GameManager.board_manager
	unit = board.get_hex(coord.x, coord.y).unit
	from_hex = board.get_hex(coord.x, coord.y)
	var mushroom_network = MushroomNetworkUtil.instance
	var press_check : Callable = (func(_x: int, _y: int) -> bool:
		return board.get_hex(_x, _y).unit == null
		)
	board.add_hex_selector(RangeHexSelect.new(mushroom_network.teleport_locations, mushroom_network.teleport_radius, 0, get_location, press_check, spell_canceled))

func get_location(target_x: int, target_y: int):
	GameManager.network.send_messages({"type": "spell_function", "id": spell_id, "method":"teleport", "args":[target_x, target_y]})
	pass

func teleport(location_x, location_y):
	var to_hex = board.get_hex(location_x,location_y)
	MushroomNetworkUtil.instance.teleport(unit, from_hex, to_hex)
	call_deferred("spell_finished")