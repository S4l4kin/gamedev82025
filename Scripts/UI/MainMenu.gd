extends Menu
class_name MainMenu

@onready var quit_button = $"VBoxContainer/Quit"

func _ready():
	connect_buttons()
	quit_button.connect("pressed", (func():
		AudioManager.play_menu_sfx("click")
		get_tree().quit()
	))
