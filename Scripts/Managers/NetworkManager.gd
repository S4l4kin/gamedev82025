extends Node

enum NetworkType {Disconnected, Client, Host}

@export var state : NetworkType = NetworkType.Disconnected

@export var port : int

var buffer : String


var connections : Array[StreamPeerTCP]
var server

signal receive_data

func _ready():

	message = message + String.num(RandomNumberGenerator.new().randi_range(0, 1000))


	if state == NetworkType.Host:
		start_server();
	else:
		var client : StreamPeerTCP = StreamPeerTCP.new()
		client.connect_to_host("127.0.0.1", port)
		connections.append(client)

	connect("receive_data", process_messages)

func process_messages(data):
	if data.type == "message":
		print(data.data)
		$Label.text = data.data + "\n" + $Label.text 
 
func start_server():
	server = TCPServer.new()
	var result = server.listen(port)
	if result == OK:
		print("Server is listening on port %d" % port)
	else:
		print("Failed to start server: %s" % result)

func _process(_delta):
	if state == NetworkType.Host:
		if server.is_connection_available():
			var client = server.take_connection()
			connections.append(client)
			var data = {"type":"message","data":"Connected to Server"}
			client.put_data(JSON.stringify(data).to_utf8_buffer())
	
	for connection in connections:
		connection.poll()
		var available_bytes : int = connection.get_available_bytes()
		if available_bytes > 0:
			print(available_bytes)
			var data = connection.get_string(available_bytes)
			buffer = buffer + data
	
	var data = parse_buffer()
	while data != null:
		if state == NetworkType.Host:
			send_messages(data)	
		else:
			emit_signal("receive_data", data)

		data = parse_buffer()

func parse_buffer() -> Variant:

	if len(buffer) == 0:
		return null

	var brackets = 0
	var length = 0
	for c in buffer:
		match c:
			"{":
				brackets += 1
			"}":
				brackets -= 1
		length += 1
		if brackets == 0:
			break
	if brackets == 0:
		var data = buffer.left(length)
		buffer = buffer.erase(0,length)
		return JSON.parse_string(data)
	else:
		return null



@export var message : String
func _input(_ev):
	if Input.is_key_pressed(KEY_SPACE):
		var data = {"type":"message", "data":message}
		send_messages(data)


func send_messages(data):
	if state == NetworkType.Host:
		emit_signal("receive_data", data)
		pass
	for connection in connections:
		connection.put_data(JSON.stringify(data).to_utf8_buffer())
