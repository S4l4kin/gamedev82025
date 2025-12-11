// NOTE: Shader automatically converted from Godot Engine 4.5.stable.mono's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform float alpha_addition = 3.0;

void fragment() {
	COLOR.a = COLOR.a * alpha_addition;
}