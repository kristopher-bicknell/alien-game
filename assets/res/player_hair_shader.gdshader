shader_type spatial;

uniform sampler2D hair_texture;
uniform vec3 hair_modulate: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 tex_color = texture(hair_texture, UV).xyz;
	ALBEDO = tex_color * hair_modulate;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
