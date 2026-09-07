shader_type canvas_item;
render_mode unshaded;

uniform sampler2D cloud_texture : source_color, filter_linear, repeat_enable;
uniform float speed : hint_range(-0.1, 0.1, 0.001) = 0.015;
uniform float phase : hint_range(0.0, 1.0, 0.001) = 0.0;
uniform vec2 uv_scale = vec2(1.0, 0.675);
uniform vec2 uv_offset = vec2(0.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 cloud_uv = UV * uv_scale + uv_offset;
	cloud_uv.y += phase + TIME * speed;
	// Repeat sampling wraps V continuously, including bilinear filtering at
	// the boundary. Keep coordinates unwrapped to preserve their derivatives.
	vec4 cloud = texture(cloud_texture, cloud_uv);
	cloud.a *= opacity;
	COLOR = cloud;
}
