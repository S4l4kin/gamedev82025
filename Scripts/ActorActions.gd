extends Node3D
class_name ActorActions
@onready var board : BoardManager = $"/root/Board"
@onready var button_list : Control = $"3DControl/SubViewport/ScrollContainer/CenterContainer/VBoxContainer"

func get_actions(hex: Vector2i) -> void:
	var actors = board.get_actors(hex.x, hex.y)
	var tile = board.get_hex(hex.x, hex.y)
	if len(actors) == 0:
		return
	
	var actions: Dictionary
	for actor in actors.keys():
		actions.merge(actors[actor].get_actions())

	for child in button_list.get_children():
		child.free()

	global_position = tile.tile.global_position
	for action in actions.keys():
		var button = Button.new()
		button.text = action
		button.disabled = not actions[action].active
		button_list.add_child(button)
		button.connect("pressed", (func (): actions[action].callable.call(); hide()))
		button.add_theme_font_size_override("font_size", 35)
	show()
