shader_type spatial;
render_mode depth_test_disabled, unshaded ;

uniform sampler2D mask : source_color;
uniform vec3 color : source_color;
uniform vec2 offset;
uniform vec2 center;
uniform float rotation: hint_range(-360.0, 360.0, 0.1) = 0;
uniform float skew: hint_range(-89.9, 89.9, 0.1) = 0;
uniform vec2 scale = vec2(1,1);
uniform sampler2D sprite : source_color;

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
	vec4 maskColor = texture(mask, UV);
	//if (maskColor.a >= 0.1)
	ALBEDO = COLOR.rgb * color;
	ALPHA = 1.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
