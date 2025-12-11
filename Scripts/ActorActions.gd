extends Node3D
class_name ActorActions
@onready var button_list : Control = $"3DControl/SubViewport/ScrollContainer/CenterContainer/VBoxContainer"
@onready var area : CollisionShape3D = $"3DControl/Quad/Area3D/CollisionShape3D"
var pixel_density : float
var padding : float = 0.1
func _ready() -> void:
	var viewport = $"3DControl/SubViewport"
	var quad = $"3DControl/Quad"
	pixel_density = quad.mesh.size.y / viewport.size.y

func get_actions(hex: Vector2i) -> void:
	var actors = GameManager.board_manager.get_actors(hex.x, hex.y)
	var tile = GameManager.board_manager.get_hex(hex.x, hex.y)
	
	for child in button_list.get_children():
		child.free()
	
	if len(actors) == 0:
		hide()
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
	
	call_deferred("set_clickable_zone")
	show()

func set_clickable_zone():
	print(button_list.size.y * pixel_density + padding)
	area.shape.size.y = button_list.size.y * pixel_density + padding
