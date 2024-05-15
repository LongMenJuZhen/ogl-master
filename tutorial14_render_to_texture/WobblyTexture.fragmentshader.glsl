#version 330 core

in vec2 UV;

out vec4 color;

uniform sampler2D renderedTexture;
uniform float time;
vec4 texture_pixel;

void main(){
	texture_pixel = texture( renderedTexture, UV );
	int pixel_size = 8;
	float color_intensity = (texture_pixel.x+texture_pixel.y+texture_pixel.z)/2.0;
	float rid = pixel_size*color_intensity;
	//  
	if(mod(gl_FragCoord.x,pixel_size)<rid&& mod(gl_FragCoord.y,pixel_size)<rid){
		color.rgb = texture( renderedTexture, UV +  0.005* vec2( sin(0.5*time+1024.0*UV.x),cos(0.5*time+768.0*UV.y))).xyz/color_intensity*color_intensity;
		color.a = 1.0;
	}
	else{
		color.rgb = vec3(0.0,0.0,0.0);
		color.a = 0.0;
	}
}
