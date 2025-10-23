extends Node
class_name CardManager

var card_data : Dictionary[String, Card]
var card_object : Dictionary
var actor_object : Dictionary


func _ready() -> void:
	load_cards_in_folder("res://Cards")

func load_card(path) -> void:
	var file = ResourceLoader.load(path, "Card")
	if file is Card:
		file.set_defaults()
		card_data.set(file.id, file)
	else:
		push_warning("Found a non Card Resource in Cards folders: "+ path)
func load_cards_in_folder(path) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				load_cards_in_folder(path+"/"+file_name)
			else:
				load_card(path+"/"+file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
