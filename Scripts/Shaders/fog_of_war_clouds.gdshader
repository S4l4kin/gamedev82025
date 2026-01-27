shader_type spatial;
render_mode unshaded, depth_test_disabled;


/*uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;*/

uniform vec3 color : source_color;
uniform sampler2D mask : source_color;
uniform sampler2D sprite : source_color;
uniform int sprite_amount;
uniform float transparency = 0.5;
void vertex() {
	// Vertex Color is sRGB: Enabled
	/*if (!OUTPUT_IS_SRGB) {
		COLOR.rgb = mix(
				pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)),
				COLOR.rgb * (1.0 / 12.92),
				lessThan(COLOR.rgb, vec3(0.04045)));
	}*/

	//UV = UV * uv1_scale.xy + uv1_offset.xy;

	// Billboard Mode: Enabled
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {

	vec2 spirte_uv = vec2(UV.x, UV.y / float(sprite_amount) + COLOR.b);

	vec4 mask_color = texture(mask, COLOR.xy);
	vec4 sprite_color = texture(sprite, spirte_uv);

	//mask_uv *= COLOR;
	
	ALPHA = (1.0 - mask_color.a) * sprite_color.a * transparency;

	ALBEDO = sprite_color.rgb * color;
	//ALBEDO = sprite_color.rgb * vec3(COLOR.xy, 1);
}
