extends SceneTree


const CLOUD_SCENE: PackedScene = preload("res://src/title/title_cloud_field.tscn")
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var first := CLOUD_SCENE.instantiate() as TitleCloudField
	var second := CLOUD_SCENE.instantiate() as TitleCloudField
	root.add_child(first)
	root.add_child(second)
	first.set_process(false)
	second.set_process(false)
	var material := first.cloud_material()
	_expect(material != second.cloud_material(), "Title instances must not share animation state.")
	var uniforms: Array[StringName] = []
	for item in material.shader.get_shader_uniform_list():
		uniforms.append(StringName(item["name"]))
	for key in [&"cloud_texture", &"use_sky_mask", &"focus_uv", &"speed", &"distortion_speed", &"distortion_phase", &"distortion_strength_px", &"distortion_scale", &"radial_scale", &"radial_repeat", &"angular_repeat", &"center_fade_start", &"center_fade_end", &"horizon_fade", &"left_lift", &"opacity", &"phase", &"uv_scale", &"uv_offset", &"sky_mask", &"mask_overlap_px"]:
		_expect(uniforms.has(key), "Missing Inspector uniform: %s" % key)
	var cloud_texture := material.get_shader_parameter(&"cloud_texture") as Texture2D
	_expect(cloud_texture != null and cloud_texture.resource_path == "res://assets/ui/title/clouds/title_cloud_radial_atlas.png", "Title clouds must use the radial atlas.")
	var sky_mask := material.get_shader_parameter(&"sky_mask") as Texture2D
	_expect(sky_mask != null and sky_mask.resource_path == "res://assets/ui/title/clouds/sky_mask.svg", "Title clouds must use the skyline mask.")
	_expect(bool(material.get_shader_parameter(&"use_sky_mask")), "Title clouds must enable the skyline mask by default.")
	_expect(float(material.get_shader_parameter(&"opacity")) > 0.0, "Title cloud material must remain visible by default.")
	var focus: Vector2 = material.get_shader_parameter(&"focus_uv")
	_expect((focus * Vector2(1920.0, 1080.0)).distance_to(Vector2(1280.0, 950.4)) < 0.01, "The horizon destination must remain behind the mountain ridge.")
	_expect(float(material.get_shader_parameter(&"mask_overlap_px")) >= 4.0, "Clouds must overlap the skyline enough to avoid a bright outline gap.")
	_expect(first.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Cloud field must not intercept input.")
	_expect(first.get_child_count() == 1 and first.get_child(0) is ColorRect, "Whole-texture projection must use one fixed CanvasItem.")
	first.set_animation_phase(0.99)
	first._process(2.0)
	_expect(is_equal_approx(float(material.get_shader_parameter(&"scroll_phase")), 0.998), "The phase must cross a texture period continuously.")
	_expect(is_zero_approx(float(second.cloud_material().get_shader_parameter(&"scroll_phase"))), "Updating one Title must not move another Title.")
	first.set_distortion_phase(0.995)
	first._process(1.0)
	_expect(is_equal_approx(float(material.get_shader_parameter(&"distortion_phase")), 0.003), "The distortion phase must wrap continuously.")
	_expect(is_zero_approx(float(second.cloud_material().get_shader_parameter(&"distortion_phase"))), "Updating one Title must not deform another Title.")
	material.set_shader_parameter(&"speed", 0.017)
	material.set_shader_parameter(&"uv_scale", Vector2(1.0, 1.3))
	first.set_animation_phase(0.25)
	first._process(3600.0)
	_expect(is_equal_approx(float(material.get_shader_parameter(&"scroll_phase")), 0.81), "Non-default speed/density must survive an hour without a TIME reset.")
	material.set_shader_parameter(&"speed", 0.0)
	first._process(5.0)
	_expect(is_equal_approx(float(material.get_shader_parameter(&"scroll_phase")), 0.81), "Zero speed must freeze the current phase without jumping.")
	material.set_shader_parameter(&"speed", -0.01)
	first._process(1.0)
	_expect(is_equal_approx(float(material.get_shader_parameter(&"scroll_phase")), 0.797), "Reverse speed must continue from the current phase.")
	first.hide()
	first._process(3.0)
	_expect(is_equal_approx(float(material.get_shader_parameter(&"scroll_phase")), 0.797), "Hidden title clouds must stop advancing.")
	root.remove_child(first)
	root.remove_child(second)
	first.queue_free()
	second.queue_free()
	await process_frame
	for failure in _failures:
		push_error(failure)
	if _failures.is_empty():
		print("Title cloud field test passed.")
	quit(0 if _failures.is_empty() else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
