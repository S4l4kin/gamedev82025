shader_type canvas_item;

//uniform int lineWeight : hint_range(-10, 10) = 3; // How thick the outline is
uniform float lineThickness : hint_range(0, 10, 0.01) = 3; // How thick the outline is
uniform float centerAlpha : hint_range(0.0, 1.0, 0.01) = 0;
uniform sampler2D stencilMask : source_color;
uniform int checkAmount : hint_range(1,720,1) = 20;
//bool isLine2(vec4 pixelColor, vec2 pos, float dx, float dy){
//	for(int x=-lineWeight; x <= lineWeight; x++){
//		for(int y=-lineWeight; y <= lineWeight; y++){
//			vec2 comparePos = vec2(pos.x+(float(x)*dx), pos.y+(float(y)*dy));
//			vec4 compareColor = texture(stencilMask, comparePos);
//			if(compareColor != pixelColor)
//				return true;
//		}
//	}
//	return false;
//}

bool isLine(vec4 pixelColor, vec2 pos, float dx, float dy){
	for(float deg = 0.0; deg < 2.0*PI; deg += (2.0*PI)/float(checkAmount)){
		vec2 comparePos = vec2(pos.x+cos(deg)*dx*lineThickness, pos.y+sin(deg)*dx*lineThickness);
		vec4 compareColor = texture(stencilMask, comparePos);
		if(compareColor != pixelColor)
			return true;
	}
	return false;
}
void fragment() {
	float dx = (SCREEN_PIXEL_SIZE.x) * float(lineThickness);
	float dy = (SCREEN_PIXEL_SIZE.y) * float(lineThickness);
	vec4 pixelColor = texture(stencilMask, SCREEN_UV);
	
	if(pixelColor.a > 0.1){
		COLOR = pixelColor;
		if(isLine(pixelColor, SCREEN_UV,dx,dy))
			COLOR.a = 1.0;
		else
			COLOR.a = centerAlpha;
	}
	else
		COLOR = vec4(0);
}
