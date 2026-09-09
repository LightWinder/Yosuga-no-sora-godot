extends SceneTree


## GUI capture: -- <output_directory> [live_seconds] [radial|title]
const RADIAL_SCENE: PackedScene = preload("res://tests/cloud_radial_test.tscn")
const TITLE_SCENE: PackedScene = preload("res://src/title/title_screen.tscn")
const VIEWPORT_SCENE: PackedScene = preload("res://tests/cloud_radial_viewports.tscn")
const PHASES: Array[float] = [0.0, 0.002, 0.15, 0.3, 0.5, 0.7, 0.9, 0.998, 1.0, 1.002]


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty() or DisplayServer.get_name() == "headless":
		push_error("Use a GUI renderer: -- <output_directory> [live_seconds] [radial|title]")
		quit(2)
		return
	var output := args[0]
	if DirAccess.make_dir_recursive_absolute(output) != OK:
		quit(2)
		return
	root.size = Vector2i(1920, 1080)
	var capture_title := args.size() > 2 and args[2] == "title"
	var scene := TITLE_SCENE if capture_title else RADIAL_SCENE
	var screen := scene.instantiate() as Control
	if capture_title:
		(screen as TitleScreen).reveal_seconds = 0.0
		(screen as TitleScreen).menu_fade_seconds = 0.0
	root.add_child(screen)
	var clouds := screen.get_node("CloudField") as TitleCloudField
	clouds.set_process(false)
	await process_frame
	clouds.visible = false
	await _save_frame(output.path_join("background.png"))
	clouds.visible = true
	for value in PHASES:
		clouds.set_animation_phase(value)
		await _save_frame(output.path_join("phase_%04d.png" % roundi(value * 1000.0)))
	clouds.set_animation_phase(0.0)
	for value in [0.0, 0.25, 0.5, 0.75, 1.0]:
		clouds.set_distortion_phase(value)
		await _save_frame(output.path_join("distortion_%04d.png" % roundi(value * 1000.0)))
	var duration := maxf(float(args[1]), 0.0) if args.size() > 1 else 0.0
	if duration > 0.0:
		clouds.set_animation_phase(0.0)
		clouds.set_process(true)
		var started := Time.get_ticks_msec()
		var next_capture := 10.0
		var frames := 0
		while float(Time.get_ticks_msec() - started) / 1000.0 < duration:
			await process_frame
			frames += 1
			var elapsed := float(Time.get_ticks_msec() - started) / 1000.0
			if elapsed >= next_capture:
				await _save_frame(output.path_join("live_%03d.png" % roundi(next_capture)))
				next_capture += 10.0
		print("Radial cloud playback: %.1f seconds, %d frames." % [duration, frames])
	if not capture_title:
		# Native macOS windows can be size-constrained by the display. Render
		# aspect checks in a fixed scene-owned SubViewport instead.
		var viewport_capture := VIEWPORT_SCENE.instantiate()
		root.add_child(viewport_capture)
		var test_viewport := viewport_capture.get_node("TestViewport") as SubViewport
		var test_clouds := test_viewport.get_node("CloudRadialTest/CloudField") as TitleCloudField
		test_clouds.set_process(false)
		test_clouds.set_animation_phase(0.0)
		for viewport_size in [Vector2i(1440, 1080), Vector2i(2560, 1080), Vector2i(720, 1280)]:
			test_viewport.size = viewport_size
			await process_frame
			await _save_frame(output.path_join("viewport_%dx%d.png" % [viewport_size.x, viewport_size.y]), test_viewport)
		root.remove_child(viewport_capture)
		viewport_capture.queue_free()
	root.remove_child(screen)
	screen.queue_free()
	await process_frame
	quit()


func _save_frame(path: String, viewport: Viewport = null) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var source_viewport := root if viewport == null else viewport
	var frame := source_viewport.get_texture().get_image()
	if viewport is SubViewport and frame.get_size() != (viewport as SubViewport).size:
		push_error("Viewport capture has unexpected dimensions: %s" % frame.get_size())
		quit(2)
		return
	if frame.save_png(path) != OK:
		push_error("Cannot save cloud capture: %s" % path)
		quit(2)
	print("Cloud capture: %s" % path)
