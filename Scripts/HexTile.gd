extends Node3D

@onready var area_node = $Area3D 

signal pressed ()

signal mouse_entered ()

signal mouse_exited ()

func _ready() -> void:
	area_node.connect("input_event", handel_input)

	area_node.connect("mouse_entered", func ():  emit_signal("mouse_entered"))
	area_node.connect("mouse_exited", func ():  emit_signal("mouse_exited"))

func handel_input(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("pressed")
