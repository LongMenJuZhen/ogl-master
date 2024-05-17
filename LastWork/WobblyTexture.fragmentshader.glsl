#version 330 core

in vec2 UV;

out vec4 color;

uniform  sampler2D DiffuseTextureSampler;
uniform  sampler2D renderedTexture;
uniform float time;
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
float mymod(float x_or_y,float pot_size){
	float dx_or_y=mod(x_or_y,pot_size);
	if(dx_or_y>pot_size/2.0){
		return pot_size-dx_or_y;
	}
	else{
		return dx_or_y;
	}
}
float lightGradient(){
	vec4 right_texture_value = texture(renderedTexture, UV + vec2(0.001,0.0));
	vec4 left_texture_value = texture(renderedTexture, UV - vec2(0.001,0.0));
	vec4 up_texture_value = texture(renderedTexture, UV + vec2(0.0,0.001));
	vec4 down_texture_value = texture(renderedTexture, UV - vec2(0.0,0.001));
	float d_light = abs(left_texture_value.z-right_texture_value.z)+abs(up_texture_value.z-down_texture_value.z);
	return d_light*4;
}
void main(){
	// 
	vec4 texture_value= texture(renderedTexture, UV/* +  0.005* vec2( sin(0.5*time+1024.0*UV.x),cos(0.5*time+768.0*UV.y))*/);
	float d_light = lightGradient();
	// texture_value.x = texture_value.x*(1-d_light)+d_light*0.8333;
	float pot_size = 16;
	float dx = mymod(gl_FragCoord.x,pot_size);
	float dy = mymod(gl_FragCoord.y,pot_size);
	float percent=(1-texture_value.z);
	if(dx*dx+dy*dy<pot_size*pot_size*percent*percent/4.0){
		color.rgb = 
		// hsv2rgb(rgb2hsv(vec3(0,0,0)))
		vec3(0,0,0)
		// vec3(texture(depthTexture,vec3(0.5,0.5,0.5)),0.5,0)
		;
		// if(texture_value.w<0.5){
		// 	color.rgb = 
		// }
		color.a = 1.0;
	}
	else{
		color.r = 
		// vec3(0,texture_value.w,0)
		hsv2rgb (texture_value.xyz).x
		;
		color.g = 
		// vec3(0,texture_value.w,0)
		hsv2rgb (texture(DiffuseTextureSampler, UV/* + vec2(0.1,0.0)*/).xyz).y
		;
		color.b = 
		// vec3(0,texture_value.w,0)
		hsv2rgb (texture(renderedTexture, UV/* - vec2(0.1,0.0)*/).xyz).z
		;
		color.a =1;
	}
}
