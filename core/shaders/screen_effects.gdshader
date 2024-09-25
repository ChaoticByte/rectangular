shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

// simple edge detection
bool is_edge(int radius, vec2 screen_uv, vec2 screen_pixel_size) {
	bool ed_found_black = false;
	bool ed_found_color = false;
	// check neighbor pixels
	for (int x = -radius; x < radius+1; x++) {
		for (int y = -radius; y < radius+1; y++) {
			vec4 p = texture(screen_texture, screen_uv + (vec2(float(x), float(y)) * screen_pixel_size));
			if (p.rgb == vec3(0.0)) {
				ed_found_black = true;
			} else {
				ed_found_color = true;
			}
		}
	}
	return ed_found_black && ed_found_color;
}

void fragment() {
	// get screen texture
	vec4 screen = texture(screen_texture, SCREEN_UV);
	// apply edge detection
	int radius = max(int(0.003 * (1.0/SCREEN_PIXEL_SIZE.y)), 1); // with a relative radius
	if (is_edge(radius, SCREEN_UV, SCREEN_PIXEL_SIZE)) {
		COLOR = screen;
	} else {
		COLOR = vec4(0, 0, 0, 1);
	}
	// apply glow
	// blur a relative radius -> x * log(1.0/SCREEN_PIXEL_SIZE.y)
	// using log, because the LOD value seems to affect the blur radius exponentially
	vec4 glow = textureLod(screen_texture, SCREEN_UV, 0.5 * log(1.0/SCREEN_PIXEL_SIZE.y));
	if (screen.rgb == vec3(0.0)) {
		COLOR = mix(COLOR, glow, 0.4) + (glow * 0.3);
	}
}
