extends Structure

@onready var board := GameManager.board_manager


func on_play():
	if GameManager.is_mine(self):
		if not MushroomNetworkUtil.instance:
			var mushroom_network = MushroomNetworkUtil.new()
			GameManager.board_manager.add_child(mushroom_network)

		var mushroom_network = MushroomNetworkUtil.instance
		mushroom_network.add_teleport_location(Vector2i(x, y))
	super.on_play()

func get_actions() -> Dictionary[String, Dictionary]:
	var actions : Dictionary[String, Dictionary] = {"Teleport" = {"callable" = get_teleport_destination, "active" = unit_stands_on_structure()}}
	actions.merge(super.get_actions())
	return actions

func unit_stands_on_structure() -> bool:
	return board.get_hex(x, y).unit != null

func get_teleport_destination():
	var mushroom_network = MushroomNetworkUtil.instance
	var press_check : Callable = (func(_x: int, _y: int) -> bool:
		return board.get_hex(_x, _y).unit == null
		)
	board.add_hex_selector(RangeHexSelect.new(mushroom_network.teleport_locations, mushroom_network.teleport_radius, 0, get_location, press_check))

func get_location(target_x: int, target_y: int):
	print("should teleport")
	var unit_id = board.get_hex(x,y).unit.actor_id
	GameManager.network.send_messages({"type": "actor_ability", "id": actor_id, "method":"teleport", "args":[unit_id, target_x, target_y]})
	pass

func teleport(unit_id, location_x, location_y):
	var unit := board.get_actor(unit_id)
	var from_hex = board.get_hex(x,y)
	var to_hex = board.get_hex(location_x,location_y)
	MushroomNetworkUtil.instance.teleport(unit, from_hex, to_hex)
