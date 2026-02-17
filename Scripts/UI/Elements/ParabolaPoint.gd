@tool
extends Marker2D
class_name ParabolaPoint

signal point_moved

func _process(delta):
    set_notify_transform(true)

func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSFORM_CHANGED:
        emit_signal("point_moved")