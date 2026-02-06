extends Node
class_name BoardManager



var hexes : Dictionary[Vector2i, Hex] = {}

@export var conqured_hexes : Dictionary[Vector2i, String]
@export var world_seed : String
var player_colors : Dictionary[String, Color]

@export var orientation : TileGenerator.HEX_ROTATION
@export var land_amount : int = 400
var grid_start : Vector2i
var grid_end : Vector2i
@export var grid_scale : float = 1

var tile_generator : TileGenerator
var world_gen : WorldGen
@onready var hover_timer : Timer = $HoverTimer
@onready var tiles = $Tiles
var current_hovered_hex : Vector2i
@onready var inspect_card: CardInspector = $Card
@onready var actor_actions: ActorActions = $Actions

@onready var outline : Outline = $"Shaders/Outline"
@onready var fog : FogOfWar = $"FogOfWar"

var hex_selector : HexSelect

signal hex_pressed (x:int, y:int)
signal hex_hovered (x:int, y:int)
signal mouse_entered_hex (x:int, y:int)
signal mouse_exited_hex (x:int, y:int)

var active_spells : Array[Spell]


func set_conqured_hex_colors(players):
	for player in players:
		player_colors[player.name] = Color(player.color.r, player.color.g, player.color.b)

func generate_world():
	var ore_features : Array[FeatureGenerator] = [
		RandomPositionFeatureGenerator.new(ResourceLoader.load("res://Features/red_ore.tres", "Feature"), 3*4), 
		RandomPositionFeatureGenerator.new(ResourceLoader.load("res://Features/yellow_ore.tres", "Feature"), 3*4),
		RandomPositionFeatureGenerator.new(ResourceLoader.load("res://Features/orange_ore.tres", "Feature"), 6*4)]
	world_gen = WorldGen.new(hash(world_seed), BigLandmassGenerator.new(land_amount), ore_features)
	var world_data = world_gen.generate_world()
	var hex_data = world_data.hex_data
	
	tile_generator = TileGenerator.new(self, tiles ,orientation, grid_scale, hex_data)

	grid_start = world_data.grid_start
	grid_end = world_data.grid_end

	#init_tiles()

	for coord in hex_data:
		hexes[coord] = tile_generator.create_hex_tile(coord.x, coord.y)
		#if coord == Vector2i.ZERO:
		#	var mesh : Mesh = hexes[coord].tile.mesh.duplicate() 
		#	var material = StandardMaterial3D.new()
		#	material.albedo_color = Color.RED
		#	mesh.surface_set_material(0, material)
		#	hexes[coord].tile.mesh = mesh
	outline.generate_empty_mulit_mesh()
func _ready():
	
	GameManager.network.connect("recieved_message", handle_network)
	
	if GameManager.network.is_host():
		if world_seed.is_empty():
			randomize()
			world_seed = str(randi())
		GameManager.network.send_messages({"type":"generate_world", "seed":world_seed})
	
	GameManager.connect("turn_end", attack_structures)
	connect("mouse_exited_hex", (func (_x, _y): current_hovered_hex = Vector2i(-1,-1)))
	connect("mouse_entered_hex", (func (x, y): current_hovered_hex = Vector2i(x, y); hover_timer.start()))
	hover_timer.connect("timeout", (func ():  inspect_hex(current_hovered_hex.x, current_hovered_hex.y)))
	connect("hex_pressed", select_hex)

	outline.add_layer("conqured_hexes", 2)
	outline.add_layer("ui", 1.25)

	
	

#func test_ore():
#	var rng = RandomNumberGenerator.new()
#	rng.seed = 137
#	var red_ore = ResourceLoader.load("res://Features/red_ore.tres", "Feature")
#	var yellow_ore = ResourceLoader.load("res://Features/yellow_ore.tres", "Feature")
#	var orange_ore = ResourceLoader.load("res://Features/orange_ore.tres", "Feature")
#	for i in 3:
#		var hex = get_hex(rng.randi_range(1, grid_width-1),rng.randi_range(1, grid_height-1))
#		print(hex)
#		while hex.feature:
#			hex = get_hex(rng.randi_range(1, grid_width-1),rng.randi_range(1, grid_height-1))
#		hex.feature = red_ore
#	for i in 3:
#		var hex = get_hex(rng.randi_range(1, grid_width-1),rng.randi_range(1, grid_height-1))
#		while hex.feature:
#			hex = get_hex(rng.randi_range(1, grid_width-1),rng.randi_range(1, grid_height-1))
#		hex.feature = yellow_ore
#	for i in 6:
#		var hex = get_hex(rng.randi_range(1, grid_width-1),rng.randi_range(1, grid_height-1))
#		while hex.feature:
#			hex = get_hex(rng.randi_range(1, grid_width-1),rng.randi_range(1, grid_height-1))
#		hex.feature = orange_ore

func handle_network(data):
	if (data.type == "generate_world"):
		world_seed = data.seed
		generate_world()

		#Setup FOW
		var padding :float = 3
		var top_left_pos = tile_generator.get_tile_pos(grid_start.x, grid_start.y)-Vector3(1,0,1)*padding
		var bottom_right_pos = tile_generator.get_tile_pos(grid_end.x, grid_end.y)+Vector3(1,0,1)*padding
		fog.set_bounding_box(top_left_pos, bottom_right_pos)
		fog.reveal_coastline(world_gen.world_data.coastline)
		fog.start_updating()

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
		var unit := get_actor(data.unit)
		var path : Array[Vector2i] = []
		for coord in data.path:
			path.append(Vector2i(coord.x, coord.y))
			
		move_unit(unit, path)
	
	if (data.type == "actor_ability"):
		var actor = get_actor(data.id)
		if actor.has_method(data.method):
			actor.callv(data.method, data.args)
		else:
			push_error("Tried to call an undefined method on actor %s"%actor.card_id)
	if(data.type == "cast_spell"):
		var card = GameManager.card_manager.get_card_data(data.id)
		var spell = card.custom_script.new()
		spell.player = data.player
		spell.spell_id = next_id
		spell.card = card
		next_id = next_id.sha256_text()
		spell.coord = Vector2i(data.coord.x, data.coord.y)
		active_spells.append(spell)

		spell.play()
	if (data.type == "spell_function"):
		var spell = get_active_spell(data.id)
		if spell.has_method(data.method):
			spell.callv(data.method, data.args)
		else:
			push_error("Tried to call an undefined method on actor %s"%spell.card_id)
	

func inspect_hex(x:int, y:int):
	var hex = get_hex(x,y)
	if get_actors(x, y) != {}:
		inspect_card.show_card("unit_hovered", Vector2i(x,y))
	if hex:
		if not is_instance_of(hex.feature, NoneFeature):
			inspect_card.show_card("unit_hovered", Vector2i(x,y))


func select_hex(x:int ,y:int):
	if hex_selector != null:
		return
	print("Clicked Hex %s, %s"%[x,y])
	var actors = get_actors(x, y)
	if  actors != {} or not is_instance_of(get_hex(x,y).feature, NoneFeature):
		inspect_card.show_card("unit_selected", Vector2i(x,y))
	else:
		inspect_card.change_lock("unit_selected", false)
	
	if GameManager.my_turn():
		actor_actions.get_actions(Vector2i(x,y))

func get_hex(x:int, y:int) -> Hex:
	var hex : Hex = null
	if hexes.has(Vector2i(x,y)):
		hex = hexes[Vector2i(x,y)]
	return hex

func add_hex_selector(selector: HexSelect):
	inspect_card.change_lock("unit_selected", false)
	add_child(selector)
	hex_selector = selector
	inspect_card.get_node("3DControl").active = false
	actor_actions.get_node("3DControl").active = false




func get_neighbours(x:int, y:int) -> Array[Hex]:
	var neighbours : Array[Hex] = []
	var neighbour_coords = HexGridUtil.get_neighbours_coord(x, y, orientation)

	for coord in neighbour_coords:
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


func move_unit(unit : Actor, path: Array[Vector2i]) -> void:
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

var next_id = "start_id".sha256_text()
func create_actor(coord: Vector2i, actor:Card) -> Actor:
	var actor_node : Actor = GameManager.card_manager.get_card_actor(actor)
	actor_node.x = coord.x
	actor_node.y = coord.y
	actor_node.actor_id = next_id
	next_id = next_id.sha256_text()
	add_child(actor_node)
	var hex = get_hex(coord.x, coord.y)
	if actor_node is Unit:
		hex.unit = actor_node
	if actor_node is Structure:
		hex.structure = actor_node
	actor_node.global_position = hex.position
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

func get_actor(actor_id: String) -> Actor:
	for hex in hexes.values():
		if hex.unit:
			if hex.unit.actor_id == actor_id:
				return hex.unit
		if hex.structure:
			if hex.structure.actor_id == actor_id:
				return hex.structure
	return null

func get_active_spell(spell_id: String) -> Spell:
	for spell in active_spells:
		if spell.spell_id == spell_id:
			return spell
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
