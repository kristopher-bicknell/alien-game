shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform float height_scale = 0.5;
uniform float water_roughness = 10.0;
uniform sampler2D noise;
uniform sampler2D normalmap;

varying vec2 tex_position;

float wave(vec2 position){
	position += texture(noise, position / 10.0).x * 2.0 - 1.0;
	vec2 wv = 1.0 - abs(sin(position));
	return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 position, float time) {
	float h = wave(position * 0.4);
	return h;
}

void vertex() {
	vec2 pos = VERTEX.xz;
	float k = height(pos, TIME);
	VERTEX.y = k;
	NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.0, 0.15, 0.2) + (0.1 * fresnel);
}