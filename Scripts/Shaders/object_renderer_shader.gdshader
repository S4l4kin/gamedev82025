shader_type spatial;
render_mode depth_test_disabled, unshaded ;

uniform vec2 offset;
uniform vec2 center;
uniform float rotation: hint_range(-360.0, 360.0, 0.1) = 0;
uniform float skew: hint_range(-89.9, 89.9, 0.1) = 0;
uniform vec2 scale = vec2(1,1);
uniform sampler2D sprite : source_color;
uniform sampler2D mask : source_color;
uniform sampler2D maskPallet : source_color, filter_nearest;

void vertex() {

	// Billboard Mode: Enabled
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);

	ivec2 size = textureSize(sprite,0);

	//Skew
	float skew_rad = radians(skew);
	mat3 skew_matrix = mat3(vec3(1.0, sin(skew_rad)/cos(skew_rad), 0.0),
                  				vec3(0.0,  1.0, 0.0),
                  				vec3(0.0,     0.0,    1.0));
	mat3 skew_scale_matrix = mat3(vec3(1.0,	0,			0),
							 vec3(0,		abs(sin(PI/2.0-skew_rad)),	0),
							 vec3(0,		0,			1));
	VERTEX = VERTEX * skew_scale_matrix * skew_matrix;

	//Rotation around center
	VERTEX = VERTEX + vec3((center.x/float(size.x)), (-center.y/float(size.y)), 0);
	float rad = radians(rotation);
	mat3 rotation_matrix = mat3(vec3(cos(-rad), -sin(-rad), 0.0),
                  				vec3(sin(-rad),  cos(-rad), 0.0),
                  				vec3(0.0,     0.0,    1.0));
	VERTEX = VERTEX * rotation_matrix;

	//Change offset
	VERTEX = VERTEX + vec3((offset.x/float(size.x)), (-offset.y/float(size.y)), 0);

	//Change Scale
	mat3 scale_matrix = mat3(vec3(scale.x,	0,			0),
							 vec3(0,		scale.y,	0),
							 vec3(0,		0,			1));
	VERTEX = VERTEX * scale_matrix;

}
void fragment() {

	vec4 pixelColor = texture(sprite, UV);
	vec4 maskColor = texture(mask, UV);
	ALBEDO = pixelColor.rgb;
	ALPHA = pixelColor.a;
	
	//Goes through the maskColor Texture
	ivec2 mask_size = textureSize(mask, 0);
	float error_degree = 0.001;
	for (float mask_y = 0.25; mask_y < 1.0; mask_y += 1.0/float(mask_size.y)){
		vec4 check_color = texture(maskPallet, vec2(0.25, mask_y));
		vec4 recolor = texture(maskPallet, vec2(0.5, mask_y));
		if( maskColor.a >= error_degree &&
		maskColor.r - check_color.r <= error_degree &&
		maskColor.g - check_color.g <= error_degree &&
		maskColor.b - check_color.b <= error_degree)
			ALBEDO = pixelColor.rgb * recolor.rgb;
	}
	
	
}