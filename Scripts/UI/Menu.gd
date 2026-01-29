extends Control
class_name Menu

@export var menu_transitions: Dictionary[BaseButton, Control] 
func _ready() -> void:
	connect_buttons()

func connect_buttons():
	print("TESAST EMMALDSKHL")
	print(menu_transitions)
	for button in menu_transitions.keys():
		print("TESAST EMMALDSKHL")
		button.connect("pressed", (func():
			AudioManager.play_menu_sfx("click")
			change_menu(menu_transitions[button])
			))


func change_menu(new_menu: Control):
	self.hide()
	new_menu.show()
	#current_menu = new_menu
	pass
