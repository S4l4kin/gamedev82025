class_name Outline
var outline_material = preload("res://Materials/Outline_shader.tres")
var priority : int = 1
func get_outline(color: Color) -> Material:
    var new_outline = outline_material.duplicate(true)

    new_outline.next_pass.albedo_color = color
    new_outline.stencil_reference = priority
    new_outline.next_pass.stencil_reference = priority
    priority += 1
    return new_outline