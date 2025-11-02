extends Node3D
class_name CardInspector

var inspecting_hex: Vector2i

@onready var board : BoardManager = $"/root/Board"
@onready var show_timer : Timer = $ShowTimer
@onready var hide_timer : Timer = $HideTimer

var show_lock : Dictionary[String, bool] = {}
@onready var card_stack = $"3DControl/SubViewport/CenterContainer"


func _ready():
	board.connect("mouse_entered_hex", mouse_entered)
	board.connect("mouse_exited_hex", mouse_exited)
	$"3DControl".node_area.connect("mouse_entered", change_lock.bind("hover_card", true))
	$"3DControl".node_area.connect("mouse_exited", change_lock.bind("hover_card", false))
	hide_timer.connect("timeout", hide_card)

func mouse_entered(x:int, y:int):
	if inspecting_hex.x == x and inspecting_hex.y == y:
		hover_unit()

func mouse_exited(x:int, y:int):
	if inspecting_hex.x == x and inspecting_hex.y == y:
		show_timer.stop();
		change_lock("unit_hovered",false)


func hover_unit():
	if not visible: 
		show_timer.start()
	else:
		change_lock("unit_hovered", true)

func change_lock(key:String, value:bool) -> void:
	show_lock[key] = value
	if not value:
		hide_timer.start()


func get_lock() -> bool:
	var flag : bool = false
	for key in show_lock.keys():
		if show_lock[key]:
			flag = true
	return flag

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			change_lock("moving", event.pressed)


func hide_card() -> void:
	if not get_lock():
		hide()

func show_card(lock: String, hex: Vector2i) -> void:
	if hex != inspecting_hex:
		show_lock = {}
		inspecting_hex = hex

		global_position = board.get_hex(hex.x,hex.y).tile.global_position
		for child in card_stack.get_children():
			child.call_deferred("free")
		var hex_data = board.hexes[hex.x][hex.y]
		var card_scene = $"/root/CardManager".get_card_scene(hex_data.unit.card_id).instantiate()
		card_stack.add_child(card_scene)


	change_lock(lock, true)
	show_timer.stop()
	show()
