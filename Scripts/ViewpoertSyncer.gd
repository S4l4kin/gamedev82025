extends Viewport
class_name  ViewportSyncer

@onready var stencil_camera : Camera3D = $Camera
@export var sync_camera : bool = true
func _process(_delta : float) -> void:
	var viewport := get_tree().root.get_viewport()
	var current_camera := viewport.get_camera_3d()

	#if self.size != viewport.size:
	#	self.size = viewport.size

	if sync_camera and current_camera:
		stencil_camera.fov = current_camera.fov
		stencil_camera.global_transform = current_camera.global_transform
