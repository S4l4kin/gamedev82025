extends Control
class_name Menu

var current_menu : Control

func change_menu(new_menu: Control):
	current_menu.hide()
	new_menu.show()
	current_menu = new_menu
	pass
