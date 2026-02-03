class_name WorldGen

var base_generator : BaseGenerator
var feature_generators : Array[FeatureGenerator]
var rng : RandomNumberGenerator
var world_data : Dictionary[String, Variant]
func _init(_seed: int, _base_generator: BaseGenerator, _feature_generators: Array[FeatureGenerator]) -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = _seed
	base_generator = _base_generator
	feature_generators = _feature_generators

	base_generator.rng = rng
	for fg in feature_generators:
		fg.rng = rng
	

func generate_world() -> Dictionary[String, Variant]:
	world_data = {}
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
	world_data.grid_start = top_left
	world_data.grid_end = bottom_right

	world_data.coastline = base_generator.find_coastline(base, top_left, bottom_right)

	var hex_data : Dictionary[Vector2i, Hex] = {}
	for coord in base.keys():
		if base.has(coord):
			var hex = Hex.new()
			hex.biome = Hex.Biome.LAND if base[coord] else Hex.Biome.SEA
			#hex.coord = coord
			hex_data[coord] = hex
	world_data.hex_data = hex_data

	for feature in feature_generators:
		feature.generate_feature(world_data)

	return world_data

func place_features():
	pass
