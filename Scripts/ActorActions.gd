extends Node3D
class_name ActorActions
@onready var button_list : Control = $"3DControl/SubViewport/ScrollContainer/CenterContainer/VBoxContainer"

func get_actions(hex: Vector2i) -> void:
	var actors = GameManager.board_manager.get_actors(hex.x, hex.y)
	var tile = GameManager.board_manager.get_hex(hex.x, hex.y)
	
	for child in button_list.get_children():
		child.free()
	
	if len(actors) == 0:
		return
	
	if actors.has("unit"):
		if not GameManager.is_mine(actors.unit):
			actors.erase("unit")
	if actors.has("structure"):
		if not GameManager.is_mine(actors.structure):
			actors.erase("structure")
	var actions: Dictionary
	for actor in actors.keys():
		if len(actors) > 1:
			var actor_actions = actors[actor].get_actions()
			for action in actor_actions.keys():
				var action_name = actor.capitalize() + ": " + action
				actions.merge({action_name: actor_actions[action]})
		else:
			actions.merge(actors[actor].get_actions())

	

	global_position = tile.tile.global_position
	for action in actions.keys():
		var button = Button.new()
		button.text = action
		button.disabled = not actions[action].active
		button_list.add_child(button)
		button.connect("pressed", (func (): actions[action].callable.call(); hide()))
		button.add_theme_font_size_override("font_size", 35)
	show()
