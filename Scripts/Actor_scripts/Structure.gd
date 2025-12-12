extends Actor
class_name Structure

var conquring_hexes : Array[Vector2i]

func on_play():
	var neighbours = GameManager.board_manager.get_neighbours(x,y)
	conquring_hexes.append(Vector2i(x,y))
	for neighbour : Hex in neighbours:
		conquring_hexes.append(neighbour.coord)
	conqure_hexes()

func on_death():
	var board = GameManager.board_manager
	for coord : Vector2i in conquring_hexes:
		print(coord)
		if not board.conqured_hexes.has(coord):
			board.conqured_hexes.erase(coord)
			board.outline.set_hex_coord_outline("conqured_hexes", coord, Color.TRANSPARENT)

func conqure_hexes():
	var board = GameManager.board_manager
	for coord : Vector2i in conquring_hexes:
		print(coord)
		if not board.conqured_hexes.has(coord):
			board.conqured_hexes[coord] = player
			board.outline.set_hex_coord_outline("conqured_hexes", coord, board.player_colors[player])
			board.fog.reveal_hex(coord.x, coord.y)
