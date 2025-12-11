extends Feature
class_name OreFeature

@export var color : GlobalEnums.COST_COLORS

func create_model() -> Node:
	var renderer : ObjectRenderer = preload("res://Scenes/ModelRenderer.tscn").instantiate()
	renderer.model = model
	renderer.call_deferred("render_amount", 1)
	renderer.call_deferred("add_mask", Color(1.0, 1.0, 1.0, 1.0), GameManager.card_manager.get_resource_color(color))
	return renderer