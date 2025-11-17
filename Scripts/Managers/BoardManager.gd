extends Node
class_name BoardManager



var hexes : Dictionary[Vector2i, Hex] = {}

@export var conqured_hexes : Dictionary[Vector2i,Array]
var player_colors : Dictionary[String, Color]

@export var orientation : BoardGenerator.HEX_ROTATION
@export var grid_width : int = 8
@export var grid_height : int = 8
@export var grid_scale : float = 1

@onready var board_generator : BoardGenerator = BoardGenerator.new(self, orientation, grid_scale)
@onready var hover_timer : Timer = $HoverTimer
@onready var tiles = $Tiles
var current_hovered_hex : Vector2i
@onready var inspect_card: CardInspector = $Card
@onready var actor_actions: ActorActions = $Actions

@onready var outline : Outline = $Outline

var hex_selector : HexSelect

signal hex_pressed (x:int, y:int)
signal hex_hovered (x:int, y:int)
signal mouse_entered_hex (x:int, y:int)
signal mouse_exited_hex (x:int, y:int)

func init_tiles():
	for x in grid_width:
		for y in grid_height:
			var hex_instance = board_generator.create_hex_tile(x,y)
			tiles.add_child(hex_instance)
			var hex = Hex.new()
			var coord = Vector2i(x,y)
			hex.passable = true
			hex.coord = coord
			hex.tile = hex_instance

			hexes[coord] = hex

func set_conqured_hex_colors(players):
	for player in players:
		player_colors[player.name] = Color(player.color.r, player.color.g, player.color.b)


func _ready():
	init_tiles()
	GameManager.network.connect("recieved_message", handle_network)
	
	connect("mouse_exited_hex", (func (_x, _y): current_hovered_hex = Vector2i(-1,-1)))
	connect("mouse_entered_hex", (func (x, y): current_hovered_hex = Vector2i(x, y); hover_timer.start()))
	hover_timer.connect("timeout", (func ():  inspect_hex(current_hovered_hex.x, current_hovered_hex.y)))
	connect("hex_pressed", select_hex)

	$Outline.add_layer("conqured_hexes", 2)
	$Outline.add_layer("ui",1.25)
	$Outline.set_hex_outline("test", get_hex(2,2), Color.RED)
	for i in get_neighbours(2,2):
		$Outline.set_hex_outline("test", i, Color.RED)
	$Outline.set_hex_outline("test", get_hex(2,5), Color.ORANGE_RED)


func handle_network(data):
	if (data.type == "create_actor"):
		var coord = data.coord
		var unit = data.unit
		var card = GameManager.card_manager.get_card_data(unit.id)
		card.health = unit.power
		card.speed = unit.speed
		var actor = create_actor(Vector2i(coord.x, coord.y), card)
		actor.player = data.player
	if (data.type == "move_unit"):
		var previous_hex = Vector2i(data.previous_hex.x, data.previous_hex.y)
		var next_hex = Vector2i(data.next_hex.x, data.next_hex.y)
		move_unit(previous_hex, next_hex)


func inspect_hex(x:int, y:int):
	if get_actors(x, y) != {}:
		inspect_card.show_card("unit_hovered", Vector2i(x,y))

func select_hex(x:int ,y:int):
	if hex_selector != null:
		return
	var actors = get_actors(x, y)
	if  actors != {}:
		inspect_card.show_card("unit_selected", Vector2i(x,y))
	else:
		inspect_card.change_lock("unit_selected", false)
	
	if GameManager.my_turn():
		actor_actions.get_actions(Vector2i(x,y))

func get_hex(x:int, y:int) -> Hex:
	var hex : Hex = null
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:

		hex = hexes[Vector2i(x,y)]
	return hex

func add_hex_selector(selector: HexSelect):
	inspect_card.change_lock("unit_selected", false)
	hex_selector = selector
	add_child(selector)

func cube_to_coord(q:int,r:int) -> Vector2i:
	var parity : int
	var col :int
	var row : int
	if orientation == BoardGenerator.HEX_ROTATION.Pointy_Top:
		parity = r&1
		col = q + (r + parity) / 2
		row = r
	else:
		parity = q&1
		col = q
		row = r + (q + parity) / 2
	return Vector2i(col, row)

func coord_to_cube(x:int,y:int):
	var parity : int
	var q :int
	var r : int
	if orientation == BoardGenerator.HEX_ROTATION.Pointy_Top:
		parity = y&1
		q = x - (y + parity) / 2
		r = y
	else:
		parity = x&1
		q = x	
		r = y - (x + parity) / 2
	return {"q":q, "r":r, "s":-q-r}


func get_neighbours(x:int, y:int) -> Array[Hex]:
	var neighbours : Array[Hex] = []
	var cube = coord_to_cube(x,y)
	var cube_neighbours = [{"q":cube.q+1,"r":cube.r},{"q":cube.q+1,"r":cube.r-1},{"q":cube.q,"r":cube.r-1},{"q":cube.q-1,"r":cube.r},{"q":cube.q-1,"r":cube.r+1},{"q":cube.q,"r":cube.r+1}]

	for neighbour in cube_neighbours:
		var coord = cube_to_coord(neighbour.q,neighbour.r)
		var hex = get_hex(coord.x,coord.y)
		if hex != null:
			neighbours.append(hex)
	
	
	return neighbours

# TODO: Refactor using tweens
func move_unit(from :Vector2i, to:Vector2i) -> void:
	var from_hex = get_hex(from.x, from.y)
	var to_hex = get_hex(to.x, to.y)
	var unit = from_hex.unit
	if unit == null:
		push_warning("tried to move a non-existant unit")
		return

	if not to_hex.passable:
		return

	unit.on_pre_move()

	var defender : Actor = to_hex.structure if to_hex.unit == null else to_hex.unit
	var move : bool = true
	
	unit.global_position = to_hex.tile.global_position
	
	if defender != null:
		move = unit.attack(defender)

	if move:
		unit.x = to.x
		unit.y = to.y
		to_hex.unit = unit
		from_hex.unit = null
		unit.on_post_move()
		outline.set_hex_coord_outline("conqured_hexes", Vector2i(unit.x, unit.y), player_colors[unit.player])


func create_actor(coord: Vector2i, actor:Card) -> Actor:
	var actor_node : Actor = GameManager.card_manager.get_card_actor(actor)
	actor_node.x = coord.x
	actor_node.y = coord.y
	add_child(actor_node)
	var hex = get_hex(coord.x, coord.y)
	if actor_node is Unit:
		hex.unit = actor_node
	if actor_node is Structure:
		hex.structure = actor_node
	actor_node.global_position = hex.tile.global_position
	return actor_node

func remove_actor(actor: Actor):
	actor.call_deferred("queue_free")
	if actor is Unit:
		hexes[Vector2i(actor.x,actor.y)].unit = null
	if actor is Structure:
		hexes[Vector2i(actor.x,actor.y)].structure = null


func get_hex_from_tile(tile: Object) -> Hex:
	for coord in hexes.keys():
		if hexes[coord].tile == tile:
			return hexes[coord]
	return null
func get_actors(x:int, y:int) -> Dictionary[String, Actor]:
	var actors : Dictionary[String, Actor] = {}
	var hex = get_hex(x,y)

	if hex != null:

		var unit : Unit = null
		unit = hex.unit
		var structure : Structure = null
		structure = hex.structure
		
		if unit != null:
			actors["unit"] = unit
		if structure != null:
			actors["structure"] = structure
	
	return actors
