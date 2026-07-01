shader_type spatial;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : source_color;
uniform vec4 rim_color : source_color;

uniform sampler2D alphaTexture;

uniform float offsetScale : hint_range(0.0001, 1.0, 0.001);
uniform float clampTop : hint_range(0.0,1.0) = 1.0;
uniform float clampBottom : hint_range(-1.0, 0.0) = 0.0;

void fragment() {
	ALPHA = texture(alphaTexture,UV).x;
	ALPHA_SCISSOR_THRESHOLD = 0.2;
	ALBEDO = albedo.rgb * texture(albedo_texture, UV).rgb;
}

float fresnel(vec3 normal, vec3 view)
{
	return (1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0));
}

float split_specular(float specular) {
	return step(0.5f, specular);
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

void vertex() {
	vec2 uvOffset = vec2(UV.x * 2.0 - 1.0, -(UV.y * 2.0 - 1.0));
	uvOffset /= 2.0;
	vec4 off = inverse(MODELVIEW_MATRIX) * vec4(uvOffset,1.0,0.0);
	off = vec4(normalize(off.xyz),0.0) * offsetScale;
	
	vec3 world_pos = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	float contribution = 1.0;
	vec3 world_pos_eff = world_pos * contribution;
	float positional_influence = - VERTEX.x + VERTEX.z - world_pos_eff.x + world_pos_eff.z;
	float offset = fract(positional_influence);
	offset = min(1.0 - offset, offset);
	offset = (1.0 - offset) * offset * 2.0;

	float t = TIME + sin(TIME + offset + cos(TIME + offset * 2.0));
	float mask = clamp(VERTEX.y,0.0, 1.0) * (clampTop - clampBottom) + clampBottom;

	float si = sin(t) / 20.0 * offset;
	float csi = cos(t) / 20.0 * offset;

	vec3 wind_offset = vec3(VERTEX.x * si * mask, VERTEX.y * si * mask, VERTEX.z * csi * mask);

	VERTEX += off.xyz + wind_offset;
}