extends Control
class_name Messanger


@onready var title_animation : AnimationPlayer = $Title/AnimationPlayer
@onready var title : RichTextLabel = $Title/RichTextLabel
var title_queue : Array[Dictionary]


func _ready():
    title_animation.animation_finished.connect(func (anim_name): if anim_name == "temporary": next_title())

func queue_title(text: String, color: Color, time: float):
    title_queue.append({"text": text, "color": color, "time": time})

    if not title_animation.is_playing():
        next_title()

func set_permament_title(text: String, color: Color, time: float):
    title_queue.clear()
    title.self_modulate = color
    title.text = text
    title_animation.speed_scale = 1.5 / time
    title_animation.play("permament")

func next_title():
    var data = title_queue.pop_front()
    if data:
        title.self_modulate = data.color
        title.text = data.text
        title_animation.speed_scale = 1.5 / data.time
        title_animation.play("temporary")