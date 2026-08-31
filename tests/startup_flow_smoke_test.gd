extends SceneTree


const TITLE_SCENE: PackedScene = preload("res://src/title/title_screen.tscn")
const WARNING_SCENE: PackedScene = preload("res://src/intro/content_warning_screen.tscn")
const BRAND_SCENE: PackedScene = preload("res://src/intro/brand_movie_screen.tscn")
const STARTUP_FLOW_SCENE: PackedScene = preload("res://src/app/startup_flow.tscn")
const ADV_SCENE: PackedScene = preload("res://src/adv/adv_screen.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(ResourceLoader.exists("res://assets/video/sphere.ogv"), "Brand movie is missing.")
	_expect(ResourceLoader.exists("res://assets/audio/bgm/BGM07_title.ogg"), "Title BGM is missing.")
	_expect(BRAND_SCENE.can_instantiate(), "Brand movie scene cannot be instantiated.")
	_expect(WARNING_SCENE.can_instantiate(), "Warning scene cannot be instantiated.")
	_expect(TITLE_SCENE.can_instantiate(), "Title scene cannot be instantiated.")
	_expect(ADV_SCENE.can_instantiate(), "ADV scene cannot be instantiated.")

	var title_save_service := SaveService.new()
	title_save_service.name = "IsolatedTitleSaveService"
	title_save_service.configure_storage(
		"/tmp/yosuga-title-smoke-%d" % Time.get_ticks_usec()
	)
	root.add_child(title_save_service)
	var title := TITLE_SCENE.instantiate() as TitleScreen
	title.configure(title_save_service)
	root.add_child(title)
	await process_frame

	var buttons := title.get_menu_buttons()
	var selected_options: Array[StringName] = []
	var new_game_requests: Array[ScenarioLaunchRequest] = []
	title.option_selected.connect(func(option_id: StringName) -> void: selected_options.append(option_id))
	title.scenario_requested.connect(func(request: ScenarioLaunchRequest) -> void: new_game_requests.append(request))
	_expect(buttons.size() == 4, "Title must expose the four fresh-install menu options.")
	if buttons.size() == 4:
		_expect(buttons[0].option_id == &"new_game", "The first title option must be New Game.")
		_expect(buttons[3].option_id == &"exit_game", "The last title option must be Exit.")
		buttons[0].pressed.emit()
		await process_frame
		_expect(selected_options == [&"new_game"], "Title click did not reach the option integration seam.")
		_expect(new_game_requests.size() == 1 and new_game_requests[0].is_new_game(), "New Game must emit a typed ADV launch request.")
		_expect(new_game_requests[0].scenario_id == "00_z000", "New Game must begin at the source opening scenario.")

	title.free()
	title_save_service.free()
	await process_frame

	Engine.time_scale = 20.0
	var startup_flow := STARTUP_FLOW_SCENE.instantiate() as StartupFlow
	root.add_child(startup_flow)
	await create_timer(1.5, true, false, true).timeout
	_expect(startup_flow.current_stage == StartupFlow.Stage.TITLE, "Automatic startup flow did not reach Title.")
	var startup_audio := startup_flow.get_node("StartupAudio") as StartupAudio
	var startup_save_service := startup_flow.get_node("SaveService") as SaveService
	startup_save_service.configure_storage(
		"/tmp/yosuga-startup-adv-smoke-%d" % Time.get_ticks_usec()
	)
	var runtime_settings := SettingsModel.defaults()
	runtime_settings["voice_volume"] = 0.31
	runtime_settings["env_se_volume"] = 0.41
	runtime_settings["se_volume"] = 0.63
	runtime_settings["movie_volume"] = 0.27
	runtime_settings["mute_env_se"] = true
	startup_audio.apply_settings(runtime_settings)
	_expect(_bus_volume_is("Voice", 0.31), "Startup audio must apply the persisted Voice bus gain.")
	_expect(_bus_volume_is("EnvSE", 0.41), "Startup audio must apply the persisted environment SE bus gain.")
	_expect(_bus_volume_is("SE", 0.63), "Startup audio must apply the persisted SE bus gain.")
	_expect(_bus_volume_is("Movie", 0.27), "Startup audio must apply the persisted Movie bus gain.")
	_expect(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"EnvSE")), "Startup audio must apply persisted bus mute flags.")
	startup_audio.apply_settings(SettingsModel.defaults())
	var read_reset_events: Array[bool] = []
	startup_flow.read_flags_reset_requested.connect(func() -> void: read_reset_events.append(true))
	var screen_host := startup_flow.get_node("ScreenHost") as Control
	var route_backdrop := startup_flow.get_node("RouteBackdrop") as ColorRect
	var overlay_layer := startup_flow.get_node("OverlayLayer") as CanvasLayer
	var overlay_host := startup_flow.get_node("OverlayLayer/OverlayHost") as Control
	var load_transition_cover := startup_flow.get_node("OverlayLayer/LoadTransitionCover") as TextureRect
	_expect(
		route_backdrop.get_index() < screen_host.get_index()
		and route_backdrop.color.is_equal_approx(Color.BLACK),
		"New Game must fade Title to the source black base, not the blue load artwork."
	)
	_expect(overlay_layer.layer > 0, "Route overlays must render on a dedicated CanvasLayer above feature-local z indices.")
	_expect(
		load_transition_cover.texture.resource_path == "res://assets/ui/intro/FRM_0501.png"
		and not load_transition_cover.visible,
		"Continue must reuse the serialized source route artwork as its initially hidden load cover."
	)
	var title_underlay := screen_host.get_child(0) as TitleScreen
	var prepared_settings := overlay_host.get_child(overlay_host.get_child_count() - 1) as SettingsScreen
	_expect(prepared_settings != null and not prepared_settings.visible, "Settings must finish its first-time scene setup invisibly before the first click.")
	_expect(prepared_settings.process_mode == Node.PROCESS_MODE_DISABLED, "Prepared settings must not process input behind Title.")
	var previous_max_fps := Engine.max_fps
	startup_flow._show_title_feature(&"settings")
	await create_timer(0.4, true, false, true).timeout
	var settings_screen := overlay_host.get_child(overlay_host.get_child_count() - 1) as SettingsScreen
	_expect(settings_screen != null, "Settings must use its dedicated route scene.")
	_expect(settings_screen == prepared_settings and settings_screen.visible, "First open must activate the already prepared Settings instance.")
	_expect(Engine.max_fps == previous_max_fps, "Settings UI must retain the application's original frame rate.")
	_expect((settings_screen.get_node("BackBufferCopy") as BackBufferCopy).copy_mode == BackBufferCopy.COPY_MODE_VIEWPORT, "Settings must copy the live route behind it directly from the root viewport.")
	_expect(screen_host.get_child_count() == 1 and screen_host.get_child(0) == title_underlay and overlay_host.get_child_count() == 1, "Settings must overlay the live Title route instead of replacing it.")
	_expect(not title_underlay.is_processing_input() and not title_underlay.is_processing_unhandled_input(), "The scene behind settings must stop receiving route input while it remains visible.")
	_expect(title_underlay.is_subscreen_departed(), "Opening settings must run the reusable Title child-screen departure animation.")
	var title_preview := settings_screen.settings_page().display_page().preview_content() as AdvScreen
	var sample_message := title_preview.current_message()
	var sample_stage := (title_preview.get_node("%StageDirector") as AdvStageDirector).presentation_state()
	var sample_portrait := (title_preview.get_node("%Portrait") as TextureRect).texture
	var sample_speaker := (title_preview.get_node("%SpeakerNameImage") as TextureRect).texture
	_expect(sample_stage.get("background") == "EA01E", "Title Settings must show the fixed train sample.")
	settings_screen.settings_page().read_flags_reset_requested.emit()
	_expect(read_reset_events.size() == 1, "StartupFlow must expose the settings read-reset integration seam.")
	settings_screen.back_requested.emit()
	await create_timer(0.7, true, false, true).timeout
	_expect(screen_host.get_child_count() == 1 and screen_host.get_child(0) == title_underlay and overlay_host.get_child_count() == 0, "Closing settings must reveal the same Title instance without replaying its route.")
	_expect(title_underlay.is_processing_input() and title_underlay.is_processing_unhandled_input(), "Closing settings must restore input to the underlying route.")
	_expect(Engine.max_fps == previous_max_fps, "Closing settings must leave the application frame rate unchanged.")
	var route_save := SaveData.create_empty("smoke")
	route_save.scenario_id = "00_z000"
	route_save.instruction_anchor = "hitret:1"
	_expect(startup_save_service.save_slot(0, route_save), "ADV route smoke test must create an isolated save fixture.")
	var path_only_request := ScenarioLaunchRequest.new()
	path_only_request.kind = ScenarioLaunchRequest.RequestKind.CONTINUE
	path_only_request.save_path = startup_save_service.slot_path(0)
	startup_flow.load_cover_enter_seconds = 0.01
	startup_flow.load_cover_leave_seconds = 0.01
	startup_flow._on_scenario_requested(path_only_request)
	_expect(
		startup_flow.current_stage == StartupFlow.Stage.TITLE
		and load_transition_cover.visible,
		"Continue must keep the source route alive while the blue load cover enters."
	)
	var load_transition_deadline := Time.get_ticks_msec() + 2000
	while load_transition_cover.visible and Time.get_ticks_msec() < load_transition_deadline:
		await process_frame
	_expect(startup_flow.current_stage == StartupFlow.Stage.ADV, "Scenario requests must replace Title with the ADV route.")
	_expect(not load_transition_cover.visible, "The blue load cover must leave only after ADV restore is ready.")
	var adv := screen_host.get_child(0) as AdvScreen
	_expect(adv != null and adv.scene_file_path.ends_with("adv_screen.tscn"), "StartupFlow must instantiate the scene-owned ADV screen.")
	_expect(adv.get_node_or_null("VisualCanvas/Stage/CameraCanvas/Background") is TextureRect, "ADV background layer must be declared in the scene-owned camera canvas.")
	_expect(adv.get_node_or_null("VisualCanvas/MessagePanel") is PanelContainer, "ADV message frame must be declared in the scene.")
	_expect(adv.current_message().begins_with("蔚蓝的天空"), "ADV route must restore real UTF-8 source dialogue.")
	_expect(path_only_request.save_data != null and path_only_request.instruction_anchor == "hitret:1", "StartupFlow must resolve path-only voice/save jump requests through SaveService.")
	var adv_message_panel := adv.get_node("VisualCanvas/MessagePanel") as Control
	var source_message := adv.current_message()
	_expect(source_message != sample_message, "The gameplay fixture must differ from the fixed Settings sample.")
	var adv_settings := startup_flow.open_settings()
	await create_timer(0.4, true, false, true).timeout
	_expect(
		adv_settings.visible and not adv_message_panel.visible,
		"Opening route-level Settings above ADV must hide dialogue chrome from the live blurred backdrop."
	)
	var adv_preview := adv_settings.settings_page().display_page().preview_content() as AdvScreen
	_expect(adv_preview != null and adv_preview.current_message() == sample_message, "In-game Settings must show the same fixed dialogue as Title, never current gameplay.")
	_expect((adv_preview.get_node("%MessagePanel") as Control).visible, "The fixed preview dialogue must remain visible while gameplay chrome is hidden.")
	var preview_stage := adv_preview.get_node("%StageDirector") as AdvStageDirector
	_expect(preview_stage.presentation_state() == sample_stage, "Preview background, characters and camera must match the Title sample, independent of gameplay.")
	_expect((adv_preview.get_node("%Portrait") as TextureRect).texture == sample_portrait, "In-game Settings must retain the fixed sample portrait.")
	_expect((adv_preview.get_node("%SpeakerNameImage") as TextureRect).texture == sample_speaker, "In-game Settings must retain the fixed sample speaker.")
	_expect(not (adv_preview.get_node("%ChoiceOverlay") as Control).visible and adv_preview.get_node("%ChoiceList").get_child_count() == 0, "The fixed preview must not contain gameplay choices.")
	adv_settings.back_requested.emit()
	await create_timer(0.7, true, false, true).timeout
	_expect(
		adv_message_panel.visible and overlay_host.get_child_count() == 0,
		"Returning from ADV Settings must restore dialogue chrome synchronously after the overlay closes."
	)
	_expect(adv.current_message() == source_message, "Closing Settings must preserve the real dialogue instead of applying the preview sample to gameplay.")
	var reopened_settings := startup_flow.open_settings()
	var reopened_preview := reopened_settings.settings_page().display_page().preview_content() as AdvScreen
	_expect(reopened_preview.current_message() == sample_message, "Reopening in-game Settings must still initialize the same fixed sample.")
	_expect((reopened_preview.get_node("%StageDirector") as AdvStageDirector).presentation_state() == sample_stage, "Reopened Settings must retain the fixed sample stage.")
	startup_flow._close_settings_overlay(false)
	adv.title_exit_seconds = 0.01
	adv.title_exit_audio_seconds = 0.01
	adv.title_exit_chrome_seconds = 0.01
	adv.title_requested.emit()
	_expect(adv.is_route_exiting(), "Returning from ADV must start the source-style deferred exit instead of replacing the scene immediately.")
	var exit_cover := adv.get_node("VisualCanvas/RouteExitCover") as ColorRect
	_expect(
		exit_cover.visible and exit_cover.z_index < adv_message_panel.z_index,
		"ADV route exit must blacken the stage below the separately departing dialogue chrome."
	)
	await create_timer(0.1, true, false, true).timeout
	_expect(startup_flow.current_stage == StartupFlow.Stage.TITLE, "ADV must construct Title only after its black exit completes.")
	var returned_title := screen_host.get_child(0) as TitleScreen
	_expect(returned_title != null, "ADV return must create the scene-owned Title screen.")
	Engine.time_scale = 1.0
	# The frame that changes time_scale can still carry the old scaled delta.
	await process_frame
	await process_frame
	returned_title.game_exit_seconds = 0.25
	(returned_title.get_node("%NewGame") as BaseButton).pressed.emit()
	_expect(startup_flow.current_stage == StartupFlow.Stage.TITLE, "New Game must keep Title alive during its deferred departure.")
	_expect(not load_transition_cover.visible, "New Game must never raise the Continue/Load blue cover.")
	await create_timer(0.04).timeout
	_expect(is_instance_valid(returned_title) and returned_title.modulate.a > 0.0 and returned_title.modulate.a < 1.0, "The real Start button must fade Title gradually before replacing it.")
	var new_game_deadline := Time.get_ticks_msec() + 2000
	while startup_flow.current_stage == StartupFlow.Stage.TITLE and Time.get_ticks_msec() < new_game_deadline:
		await process_frame
	_expect(startup_flow.current_stage == StartupFlow.Stage.ADV, "New Game must enter ADV after the complete Title fade.")
	var new_adv := screen_host.get_child(0) as AdvScreen
	var new_stage := new_adv.get_node("%StageDirector") as AdvStageDirector
	var initial_snapshot := new_adv.get_node("%SnapshotFallback") as ColorRect
	var initial_message_panel := new_adv.get_node("%MessagePanel") as Control
	var initial_menu := new_adv.get_node("%SystemMenu") as Control
	_expect(new_stage.is_transitioning() and initial_snapshot.color.is_equal_approx(Color.BLACK), "The first CG must crossfade from the same black base as Title's exit.")
	_expect((new_adv.get_node("%SnapshotBackground") as TextureRect).texture == null, "The first CG must not inherit Title or Settings-preview artwork.")
	_expect(initial_message_panel.modulate.a < 1.0 and initial_menu.modulate.a < 1.0, "The first dialogue and menu must fade in rather than appear at full opacity.")
	_expect(is_equal_approx(float(startup_save_service.load_autosave().presentation.get("message_frame_alpha", 0.0)), 1.0), "Opening-animation opacity must not leak into the first autosave.")
	await create_timer(0.55).timeout
	_expect(not new_stage.is_transitioning() and new_stage.presentation_state().get("background") == "B27a", "New Game must settle on the original opening sky CG after its 500 ms update.")
	_expect(is_equal_approx(initial_message_panel.modulate.a, 1.0) and is_equal_approx(initial_menu.modulate.a, 1.0), "The first dialogue and menu must complete their 300 ms reveal.")
	_expect(initial_message_panel.position.is_equal_approx(Vector2(0, 760)) and is_equal_approx(initial_menu.position.y, 870.0), "The initial dialogue reveal is a fade, not the manual-hide slide animation.")
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


func _bus_volume_is(bus_name: StringName, expected_linear: float) -> bool:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return false
	return is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(bus_index)), expected_linear)
