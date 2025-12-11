extends Node
class_name Outline

var layers : Dictionary[String, Dictionary] = {}
@onready var board : BoardManager = GameManager.board_manager


var empty_multi_mesh : MultiMesh
var mesh_material : Material
func generate_empty_mulit_mesh():

	empty_multi_mesh = MultiMesh.new()
	empty_multi_mesh.mesh = preload("res://Assets/Models/Hex/HexTile.res")
	empty_multi_mesh.use_colors = true
	empty_multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	empty_multi_mesh.instance_count = board.grid_width * board.grid_height
	print("Generating multimesh")
	for coord in board.hexes.keys():
		var mesh_index = coord.y*board.grid_width + coord.x
		var tile = board.hexes[coord].tile
		empty_multi_mesh.set_instance_transform(mesh_index, tile.global_transform)
		empty_multi_mesh.set_instance_color(mesh_index, Color.TRANSPARENT)
	
	mesh_material = StandardMaterial3D.new()
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.vertex_color_use_as_albedo = true
	mesh_material.vertex_color_is_srgb = true
	mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func add_layer(layer_name:String, outline_thickness : float = 2):
	var layer_viewport = SubViewport.new()
	layer_viewport.name = layer_name +"Viewport"

	layer_viewport.transparent_bg = true
	layer_viewport.own_world_3d = true

	#layer_viewport.set_script(preload("res://Scripts/ViewpoertSyncer.gd"))

	var layer_camera = Camera3D.new()
	layer_camera.name = "Camera"

	#layer_camera.set_cull_mask_value(2, false)
	#layer_camera.set_cull_mask_value(3, false)
	#layer_camera.set_cull_mask_value(4, true)
	
	layer_viewport.add_child(layer_camera)

	if not empty_multi_mesh:
		generate_empty_mulit_mesh()
	var multi_mesh = empty_multi_mesh.duplicate()
	var multi_mesh_instance = MultiMeshInstance3D.new()

	multi_mesh_instance.multimesh = multi_mesh
	multi_mesh_instance.material_override = mesh_material
	multi_mesh_instance.material_override = mesh_material
	layer_viewport.add_child(multi_mesh_instance)

	


	layers[layer_name] = {"viewport":layer_viewport, "multi_mesh":multi_mesh}

	add_child(layer_viewport)

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
	#$SubViewportContainer.move_to_front()

	

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
		pass
	
	obj_clone.material_override = layers[layer].colors[color]

	layer_viewport.add_child(obj_clone)

func set_hex_outline(layer_name:String, hex:Hex, color:Color):
	set_hex_coord_outline(layer_name, hex.coord, color)

func set_hex_coord_outline(layer_name:String, coord:Vector2i, color:Color):
	if not layers.keys().has(layer_name):
		add_layer(layer_name)
	var mesh_index = coord.y*board.grid_width + coord.x
	var layer = layers[layer_name]
	layer.multi_mesh.set_instance_color(mesh_index, color)

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
