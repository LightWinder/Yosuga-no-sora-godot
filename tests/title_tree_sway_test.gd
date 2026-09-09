extends SceneTree


const BACKGROUND_SCENE: PackedScene = preload("res://src/title/title_tree_sway_background.tscn")
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var first := BACKGROUND_SCENE.instantiate() as TitleTreeSwayBackground
	var second := BACKGROUND_SCENE.instantiate() as TitleTreeSwayBackground
	root.add_child(first)
	root.add_child(second)
	first.set_process(false)
	second.set_process(false)
	var first_material := first.sway_material()
	_expect(first_material != second.sway_material(), "Title backgrounds must not share sway phase state.")
	var uniforms: Array[StringName] = []
	for item in first_material.shader.get_shader_uniform_list():
		uniforms.append(StringName(item["name"]))
	for key in [&"sway_mask", &"sway_speed", &"sway_phase", &"sway_strength_px", &"detail_strength_px", &"spatial_frequency", &"design_size"]:
		_expect(uniforms.has(key), "Missing tree sway Inspector uniform: %s" % key)
	_expect(first.texture.resource_path == "res://assets/ui/title/QD-13-BG.png", "Tree sway must retain the supplied Title background.")
	var mask := first_material.get_shader_parameter(&"sway_mask") as Texture2D
	_expect(mask != null and mask.resource_path == "res://assets/ui/title/background/title_tree_sway_mask.png", "Tree sway must use the PSD-derived canopy mask.")
	_expect(first.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Animated background must not intercept input.")
	_expect(first.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "Animated background must preserve cover cropping.")
	first.set_sway_phase(0.99)
	first._process(0.25)
	_expect(is_equal_approx(float(first_material.get_shader_parameter(&"sway_phase")), 0.015), "Tree sway phase must wrap continuously.")
	_expect(is_zero_approx(float(second.sway_material().get_shader_parameter(&"sway_phase"))), "Updating one Title must not sway another Title.")
	first.hide()
	first._process(1.0)
	_expect(is_equal_approx(float(first_material.get_shader_parameter(&"sway_phase")), 0.015), "Hidden Title backgrounds must stop swaying.")
	root.remove_child(first)
	root.remove_child(second)
	first.queue_free()
	second.queue_free()
	await process_frame
	for failure in _failures:
		push_error(failure)
	if _failures.is_empty():
		print("Title tree sway test passed.")
	quit(0 if _failures.is_empty() else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
