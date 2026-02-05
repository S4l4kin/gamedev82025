extends Menu
class_name LobbyMenu

func _ready():
	GameManager.network.connect("recieved_message", handle_network)
	$Buttons/Start.connect("pressed", (func():
		AudioManager.play_menu_sfx("click")
		GameManager.network.send_messages({"type":"start_game"})
		GameManager.network.send_messages({"type":"hide_start_ui"})
		))

func show_start_button():
	$Buttons/Start.show()


func handle_network(data):
	if data.type == "update_player_list":
		call_deferred("update_player_list")
	if data.type == "hide_start_ui":
		get_parent().call_deferred("free")

func update_player_list():
	var player_list = $"ScrollContainer/PlayerList"
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
