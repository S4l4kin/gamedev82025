extends Node

@export var slider : Slider
@export var texture : Control
@export var line : ParabolaLine


func _ready():
	slider.value_changed.connect(test)

func test(value):
	texture.global_position = line.get_point_weight(value)
	texture.rotation = line.get_perpendicular_weight(value)
