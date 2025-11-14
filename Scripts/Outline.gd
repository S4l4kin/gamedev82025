extends Node
class_name Outline

var layers : Dictionary[String, Dictionary] = {}
@onready var board : BoardManager = $"/root/Board" 



func add_layer(layer_name:String, outline_thickness = 2):
	var layer_viewport = SubViewport.new()
	layer_viewport.name = layer_name +"Viewport"

	layer_viewport.transparent_bg = true
	layer_viewport.own_world_3d = true

	#layer_viewport.set_script(preload("res://Scripts/ViewpoertSyncer.gd"))

	var layer_camera = Camera3D.new()
	layer_camera.name = "Camera"

	layer_camera.set_cull_mask_value(2, false)
	layer_camera.set_cull_mask_value(3, true)
	
	layer_viewport.add_child(layer_camera)



	layers[layer_name] = {"hexes":{}, "colors": {}}

	add_child(layer_viewport)
	layers[layer_name].viewport = layer_viewport

	var layer_color_rect = ColorRect.new()
	layer_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(layer_color_rect)
	layers[layer_name].color_rect = layer_color_rect

	var outline_material = ShaderMaterial.new()
	outline_material.shader = preload("res://Scripts/Shaders/outline_shader.gdshader")
	outline_material.resource_local_to_scene = true
	

	
	outline_material.set_shader_parameter("stencilMask", layer_viewport.get_texture())
	outline_material.set_shader_parameter("lineThickness", outline_thickness)
	layer_color_rect.material = outline_material
	$SubViewportContainer.move_to_front()

	

func set_outline(layer:String, obj:Node, color:Color):
	if not layers.keys().has(layer):
		add_layer(layer)

	var layer_viewport = layers[layer].viewport
	var obj_clone = obj.duplicate()
	obj_clone.global_transform = obj.global_transform
	if obj_clone is VisualInstance3D:
		obj_clone.set_layer_mask_value(2, false)
		obj_clone.set_layer_mask_value(3, true)
	
	if not layers[layer].colors.keys().has(color):
		var color_material = create_outline_material(color)
		layers[layer].colors[color] = color_material
	
	obj_clone.material_override = layers[layer].colors[color]

	layer_viewport.add_child(obj_clone)

func set_hex_outline(layer_name:String, hex:Hex, color:Color):
	if not layers.keys().has(layer_name):
		add_layer(layer_name)
		
	var layer = layers[layer_name]

	if color.a == 1:
		if not layer.hexes.keys().has(hex.coord):
			var hex_copy = MeshInstance3D.new()
			hex_copy.mesh = hex.tile.mesh
			hex_copy.global_transform = hex.tile.global_transform
			layer.hexes[hex.coord] = hex_copy
			layer.viewport.add_child(hex_copy)
		if not layer.colors.keys().has(color):
			var color_material = create_outline_material(color)
			layer.colors[color] = color_material

		layer.hexes[hex.coord].material_override = layer.colors[color]
	else:
		if layer.hexes.keys().has(hex.coord):
			layer.hexes[hex.coord].free()
			layer.hexes.erase(hex.coord)


func create_outline_material(color:Color, line_thickness: float=2) -> Material:
	var color_material = StandardMaterial3D.new()
	color_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	color_material.albedo_color = color
	return color_material

func set_hex_coord_outline(layer_name:String, coord:Vector2i, color:Color):
	var hex = board.get_hex(coord.x, coord.y)
	set_hex_outline(layer_name, hex, color)

func _process(_delta: float) -> void:
	var viewport := get_tree().root.get_viewport()
	var current_camera := viewport.get_camera_3d()

	for layer in layers.keys():
		var layer_viewport = layers[layer].viewport
		var layer_camera = layer_viewport.get_node("Camera")
		if layer_viewport.size != viewport.size:
			layer_viewport.size = viewport.size
	
		if current_camera:
			layer_camera.fov = current_camera.fov
			layer_camera.global_transform = current_camera.global_transform
