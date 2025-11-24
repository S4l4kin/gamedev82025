shader_type spatial;
render_mode depth_test_disabled, unshaded ;

uniform vec2 offset;
uniform sampler2D sprite : source_color;
void vertex() {

	// Billboard Mode: Enabled
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	VERTEX = VERTEX + vec3(offset.x/100.0, -offset.y/140.0, 0);
}
void fragment() {
	vec4 pixelColor = texture(sprite, UV);
	ALBEDO = pixelColor.rgb;
	ALPHA = pixelColor.a;
}