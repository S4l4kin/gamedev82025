extends Structure

var spawned_unit = preload("res://Cards/Test/farmer.tres")
var spawned_per_turn : int = 1
func on_turn_start():
	var board = GameManager.board_manager
	var neighbours = board.get_neighbours(x, y)
	for i in spawned_per_turn:
		var random_neighbour = neighbours.pick_random()
		neighbours.erase(random_neighbour)
		while random_neighbour.unit and len(neighbours) > 1:
			random_neighbour = neighbours.pick_random()
			neighbours.erase(random_neighbour)
		if len(neighbours) > 0:
			GameManager.network.send_messages({"type" : "create_actor", "unit": {"id": spawned_unit.id, "speed": spawned_unit.speed, "power": spawned_unit.health}, "coord": {"x": random_neighbour.coord.x, "y": random_neighbour.coord.y}, "player": player})
