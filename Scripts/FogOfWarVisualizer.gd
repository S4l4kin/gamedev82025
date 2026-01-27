extends Node
class_name FogOwWarVisualiser


@export var fog_color : Color
@export var density : float = 1
@export var fog_height : float = 1

@export_group("Clouds")
@export var clouds_texture : Texture2D
@export var texure_height : int
@export var cloud_size : Vector2
@export var cloud_speed : float
@export var cloud_dir : Array[float]

@onready var clouds : MultiMeshInstance3D = $Clouds
@onready var quad : MeshInstance3D = $Quad
@onready var fog := get_parent()


var bounding_box : Rect2

func _ready() -> void:
	quad.material_override.set_shader_parameter("color", fog_color)
	clouds.material_override.set_shader_parameter("color", fog_color)
	clouds.material_override.set_shader_parameter("sprite", clouds_texture)
	@warning_ignore("integer_division")
	clouds.material_override.set_shader_parameter("sprite_amount", clouds_texture.get_height() / texure_height)

	var multimesh = MultiMesh.new()
	var cloud_mesh = QuadMesh.new()
	
	multimesh.use_colors = true
	multimesh.use_custom_data = true
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	
	cloud_mesh.size = cloud_size
	multimesh.mesh = cloud_mesh

	clouds.multimesh = multimesh


func _process(delta):
	update_cloud_pos(delta)
	pass

func update_cloud_pos(delta):
	var multimesh = clouds.multimesh
	for i in multimesh.instance_count:
		var dir = cloud_dir[i] + randf_range(-1,1)*0.05
		cloud_dir[i] = dir
		var new_pos = multimesh.get_instance_transform(i).origin + Vector3(cos(dir), 0, sin(dir)) * cloud_speed * delta
		var far = bounding_box.end - bounding_box.position
		if new_pos.x > far.x:
			new_pos.x = 0
		elif new_pos.x < 0:
			new_pos.x = far.x

		if new_pos.z > far.y:
			new_pos.z = 0
		elif new_pos.z < 0:
			new_pos.z = far.y
		multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, new_pos))

		var local_pos = Vector2(new_pos.x - bounding_box.position.x, new_pos.z - bounding_box.position.y) + bounding_box.position
		var uv = Vector2(float(local_pos.x) / (bounding_box.end.x - bounding_box.position.x), float(local_pos.y) / (bounding_box.end.y - bounding_box.position.y))
		var old_color = multimesh.get_instance_color(i)
		multimesh.set_instance_color(i, Color(uv.x, uv.y, old_color.b))

func set_size (_bounding_box : Rect2):
	
	bounding_box = _bounding_box
	var a : Vector3 = Vector3(bounding_box.position.x, fog_height ,bounding_box.position.y) 
	var dx = bounding_box.end.x - bounding_box.position.x
	var dy = bounding_box.end.y - bounding_box.position.y

	quad.global_position = a
	clouds.global_position = a

	var mesh = QuadMesh.new()
	
	mesh.size.x = dx
	mesh.size.y = dy
	mesh.center_offset.x = mesh.size.x/2
	mesh.center_offset.y = -mesh.size.y/2
	quad.mesh = mesh

	

	quad.material_override.set_shader_parameter("mask", fog.fow_texture)
	clouds.material_override.set_shader_parameter("mask", fog.fow_texture)
	$TextureRect.texture = fog.fow_texture

	var cloud_amount = ceil((dx * dy) / (cloud_size.x * cloud_size.y) * density) # Whole area / cloud area * cloud density

	print("Cloud needed to fill area: %s"%cloud_amount)

	var multimesh = clouds.multimesh
	multimesh.instance_count = cloud_amount
	@warning_ignore("integer_division")
	var sprite_amount = clouds_texture.get_height() / texure_height
	for i in cloud_amount:
		var cloud_x = randf()
		var cloud_y = randf()
		var sprite = randi_range(0,sprite_amount-1)
		multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(cloud_x * dx, 0, cloud_y * dy)))
		multimesh.set_instance_color(i, Color(cloud_x, cloud_y, float(sprite)/sprite_amount))
		cloud_dir.append(randf_range(-1,1) * 2 * PI)
