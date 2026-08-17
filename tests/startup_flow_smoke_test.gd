extends SceneTree


const TITLE_SCENE: PackedScene = preload("res://src/title/title_screen.tscn")
const WARNING_SCENE: PackedScene = preload("res://src/intro/content_warning_screen.tscn")
const BRAND_SCENE: PackedScene = preload("res://src/intro/brand_movie_screen.tscn")
const STARTUP_FLOW_SCENE: PackedScene = preload("res://src/app/startup_flow.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(ResourceLoader.exists("res://assets/video/sphere.ogv"), "Brand movie is missing.")
	_expect(ResourceLoader.exists("res://assets/audio/bgm/BGM07_title.ogg"), "Title BGM is missing.")
	_expect(BRAND_SCENE.can_instantiate(), "Brand movie scene cannot be instantiated.")
	_expect(WARNING_SCENE.can_instantiate(), "Warning scene cannot be instantiated.")
	_expect(TITLE_SCENE.can_instantiate(), "Title scene cannot be instantiated.")

	var title := TITLE_SCENE.instantiate() as TitleScreen
	root.add_child(title)
	await process_frame

	var buttons := title.get_menu_buttons()
	var selected_options: Array[StringName] = []
	title.option_selected.connect(func(option_id: StringName) -> void: selected_options.append(option_id))
	_expect(buttons.size() == 4, "Title must expose the four fresh-install menu options.")
	if buttons.size() == 4:
		_expect(buttons[0].option_id == &"new_game", "The first title option must be New Game.")
		_expect(buttons[3].option_id == &"exit_game", "The last title option must be Exit.")
		buttons[0].pressed.emit()
		await process_frame
		_expect(selected_options == [&"new_game"], "Title click did not reach the option integration seam.")

	title.free()
	await process_frame

	Engine.time_scale = 20.0
	var startup_flow := STARTUP_FLOW_SCENE.instantiate() as StartupFlow
	root.add_child(startup_flow)
	await create_timer(1.5, true, false, true).timeout
	_expect(startup_flow.current_stage == StartupFlow.Stage.TITLE, "Automatic startup flow did not reach Title.")
	startup_flow.free()
	Engine.time_scale = 1.0
	# Give the audio mixing thread time to release stopped Vorbis playback objects.
	await create_timer(0.25, true, false, true).timeout

	if _failures.is_empty():
		print("Startup flow smoke test passed.")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
