@tool
extends Node3D
class_name ActorRenderer
var color : Color
@export var model : PackedScene
var animations : Dictionary[String, Texture]
var max_model : int
@export var offsets : Array[PackedVector2Array]
@export_range(1,9, 1) var show_offset : int:
	set(s):
		show_offset = s
		if Engine.is_editor_hint():
			current_offset = offsets[s-1]
			
@export var current_offset : PackedVector2Array:
	set(s):
		current_offset = s
		if Engine.is_editor_hint():
			offsets[show_offset-1] = s
var gizmo_color := [Color.RED, Color.ORANGE_RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.LIGHT_BLUE, Color.DARK_BLUE, Color.PURPLE, Color.MAGENTA]

var actor : Actor
@onready var numerical_power : Sprite3D = get_parent().get_node("NumericalPower")
var pixel_density : int = 128
func _process(_delta):
	if Engine.is_editor_hint():
		
		var gizmo : MultiMeshInstance3D = $Gizmo
		var multi_mesh := MultiMesh.new()
		var point_mesh := CylinderMesh.new()
		point_mesh.bottom_radius = 0
		point_mesh.top_radius = 0.05
		point_mesh.height = 0.01
		multi_mesh.mesh = point_mesh
		multi_mesh.use_colors = true
		multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
		gizmo.multimesh = multi_mesh
		multi_mesh.instance_count = show_offset
		for i in len(offsets[show_offset-1]):
			var _offsets = offsets[show_offset-1][i]
			multi_mesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(_offsets.x, 0, _offsets.y)))
			multi_mesh.set_instance_color(i, gizmo_color[i])

func render_amount(amount: int):
	if amount > max_model:
		numerical_power.show()
		numerical_power.get_node("Viewport/Text").text = str(amount)
		amount = max_model
	else:
		numerical_power.hide()

	var offset = offsets[amount-1]
	for child in get_children():
		if child is MultiMeshInstance3D:
			#print(child.name)
			child.multimesh.visible_instance_count = amount
			for i in amount:
				var pos = Vector3(offset[i].x,0,offset[i].y)
				child.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, pos))



func _ready() -> void:
	if Engine.is_editor_hint():
		return
	$Gizmo.free()
	call_deferred("init_renderer")
var setuped : bool = false
func init_renderer():
	setuped = true
	actor = get_parent()
	color = GameManager.board_manager.player_colors[actor.player]
	var model_node = model.instantiate()
	max_model = model_node.max_model
	if model_node.pixel_density > 0:
		pixel_density = model.pixel_density
	for child in model_node.get_children():
		if child is Sprite2D:
			var mask = child.get_node("Mask")

			var material = ShaderMaterial.new()
			material.shader = preload("res://Scripts/Shaders/actor_renderer_shader.gdshader")

			material.set_shader_parameter("offset", child.position)
			material.set_shader_parameter("sprite", child.texture)
			material.set_shader_parameter("playerMask", mask.texture)
			material.set_shader_parameter("playerColor", color)
			material.set_shader_parameter("center", child.offset)
			material.set_shader_parameter("rotation", child.rotation_degrees)
			material.set_shader_parameter("scale", child.scale)
			material.set_shader_parameter("skew", rad_to_deg(child.skew))

			var multi_mesh_instance = MultiMeshInstance3D.new()
			multi_mesh_instance.name = child.name
			multi_mesh_instance.material_override = material
			
			var multi_mesh = MultiMesh.new()
			var mesh = QuadMesh.new()
			mesh.size = child.texture.get_size() / pixel_density
			multi_mesh.mesh = mesh
			multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
			multi_mesh.instance_count = 9
			multi_mesh_instance.multimesh = multi_mesh
			add_child(multi_mesh_instance)
	render_amount(actor.health)
	numerical_power.get_node("Viewport/Fill").color = color
	#numerical_power.get_node("Viewport/Border").color = Color.BLACK if color.get_luminance() > 0.5 else Color.WHITE
	numerical_power.get_node("Viewport/Text").self_modulate = Color.BLACK if color.get_luminance() > 0.5 else Color.WHITE
