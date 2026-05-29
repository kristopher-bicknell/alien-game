shader_type spatial;

uniform vec3 skin_modulate: source_color;

void vertex() {
	
}

void fragment() {
	ALBEDO = skin_modulate;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
