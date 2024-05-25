#version 330 core

// Interpolated values from the vertex shaders
in vec2 UV;
in vec3 Position_worldspace;
in vec3 Normal_cameraspace;
in vec3 EyeDirection_cameraspace;
in vec3 LightDirection_cameraspace;

// Ouput data
layout(location = 0) out vec4 color;


// Values that stay constant for the whole mesh.
uniform sampler2D myTextureSampler;
uniform sampler2D RampTextureSampler;
uniform mat4 MV;
uniform vec3 LightPosition_worldspace;

uniform float AmbientStrength;
uniform float DiffuseStrength;
uniform float SpecularStrength;
uniform float ChromaticAberrationStrength;
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
// 哈希函数，用于生成伪随机梯度向量
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// 线性插值
float lerp(float a, float b, float t) {
    return a + t * (b - a);
}

// 平滑插值函数
float smoothstep(float edge0, float edge1, float x) {
    float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

// 2D柏林噪声函数
float perlinNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    // 平滑插值
    f = f * f * (3.0 - 2.0 * f);
    
    // 为格点分配伪随机值
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    // 插值
    float mixAB = lerp(a, b, f.x);
    float mixCD = lerp(c, d, f.x);
    float mixFinal = lerp(mixAB, mixCD, f.y);
    
    return mixFinal;
}
void main(){

	// Light emission properties
	// You probably want to put them as uniforms
	vec3 LightColor = vec3(1,1,1);
	float LightPower = 256.0f;
	
	// Material properties
	vec3 MaterialColor = texture( myTextureSampler, UV ).rgb;
	vec3 MaterialHSV = rgb2hsv(MaterialColor);
	
	float MaterialAmbientColor = 0.1 * MaterialHSV.z;
	float MaterialSpecularColor = 0.3;
	float MaterialDiffuseColor = 0.6;
	// Distance to the light
	float distance = length( LightPosition_worldspace - Position_worldspace);

	// Normal of the computed fragment, in camera space
	vec3 n = normalize( Normal_cameraspace );
	// Direction of the light (from the fragment to the light)
	vec3 l = normalize( LightDirection_cameraspace );
	// Cosine of the angle between the normal and the light direction, 
	// clamped above 0
	//  - light is at the vertical of the triangle -> 1
	//  - light is perpendiular to the triangle -> 0
	//  - light is behind the triangle -> 0
	float cosTheta = clamp( dot( n,l ), 0,1 );
	
	// Eye vector (towards the camera)
	vec3 E = normalize(EyeDirection_cameraspace);
	// Direction in which the triangle reflects the light
	vec3 R = reflect(-l,n);
	// Cosine of the angle between the Eye vector and the Reflect vector,
	// clamped to 0
	//  - Looking into the reflection -> 1
	//  - Looking elsewhere -> < 1
	float cosAlpha = clamp( dot( E,R ), 0,1 );
	float cosEdge = clamp( dot( E,n ), 0,1 );
	
	color.r =MaterialHSV.x;//+ChromaticAberrationStrength*perlinNoise(Position_worldspace.xy*8);
		// // Ambient : simulates indirect lighting
		// MaterialAmbientColor +
		// // Diffuse : "color" of the object
		// MaterialDiffuseColor  * LightColor * LightPower * cosTheta / (distance*distance) +
		// // Specular : reflective highlight, like a mirror
		// MaterialSpecularColor * LightColor * LightPower * pow(cosAlpha,5) / (distance*distance)
		;
	color.g = MaterialHSV.y/* +ChromaticAberrationStrength*perlinNoise(Position_worldspace.xy*6) */;
	MaterialDiffuseColor = MaterialDiffuseColor  * LightPower * cosTheta / (distance*distance);
	MaterialSpecularColor = MaterialSpecularColor * LightPower * pow(cosAlpha,5) / (distance*distance);
	float AmbientSample = rgb2hsv(texture( RampTextureSampler, vec2(MaterialAmbientColor, 0.875)).rgb).z;
	float DiffuseSample = rgb2hsv(texture( RampTextureSampler, vec2(MaterialDiffuseColor, 0.625)).rgb).z;
	float SpecularSample = rgb2hsv(texture( RampTextureSampler, vec2(MaterialSpecularColor, 0.375)).rgb).z;

	color.b = 
	// cosEdge;
	MaterialAmbientColor*AmbientStrength+
	floor(DiffuseStrength*1*1*LightPower*cosTheta / (distance*distance)*5)/5+
	SpecularStrength*0.3*1*LightPower*pow(cosAlpha,5) / (distance*distance);
	if (cosEdge<0.1){
		color.b = 0;
	}
	color.a = 1.0f;
	// fragmentdepth=  gl_FragCoord.z;
}