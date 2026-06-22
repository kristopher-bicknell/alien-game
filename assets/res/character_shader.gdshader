shader_type spatial;

//render_mode ambient_light_disabled;


uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : source_color;
uniform bool clamp_diffuse_to_max = true;

uniform int cuts : hint_range(1, 8) = 2;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

uniform bool use_attenuation = true;

uniform bool use_specular = true;
uniform float specular_strength : hint_range(0.0f, 1.0f) = 1.0f;
uniform float specular_shininess : hint_range(0.0f, 32.0f) = 16.0f;
uniform sampler2D specular_map : source_color;


uniform vec4 shadow_color: source_color;
uniform vec4 rim_color : source_color;

uniform bool use_rim = true;
uniform float rim_width : hint_range(0.0f, 16.0f) = 12.0f;


uniform bool use_ramp = false;
uniform sampler2D ramp : source_color;

uniform bool use_borders = false;
uniform float border_width = 0.01f;

varying vec3 vertex_pos;
//varying vec3 normal;

float split_specular(float specular) {
	return step(0.5f, specular);
}

void vertex() {
	vertex_pos = VERTEX;
	//normal = NORMAL;
}

void fragment() {
	ALBEDO = albedo.rgb * texture(albedo_texture, UV).rgb;
}

float fresnel(vec3 normal, vec3 view)
{
	return (1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0));
}

void light() {
	//break up the shadows into bands
	float light = max(dot(NORMAL, LIGHT), 0.0) * ATTENUATION;
	light = round(light * 3.0) / 3.0;
	
	vec3 diffuse = vec3(light) * LIGHT_COLOR / PI;
	
	DIFFUSE_LIGHT += diffuse;
	
	//rim lighting
	float rim = fresnel(NORMAL, VIEW);
	rim = step(0.7, rim);
	rim *= light;
	SPECULAR_LIGHT += vec3(rim) * rim_color.rgb / PI;
}
