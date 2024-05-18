#version 330 core

// Interpolated values from the vertex shaders
in vec3 Position_worldspace;

// Ouput data
layout(location = 0) out vec4 color;


// Values that stay constant for the whole mesh.
uniform mat4 MV;
vec3 rgb2hsv(vec3 rgb) {
	float r = rgb.r;
	float g = rgb.g;
	float b = rgb.b;
	float min = min(min(r, g), b);
	float max = max(max(r, g), b);
	float delta = max - min;
	vec3 hsv = vec3(0, 0, max);
	if (max != 0) hsv.y = delta / max;
	if (hsv.y == 0) hsv.x = 0;
	else {
		if (r == max) hsv.x = (g - b) / delta;
		else if (g == max) hsv.x = 2 + (b - r) / delta;
		else hsv.x = 4 + (r - g) / delta;
		hsv.x *= 60;
		if (hsv.x < 0) hsv.x += 360;
	}
	hsv.x /= 360.0; // Normalize h to the range [0, 1]
	return hsv;
}
vec3 hsv2rgb(vec3 hsv) {
	float h = hsv.x * 360.0; // Convert h back to degrees
	float s = hsv.y;
	float v = hsv.z;
	float c = v * s;
	float x = c * (1 - abs(mod(h / 60, 2) - 1));
	float m = v - c;
	vec3 rgb;
	if (h < 60) rgb = vec3(c, x, 0);
	else if (h < 120) rgb = vec3(x, c, 0);
	else if (h < 180) rgb = vec3(0, c, x);
	else if (h < 240) rgb = vec3(0, x, c);
	else if (h < 300) rgb = vec3(x, 0, c);
	else rgb = vec3(c, 0, x);
	return rgb + vec3(m);
}
void main(){
    color.rgb = Position_worldspace;
	color.a = 1;
}