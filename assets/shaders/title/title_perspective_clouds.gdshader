shader_type canvas_item;
render_mode unshaded;

uniform sampler2D cloud_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D sky_mask : filter_linear, repeat_disable;

// The convergence point sits below the visible mountain ridge. The mask hides
// clouds before they reach it, so no point-shaped sink is visible in the sky.
uniform vec2 focus_uv = vec2(0.6666667, 0.88);
uniform float artwork_aspect = 1.7768332;

uniform float speed : hint_range(-0.1, 0.1, 0.001) = 0.004;
uniform float scroll_phase = 0.0;
uniform float distortion_speed : hint_range(0.0, 0.05, 0.001) = 0.008;
uniform float distortion_phase = 0.0;
uniform float distortion_strength_px : hint_range(0.0, 2.0, 0.05) = 1.4;
uniform float distortion_scale : hint_range(0.5, 8.0, 0.1) = 3.0;
uniform float radial_scale : hint_range(0.1, 64.0, 0.05) = 20.0;
uniform float radial_repeat : hint_range(0.1, 8.0, 0.05) = 0.45;
uniform float angular_repeat : hint_range(0.1, 4.0, 0.05) = 2.0;
uniform float center_fade_start : hint_range(0.0, 0.5, 0.005) = 0.02;
uniform float center_fade_end : hint_range(0.0, 0.5, 0.005) = 0.08;
// Fade over the final part of the route instead of letting opaque clouds pile
// up at the destination. With the defaults this spans artwork y=0.70..0.88.
uniform float horizon_fade : hint_range(0.0, 0.3, 0.005) = 0.18;
uniform float left_lift : hint_range(0.0, 0.2, 0.005) = 0.04;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

uniform float phase : hint_range(0.0, 1.0, 0.001) = 0.15;
uniform vec2 uv_offset = vec2(-0.5, 0.0);
uniform vec2 uv_scale = vec2(1.0);
uniform bool use_sky_mask = true;
// Move the sky/terrain boundary slightly into the painted foreground. This
// lets cloud pixels reach the ridge and foliage instead of leaving a bright
// outline between them, without adding another fullscreen foreground draw.
uniform float mask_overlap_px : hint_range(0.0, 16.0, 0.5) = 6.0;


void fragment() {
	float view_aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 crop = vec2(
		min(1.0, view_aspect / artwork_aspect),
		min(1.0, artwork_aspect / view_aspect)
	);
	vec2 art_uv = (UV - 0.5) * crop + 0.5;
	// Two broad periodic waves move at different angles. Keeping the amplitude
	// in design pixels prevents the effect from stretching clouds or changing
	// their route, and the normalized phase makes the deformation loop cleanly.
	float wave_phase = distortion_phase * TAU;
	vec2 wave_position = art_uv * distortion_scale * TAU;
	vec2 distortion = vec2(
		sin(wave_position.y + wave_phase) + 0.5 * sin(wave_position.x * 1.3 - wave_phase),
		cos(wave_position.x * 0.8 - wave_phase) + 0.5 * cos((wave_position.x + wave_position.y) * 0.7 + wave_phase)
	) / 1.5;
	vec2 sample_uv = art_uv + distortion * distortion_strength_px / vec2(1920.0, 1080.0);

	// Height units keep angles and radial distance isotropic on the artwork.
	vec2 p = (sample_uv - focus_uv) * vec2(artwork_aspect, 1.0);
	float radius = length(p);
	float angle = atan(p.x, -p.y + 0.0000001);

	// The atlas is an unwrapped angle/radius cloud field. Rewrapping it restores
	// the authored left, centre, and right trajectories without planar stretching.
	float source_u = (angle / TAU + 0.5) * angular_repeat;
	float source_v = log(1.0 + radius * max(radial_scale, 0.0001));
	source_v *= max(radial_repeat, 0.0001);
	// Keep the far-left bank clear of the high mountain silhouette while
	// preserving the same radial route. The blend reaches zero before centre.
	float left_weight = 1.0 - smoothstep(0.08, 0.52, art_uv.x);
	source_v -= left_lift * left_weight;
	vec2 cloud_uv = vec2(source_u, source_v + phase) * uv_scale + uv_offset;
	cloud_uv.y += scroll_phase;
	vec4 cloud = texture(cloud_texture, cloud_uv);

	float fade_end = max(center_fade_end, center_fade_start + 0.0001);
	float center_alpha = smoothstep(center_fade_start, fade_end, radius);
	float upper_alpha = smoothstep(0.0, max(horizon_fade, 0.0001), focus_uv.y - art_uv.y);
	cloud.a *= center_alpha * upper_alpha * opacity;
	if (use_sky_mask) {
		vec2 mask_uv = art_uv - vec2(0.0, mask_overlap_px / 1080.0);
		float sky_visibility = texture(sky_mask, mask_uv).r;
		cloud.a *= smoothstep(0.2, 0.8, sky_visibility);
	}

	COLOR *= cloud;
}
