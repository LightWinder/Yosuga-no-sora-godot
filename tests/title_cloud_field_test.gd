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
	for key in [&"focus_uv", &"speed", &"radial_scale", &"radial_repeat", &"angular_repeat", &"center_fade_start", &"center_fade_end", &"opacity", &"phase", &"uv_scale", &"uv_offset", &"sky_mask"]:
		_expect(uniforms.has(key), "Missing Inspector uniform: %s" % key)
	var focus: Vector2 = material.get_shader_parameter(&"focus_uv")
	_expect((focus * Vector2(1920.0, 1080.0)).distance_to(Vector2(1280.0, 864.0)) < 0.01, "Focus must retain the requested design position.")
	_expect(first.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Cloud field must not intercept input.")
	_expect(first.get_child_count() == 1 and first.get_child(0) is ColorRect, "Whole-texture projection must use one fixed CanvasItem.")
	first.set_animation_phase(0.99)
	first._process(2.0)
	_expect(is_equal_approx(float(material.get_shader_parameter(&"scroll_phase")), 0.02), "The phase must cross a texture period continuously.")
	_expect(is_zero_approx(float(second.cloud_material().get_shader_parameter(&"scroll_phase"))), "Updating one Title must not move another Title.")
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
