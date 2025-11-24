@tool
extends MeshInstance3D
class_name FogOfWar

@onready var board: BoardManager = GameManager.board_manager

@export var pixel_resolution : int = 28800000
var resolution : Vector2i
var pixel_density : int
var vertical_offset : float = 1

var rd : RenderingDevice
var current_mask : Image
var current_texture : ImageTexture

var target_mask : Image

var circles : Array[Dictionary]
@onready var timer : Timer = $UpdateTimer
#Configures so that the cameras bounding box is point a and point b
func set_bounding_box(a: Vector3, b: Vector3):

	var dx : float = abs(b.x-a.x)
	var dz : float = abs(b.z-a.z)
	print(b)
	bounding_box.position = Vector2(a.x, a.z)
	bounding_box.end = Vector2(b.x, b.z)

	var resolution_y : int = roundi(sqrt(pixel_resolution)+0.4)
	var resolution_x : int = roundi((dx/dz*resolution_y)+0.4)
	
	resolution = Vector2i(resolution_x, resolution_y)
	pixel_density = resolution_x / dx
	mesh = QuadMesh.new()
	
	mesh.size.x = dx
	mesh.size.y = dz
	mesh.center_offset.x = mesh.size.x/2
	mesh.center_offset.y = -mesh.size.y/2

	global_position = a
	
	current_mask = Image.create_empty(resolution_x,resolution_y, false, Image.FORMAT_RGBAF)
	target_mask = Image.create_empty(resolution_x,resolution_y, false, Image.FORMAT_RGBAF)

	set_rendering_device()
	

var update_fog_mask_shader := RID()
var update_fog_mask_pipeline := RID()

var draw_fog_mask_shader := RID()
var draw_fog_mask_pipeline := RID()

var target_mask_view : RDTextureView
var target_mask_format : RDTextureFormat

var current_mask_view : RDTextureView
var current_mask_format : RDTextureFormat

var target_mask_texture : RID
var current_mask_texture : RID

var bounding_box : Rect2

func set_rendering_device():

	rd = RenderingServer.get_rendering_device()

	target_mask_view = RDTextureView.new()
	target_mask_format = RDTextureFormat.new()
	current_mask_view = RDTextureView.new()
	current_mask_format = RDTextureFormat.new()

	
	target_mask_format.height = target_mask.get_height()
	target_mask_format.width = target_mask.get_width()
	target_mask_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	target_mask_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT+ 
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	)

	
	current_mask_format.height = target_mask.get_height()
	current_mask_format.width = target_mask.get_width()
	current_mask_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	current_mask_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT +
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT + 
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + 
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	)

	target_mask_texture = rd.texture_create(target_mask_format, target_mask_view, [target_mask.get_data()])
	current_mask_texture = rd.texture_create(current_mask_format, current_mask_view, [current_mask.get_data()])

	var texture_rd = Texture2DRD.new()
	texture_rd.texture_rd_rid = current_mask_texture
	self.material_override.set_shader_parameter("mask", texture_rd)
	$"/root/Board/TextureRect".texture = texture_rd

func start_updating():
	timer.connect("timeout", update_fog_mask)
	timer.start()
func stop_updating():
	timer.stop()
	timer.disconnect("timeout", update_fog_mask)

func update_fog_mask():
	if not rd:
		return

	var update_fog_mask_shader_file := load("res://Scripts/Shaders/update_fog_of_war_mask.glsl")
	var update_fog_mask_shader_spirv: RDShaderSPIRV = update_fog_mask_shader_file.get_spirv()
	update_fog_mask_shader = rd.shader_create_from_spirv(update_fog_mask_shader_spirv)
	update_fog_mask_pipeline = rd.compute_pipeline_create(update_fog_mask_shader)
	
	#var start = Time.get_ticks_usec()
	var target_mask_uniform = RDUniform.new()
	target_mask_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	target_mask_uniform.binding = 0
	target_mask_uniform.add_id(target_mask_texture)


	var current_mask_uniform = RDUniform.new()
	current_mask_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	current_mask_uniform.binding = 1
	current_mask_uniform.add_id(current_mask_texture)


	var groups: Vector3i = Vector3((resolution.x - 1) / 32.0 + 1.0, (resolution.y - 1) / 32.0 + 1.0, 1.0).floor()

	var bindings: Array[RDUniform] = [
		target_mask_uniform,
		current_mask_uniform
	]

	var uniform_set := rd.uniform_set_create(bindings, update_fog_mask_shader, 0)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, update_fog_mask_pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
	rd.compute_list_end()
	#var end = Time.get_ticks_usec()
	#var time = (end-start)/1000.0

	rd.free_rid(update_fog_mask_shader)
	#rd.free_rid(update_fog_mask_pipeline)
	#print(target_mask_uniform.get_reference_count())
#	print("Update Fog of war took: %sms" % [time])


func draw_onto_fog_mask(pos: Vector2, radius: float, seed: bool):
	if not rd:
		return
	var start = Time.get_ticks_usec()
	
	var draw_fog_mask_shader_file := load("res://Scripts/Shaders/draw_fog_of_war_mask.glsl")
	var draw_fog_mask_shader_spirv: RDShaderSPIRV = draw_fog_mask_shader_file.get_spirv()
	draw_fog_mask_shader = rd.shader_create_from_spirv(draw_fog_mask_shader_spirv)
	draw_fog_mask_pipeline = rd.compute_pipeline_create(draw_fog_mask_shader)

	var target_mask_uniform = RDUniform.new()
	target_mask_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	target_mask_uniform.binding = 0
	target_mask_uniform.add_id(target_mask_texture)

	var input := PackedFloat32Array([pos.x, pos.y, radius * pixel_density, seed])
	var input_bytes := input.to_byte_array()
	var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)

	var draw_uniform = RDUniform.new()
	draw_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	draw_uniform.binding = 1
	draw_uniform.add_id(buffer)

	var groups: Vector3i = Vector3((resolution.x - 1) / 32.0 + 1.0, (resolution.y - 1) / 32.0 + 1.0, 1.0).floor()

	var bindings: Array[RDUniform] = [
		target_mask_uniform,
		draw_uniform
	]

	var uniform_set := rd.uniform_set_create(bindings, draw_fog_mask_shader, 0)
	var compute_list := rd.compute_list_begin()

	rd.compute_list_bind_compute_pipeline(compute_list, draw_fog_mask_pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
	rd.compute_list_end()

	rd.free_rid(draw_fog_mask_shader)
	rd.free_rid(buffer)
	
	var end = Time.get_ticks_usec()
	var time = (end-start)/1000.0
	print("Drawing onto target mask took: %sms" % [time])

func reveal_hex(x: int, y:int):
	var hex = board.get_hex(x, y)
	var hex_position = hex.tile.global_position

	
	var uv = world_space_to_pixel_space(Vector2(hex_position.x, hex_position.z))



	var radius : float = 4
	draw_onto_fog_mask(uv, radius, not circle_overlap(uv, radius))
	circles.append({"x": uv.x, "y":uv.y, "radius": radius})

func reveal_coord(pos: Vector3, radius: float):

	var uv = world_space_to_pixel_space(Vector2(pos.x,pos.z))

	draw_onto_fog_mask(uv, radius, not circle_overlap(uv, radius))
	circles.append({"x": uv.x, "y":uv.y, "radius": radius})

func circle_overlap (pos: Vector2i, radius: float) -> bool:
	for circle in circles:
		if sqrt((pos.x-circle.x)**2+(pos.y-circle.y)**2) < (circle.radius + radius) * pixel_density:
			return true
	print("No Overlapp!")
	return false

func world_space_to_pixel_space(pos: Vector2) -> Vector2:
	pos = Vector2(pos.x - bounding_box.position.x, pos.y - bounding_box.position.y)
	return Vector2(float(pos.x) / (bounding_box.end.x - bounding_box.position.x) * resolution.x, float(pos.y) / (bounding_box.end.y - bounding_box.position.y) * resolution.y)
