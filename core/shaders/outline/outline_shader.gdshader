shader_type canvas_item;
render_mode unshaded;

// uniforms

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

// constants

const vec3 BLACK = vec3(0);
const float glow_strength = 0.5;
const float glow_size_lod = 3.0;
const int outline_radius = 1;

// simple edge detection based on black

bool is_edge(int radius, vec2 screen_uv, vec2 screen_pixel_size) {
	bool ed_found_bg = false;
	bool ed_found_color = false;
	// check neighbor pixels
	for (int x = -radius; x <= radius; x++) {
		for (int y = -radius; y <= radius; y++) {
			vec4 p = texture(screen_texture, screen_uv + (vec2(float(x), float(y)) * screen_pixel_size));
			if (p.rgb == BLACK) {
				ed_found_bg = true;
			} else {
				ed_found_color = true;
			}
		}
	}
	return ed_found_bg && ed_found_color;
}

//

void fragment() {
	// get screen texture
	vec4 screen = texture(screen_texture, SCREEN_UV);
	// apply edge detection
	if (is_edge(outline_radius, SCREEN_UV, SCREEN_PIXEL_SIZE)) {
		if (screen.rgb != BLACK) { // would be incompatible with target backgrounds != black
			COLOR = screen;
		}
	}
	// apply glow
	// blur a relative radius -> x * log(1.0/SCREEN_PIXEL_SIZE.y)
	// using log, because the LOD value seems to affect the blur radius exponentially
	vec4 glow = textureLod(screen_texture, SCREEN_UV, glow_size_lod);
	if (screen.rgb == BLACK) {
		COLOR += glow * glow_strength;
	}
	// set alpha to 1
	COLOR.a = 1.0;
}
