shader_type canvas_item;
render_mode unshaded;

uniform sampler2D previous_texture : filter_linear, repeat_disable;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

varying vec4 character_modulate;

void vertex() {
	// Capture only the CanvasItem tint. Reading COLOR directly in fragment()
	// also includes the current TextureRect texture and would multiply it twice.
	character_modulate = COLOR;
}

void fragment() {
	vec4 previous_color = texture(previous_texture, UV);
	vec4 next_color = texture(TEXTURE, UV);
	COLOR = mix(previous_color, next_color, progress) * character_modulate;
}
