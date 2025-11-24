extends Node3D
class_name CardInspector

var inspecting_hex: Vector2i

@onready var board : BoardManager = $"/root/Board"
@onready var show_timer : Timer = $ShowTimer
@onready var hide_timer : Timer = $HideTimer

var show_lock : Dictionary[String, bool] = {}
@onready var card_stack = $"3DControl/SubViewport/CenterContainer/Control"


func _ready():
	board.connect("mouse_entered_hex", mouse_entered)
	board.connect("mouse_exited_hex", mouse_exited)
	$"3DControl".node_area.connect("mouse_entered", change_lock.bind("hover_card", true))
	$"3DControl".node_area.connect("mouse_exited", change_lock.bind("hover_card", false))
	hide_timer.connect("timeout", hide_card)
	$"3DControl/SubViewport/Left".connect("pressed", func(): card_stack.move_child(card_stack.get_child(-1),0))
	$"3DControl/SubViewport/Right".connect("pressed", func(): card_stack.move_child(card_stack.get_child(-1),-2))
	card_stack.connect("child_order_changed", position_cards)

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
	
	show_lock = {}
	inspecting_hex = hex

	global_position = board.get_hex(hex.x,hex.y).tile.global_position
	for child in card_stack.get_children():
		child.call_deferred("free")
	var hex_data = board.hexes[Vector2i(hex.x, hex.y)]
	if hex_data.unit:
		var unit_card_scene = GameManager.card_manager.get_card_scene(hex_data.unit.card_id).instantiate()
		card_stack.add_child(unit_card_scene)
	if hex_data.structure:
		var structure_card_scene = GameManager.card_manager.get_card_scene(hex_data.structure.card_id).instantiate()
		card_stack.add_child(structure_card_scene)


	change_lock(lock, true)
	show_timer.stop()
	position_cards()
	show()

func position_cards():
	var child_count = card_stack.get_child_count()
	for i in child_count:
		var child : Control = card_stack.get_child(i)
		#Top card
		if i == child_count-1:
			child.show()
			child.modulate = Color.WHITE
			child.position = Vector2.ZERO
			pass
		#Second top card
		elif i == child_count-2:
			child.show()
			child.modulate = Color.GRAY
			child.position = Vector2(-9, 9)
			pass
		#Everyother card
		else:
			child.hide()
