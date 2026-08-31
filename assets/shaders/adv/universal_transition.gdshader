shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D rule_texture : filter_linear, repeat_disable;
uniform float progress : hint_range(-0.1, 1.1) = -0.05;
uniform float softness : hint_range(0.001, 0.25) = 0.04;
uniform bool use_rule = false;

void fragment() {
	// CanvasGroup stores its children in the backbuffer using premultiplied
	// alpha. Convert that composed image back before drawing it once.
	vec4 source = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (source.a > 0.0001) {
		source.rgb /= source.a;
	}
	if (use_rule) {
		float rule_value = texture(rule_texture, SCREEN_UV).r;
		source.a *= smoothstep(progress - softness, progress + softness, rule_value);
	}
	COLOR *= source;
}
