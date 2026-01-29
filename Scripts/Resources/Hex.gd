extends Resource
class_name Hex

var unit : Unit
var structure : Structure
var feature : Feature:
	set(s):
		feature = s
		if s:
			feature_model = feature.create_model()
			feature_model.global_position = position
			GameManager.board_manager.add_child(feature_model)
		else:
			feature_model.call_deferred("free")
var feature_model : ObjectRenderer
var tile : MeshInstance3D
var passable : bool = true
var coord : Vector2i
var position : Vector3
