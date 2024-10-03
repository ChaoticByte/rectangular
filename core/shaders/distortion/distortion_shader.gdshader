shader_type canvas_item;
render_mode unshaded;

// uniforms

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D vignette_mask;

// constants

const float rgb_distortion_v_mult = 0.9;
const float rgb_distortion_v_exp = 2.0;
const float rgb_distortion_v_min = 0.04;
const float rgb_distortion_v_max = 0.12;

//

void fragment() {
	float v = texture(vignette_mask, SCREEN_UV).r;
	// rgb & blur distortion
	float v_ = clamp(
		pow(v * rgb_distortion_v_mult, rgb_distortion_v_exp),
		rgb_distortion_v_min,
		rgb_distortion_v_max
	);
	vec2 screen_uv_r = SCREEN_UV - (v_ * 0.01);
	vec2 screen_uv_g = SCREEN_UV + (v_ * 0.01);
	vec2 screen_uv_b = SCREEN_UV;
	COLOR.r = textureLod(screen_texture, screen_uv_r, v).r;
	COLOR.g = textureLod(screen_texture, screen_uv_g, v).g;
	COLOR.b = textureLod(screen_texture, screen_uv_b, v).b;
	COLOR.a = 1.0;
}
