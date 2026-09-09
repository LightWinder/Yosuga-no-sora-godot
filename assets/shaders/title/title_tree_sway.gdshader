shader_type canvas_item;
render_mode unshaded;

uniform sampler2D sway_mask : filter_linear_mipmap, repeat_disable;
uniform float sway_speed : hint_range(0.0, 0.3, 0.005) = 0.1;
uniform float sway_phase = 0.0;
uniform float sway_strength_px : hint_range(0.0, 12.0, 0.1) = 7.0;
uniform float detail_strength_px : hint_range(0.0, 4.0, 0.05) = 2.0;
uniform float spatial_frequency : hint_range(0.1, 4.0, 0.05) = 1.15;
uniform vec2 design_size = vec2(1920.0, 1080.0);
varying vec4 canvas_color;


void vertex() {
	// Fragment COLOR already contains the default texture sample. Carry the
	// CanvasItem tint separately so the displaced sample is applied only once.
	canvas_color = COLOR;
}


void fragment() {
	float weight = texture(sway_mask, UV).r;
	float cycle = sway_phase * TAU;
	// Integer temporal harmonics make both the value and velocity continuous at
	// the phase wrap. The two spatial waves keep the tree line from moving as a
	// single rigid plate.
	float broad_sway = sin(cycle + UV.x * TAU * spatial_frequency);
	float leaf_flutter = sin(cycle * 2.0 + UV.x * TAU * 2.1 + UV.y * TAU * 1.4);
	float vertical_flutter = cos(cycle * 2.0 - UV.x * TAU * 1.6);
	vec2 displacement_px = vec2(
		broad_sway * sway_strength_px + leaf_flutter * detail_strength_px,
		vertical_flutter * detail_strength_px * 0.22
	) * weight;
	vec2 sample_uv = UV + displacement_px / max(design_size, vec2(1.0));
	COLOR = texture(TEXTURE, sample_uv) * canvas_color;
}
