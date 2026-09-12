shader_type canvas_item;
render_mode unshaded;

uniform float top_opacity : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float fade_end : hint_range(0.05, 0.5, 0.01) = 0.28;

void fragment() {
	float fade = 1.0 - smoothstep(0.0, fade_end, UV.y);
	COLOR = vec4(0.220, 0.470, 0.560, top_opacity * fade);
}
