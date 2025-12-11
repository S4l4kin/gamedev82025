extends Menu



func _ready():
	current_menu = $"Join Menu"
	GameManager.network.connect("recieved_message", handle_network)
	$"Join Menu/HostButton".connect("pressed", (func(): 
		audiomanager.play_menu_sfx("click")
		change_menu($Lobby)
		GameManager.network.start_server(int($"Join Menu/Options/Port".text))
		var player = get_player_data()
		GameManager.player_name = player.name
		GameManager.players.append(player)
		update_player_list()
		$Lobby/StartButton.show()
		))
	$"Join Menu/JoinButton".connect("pressed", (func(): 
		audiomanager.play_menu_sfx("click")
		change_menu($Lobby)
		GameManager.network.join_server($"Join Menu/Options/IP".text, int($"Join Menu/Options/Port".text))
		var player = get_player_data()
		GameManager.player_name = player.name
		GameManager.players.append(player)
		))
	$"Join Menu/Options/Color".connect("color_changed", (func(color: Color):
		$"Join Menu/Options/Color/Label".self_modulate = Color.BLACK if color.get_luminance() > 0.5 else Color.WHITE
	))
	$Lobby/StartButton.connect("pressed", (func():
		audiomanager.play_menu_sfx("click")
		GameManager.network.send_messages({"type":"start_game"})
		GameManager.network.send_messages({"type":"hide_start_ui"})
		))
	var color = Color(randf(),randf(),randf(),1)
	$"Join Menu/Options/Color".color = color
	$"Join Menu/Options/Color".emit_signal("color_changed", color)

func get_player_data():
	var player : Dictionary = {}

	player.name = $"Join Menu/Options/Name".text
	var color =  $"Join Menu/Options/Color".color
	player.color = {"r":color.r, "g":color.g, "b":color.b }

	return player

func handle_network(data):
	if data.type == "update_player_list":
		call_deferred("update_player_list")
	if data.type == "hide_start_ui":
		call_deferred("free")

func update_player_list():
	var player_list = $"Lobby/ScrollContainer/PlayerList"
	for child in player_list.get_children():
		child.free()
	var label = Label.new()
	label.text = "Player List"
	player_list.add_child(label)

	for player in GameManager.players:
		var player_name = Label.new()
		player_name.text = player.name
		player_name.self_modulate = Color(player.color.r,player.color.g, player.color.b, 1)
		player_list.add_child(player_name)
