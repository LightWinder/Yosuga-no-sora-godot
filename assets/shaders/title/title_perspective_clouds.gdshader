shader_type canvas_item;
render_mode unshaded;

uniform sampler2D cloud_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D sky_mask : filter_linear, repeat_disable;
uniform vec2 focus_uv = vec2(0.6666667, 0.8);
// Read by TitleCloudField's phase clock; speed changes do not jump the image.
uniform float speed : hint_range(-0.1, 0.1, 0.001) = 0.015;
uniform float radial_scale : hint_range(0.1, 64.0, 0.05) = 20.0;
uniform float radial_repeat : hint_range(0.1, 8.0, 0.05) = 0.45;
uniform float angular_repeat : hint_range(0.1, 4.0, 0.05) = 1.0;
uniform float center_fade_start : hint_range(0.0, 0.5, 0.005) = 0.03;
uniform float center_fade_end : hint_range(0.0, 0.5, 0.005) = 0.10;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float phase : hint_range(0.0, 1.0, 0.001) = 0.0;
uniform vec2 uv_offset = vec2(0.0);
uniform vec2 uv_scale = vec2(1.0);
uniform bool use_sky_mask = true;
uniform float artwork_aspect = 1.7768332;
// Normalized texture phase supplied by the scene-local clock.
uniform float scroll_phase = 0.0;

void fragment() {
	float view_aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 crop = vec2(min(1.0, view_aspect / artwork_aspect), min(1.0, artwork_aspect / view_aspect));
	vec2 art_uv = (UV - 0.5) * crop + 0.5;
	// Height units keep radial distance isotropic on a 16:9 canvas.
	vec2 p = (art_uv - focus_uv) * vec2(artwork_aspect, 1.0);
	float r = length(p);
	// U runs left -> centre -> right across the upper sky. The angular branch
	// cut is below the focus, not across the visible left-hand cloud bank.
	float angle = atan(p.x, -p.y + 0.0000001);
	float u = (angle / TAU + 0.5) * angular_repeat;
	float v = log(1.0 + r * max(radial_scale, 0.0001)) * max(radial_repeat, 0.0001);
	vec2 cloud_uv = vec2(u, v + phase) * uv_scale + uv_offset;
	cloud_uv.y += scroll_phase;
	// Hardware repeat interpolates the boundary. Unwrapped UVs preserve mip derivatives.
	vec4 cloud = texture(cloud_texture, cloud_uv);
	float fade_end = max(center_fade_end, center_fade_start + 0.0001);
	cloud.a *= smoothstep(center_fade_start, fade_end, r) * opacity;
	if (use_sky_mask) {
		cloud.a *= texture(sky_mask, art_uv).r;
	}
	COLOR *= cloud;
}
