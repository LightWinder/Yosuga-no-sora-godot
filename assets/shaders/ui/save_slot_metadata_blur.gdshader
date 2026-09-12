shader_type canvas_item;

uniform float blur_radius : hint_range(0.0, 6.0, 0.1) = 2.4;
uniform float blur_start : hint_range(0.0, 1.0, 0.01) = 0.38;
uniform vec3 tint_color : source_color = vec3(0.220, 0.470, 0.560);

void fragment() {
	vec2 offset = TEXTURE_PIXEL_SIZE * blur_radius;
	vec4 blurred = texture(TEXTURE, UV) * 0.28;
	blurred += texture(TEXTURE, UV + vec2(offset.x, 0.0)) * 0.12;
	blurred += texture(TEXTURE, UV - vec2(offset.x, 0.0)) * 0.12;
	blurred += texture(TEXTURE, UV + vec2(0.0, offset.y)) * 0.12;
	blurred += texture(TEXTURE, UV - vec2(0.0, offset.y)) * 0.12;
	blurred += texture(TEXTURE, UV + offset) * 0.06;
	blurred += texture(TEXTURE, UV - offset) * 0.06;
	blurred += texture(TEXTURE, UV + vec2(offset.x, -offset.y)) * 0.06;
	blurred += texture(TEXTURE, UV + vec2(-offset.x, offset.y)) * 0.06;

	float mask = smoothstep(blur_start, 0.75, UV.y);
	float tint_strength = mix(0.34, 0.88, smoothstep(0.44, 0.9, UV.y));
	vec3 color = mix(blurred.rgb, tint_color, tint_strength);
	COLOR = vec4(color, mask);
}
