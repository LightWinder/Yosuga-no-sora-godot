shader_type canvas_item;
render_mode unshaded;

uniform vec2 rect_size = vec2(252.0, 242.0);
uniform vec4 shadow_color : source_color = vec4(0.18, 0.8, 1.0, 0.2);
uniform float shadow_width = 8.0;
uniform float corner_radius = 18.0;

float rounded_rect_distance(vec2 point, vec2 half_size, float radius) {
	vec2 distance = abs(point) - half_size + vec2(radius);
	return length(max(distance, vec2(0.0))) + min(max(distance.x, distance.y), 0.0) - radius;
}

void fragment() {
	vec2 point = (UV - vec2(0.5)) * rect_size;
	float shape_distance = rounded_rect_distance(point, rect_size * 0.5, corner_radius);
	float inside_mask = 1.0 - smoothstep(-0.75, 0.75, shape_distance);
	float distance_from_edge = max(-shape_distance, 0.0);
	float inward_fade = 1.0 - smoothstep(0.0, shadow_width, distance_from_edge);
	COLOR = vec4(shadow_color.rgb, shadow_color.a * inside_mask * inward_fade);
}
