extends Resource
class_name Feature

@export var display_card : String
@export var model : PackedScene
var name:
	get():
		return display_card



func create_model() -> Node:
	var renderer : ObjectRenderer = preload("res://Scenes/ModelRenderer.tscn").instantiate()
	renderer.model = model
	renderer.call_deferred("render_amount", 1)
	return renderer
