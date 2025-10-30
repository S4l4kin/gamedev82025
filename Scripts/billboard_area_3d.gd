extends Area3D

enum BILLBOARD_TYPE {Disabled, Enabled, YBillboard}

@export var billboard_mode : BILLBOARD_TYPE

func _process(delta):
	# Try to match the area with the material's billboard setting, if enabled.
	if billboard_mode > 0:
		# Get the camera.
		var camera := get_viewport().get_camera_3d()
		# Look in the same direction as the camera.
		var look := camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
		look = position + look

		# Y-Billboard: Lock Y rotation, but gives bad results if the camera is tilted.
		if billboard_mode == 2:
			look = Vector3(look.x, 0, look.z)

		look_at(look, Vector3.UP)

		# Rotate in the Z axis to compensate camera tilt.
		rotate_object_local(Vector3.BACK, camera.rotation.z)
