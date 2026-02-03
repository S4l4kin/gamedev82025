extends Resource
class_name Hex

enum Biome {LAND, SEA}

var unit : Unit
var structure : Structure
var feature : Feature = NoneFeature.new()#:
	#set(s):
	#	if s:
	#		if not is_instance_of(s, NoneFeature):
	#			if feature_model:
	#				feature_model.call_deferred("free")
	#			feature_model = feature.create_model()
	#			feature_model.global_position = position
	#			GameManager.board_manager.add_child(feature_model)
	#		elif feature_model:
	#				feature_model.call_deferred("free")
	#	else:
	#		feature_model.call_deferred("free")
	#	feature = s
var feature_model : ObjectRenderer
var tile : MeshInstance3D
var passable : bool = true
var coord : Vector2i
var position : Vector3#:
	#get():
	#	return GameManager.board_manager.tile_generator.get_tile_pos(coord.x, coord.y)
var biome : Biome
