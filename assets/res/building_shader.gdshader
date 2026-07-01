shader_type spatial;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : source_color;
uniform sampler2D alphaTexture;

uniform vec4 rim_color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

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
