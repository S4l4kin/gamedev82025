extends Node3D

@export var keyboard_speed : float = 1
@export var mouse_speed : float = 1
var mouse_old_pos = null

func _process(delta: float) -> void:
	var delta_direction : Vector3
	if Input.is_key_pressed(KEY_W):
		delta_direction = Vector3.FORWARD 
	if Input.is_key_pressed(KEY_S):
		delta_direction = Vector3.BACK 
	if Input.is_key_pressed(KEY_A):
		delta_direction = Vector3.LEFT 
	if Input.is_key_pressed(KEY_D):
		delta_direction = Vector3.RIGHT 
	global_position = global_position + delta_direction * keyboard_speed * delta * 10

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.button_mask&MOUSE_BUTTON_MASK_MIDDLE == MOUSE_BUTTON_MASK_MIDDLE:
			if mouse_old_pos != null:
				global_position = global_position + Vector3(-event.position.x+mouse_old_pos.x,0,-event.position.y+mouse_old_pos.y)*mouse_speed/100
			mouse_old_pos = event.position
		else:
			mouse_old_pos = null
