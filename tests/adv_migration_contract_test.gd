extends SceneTree


const ADV_SCENE: PackedScene = preload("res://src/adv/adv_screen.tscn")
const CHOICE_SCENE: PackedScene = preload("res://src/adv/components/adv_choice_button.tscn")
const FIXTURE_DIRECTORY := "res://tests/fixtures/scenario"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_runtime_progress_contract()
	await _test_scene_and_animation_contract()
	if _failures.is_empty():
		print("ADV migration contract test passed.")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_runtime_progress_contract() -> void:
	var progress_catalog := AdvProgressCatalog.load_default()
	_expect(progress_catalog.load_error.is_empty(), "Imported CgFlag progress manifest must load.")
	_expect(
		progress_catalog.registered_flag_count() == 942
		and progress_catalog.flags_for_cg("EA01E") == [1006, 1001]
		and progress_catalog.flags_for_cg("B27A").is_empty()
		and progress_catalog.flags_for_cg("SP52") == [1297]
		and progress_catalog.flags_for_character("CA02_01M") == [115, 116],
		"CG and bust-up progress lookup must reproduce SetupCg/SetupBustup base and difference flags, using the source table's first definition for duplicate event/HCG keys."
	)
	var tone_catalog := AdvToneCatalog.load_default()
	_expect(
		tone_catalog.load_error.is_empty()
		and tone_catalog.registered_background_count() == 95
		and tone_catalog.tone_for_background("B01C") == "night_l"
		and tone_catalog.tone_for_background("EZ01B") == "evening"
		and tone_catalog.tone_for_background("EA01E") == "normal",
		"Imported UTF-8 background-tone metadata must reproduce CgSetupInfo lookup without runtime TJS decoding."
	)
	var macro_runtime := KrkrScenarioRuntime.new()
	root.add_child(macro_runtime)
	macro_runtime.configure(FIXTURE_DIRECTORY)
	var macro_tags: Array[StringName] = []
	var staff_roll_routes: Array[String] = []
	var macro_waits: Array[Dictionary] = []
	macro_runtime.instruction_executed.connect(
		func(instruction: KrkrScenarioInstruction) -> void:
			macro_tags.append(instruction.tag_name)
			if instruction.tag_name == &"staffroll":
				staff_roll_routes.append(instruction.string_argument("id"))
	)
	macro_runtime.wait_started.connect(
		func(milliseconds: int, cancellable: bool) -> void:
			macro_waits.append({"milliseconds": milliseconds, "cancellable": cancellable})
	)
	_expect(macro_runtime.handles(&"finish"), "Runtime must register source macro definitions from UTF-8 macro.ks.")
	_expect(macro_runtime.start_scenario("macro_invocation"), "Synthetic source macro invocation must start.")
	_expect(
		macro_runtime.pause_reason() == KrkrScenarioRuntime.PauseReason.TIMER
		and macro_waits.size() == 1
		and not bool(macro_waits[0].cancellable),
		"HitCancel on the source Wait tag must make the timer non-cancellable."
	)
	macro_runtime.advance()
	_expect(
		macro_runtime.pause_reason() == KrkrScenarioRuntime.PauseReason.TIMER,
		"Advancing must not skip a HitCancel timer."
	)
	await create_timer(0.08).timeout
	await process_frame
	_expect(
		macro_runtime.is_waiting_external(&"movie")
		and macro_tags.has(&"hide")
		and macro_tags.has(&"staffroll")
		and staff_roll_routes == ["穹"],
		"Macro expansion must preserve body order and substitute the ending route argument (tags=%s, route=%s, wait=%s)." % [
			macro_tags,
			staff_roll_routes,
			macro_runtime.external_wait_reason(),
		]
	)
	macro_runtime.resume_external(&"movie")

	var wait_runtime := KrkrScenarioRuntime.new()
	root.add_child(wait_runtime)
	wait_runtime.configure(FIXTURE_DIRECTORY)
	var wait_messages: Array[String] = []
	wait_runtime.dialogue_ready.connect(
		func(_speaker: String, message: String, _voice: String, _anchor: String, _read: bool) -> void:
			wait_messages.append(message)
	)
	_expect(wait_runtime.start_scenario("wait_cancellable"), "Cancellable wait fixture must start.")
	_expect(wait_runtime.pause_reason() == KrkrScenarioRuntime.PauseReason.TIMER, "Wait must pause progress.")
	wait_runtime.advance()
	_expect(wait_messages == ["等待已跳过"], "A Wait without HitCancel must advance immediately on input.")

	var choice_runtime := KrkrScenarioRuntime.new()
	root.add_child(choice_runtime)
	choice_runtime.configure(FIXTURE_DIRECTORY)
	var choice_errors: Array[String] = []
	var choice_messages: Array[String] = []
	choice_runtime.runtime_error.connect(func(message: String) -> void: choice_errors.append(message))
	choice_runtime.dialogue_ready.connect(
		func(_speaker: String, message: String, _voice: String, _anchor: String, _read: bool) -> void:
			choice_messages.append(message)
	)
	_expect(choice_runtime.start_scenario("choice_disabled"), "Disabled-choice fixture must start.")
	choice_runtime.choose(0)
	_expect(
		choice_runtime.is_waiting_for_choice() and choice_errors.size() == 1,
		"Rejecting a disabled option must keep the selection active instead of terminating playback."
	)
	choice_runtime.choose(1)
	_expect(
		choice_messages == ["有效选项继续执行"]
		and int(choice_runtime.parameters.get("112", 0)) == 4
		and bool(choice_runtime.global_flags.get("9", false))
		and bool(choice_runtime.parameters.get("select_terminated", false)),
		"A valid option must continue through SelectTerminate, conditions, parameters, and global flags."
	)
	var choice_save := choice_runtime.build_save_data("adv-contract")
	_expect(
		int(choice_save.scenario_parameters.get("112", 0)) == 4
		and bool(choice_save.global_flags.get("9", false)),
		"Save snapshots must retain scenario parameters and global route progress."
	)

	var route_runtime := KrkrScenarioRuntime.new()
	root.add_child(route_runtime)
	route_runtime.configure(FIXTURE_DIRECTORY)
	var route_messages: Array[String] = []
	route_runtime.dialogue_ready.connect(
		func(_speaker: String, message: String, _voice: String, _anchor: String, _read: bool) -> void:
			route_messages.append(message)
	)
	_expect(route_runtime.start_scenario("route_redirect"), "Common-route redirect fixture must start.")
	_expect(
		route_runtime.current_scenario_id == "00_b001"
		and route_messages == ["奈绪路线跳转成功"],
		"The common route boundary must redirect according to source local route flags."
	)

	var recollection_runtime := KrkrScenarioRuntime.new()
	root.add_child(recollection_runtime)
	recollection_runtime.configure(FIXTURE_DIRECTORY)
	var recollection_finished: Array[int] = [0]
	recollection_runtime.playback_finished.connect(func() -> void: recollection_finished[0] += 1)
	_expect(
		recollection_runtime.start_scenario(
			"recollection_boundary", "", null, true, "recollect"
		),
		"Recollection fixture must enter through its source label."
	)
	recollection_runtime.advance()
	_expect(
		recollection_finished[0] == 1 and recollection_runtime.pause_reason() == KrkrScenarioRuntime.PauseReason.FINISHED,
		"Recollection playback must return at @Recollect instead of continuing the normal route."
	)
	_expect(
		recollection_runtime.start_scenario("recollection_boundary"),
		"The same fixture must also run as normal route progress."
	)
	recollection_runtime.advance()
	_expect(
		bool(recollection_runtime.global_flags.get("77", false))
		and recollection_runtime.is_waiting_for_dialogue(),
		"Normal playback must unlock the recollection globally and continue beyond its boundary."
	)

	macro_runtime.free()
	wait_runtime.free()
	choice_runtime.free()
	route_runtime.free()
	recollection_runtime.free()
	await process_frame


func _test_scene_and_animation_contract() -> void:
	var previous_root_size := root.size
	root.size = Vector2i(1920, 1080)
	var save_service := SaveService.new()
	save_service.name = "AdvContractSaveService"
	var temporary_root := "/tmp/yosuga-adv-contract-%d" % Time.get_ticks_usec()
	save_service.configure_storage(temporary_root)
	root.add_child(save_service)
	var settings_repository := SettingsRepository.new()
	settings_repository.configure_storage("%s/settings.json" % temporary_root)
	var screen := ADV_SCENE.instantiate() as AdvScreen
	screen.configure(ScenarioLaunchRequest.new_game(), save_service, settings_repository)
	root.add_child(screen)
	await process_frame

	var dialogue_view := screen.get_node("%DialogueView") as AdvDialogueView
	_expect(dialogue_view.scene_file_path == "res://src/adv/components/adv_dialogue_view.tscn", "Gameplay must use the shared dialogue scene as a normal instance.")
	_expect(screen.get_node_or_null("VisualCanvas/DialogueView/MessagePanel") is PanelContainer, "Dialogue frame must remain scene-owned.")
	_expect(screen.get_node_or_null("VisualCanvas/DialogueView/MessagePanel/MessageColumn/Portrait") is TextureRect, "Dialogue portrait must remain scene-owned.")
	var stage_fallback := screen.get_node("VisualCanvas/Stage/StageFallback") as ColorRect
	var message_panel := screen.get_node("VisualCanvas/DialogueView/MessagePanel") as Control
	_expect(
		stage_fallback.mouse_filter == Control.MOUSE_FILTER_IGNORE
		and message_panel.mouse_filter == Control.MOUSE_FILTER_PASS,
		"The stage must ignore pointer input while the dialogue panel passes empty-area clicks and retains interactive child controls."
	)
	_expect(stage_fallback.color.is_equal_approx(Color.BLACK), "The initial ADV stage must use the source black backing, never a blue placeholder.")
	_expect(message_panel.modulate.a < 1.0, "New Game must begin with a gradual dialogue reveal.")
	screen._open_history()
	_expect(not message_panel.visible, "Opening history during the initial fade must hide dialogue immediately.")
	await create_timer(0.35).timeout
	_expect(not message_panel.visible, "The initial reveal must not finish underneath an active overlay and show dialogue again.")
	screen._close_history()
	_expect(message_panel.visible and is_equal_approx(message_panel.modulate.a, 1.0), "Closing an early overlay must restore full dialogue opacity, not a partial fade value.")
	_expect(
		screen.get_node_or_null("VisualCanvas/DialogueView/MessagePanel/MessageColumn/AdvanceIndicator") == null,
		"The removed blinking advance arrow must not remain in the dialogue scene."
	)
	var initial_message := screen.current_message()
	_send_primary_click(screen.size * 0.5)
	await process_frame
	_send_primary_click(screen.size * 0.5)
	await process_frame
	_expect(
		screen.current_message() != initial_message,
		"A primary click on the non-interactive stage must reach AdvScreen and advance past the current dialogue boundary."
	)
	var message_hide_button := screen.get_node(
		"VisualCanvas/DialogueView/MessagePanel/MessageColumn/MessageHideButton"
	) as TextureButton
	var message_before_manual_hide := screen.current_message()
	var message_rest_position := message_panel.position
	_send_primary_click(message_hide_button.get_global_rect().get_center())
	await create_timer(0.35).timeout
	_expect(
		not message_panel.visible
		and not (screen.get_node("VisualCanvas/SystemMenu") as Control).visible,
		"The source message-hide button must slide and fade the dialogue chrome out."
	)
	_send_primary_click(screen.size * 0.5)
	await create_timer(0.35).timeout
	_expect(
		message_panel.visible
		and message_panel.position.is_equal_approx(message_rest_position)
		and screen.current_message() == message_before_manual_hide,
		"The first stage click after a manual hide must restore the dialogue chrome without advancing text."
	)
	_expect(
		screen.get_node_or_null("VisualCanvas/SystemMenu/PreviousChoiceButton") is TextureButton
		and screen.get_node_or_null("VisualCanvas/SystemMenu/NextChoiceButton") is TextureButton
		and screen.get_node_or_null("VisualCanvas/SystemMenu/MenuLockButton") is TextureButton
		and screen.get_node_or_null("VisualCanvas/SystemMenu/AutoModeIndicator") is TextureRect
		and screen.get_node_or_null("VisualCanvas/SystemMenuRecallButton") is TextureButton,
		"The complete source system menu must remain fixed, previewable scene content."
	)
	_expect(
		screen.get_node_or_null("AutoIndicatorTimer") is Timer
		and screen.get_node_or_null("SystemMenuAutoHideTimer") is Timer,
		"System-menu animation timing must use scene-owned Timer nodes."
	)
	_expect(screen.get_node_or_null("VisualCanvas/DialogueView/MessagePanel/MessageColumn/SpeakerNameImage") is TextureRect, "Speaker name artwork must remain scene-owned.")
	_expect(screen.get_node_or_null("VisualCanvas/ChoiceOverlay/ChoiceCenter/ChoiceList") is VBoxContainer, "Choice layout must remain scene-owned.")
	var route_exit_cover := screen.get_node_or_null("VisualCanvas/RouteExitCover") as ColorRect
	var route_exit_blocker := screen.get_node_or_null("VisualCanvas/RouteExitBlocker") as Control
	_expect(
		route_exit_cover != null
		and route_exit_cover.z_index < message_panel.z_index
		and route_exit_blocker != null
		and route_exit_blocker.z_index > route_exit_cover.z_index,
		"ADV return-to-title must keep a scene-owned black stage cover below chrome and a separate input blocker above it."
	)
	_expect(screen.get_node_or_null("VisualCanvas/Stage/CameraCanvas/BackgroundScrollLayer") is Control, "Tiled background-scroll host must remain scene-owned.")
	_expect(screen.get_node_or_null("VisualCanvas/Stage/TransitionSnapshot") is Control, "Transition snapshot must remain scene-owned.")
	var snapshot_group := screen.get_node_or_null(
		"VisualCanvas/Stage/TransitionSnapshot/SnapshotGroup"
	) as CanvasGroup
	var snapshot_fallback := screen.get_node_or_null(
		"VisualCanvas/Stage/TransitionSnapshot/SnapshotGroup/SnapshotCamera/SnapshotFallback"
	) as ColorRect
	var snapshot_background := screen.get_node_or_null(
		"VisualCanvas/Stage/TransitionSnapshot/SnapshotGroup/SnapshotCamera/SnapshotBackground"
	) as TextureRect
	_expect(
		snapshot_group != null
		and snapshot_group.material is ShaderMaterial
		and snapshot_fallback != null and snapshot_fallback.material == null
		and snapshot_background != null and snapshot_background.material == null,
		"Transition layers must be composited by one CanvasGroup before fading so the blue fallback cannot bleed through a textured snapshot."
	)
	_expect(
		screen.get_node_or_null("VisualCanvas/EyeCatchOverlay/EyeCatchContent/EyeCatchTopBand") is ColorRect
		and screen.get_node_or_null("VisualCanvas/EyeCatchOverlay/EyeCatchContent/EyeCatchBottomBand") is ColorRect
		and screen.get_node_or_null("VisualCanvas/EyeCatchOverlay/EyeCatchContent/EyeCatchDateBlack") is ColorRect
		and screen.get_node_or_null("VisualCanvas/EyeCatchOverlay/EyeCatchContent/EyeCatchLogo") is TextureRect,
		"Source time/date eye-catch layers must remain fixed scene-owned controls."
	)
	var system_menu := screen.get_node("VisualCanvas/SystemMenu") as Control
	_expect(
		system_menu.position.is_equal_approx(Vector2(1602.0, 870.0))
		and screen.get_node_or_null("VisualCanvas/SystemMenu/SaveButton") is TextureButton
		and screen.get_node_or_null("VisualCanvas/SystemMenu/QuickLoadButton") is TextureButton,
		"The source 4x3 icon system-menu layout and quick actions must remain scene-owned."
	)
	var system_button_names: Array[String] = [
		"PreviousChoiceButton", "AutoButton", "SkipButton", "NextChoiceButton",
		"SaveButton", "LoadButton", "QuickSaveButton", "QuickLoadButton",
		"HistoryButton", "SettingsButton", "MenuLockButton", "TitleButton",
	]
	for button_name in system_button_names:
		var system_button := screen.get_node("VisualCanvas/SystemMenu/%s" % button_name) as TextureButton
		_send_pointer_motion(system_button.get_global_rect().get_center())
		await process_frame
		_expect(
			root.gui_get_hovered_control() == system_button,
			"The right-side system-menu button %s must own its GUI hit area." % button_name
		)
	var settings_requests: Array[bool] = []
	screen.settings_requested.connect(func() -> void: settings_requests.append(true))
	var settings_button := screen.get_node("VisualCanvas/SystemMenu/SettingsButton") as TextureButton
	_send_primary_click(settings_button.get_global_rect().get_center())
	await process_frame
	_expect(
		not settings_requests.is_empty(),
		"A real GUI click on the right-side system menu must reach its button instead of the dialogue panel."
	)
	var choice_layer := screen.get_node("VisualCanvas/ChoiceOverlay") as Control
	var eye_catch_layer := screen.get_node("VisualCanvas/EyeCatchOverlay") as Control
	var history_layer := screen.get_node("VisualCanvas/HistoryOverlay") as Control
	var feature_layer := screen.get_node("VisualCanvas/FeatureOverlay") as Control
	var confirmation_layer := screen.get_node("VisualCanvas/TitleConfirmation") as Control
	var movie_layer := screen.get_node("VisualCanvas/MovieLayer") as Control
	_expect(
		message_panel.z_index > 1000
		and system_menu.z_index > message_panel.z_index
		and choice_layer.z_index > system_menu.z_index
		and eye_catch_layer.z_index > choice_layer.z_index
		and history_layer.z_index > eye_catch_layer.z_index
		and feature_layer.z_index == history_layer.z_index
		and confirmation_layer.z_index > feature_layer.z_index
		and movie_layer.z_index > confirmation_layer.z_index,
		"ADV chrome and modal overlays must remain above the source character-order range and preserve a deterministic scene-owned stack."
	)
	screen._open_history()
	_expect(
		history_layer.visible and not message_panel.visible,
		"Opening a right-side feature overlay must hide the ADV dialogue chrome immediately."
	)
	screen._close_history()
	_expect(
		message_panel.visible and message_panel.position.is_equal_approx(message_rest_position),
		"Returning from a feature overlay must restore dialogue chrome synchronously with a zero-second transition."
	)
	screen._open_save_load(SaveLoadPage.Mode.SAVE)
	await process_frame
	_expect(
		feature_layer.visible and not message_panel.visible,
		"The in-game Save/Load overlay must use the same temporary dialogue-hide state."
	)
	screen._close_save_load()
	_expect(message_panel.visible, "Closing Save/Load must restore dialogue chrome immediately.")
	screen._request_title()
	_expect(
		confirmation_layer.visible and not message_panel.visible,
		"The return-title confirmation must hide dialogue chrome beneath its modal shade."
	)
	screen._cancel_title_confirmation()
	_expect(message_panel.visible, "Canceling return-title must restore dialogue chrome immediately.")

	var stage := screen.get_node("StageDirector") as AdvStageDirector
	screen._play_bgm("BGM05", 0)
	var navigation_missing_assets: Array[String] = []
	screen._stage_director.missing_asset.connect(
		func(_kind: String, resource_id: String) -> void:
			navigation_missing_assets.append(resource_id)
	)
	screen.runtime().configure(FIXTURE_DIRECTORY)
	_expect(screen.runtime().start_scenario("eyecatch"), "Source time eye-catch fixture must start.")
	_expect(
		screen.runtime().is_waiting_external(&"eyecatch")
		and (screen.get_node("VisualCanvas/EyeCatchOverlay") as Control).visible
		and screen._bgm_asset == "BGM05",
		"EyeCatch must pause progression while BgmStop=0 preserves the running BGM."
	)
	screen.runtime().advance()
	await process_frame
	_expect(
		screen.current_message() == "章节过场继续执行"
		and not (screen.get_node("VisualCanvas/EyeCatchOverlay") as Control).visible
		and str(stage.presentation_state().get("background", "")).to_upper() == "B27A",
		"EyeCatch input cancellation must commit its pending stage and resume at the next dialogue."
	)
	_expect(screen.runtime().start_scenario("eyecatch_date"), "Source date eye-catch fixture must start.")
	screen.runtime().advance()
	await process_frame
	_expect(
		screen.current_message() == "日期过场继续执行"
		and str(stage.presentation_state().get("background", "")).to_upper() == "BLACK",
		"Cancelling a DATE eye-catch must preserve its source black-stage handoff."
	)

	stage.clear()
	stage.execute(_tag(&"cg", {"file": "B27A"}))
	stage.execute(_tag(&"char", {"file": "CA02_01M", "order": 930}))
	stage.execute(_tag(&"update", {"time": 0}))
	stage.execute(_tag(&"cg", {"file": "B01C"}))
	stage.execute(_tag(&"char", {"file": "CA02_01M"}))
	stage.execute(_tag(&"update", {"time": 0}))
	var toned_character := screen.get_node("VisualCanvas/Stage/CharacterLayer").get_child(0) as TextureRect
	var night_tone := AdvToneCatalog.load_default().color_for_tone("night_l")
	_expect(
		is_equal_approx(toned_character.modulate.r, night_tone.r)
		and is_equal_approx(toned_character.modulate.b, night_tone.b),
		"Characters introduced over a source night background must inherit its environmental tone."
	)
	stage.execute(_tag(&"tone", {"type": "MONOCHROME"}, [&"all"]))
	stage.execute(_tag(&"update", {"time": 0}))
	_expect(
		toned_character.modulate.r < night_tone.r,
		"Tone all must combine the scripted effect with the current environmental tone."
	)
	stage.execute(_tag(&"tone"))
	stage.execute(_tag(&"update", {"time": 0}))
	_expect(
		is_equal_approx(toned_character.modulate.r, night_tone.r)
		and is_equal_approx(toned_character.modulate.b, night_tone.b),
		"A bare Tone tag must restore each character to the current background environment tone."
	)
	stage.clear()
	stage.execute(_tag(&"cg", {"file": "B27A"}))
	stage.execute(_tag(&"char", {"file": "CA02_01M", "order": 930}))
	stage.execute(_tag(&"update", {"time": 0}))
	_expect(
		bool(screen.runtime().global_flags.get("115", false))
		and bool(screen.runtime().global_flags.get("116", false)),
		"Presenting a bust-up must register both source dress and difference CgFlag progress."
	)
	screen._update_dialogue_chrome("穹")
	var speaker_name_image := screen.get_node("VisualCanvas/DialogueView/MessagePanel/MessageColumn/SpeakerNameImage") as TextureRect
	var portrait := screen.get_node("VisualCanvas/DialogueView/MessagePanel/MessageColumn/Portrait") as TextureRect
	_expect(
		speaker_name_image.visible and speaker_name_image.texture != null
		and portrait.visible and portrait.texture != null,
		"Source speaker-name artwork and the matching T portrait must be selected from dialogue state."
	)
	var opening_state := stage.presentation_state()
	_expect(
		str(opening_state.get("background", "")).to_upper() == "B27A"
		and (opening_state.get("characters", {}) as Dictionary).has("穹"),
		"CG and character orders must commit into the stage presentation."
	)
	var character_layer := screen.get_node("VisualCanvas/Stage/CharacterLayer") as Control
	_expect(
		character_layer.get_child_count() == 1
		and (character_layer.get_child(0) as Control).z_index == 930,
		"Explicit source character order must control visual stacking."
	)
	var opening_character := character_layer.get_child(0) as TextureRect
	_expect(
		opening_character.pivot_offset.is_equal_approx(Vector2(554.4, 347.4))
		and opening_character.position.is_equal_approx(Vector2(405.6, 192.6)),
		"Character guide points must come from the imported source bust-up CSV layout."
	)
	stage.execute(_tag(&"clearchar", {"id": "-1", "time": 30}))
	stage.execute(_tag(&"update", {"time": 30}))
	_expect(
		character_layer.get_child_count() == 1
		and (stage.presentation_state().get("characters", {}) as Dictionary).is_empty(),
		"ClearChar id=-1 must start the source fade-out while persistent presentation already reflects the cleared stage."
	)
	await _wait_until(func() -> bool: return character_layer.get_child_count() == 0, 0.15)
	_expect(character_layer.get_child_count() == 0, "ClearChar fade-out must remove every source bust-up at completion.")

	stage.execute(_tag(&"char", {"file": "CA02_01M", "x": 0, "y": 0}))
	stage.execute(_tag(&"update", {"time": 0}))
	stage.execute(_tag(&"move", {
		"id": "穹", "mx": 100, "fade": 1, "time": 1000,
	}))
	stage.execute(_tag(&"update", {"time": 0}))
	await _wait_until(func() -> bool: return not stage.is_action_running("穹"), 0.75)
	var moved_character := character_layer.get_child(0) as TextureRect
	_expect(
		not stage.is_action_running("穹")
		and is_equal_approx(moved_character.modulate.a, 1.0),
		"Move must use the source 500 ms default cycle and ignore stray fade/time fields instead of becoming Leave."
	)
	stage.execute(_tag(&"leave", {
		"id": "穹", "mx": 100, "my": 0, "fade": 1, "time": 1000, "accel": 1,
	}))
	stage.execute(_tag(&"update", {"time": 0}))
	await _wait_until(func() -> bool: return character_layer.get_child_count() == 0, 0.75)
	_expect(
		character_layer.get_child_count() == 0,
		"Leave must dispatch the source 500 ms ActionAdvMoveFadeOut sequence and remove its bust-up."
	)

	stage.clear()
	stage.execute(_tag(&"cg", {"file": "B27A", "center": "400,900"}))
	stage.execute(_tag(&"update", {"time": 0}))
	var tall_background := screen.get_node("VisualCanvas/Stage/CameraCanvas/Background") as TextureRect
	var camera_canvas := screen.get_node("VisualCanvas/Stage/CameraCanvas") as Control
	var tall_state := stage.presentation_state()
	var tall_spec := tall_state.get("background_spec", {}) as Dictionary
	_expect(
		tall_background.size.is_equal_approx(Vector2(1920.0, 2160.0))
		and tall_background.position.is_equal_approx(Vector2(0.0, -1080.0))
		and is_equal_approx(float(tall_spec.get("coordinate_scale", 0.0)), 3.6),
		"Tall source backgrounds must keep native size and use their scaled center anchor."
	)
	stage.execute(_tag(&"movecamera", {"x": 0, "y": -600, "z": 0, "time": 0}))
	_expect(
		camera_canvas.position.is_equal_approx(Vector2(0.0, 1080.0))
		and camera_canvas.scale.is_equal_approx(Vector2.ONE),
		"Tall-background camera coordinates must use the source 3.6x logical grid."
	)
	stage.execute(_tag(&"char", {"file": "CA02_01M"}))
	stage.execute(_tag(&"update", {"time": 0}))
	stage.execute(_tag(&"movecamera", {"x": 0, "y": 0, "z": 128, "time": 0}))
	var closeup_character := character_layer.get_child(0) as TextureRect
	_expect(
		camera_canvas.position.is_equal_approx(Vector2.ZERO)
		and camera_canvas.scale.is_equal_approx(Vector2(2.0, 2.0))
		and is_equal_approx(closeup_character.scale.x, 158.0 / 30.0),
		"Source camera depth must project backgrounds and character depth independently."
	)
	stage.clear()
	stage.restore_presentation(tall_state)
	_expect(
		tall_background.position.is_equal_approx(Vector2(0.0, -1080.0)),
		"Save restoration must preserve the source background center anchor."
	)
	stage.clear()
	stage.execute(_tag(&"cg", {"file": "B20A", "center": "1307,300"}))
	stage.execute(_tag(&"update", {"time": 0}))
	var wide_spec := (stage.presentation_state().get("background_spec", {}) as Dictionary)
	_expect(
		is_equal_approx(float(wide_spec.get("coordinate_scale", 0.0)), 2.0)
		and tall_background.position.is_equal_approx(Vector2.ZERO),
		"Wide non-tall backgrounds must retain the source fullscreen anchor and normal camera grid."
	)

	screen.runtime().global_flags["88"] = true
	screen._on_choices_ready([{"text": "存档边界", "hint": "", "disabled": false}])
	var choice_autosave := save_service.load_autosave()
	var choice_profile := save_service.load_profile()
	_expect(
		choice_autosave != null and choice_autosave.instruction_anchor == screen.runtime().current_anchor,
		"Opening a choice must write a restorable autosave at the pre-selection boundary."
	)
	_expect(
		choice_profile != null and bool(choice_profile.global_flags.get("88", false)),
		"Autosave boundaries must also persist global unlock progress in ProfileData."
	)
	screen._clear_choice_buttons()
	(screen.get_node("VisualCanvas/ChoiceOverlay") as Control).visible = false
	screen._choice_checkpoints.clear()
	screen._choice_history_position = 0

	stage.execute(_tag(&"cg", {"file": "EA01E"}))
	_expect(
		bool(screen.runtime().global_flags.get("1001", false))
		and bool(screen.runtime().global_flags.get("1006", false)),
		"Presenting an event CG must register both source base and difference album flags."
	)
	stage.execute(_tag(&"update", {
		"transition": "universal",
		"rule": "WIP_LR",
		"time": 30,
	}))
	_expect(stage.is_transitioning(), "Universal Update must start a rule-mask transition.")
	_expect(
		(screen.get_node("VisualCanvas/Stage/TransitionSnapshot") as Control).visible,
		"A running Update must expose the scene-owned previous-frame snapshot."
	)
	await create_timer(0.12).timeout
	await process_frame
	_expect(not stage.is_transitioning(), "Universal Update must finish and release its snapshot.")

	stage.clear()
	stage.execute(_tag(&"cg", {"file": "B34a"}))
	stage.execute(_tag(&"char", {"file": "CB02_11M"}))
	stage.execute(_tag(&"update", {"time": 0}))
	stage.execute(_tag(&"char", {"file": "CB02_01M", "time": 30}))
	stage.execute(_tag(&"update"))
	var local_character_transition := character_layer.get_child(0) as TextureRect
	_expect(
		not stage.is_transitioning()
		and not (screen.get_node("VisualCanvas/Stage/TransitionSnapshot") as Control).visible
		and local_character_transition.material is ShaderMaterial,
		"A bust-up-only source update must crossfade inside that character layer instead of retaining two complete stage images."
	)
	await create_timer(0.12).timeout
	await process_frame
	_expect(
		local_character_transition.material == null,
		"A completed bust-up crossfade must release its temporary local material."
	)
	var settled_character_state := stage.presentation_state()
	stage.clear()
	stage.restore_presentation(settled_character_state)
	var restored_character := character_layer.get_child(0) as TextureRect
	_expect(
		restored_character.material == null
		and stage._character_transition_tweens.is_empty(),
		"Save and navigation restoration must materialize settled character state without starting a hidden activation tween."
	)

	stage.clear()
	stage.execute(_tag(&"cg", {"file": "B27A"}))
	stage.execute(_tag(&"char", {"file": "CA02_01M"}))
	stage.execute(_tag(&"update", {"time": 0}))
	stage.execute(_tag(&"action", {
		"id": "穹",
		"action": "ActionAdvJump",
		"height": 30,
		"cycle": 30,
		"count": 1,
	}))
	_expect(stage.is_action_running("穹"), "ActionAdvJump must start on a committed character.")
	await _wait_until(func() -> bool: return not stage.is_action_running("穹"), 0.25)
	_expect(not stage.is_action_running("穹"), "Finite character actions must restore their origin and finish.")
	stage.execute(_tag(&"action", {
		"id": "穹",
		"action": "ActionAdvWave",
		"height": 3,
		"cycle": 30,
		"count": -1,
	}))
	await create_timer(0.05).timeout
	_expect(stage.is_action_running("穹"), "Negative-count source breathing actions must loop until explicitly stopped.")
	_expect(stage.is_action_looping("穹"), "The stage must identify negative-count source actions as non-terminating loops.")
	screen._waiting_action_target = ""
	screen._wait_for_action(_tag(&"waitaction", {"id": "穹"}))
	_expect(
		screen._waiting_action_target.is_empty(),
		"WaitAction must ignore a source loop instead of creating an external wait that can never finish."
	)
	var animated_state := stage.presentation_state()
	stage.clear()
	stage.restore_presentation(animated_state)
	_expect(stage.is_action_running("穹"), "Saving and restoring must resume persistent source character actions.")
	stage.stop_action("穹")

	stage.execute(_tag(&"action", {
		"id": "カメラ",
		"action": "ActionWave",
		"width": 32,
		"height": 0,
		"cycle": 30,
		"count": 2,
	}))
	_expect(stage.is_action_running("カメラ"), "ActionWave must animate the source camera target.")
	await _wait_until(func() -> bool: return not stage.is_action_running("カメラ"), 0.25)
	_expect(not stage.is_action_running("カメラ"), "Finite camera shake must complete.")
	stage.execute(_tag(&"movecamera", {"x": 40, "y": -20, "z": 16, "time": 30, "accel": 2}))
	_expect(stage.is_camera_moving(), "MoveCamera must create an independently waitable camera tween.")
	await _wait_until(func() -> bool: return not stage.is_camera_moving(), 0.25)
	_expect(not stage.is_camera_moving(), "MoveCamera must reach its final transform.")
	var camera_start_state := stage.presentation_state()
	stage.execute(_tag(&"movecamera", {"x": 0, "y": -120, "z": 0, "time": 300, "accel": 1}))
	var moving_camera_state := stage.presentation_state()
	var saved_camera_move := moving_camera_state.get("camera_move", {}) as Dictionary
	_expect(
		stage.is_camera_moving()
		and saved_camera_move.get("start_world_position", []) == camera_start_state.get("camera_world_position", [])
		and int(saved_camera_move.get("duration_milliseconds", 0)) == 300,
		"An in-flight camera save must retain the source move's original start and full base duration."
	)
	await create_timer(0.05).timeout
	moving_camera_state = stage.presentation_state()
	stage.clear()
	stage.restore_presentation(moving_camera_state)
	var replayed_camera_state := stage.presentation_state()
	_expect(
		stage.is_camera_moving()
		and replayed_camera_state.get("camera_world_position", []) == saved_camera_move.get("start_world_position", []),
		"Loading an in-flight camera save must jump back to the original start and replay the move."
	)
	await _wait_until(func() -> bool: return not stage.is_camera_moving(), 0.5)
	_expect(
		not stage.is_camera_moving()
		and (stage.presentation_state().get("camera_move", {}) as Dictionary).is_empty(),
		"A restored source camera move must finish normally and leave no stale save metadata."
	)
	stage.set_screen_effects_enabled(false)
	stage.execute(_tag(&"movecamera", {"x": 0, "y": 0, "z": 0, "time": 300}))
	_expect(
		not stage.is_camera_moving(),
		"Disabling source screen effects must settle MoveCamera immediately instead of saving a replay."
	)
	stage.set_screen_effects_enabled(true)

	stage.execute(_tag(&"bgscroll", {"file": "EZ01A", "mx": 800, "my": 0, "cycle": 80}))
	var scroll_layer := screen.get_node("VisualCanvas/Stage/CameraCanvas/BackgroundScrollLayer") as Control
	var scroll_tiles := screen.get_node("VisualCanvas/Stage/CameraCanvas/BackgroundScrollLayer/BackgroundScrollTiles") as Control
	_expect(scroll_layer.visible and scroll_tiles.get_child_count() > 1, "BgScroll must tile its source image so motion never exposes an empty edge.")
	var scroll_state := stage.presentation_state()
	var scroll_spec := scroll_state.get("background_scroll", {}) as Dictionary
	_expect(
		not scroll_spec.is_empty()
		and is_equal_approx(float(scroll_spec.get("mx", 0.0)), 800.0),
		"BgScroll must retain the source engine's raw 1920x1080 pixel travel in save presentation state."
	)
	stage.clear()
	stage.restore_presentation(scroll_state)
	_expect(scroll_layer.visible and scroll_tiles.get_child_count() > 1, "Loading must restore a running tiled background scroll.")

	var choice_button := CHOICE_SCENE.instantiate() as AdvChoiceButton
	root.add_child(choice_button)
	await process_frame
	choice_button.configure(0, "敲门", "穹", true)
	_expect(
		choice_button.choice_text == "敲门"
		and choice_button.get_node("ChoiceText").text == "敲门"
		and (choice_button.get_node("Background") as TextureRect).texture is AtlasTexture,
		"Reusable choice scene must bind source artwork and code-rendered text."
	)
	choice_button.free()

	screen.runtime().configure(FIXTURE_DIRECTORY)
	_expect(screen.runtime().start_scenario("choice_navigation"), "Choice-navigation fixture must start at a dialogue boundary.")
	await process_frame
	screen._jump_to_next_choice()
	_expect(
		screen.get_node_or_null("VisualCanvas/ChoiceJumpCover") == null,
		"Next-choice navigation must not insert an intermediate loading cover."
	)
	await _wait_until(
		func() -> bool: return (screen.get_node("VisualCanvas/ChoiceOverlay") as Control).visible,
		0.8
	)
	var choice_overlay := screen.get_node("VisualCanvas/ChoiceOverlay") as Control
	var choice_list := screen.get_node("VisualCanvas/ChoiceOverlay/ChoiceCenter/ChoiceList") as VBoxContainer
	_expect(
		choice_overlay.visible
		and screen.get_node_or_null("VisualCanvas/ChoiceOverlay/Shade") == null
		and is_equal_approx(choice_overlay.modulate.a, 1.0)
		and choice_list.get_child_count() == 1
		and screen.runtime().is_waiting_for_choice()
		and navigation_missing_assets.is_empty()
		and str(screen._stage_director.presentation_state().get("background", "")) == "BLACK"
		and screen._menu_visibility_tween == null
		and (screen.get_node("VisualCanvas/DialogueView/MessagePanel") as Control).visible
		and is_equal_approx((screen.get_node("VisualCanvas/DialogueView/MessagePanel") as Control).modulate.a, 1.0)
		and (screen.get_node("VisualCanvas/DialogueView/MessagePanel/MessageColumn/MessageLabel") as RichTextLabel).text == "选项跳转起点",
		"Next-choice navigation must restore the last pre-choice dialogue and stop exactly at StartSelect (visible=%s, rows=%d, pause=%s, jumping=%s)." % [
			choice_overlay.visible,
			choice_list.get_child_count(),
			screen.runtime().pause_reason(),
			screen._jumping_to_next_choice,
		]
	)
	var first_choice := choice_list.get_child(0) as Button
	_expect(
		first_choice != null
		and not first_choice.has_focus()
		and (screen.get_node("Audio/SePlayer") as AudioStreamPlayer).stream == null,
		"Choice navigation must neither focus the first row nor play an intermediate one-shot effect."
	)
	settings_requests.clear()
	_send_primary_click(settings_button.get_global_rect().get_center())
	await process_frame
	_expect(
		not settings_requests.is_empty() and choice_overlay.visible,
		"Choice rows must not turn the rest of the player chrome into an input-blocking modal."
	)
	if choice_list.get_child_count() == 1:
		(choice_list.get_child(0) as Button).pressed.emit()
	await _wait_until(func() -> bool: return screen.current_message() == "选项跳转完成", 0.9)
	var previous_choice_button := screen.get_node("VisualCanvas/SystemMenu/PreviousChoiceButton") as TextureButton
	_expect(
		screen.current_message() == "选项跳转完成"
		and is_equal_approx((screen.get_node("VisualCanvas/DialogueView/MessagePanel") as Control).modulate.a, 1.0)
		and not previous_choice_button.disabled,
		"Selecting an option must complete source Show, continue progress, and expose the previous-choice command."
	)
	var post_choice_save := screen._build_save_snapshot()
	_expect(
		post_choice_save.choice_navigation_stack.size() == 1
		and post_choice_save.choice_navigation_position == 1,
		"Saving after a choice must persist the source previous-choice stack and cursor."
	)
	screen._load_from_save_page(post_choice_save, "")
	await _wait_until(func() -> bool: return screen.current_message() == "选项跳转完成", 0.9)
	_expect(
		not previous_choice_button.disabled,
		"Loading must restore the previous-choice command before the first dialogue autosave rewrites state."
	)
	screen._jump_to_previous_choice()
	await _wait_until(func() -> bool: return choice_overlay.visible, 0.2)
	_expect(
		choice_overlay.visible
		and screen.runtime().is_waiting_for_choice()
		and not bool(screen.runtime().local_flags.get("8", false)),
		"Previous-choice navigation must restore the exact pre-branch runtime and presentation checkpoint."
	)
	if choice_list.get_child_count() == 1:
		(choice_list.get_child(0) as Button).pressed.emit()
	await _wait_until(func() -> bool: return screen.current_message() == "选项跳转完成" and not choice_overlay.visible, 0.6)
	var rollback_message := screen.current_message()
	var rollback_stage := screen._stage_director.presentation_state()
	screen._jump_to_next_choice()
	await _wait_until(func() -> bool: return not screen._jumping_to_next_choice, 0.8)
	await process_frame
	var restored_stage := screen._stage_director.presentation_state()
	_expect(
		screen.current_message() == rollback_message
		and (screen.get_node("VisualCanvas/DialogueView/MessagePanel") as Control).visible
		and str(restored_stage.get("background", "")) == str(rollback_stage.get("background", ""))
		and (restored_stage.get("characters", {}) as Dictionary).keys() == (rollback_stage.get("characters", {}) as Dictionary).keys(),
		"A next-choice jump with no later selection must restore the original dialogue, background, and characters."
	)

	screen._choice_checkpoints.clear()
	screen._choice_history_position = 0
	_expect(
		screen.runtime().start_scenario("choice_navigation_round_trip"),
		"Choice-navigation round-trip fixture must start at its first dialogue."
	)
	await process_frame
	screen._jump_to_next_choice()
	await _wait_until(func() -> bool: return choice_overlay.visible, 0.5)
	var navigation_message_label := screen.get_node(
		"VisualCanvas/DialogueView/MessagePanel/MessageColumn/MessageLabel"
	) as RichTextLabel
	var navigation_speaker_name_image := screen.get_node(
		"VisualCanvas/DialogueView/MessagePanel/MessageColumn/SpeakerNameImage"
	) as TextureRect
	var navigation_portrait := screen.get_node(
		"VisualCanvas/DialogueView/MessagePanel/MessageColumn/Portrait"
	) as TextureRect
	var first_choice_speaker_texture := navigation_speaker_name_image.texture
	var first_choice_portrait_texture := navigation_portrait.texture
	_expect(
		screen.current_message() == "第一个选项之前"
		and navigation_message_label.text == "第一个选项之前"
		and navigation_message_label.get_theme_font_size("normal_font_size") == 48
		and first_choice_speaker_texture != null
		and first_choice_portrait_texture != null,
		"The first choice checkpoint must include its complete pre-choice dialogue presentation."
	)
	if choice_list.get_child_count() == 1:
		(choice_list.get_child(0) as Button).pressed.emit()
	await _wait_until(func() -> bool: return screen.current_message() == "第二个选项跳转起点", 0.6)
	screen._jump_to_next_choice()
	await _wait_until(
		func() -> bool: return choice_overlay.visible and choice_list.get_child_count() == 1,
		0.5
	)
	_expect(
		choice_overlay.visible
		and screen.runtime().is_waiting_for_choice()
		and not previous_choice_button.disabled,
		"Reaching the next choice must immediately refresh and enable previous-choice navigation without requiring a selection."
	)
	_expect(
		navigation_message_label.text == "第二个选项之前"
		and navigation_message_label.get_theme_font_size("normal_font_size") == 50
		and navigation_speaker_name_image.texture != first_choice_speaker_texture
		and navigation_portrait.texture != first_choice_portrait_texture,
		"A temporary font on a skipped intermediate line must not leak into the later choice dialogue."
	)
	screen._jump_to_previous_choice()
	await _wait_until(func() -> bool: return choice_overlay.visible, 0.2)
	var restored_first_choice := choice_list.get_child(0) as AdvChoiceButton \
		if choice_list.get_child_count() == 1 else null
	_expect(
		restored_first_choice != null
		and restored_first_choice.choice_text == "第一条路线"
		and screen.current_message() == "第一个选项之前"
		and navigation_message_label.text == "第一个选项之前"
		and navigation_message_label.get_theme_font_size("normal_font_size") == 48
		and navigation_speaker_name_image.texture == first_choice_speaker_texture
		and navigation_portrait.texture == first_choice_portrait_texture,
		"Previous-choice navigation from an unselected next choice must restore the earlier choice together with its speaker, message, and portrait."
	)

	var snapshot := screen._build_save_snapshot()
	_expect(
		snapshot.presentation.has("message_frame_type")
		and snapshot.presentation.has("message_frame_position")
		and bool(snapshot.presentation.get("message_font_bound", false))
		and snapshot.presentation.has("bgm")
		and snapshot.presentation.has("environment_audio"),
		"Dialogue progress saves must include frame layout and persistent audio presentation."
	)
	var restored_frame := snapshot.presentation.duplicate(true)
	restored_frame["message_frame_type"] = "10"
	restored_frame["message_frame_position"] = [25.0, 90.0]
	restored_frame["message_frame_visible"] = false
	restored_frame["message_frame_alpha"] = 0.4
	screen._set_message_visible(true)
	screen._restore_presentation(restored_frame)
	await create_timer(0.35).timeout
	var saved_frame := screen._build_save_snapshot().presentation
	_expect(
		saved_frame.get("message_frame_type") == "10"
		and saved_frame.get("message_frame_position") == [25.0, 90.0]
		and not bool(saved_frame.get("message_frame_visible"))
		and is_equal_approx(float(saved_frame.get("message_frame_alpha")), 0.4)
		and message_panel.size == Vector2(1920, 1080)
		and not system_menu.visible,
		"Save restoration must preserve frame schema/layout/alpha and cancel the previous fade's completion."
	)
	screen._restore_presentation(snapshot.presentation)
	screen.runtime().global_flags["25"] = true
	screen._on_playback_finished()
	var ending_profile := save_service.load_profile()
	_expect(
		ending_profile != null and ending_profile.is_global_flag_set(25),
		"Reaching scenario EOF must persist final route-completion flags before returning to Title."
	)

	screen.free()
	save_service.free()
	await process_frame
	root.size = previous_root_size
	# The Vorbis mixer releases playback packet objects asynchronously.
	await create_timer(0.25, true, false, true).timeout


func _tag(
		tag_name: StringName,
		arguments: Dictionary = {},
		flags: Array[StringName] = []
) -> KrkrScenarioInstruction:
	return KrkrScenarioInstruction.tag(tag_name, arguments, flags, 0, "")


func _send_primary_click(position: Vector2) -> void:
	var pressed := InputEventMouseButton.new()
	pressed.button_index = MOUSE_BUTTON_LEFT
	pressed.position = position
	pressed.global_position = position
	pressed.pressed = true
	Input.parse_input_event(pressed)
	var released := InputEventMouseButton.new()
	released.button_index = MOUSE_BUTTON_LEFT
	released.position = position
	released.global_position = position
	released.pressed = false
	Input.parse_input_event(released)


func _send_pointer_motion(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	Input.parse_input_event(motion)


func _wait_until(predicate: Callable, timeout_seconds: float) -> void:
	var deadline := Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while not bool(predicate.call()) and Time.get_ticks_msec() < deadline:
		await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
