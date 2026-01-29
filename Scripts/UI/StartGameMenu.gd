extends Menu
class_name GameStartMenu

@export var lobby_menu : LobbyMenu

func _ready():
	$Buttons/Host.connect("pressed", (func(): 
		AudioManager.play_menu_sfx("click")
		change_menu(lobby_menu)
		GameManager.network.start_server(int($"Options/Port".text))
		var player = get_player_data()
		GameManager.player_name = player.name
		GameManager.players.append(player)
		lobby_menu.update_player_list()
		lobby_menu.show_start_button()
		))
	$"Buttons/Join".connect("pressed", (func(): 
		AudioManager.play_menu_sfx("click")
		change_menu(lobby_menu)
		GameManager.network.join_server($"Options/IP".text, int($"Options/Port".text))
		var player = get_player_data()
		GameManager.player_name = player.name
		GameManager.players.append(player)
		))
	$"Options/Color".connect("color_changed", (func(new_color: Color):
		$"Options/Color/Label".self_modulate = Color.BLACK if new_color.get_luminance() > 0.5 else Color.WHITE
	))
	
	var color = Color(randf(),randf(),randf(),1)
	$"Options/Color".color = color
	$"Options/Color".emit_signal("color_changed", color)
	connect_buttons()
func get_player_data():
	var player : Dictionary = {}

	player.name = $"Options/Name".text
	var color =  $"Options/Color".color
	player.color = {"r":color.r, "g":color.g, "b":color.b }

	return player
