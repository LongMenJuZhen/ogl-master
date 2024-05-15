#version 330 core

in vec2 UV;

out vec4 color;

uniform sampler2D renderedTexture;
uniform float time;
vec4 texture_pixel;
float mymod(float x_or_y,int pixel_size){
	float dx_or_y=mod(x_or_y,pixel_size);
	if(dx_or_y>pixel_size/2.0){
		return pixel_size-dx_or_y;
	}
	else{
		return dx_or_y;
	}
}
void main(){
	texture_pixel = texture( renderedTexture, UV );
	
	float color_intensity = (texture_pixel.x+texture_pixel.y+texture_pixel.z)/2.0;
	
	int pot_size = 32;
	float dx = mymod(gl_FragCoord.x,pixel_size);
	float dy = mymod(gl_FragCoord.y,pixel_size);

	color.rgb = vec3(0.0,0.0,0.0);
	color.a = 0.0;
	if(dx*dx+dy*dy<pixel_size*pixel_size/4.0){
		color.rgb = texture( renderedTexture, UV +  0.005* vec2( sin(0.5*time+1024.0*UV.x),cos(0.5*time+768.0*UV.y))).xyz/color_intensity*color_intensity;
		color.a =1;
	}
	else{
		color.rgb = vec3(0.0,0.0,0.0);
		color.a = 0.0;
	}
}
