extends Node3D

@export var keyboard_speed : float = 1
@export var mouse_speed : float = 1
@export var zoom_speed : float = 1
@onready var board : BoardManager = GameManager.board_manager

var zoom_level : float = 1
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
	if delta_direction != Vector3.ZERO:
		move_camera(delta_direction * keyboard_speed * delta * max(zoom_level,0.1))


func _ready():
	zoom_level = global_position.y / zoom_speed
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.button_mask&MOUSE_BUTTON_MASK_MIDDLE == MOUSE_BUTTON_MASK_MIDDLE or event.button_mask&MOUSE_BUTTON_MASK_RIGHT == MOUSE_BUTTON_MASK_RIGHT:
			if mouse_old_pos != null:
				move_camera(Vector3(-event.position.x+mouse_old_pos.x,0,-event.position.y+mouse_old_pos.y)*mouse_speed/100 * max(zoom_level,0.1)/10)
			mouse_old_pos = event.position
		else:
			mouse_old_pos = null
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			if position.y > 1:
				position -=  Vector3(0, -sin(rotation.x), cos(rotation.x)) * zoom_speed
				zoom_level = global_position.y / zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
				position +=  Vector3(0, -sin(rotation.x), cos(rotation.x)) * zoom_speed
				zoom_level = global_position.y / zoom_speed
		#print(event)

func move_camera(dir: Vector3):
	var new_pos = global_position + dir
	var top_left = board.tile_generator.get_tile_pos(board.grid_start.x, board.grid_start.y)
	var bottom_right = board.tile_generator.get_tile_pos(board.grid_end.x, board.grid_end.y) + Vector3.BACK * 5
	global_position = Vector3(clamp(new_pos.x, top_left.x, bottom_right.x), new_pos.y, clamp(new_pos.z, top_left.z, bottom_right.z, ))
