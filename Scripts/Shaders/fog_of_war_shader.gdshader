shader_type spatial;
render_mode unshaded;

uniform sampler2D mask : source_color;
uniform float smoothing;
uniform vec3 base_color : source_color;
uniform vec3 color : source_color;
uniform int bands;

uniform int cell_amount = 2;
uniform vec2 period = vec2(5., 1.);


uniform vec2 wind_dir1 = vec2(1.,0.5);
uniform vec2 wind_dir2 = vec2(-1.,0.);
uniform float wind_strength = 200;

vec2 modulo(vec2 divident, vec2 divisor){
	vec2 positiveDivident = mod(divident, divisor) + divisor;
	return mod(positiveDivident, divisor);
}

vec2 random(vec2 value){
	value = vec2( dot(value, vec2(127.1,311.7) ),
				  dot(value, vec2(269.5,183.3) ) );
	return -1.0 + 2.0 * fract(sin(value) * 43758.5453123);
}

float seamless_noise(vec2 uv, vec2 _period) {
	uv = uv * float(cell_amount);
	vec2 cellsMinimum = floor(uv);
	vec2 cellsMaximum = ceil(uv);
	vec2 uv_fract = fract(uv);

	cellsMinimum = modulo(cellsMinimum, _period);
	cellsMaximum = modulo(cellsMaximum, _period);

	vec2 blur = smoothstep(0.0, 1.0, uv_fract);

	vec2 lowerLeftDirection = random(vec2(cellsMinimum.x, cellsMinimum.y));
	vec2 lowerRightDirection = random(vec2(cellsMaximum.x, cellsMinimum.y));
	vec2 upperLeftDirection = random(vec2(cellsMinimum.x, cellsMaximum.y));
	vec2 upperRightDirection = random(vec2(cellsMaximum.x, cellsMaximum.y));

	vec2 fraction = fract(uv);

	return mix( mix( dot( lowerLeftDirection, fraction - vec2(0, 0) ),
                     dot( lowerRightDirection, fraction - vec2(1, 0) ), blur.x),
                mix( dot( upperLeftDirection, fraction - vec2(0, 1) ),
                     dot( upperRightDirection, fraction - vec2(1, 1) ), blur.x), blur.y) * 0.8 + 0.5;
}

float fbm(vec2 uv) {
    int octaves = 30;
    float amplitude = 0.5;
    float frequency = 0.75;
	float value = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amplitude * seamless_noise(frequency * uv, period);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

float quantize(float value){
	return round(value * float(bands)) / float(bands);
}

void fragment() {
	float alpha = texture(mask, UV).a;
	float noise = fbm(UV + (wind_dir1 / wind_strength) * TIME) * fbm(UV - (wind_dir2 / wind_strength) * TIME) * 2.;

	if(alpha >= 1.)
		ALPHA = 0.;
	else if(alpha > 0. && alpha > noise)
		ALPHA = 1.- alpha;
	
	vec3 fog_color = color.rgb * base_color.rgb;
	
	ALBEDO = mix(fog_color, quantize(noise) * fog_color, 0.55);
}