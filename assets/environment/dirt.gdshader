shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_albedo_dirt: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_albedo_grass : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_albedo_stone : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size = ivec2(512,512);
uniform float point_size = 0.1; //wtf does this do? can i remove it? i wont remove it.

uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_normal_dirt : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_normal_grass : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_normal_stone : hint_roughness_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_heightmap_stone : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform float heightmap_scale : hint_range(-16.0, 16.0, 0.001);
uniform int heightmap_min_layers : hint_range(1, 64);
uniform int heightmap_max_layers : hint_range(1, 64);

uniform vec3 uv1_scale = vec3(1,1,1);
varying vec4 custom_data;

void vertex() {
	UV = UV * uv1_scale.xy;
	custom_data = INSTANCE_CUSTOM;
}

void fragment() {
	vec4 albedo;
	vec4 albedo_tex;
	float roughness;
	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex;
	if (custom_data.x >= 0.0) { //above stone level
		if (custom_data.z > -0.25 || custom_data.x < 1.0) { //dry = dirt
			albedo_tex = texture(texture_albedo_dirt,UV);
			if (custom_data.y < 0.0) { //cold dirt
				albedo = vec4(1.0,0.41,0.46,1.0);
			} else if (custom_data.y >= 0.0) { //warm dirt
				albedo = vec4(0.99,0.45,0.0,1.0);
			}
			// Normal Map: Enabled
			NORMAL_MAP = texture(texture_normal_dirt, UV).rgb;
			NORMAL_MAP_DEPTH = 1.5;
			roughness = 0.95;
			roughness_tex = 1.0;
		} else if (custom_data.z <= -0.25 && custom_data.x == 1.0) { //wet = grass
			albedo_tex = texture(texture_albedo_grass,UV);
			if (custom_data.y < 0.0) { //cold grass
				albedo = vec4(0.25,0.78,0.67,1.0);
			} else if (custom_data.y >= 0.0) { //warm grass
				albedo = vec4(0.01,0.65,0.35,1.0);
			}
			//Normal Map: Enabled
			NORMAL_MAP = texture(texture_normal_grass, UV).rgb;
			NORMAL_MAP_DEPTH = 4.0;
			roughness = 0.8;
			roughness_tex = 1.0;
		}
	} else if (custom_data.x < 0.0) { //stone
		//albedo
		albedo = vec4(0.24, 0.18, 0.15, 1.0);
		albedo_tex = texture(texture_albedo_stone, UV);
		// Normal Map: Enabled
		NORMAL_MAP = texture(texture_normal_stone, UV).rgb;
		NORMAL_MAP_DEPTH = 4.0;
		//roughness
		roughness = 1.0;
		roughness_tex = 1.0;
	}
	else {
		//cry harder
	}

	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ROUGHNESS = roughness_tex * roughness;

}
