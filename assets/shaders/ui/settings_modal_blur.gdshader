shader_type canvas_item;

// Read the scene already rendered behind this CanvasItem from BackBufferCopy.
// A mipmap LOD gives full-screen UI a live blur with one texture lookup instead
// of a costly multi-tap Gaussian kernel, which keeps it practical on mobile.
uniform sampler2D screen_texture
	: hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float blur_lod : hint_range(0.0, 5.0) = 0.0;
uniform vec4 tint_color : source_color = vec4(0.02, 0.08, 0.12, 0.08);


void fragment() {
	vec4 blurred = textureLod(screen_texture, SCREEN_UV, blur_lod);
	vec3 tinted = mix(blurred.rgb, tint_color.rgb, tint_color.a);
	COLOR = vec4(tinted, 1.0);
}
