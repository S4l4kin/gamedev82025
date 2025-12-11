extends Node

var card_manager_scene = preload("res://Scenes/card_manager.tscn")
var board_manager_scene = preload("res://Scenes/board.tscn")
var player_scene = preload("res://Scenes/player.tscn")

enum GAME_STATE {Normal, Setup}
var game_state : GAME_STATE

var card_manager : CardManager
var board_manager : BoardManager
var deck : DeckManager
var network : NetworkManager

var turn_count : int = -1


@export var player_name : String

var players : Array = []

var turn_order : Array = []
var current_turn : String = ""

signal turn_start (player_name : String)
signal turn_end (player_name : String)

func start_game():
	board_manager = board_manager_scene.instantiate()
	board_manager.set_conqured_hex_colors(players)
	var player_node = player_scene.instantiate()
	deck = player_node.get_node("Deck")
	get_tree().root.add_child.call_deferred(board_manager)
	get_tree().root.add_child.call_deferred(player_node)
	game_state = GAME_STATE.Setup
	if network.is_host():
		for player in players:
			print(player)
			turn_order.append(player.name)
		turn_order.shuffle()
		network.call_deferred("send_messages", {"type":"next_turn"})
	#audiomanager.play_global_sfx("click")
	Audiomanager.play_music("res://Assets/Resources/Audio/Music/4x Card Game Theme.ogg")

func update_players(updated_players):
	players = updated_players

func append_players(append_players):
	players.append_array(append_players)

func remove_player(player):
	if not turn_order.has(player):
		return
	
	turn_order.erase(player)

	if len(turn_order) == 1:
		network.send_messages({"type":"announce_victor","victor":turn_order[0]})

func announce_victor(victor):
	audiomanager.stop_music()
	audiomanager.play_global_sfx("game_win")
	var victor_label = Label.new()
	victor_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	victor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victor_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victor_label.text = "%s won!"%victor
	victor_label.self_modulate = board_manager.player_colors[victor]
	victor_label.add_theme_font_size_override("font_size", 32)
	get_tree().root.add_child(victor_label)

func handle_network(data):
	if data.type == "join_server":
		print("Joined Server")
		append_players(data.player_list)
		network.send_messages({"type": "update_player_list",  "player_list":players})
	if data.type == "update_player_list":
		print("Update Player List")
		update_players(data.player_list)
	if data.type == "start_game":
		start_game()
			
			
	if data.type == "next_turn":
		if network.is_host():
			var next_player = turn_order.pop_front()
			turn_order.append(next_player)
			
			turn_count += 1
			if turn_count == len(players):
				network.send_messages({
				"type":"change_state",
				"state": GAME_STATE.Normal
			})
			network.send_messages({
				"type":"change_turn",
				"player": next_player
			})
	if data.type == "change_turn":
		emit_signal("turn_end", current_turn)
		current_turn = data.player
		$"/root/Player/EndTurn".disabled = not my_turn() if game_state != GAME_STATE.Setup else true
		$"/root/Player/EndTurn/CurrentTurn".text = current_turn
		emit_signal("turn_start", current_turn)
	if data.type == "change_state":
		game_state = data.state
	if data.type == "announce_victor":
		announce_victor(data.victor)
func get_players():
	return players

func _ready():
	card_manager = card_manager_scene.instantiate()
	network = NetworkManager.new()

	network.connect("recieved_message", handle_network)

	get_tree().root.add_child.call_deferred(card_manager)
	get_tree().root.add_child.call_deferred(network)


func is_mine(unit: Actor) -> bool:
	return unit.player == player_name
func my_turn() ->bool:
	return current_turn == player_name

func get_round_count() -> bool:
	return turn_count / len(players)
