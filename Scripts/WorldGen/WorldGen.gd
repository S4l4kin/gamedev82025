class_name WorldGen

var base_generator : BaseGenerator
var feature_generators : Array[FeatureGenerator]
var rng : RandomNumberGenerator
var world_data 
func _init(_seed: int, _base_generator: BaseGenerator, _feature_generators: Array[FeatureGenerator]) -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = _seed
	base_generator = _base_generator
	feature_generators = _feature_generators

	base_generator.rng = rng
	for fg in feature_generators:
		fg.rng = rng
	

func generate_world() -> Dictionary[String, Variant]:
	var temp : Dictionary[String, Variant] = {}
	var base = base_generator.generate_base()

	var top_left : Vector2i = Vector2i.ZERO
	var bottom_right : Vector2i = Vector2i.ZERO

	for coord in base.keys():
		if coord.x < top_left.x:
			top_left.x = coord.x
		if coord.x > bottom_right.x:
			bottom_right.x = coord.x
		if coord.y < top_left.y:
			top_left.y = coord.y
		if coord.y > bottom_right.y:
			bottom_right.y = coord.y
	temp.grid_start = top_left
	temp.grid_end = bottom_right

	temp.coastline = base_generator.find_coastline(base, top_left, bottom_right)

	base.get_or_add(top_left, false)
	base.get_or_add(bottom_right, false)

	var hex_data : Dictionary[Vector2i, Dictionary] = {}
	for hex in base.keys():
		if base.has(hex):
			hex_data[hex] = {"biome": "land" if base[hex] else "sea" }
	temp.hex_data = hex_data
	world_data = temp
	return temp

func place_features():
	pass
