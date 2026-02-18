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
var player : Player
 
var turn_count : int = -1
var messanger : Messanger

@export var player_name : String

var players : Array = []

var turn_order : Array = []
var current_turn : String = ""

signal turn_start (player_name : String)
signal turn_end (player_name : String)

func start_game():
	board_manager = board_manager_scene.instantiate()
	board_manager.set_conqured_hex_colors(players)
	player = player_scene.instantiate()
	deck = player.get_node("Deck")
	messanger = preload("res://Scenes/messager.tscn").instantiate()
	get_tree().root.add_child.call_deferred(board_manager)
	get_tree().root.add_child.call_deferred(player)
	get_tree().root.add_child.call_deferred(messanger)
	game_state = GAME_STATE.Setup
	if network.is_host():
		for player in players:
			print(player)
			turn_order.append(player.name)
		turn_order.shuffle()
		network.call_deferred("send_messages", {"type":"next_turn"})
	AudioManager.play_music("res://Assets/Resources/Audio/Music/TerraIncognitaTheme.ogg")

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
	
	var who_won = "You" if player_name == victor else "%s"%victor
	var text_color = get_player_color(victor)

	messanger.set_permament_title("%s Won!"%who_won, text_color, 3)


	var tween = create_tween()
	tween.tween_property(player, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(player.call_deferred.bind("free"))

	AudioManager.stop_music()
	AudioManager.play_global_sfx("game_win")
	

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
		
		var whos_turn = "Your" if my_turn() else "%s's"%current_turn
		var text_color = get_player_color(current_turn)
		
		messanger.queue_title("%s Turn"%whos_turn, text_color, 2)
		
		
		emit_signal("turn_start", current_turn)
	if data.type == "change_state":
		game_state = data.state
	if data.type == "announce_victor":
		announce_victor(data.victor)
		
	if data.type == "play_3d_sfx":
		var pos = Vector3(data.pos.x, data.pos.y, data.pos.z)
		AudioManager.play_3d_sfx(data.key, pos, data.vol)
	
func get_players():
	return players

func _ready():
	card_manager = card_manager_scene.instantiate()
	network = NetworkManager.new()

	network.connect("recieved_message", handle_network)

	get_tree().root.add_child.call_deferred(card_manager)
	get_tree().root.add_child.call_deferred(network)


func get_player_color(who: String) -> Color:
	for n in players:
		if n.name == who:
			return Color(n.color.r, n.color.g, n.color.b)
	return Color.TRANSPARENT

func is_mine(unit: Actor) -> bool:
	return unit.player == player_name
func my_turn() ->bool:
	return current_turn == player_name

func get_round_count() -> bool:
	return turn_count / len(players)
