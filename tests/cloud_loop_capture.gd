extends SceneTree


## GUI-only diagnostic capture. Headless Godot has no rendered viewport image.
## -- <output_directory> [live_seconds]
const TEST_SCENE: PackedScene = preload("res://tests/cloud_test.tscn")
const PHASES: Array[float] = [0.0, 0.25, 0.5, 0.75, 0.999, 1.0, 1.001]


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.is_empty() or DisplayServer.get_name() == "headless":
		push_error("Run with a GUI renderer: -- <output_directory> [live_seconds]")
		quit(2)
		return
	var output_directory := arguments[0]
	if DirAccess.make_dir_recursive_absolute(output_directory) != OK:
		push_error("Cannot create capture directory: %s" % output_directory)
		quit(2)
		return
	root.size = Vector2i(1920, 1080)
	var screen := TEST_SCENE.instantiate() as Control
	root.add_child(screen)
	var clouds := screen.get_node("VisualCanvas/CloudLayer") as ColorRect
	var material := clouds.material as ShaderMaterial
	material.set_shader_parameter(&"speed", 0.0)
	for index in range(PHASES.size()):
		material.set_shader_parameter(&"phase", PHASES[index])
		await process_frame
		await RenderingServer.frame_post_draw
		var output_path := output_directory.path_join("phase_%04d.png" % roundi(PHASES[index] * 1000.0))
		if root.get_texture().get_image().save_png(output_path) != OK:
			push_error("Cannot save capture: %s" % output_path)
			quit(2)
			return
		print("Cloud loop phase %.3f: %s" % [PHASES[index], output_path])
	# Magnify the actual repeated sample, without editing the supplied PNG.
	# The bottom/top boundary is at y=540; source x=480..960 is shown at 4x.
	material.set_shader_parameter(&"uv_scale", Vector2(0.25, 0.16875))
	material.set_shader_parameter(&"uv_offset", Vector2(0.25, 0.0))
	material.set_shader_parameter(&"phase", 0.915625)
	await process_frame
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png(output_directory.path_join("seam_detail.png")) != OK:
		push_error("Cannot save seam detail.")
		quit(2)
		return
	material.set_shader_parameter(&"uv_scale", Vector2(1.0, 0.675))
	material.set_shader_parameter(&"uv_offset", Vector2.ZERO)
	var live_seconds := maxf(0.0, float(arguments[1])) if arguments.size() > 1 else 0.0
	if live_seconds > 0.0:
		material.set_shader_parameter(&"phase", 0.0)
		material.set_shader_parameter(&"speed", 0.015)
		var started_at := Time.get_ticks_msec()
		var frame_count := 0
		while float(Time.get_ticks_msec() - started_at) / 1000.0 < live_seconds:
			await process_frame
			frame_count += 1
		print("Cloud loop live playback: %.1f seconds, %d frames." % [live_seconds, frame_count])
	root.remove_child(screen)
	screen.queue_free()
	await process_frame
	quit()
