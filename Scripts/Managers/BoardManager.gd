extends Node
class_name BoardManager



var hexes : Dictionary[Vector2i, Hex] = {}

@export var conqured_hexes : Dictionary[Vector2i, String]
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

@onready var outline : Outline = $"Shaders/Outline"
@onready var fog : FogOfWar = $"Fog"

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
	GameManager.connect("turn_end", attack_structures)
	connect("mouse_exited_hex", (func (_x, _y): current_hovered_hex = Vector2i(-1,-1)))
	connect("mouse_entered_hex", (func (x, y): current_hovered_hex = Vector2i(x, y); hover_timer.start()))
	hover_timer.connect("timeout", (func ():  inspect_hex(current_hovered_hex.x, current_hovered_hex.y)))
	connect("hex_pressed", select_hex)

	outline.add_layer("conqured_hexes", 2)
	outline.add_layer("ui",1.25)

	var padding :float = 2
	
	fog.set_bounding_box(-Vector3(1,0,1)*padding, get_hex(grid_width-1,grid_height-1).tile.position+Vector3(1,0,1)*padding)
	
	
	var start_hex = get_hex(randi_range(0, grid_width-1), randi_range(0, grid_height-1))
	fog.reveal_coord(start_hex.tile.global_position, 6)
	var camera = get_viewport().get_camera_3d()
	camera.global_position = Vector3(start_hex.tile.global_position.x, camera.global_position.y,start_hex.tile.global_position.z)
	fog.start_updating()


func handle_network(data):
	if (data.type == "create_actor"):
		var coord = data.coord
		var unit = data.unit
		var card = GameManager.card_manager.get_card_data(unit.id)
		card.health = unit.power
		card.speed = unit.speed
		var actor = create_actor(Vector2i(coord.x, coord.y), card)
		actor.player = data.player
		actor.color = player_colors[data.player]
		actor.on_play()

	if (data.type == "move_unit"):
		var from := Vector2i(data.from.x, data.from.y)
		var path : Array[Vector2i] = []
		for coord in data.path:
			path.append(Vector2i(coord.x, coord.y))
			
		move_unit(from, path)


func inspect_hex(x:int, y:int):
	if get_actors(x, y) != {}:
		inspect_card.show_card("unit_hovered", Vector2i(x,y))

func select_hex(x:int ,y:int):
	if hex_selector != null:
		return
	print("Clicked Hex %s, %s"%[x,y])
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
	add_child(selector)
	hex_selector = selector
	inspect_card.get_node("3DControl").active = false
	actor_actions.get_node("3DControl").active = false

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


func attack_structures(player_turn : String):
	for hex in hexes.values():
		var unit = hex.unit
		var structure = hex.structure
		if not unit or not structure:
			continue
		if unit.player == player_turn:
			if unit.player != structure.player:
				unit.attack(structure)	


func move_unit(from :Vector2i, path: Array[Vector2i]) -> void:
	print(get_hex(from.x, from.y).unit)
	print(path)
	var from_hex = get_hex(from.x, from.y)
	var unit = from_hex.unit
	var moving_speed = 1
	if unit == null:
		push_warning("tried to move a non-existant unit")
		return
	var tween = get_tree().create_tween()
	for step in path:
		unit.speed -= 1
		var next_hex = get_hex(step.x, step.y)
		if not next_hex.passable:
			break
		tween.tween_callback(func ():
			unit.on_pre_move()
			fog.reveal_hex(step.x, step.y)
		)
		tween.tween_property(unit, "position", next_hex.tile.global_position, moving_speed)
		tween.tween_callback(func ():
			if not unit:
				return
			var defender : Actor = next_hex.unit
			var survived : bool = true
			if defender:
				if defender.player != unit.player:
					survived = unit.attack(defender)
			if survived:
				var current_hex = get_hex(unit.x, unit.y)
				unit.x = step.x
				unit.y = step.y
				if current_hex.unit == unit:
					current_hex.unit = null
				if not defender:
					next_hex.unit = unit
				
				unit.on_post_move()
				
		)


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
