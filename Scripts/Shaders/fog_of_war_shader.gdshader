shader_type spatial;
render_mode depth_test_disabled, unshaded;

uniform sampler2D mask : source_color;
uniform float smoothing;
uniform vec3 fogColor : source_color;

float lerp (float a, float b, float t) {
	return a + (b - a) * t;
}
void fragment() {
	vec4 targetColor = texture(mask, UV);
	ALBEDO = vec3(0);
	ALPHA = 1.0- targetColor.a;
	ALBEDO = fogColor.rgb;
}