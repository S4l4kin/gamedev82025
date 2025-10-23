extends Node

enum NetworkType {Disconnected, Client, Host}

@export var state : NetworkType = NetworkType.Disconnected

var buffer : String


var connections : Array[StreamPeerTCP]
var server


#If a component cares about network messages subscribe / connect to this signal, it will emit each time there is a valid message. 
#Each message should have "type" field for easier filtering.
signal receive_data

#Used to start the server
func start_server(port):
	state = NetworkType.Host
	server = TCPServer.new()
	var result = server.listen(port)
	if result == OK:
		print("Server is listening on port %d" % port)
	else:
		print("Failed to start server: %s" % result)

#Used to join a server
func join_server(ip, port):
	var client : StreamPeerTCP = StreamPeerTCP.new()
	client.connect_to_host(ip, port)
	connections.append(client)

#Debug function to send debug messages
func process_messages(data):
	if data.type == "message":
		print(data.data)
 

func _process(_delta):
	var data
	if state == NetworkType.Host:
		if server.is_connection_available():
			var client = server.take_connection()
			connections.append(client)
			data = {"type":"message","data":"Connected to Server"}
			client.put_data(JSON.stringify(data).to_utf8_buffer())

	#Go through each client and check if they have any messages and appends it to the buffer string.
	for connection in connections:
		connection.poll()
		var available_bytes : int = connection.get_available_bytes()
		if available_bytes > 0:
			print(available_bytes)
			data = connection.get_string(available_bytes)
			buffer = buffer + data
	
	#Checks if the text buffer has a valid message and then sends that valid message forward.
	data = parse_buffer()
	while data != null:
		if state == NetworkType.Host:
			send_messages(data)	
		else:
			emit_signal("receive_data", data)

		data = parse_buffer()

#Naive way to check for a valid message. Messages are in JSON format so check if there is as many { and } symbols,
# if there is it should be a valid message.
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

func send_messages(data):
	if state == NetworkType.Host:
		emit_signal("receive_data", data)
		pass
	for connection in connections:
		connection.put_data(JSON.stringify(data).to_utf8_buffer())
