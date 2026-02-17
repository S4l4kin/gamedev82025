@tool
extends Node2D
class_name ParabolaLine

var point_a : ParabolaPoint
var point_b : ParabolaPoint
var point_c : ParabolaPoint


@export var range_max : float
@export var range_min : float

@export var a :float
@export var b :float
@export var c :float

@export var render_ingame : bool = false:
	set(v):
		render_ingame = v
		queue_redraw()

func _ready():
	print(get_point(100))

func _process(delta):
	if Engine.is_editor_hint():
		if not point_a:
			point_a = create_point()
			point_a.name = "PointA"
		if not point_b:
			point_b = create_point()
			point_b.name = "PointB"
		if not point_c:
			point_c = create_point()
			point_c.name = "PointC"

func create_point () -> ParabolaPoint:
	var point = ParabolaPoint.new()
	add_child(point)
	point.set_owner(self.get_owner())
	point.point_moved.connect(points_moved)
	return point
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		points_moved()


func points_moved():
	if not Engine.is_editor_hint():
		return
	var x1 : float = point_a.position.x
	var x2 : float = point_b.position.x
	var x3 : float = point_c.position.x
	var y1 : float = point_a.position.y
	var y2 : float = point_b.position.y
	var y3 : float = point_c.position.y

	if (pow(x2,2)-pow(x1,2))*(x3-x2)-(pow(x3,2)-pow(x2,2))*(x2-x1) == 0 or (x2-x1) == 0:
		return


	a = (((x3-x2)*(y2-y1))-((x2-x1)*(y3-y2)))/((pow(x2,2)-pow(x1,2))*(x3-x2)-(pow(x3,2)-pow(x2,2))*(x2-x1))
	b = (y2-y1-a*(pow(x2,2)-pow(x1,2)))/(x2-x1)
	c = y1 - a*pow(x1,2)-b*x1

	range_max = x1
	range_min = x1

	for x in [x2, x3]:
		if x < range_min:
			range_min = x
		if x > range_max:
			range_max = x
	queue_redraw()

func _draw():
	if not (Engine.is_editor_hint() or render_ingame):
		return
	var resolution : float = 1
	var line_color = Color.LIME_GREEN
	var x1 = range_min
	var x2 = x1 + resolution

	while x2 <= range_max:
		var point1 = get_point(x1)
		var point2 = get_point(x2)
		draw_line(point1, point2, line_color)
		x1 = x2
		x2 = x2 + resolution

func get_point(x):
	return Vector2(x, a*pow(x,2)+b*x+c)

func get_perpendicular(x):
	var slope : float = 2*a*x+b

	return atan(slope)


func get_perpendicular_weight(value):
	var x = lerp(range_min, range_max, value)
	return get_perpendicular(x)
func get_point_weight(value):
	var x = lerp(range_min, range_max, value)
	return get_point(x)
