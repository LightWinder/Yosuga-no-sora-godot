extends SceneTree

const PREVIEW_SCENE: PackedScene = preload("res://src/adv/preview/adv_settings_preview.tscn")
const DIALOGUE_PATH := "res://src/adv/components/adv_dialogue_view.tscn"
const THEME: Theme = preload("res://assets/themes/yosuga_theme.tres")

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var viewport := SubViewport.new()
	viewport.name = "PreviewTestViewport"
	viewport.size = Vector2i(1920, 1080)
	viewport.gui_disable_input = true
	root.add_child(viewport)
	var preview := PREVIEW_SCENE.instantiate() as AdvSettingsPreview
	var settings := SettingsModel.defaults()
	settings["window_depth"] = 37
	settings["message_speed"] = 100
	settings["auto_speed"] = 300
	preview.configure(settings)
	viewport.add_child(preview)
	var view := preview.get_node("%DialogueView") as AdvDialogueView
	var label := view.get_node("%MessageLabel") as RichTextLabel
	var timer := preview.get_node("%ReplayTimer") as Timer
	_expect(view.is_revealing() and label.visible_characters == 0, "Visible preview must start its fixed reveal immediately.")
	_expect(preview.size == Vector2(1920, 1080), "Preview must fill the original 1920x1080 viewport.")
	_test_structure(preview)
	_test_settings(preview, settings)
	_test_reveal_speed(preview, settings)
	await _test_replay(preview, settings)
	await _test_visibility(preview)
	await _test_input(preview, viewport)
	# Disposing an active loop must not leave timers or deferred callbacks alive.
	view.finish_reveal()
	_expect(not timer.is_stopped(), "Disposal fixture must have a pending replay.")
	viewport.queue_free()
	await process_frame
	await process_frame
	if _failures.is_empty():
		print("ADV settings preview test passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _test_structure(preview: AdvSettingsPreview) -> void:
	_expect(preview.scene_file_path.ends_with("adv_settings_preview.tscn"), "Settings must use its dedicated lightweight scene.")
	_expect(preview.get_child_count() == 3, "Preview must contain only Background, DialogueView and ReplayTimer.")
	var view := preview.get_node("%DialogueView") as AdvDialogueView
	_expect(view.scene_file_path == DIALOGUE_PATH, "Preview must reuse the exact normal gameplay dialogue scene.")
	_expect((preview.get_node("%ReplayTimer") as Timer).one_shot, "Replay must use one cancellable, scene-owned one-shot timer.")
	for forbidden in ["ScenarioRuntime", "StageDirector", "BgmPlayer", "VoicePlayer", "MoviePlayer", "ChoiceOverlay", "HistoryOverlay", "SystemMenu", "SaveService"]:
		_expect(preview.find_child(forbidden, true, false) == null, "Preview must not create %s." % forbidden)
	_expect(preview.find_children("*", "AudioStreamPlayer", true, false).is_empty(), "Preview must not instantiate even idle audio players.")
	_expect(preview.find_children("*", "VideoStreamPlayer", true, false).is_empty(), "Preview must not instantiate a movie player.")
	_expect((preview.get_node("%Background") as TextureRect).texture.resource_path == "res://assets/content/event_1920/EA01E.png", "Preview must use the existing train CG directly.")
	_expect((view.get_node("%SpeakerLabel") as Label).text == "穹", "Sample speaker must remain fixed.")
	_expect((view.get_node("%SpeakerNameImage") as TextureRect).texture == AdvSettingsPreview.SAMPLE_NAME, "Sample must reuse the imported speaker-name texture.")
	_expect((view.get_node("%MessageLabel") as RichTextLabel).text == AdvSettingsPreview.SAMPLE_MESSAGE, "Sample text must be deterministic.")
	_expect(AdvSettingsPreview.SAMPLE_MESSAGE.length() >= 30 and AdvSettingsPreview.SAMPLE_MESSAGE.length() <= 55, "The speed demo needs a longer, bounded sample.")


func _test_settings(preview: AdvSettingsPreview, settings: Dictionary) -> void:
	var view := preview.get_node("%DialogueView") as AdvDialogueView
	var label := view.get_node("%MessageLabel") as RichTextLabel
	var portrait := view.get_node("%Portrait") as TextureRect
	var panel := view.get_node("%MessagePanel") as PanelContainer
	var style := panel.get_theme_stylebox("panel") as StyleBoxTexture
	_expect(is_equal_approx(style.modulate_color.a, 0.37), "Pre-tree configure must apply opacity on ready.")
	_expect(portrait.texture == AdvSettingsPreview.SAMPLE_PORTRAIT and portrait.visible, "Initial sample must display the fixed portrait.")
	_expect(label.get_theme_color("default_color") == AdvDialogueAppearance.READ_COLOR, "Fixed sample must be treated as already read.")
	settings["portrait_visible"] = false
	settings["read_color"] = false
	settings["window_depth"] = 25
	preview.apply_settings(settings)
	_expect(not portrait.visible and portrait.texture == null, "Portrait-off must remove the supplied portrait.")
	_expect(label.get_theme_color("default_color") == AdvDialogueAppearance.UNREAD_COLOR, "Read-color off must use the gameplay unread color.")
	_expect(is_equal_approx(style.modulate_color.a, 0.25) and label.modulate == Color.WHITE and portrait.modulate == Color.WHITE, "Only the frame texture should fade.")
	_expect(style != THEME.get_stylebox("panel", "AdvMessagePanel"), "Preview must own its mutable StyleBox.")
	for font_type in range(6):
		settings["font_type"] = font_type
		preview.apply_settings(settings)
		_expect(label.get_theme_font("normal_font") == AdvDialogueAppearance.message_font(font_type), "Preview and gameplay must resolve the same bundled font, including unsupported-family fallback.")
	settings["portrait_visible"] = true
	settings["read_color"] = true
	preview.apply_settings(settings)
	_expect(portrait.visible and portrait.texture == AdvSettingsPreview.SAMPLE_PORTRAIT, "Portrait-on must restore the fixed portrait, not a gameplay portrait.")


func _test_reveal_speed(preview: AdvSettingsPreview, settings: Dictionary) -> void:
	var view := preview.get_node("%DialogueView") as AdvDialogueView
	var label := view.get_node("%MessageLabel") as RichTextLabel
	view._reveal_tween.custom_step(0.4)
	_expect(label.visible_characters == 4, "Fixture must reveal several characters.")
	var old_tween := view._reveal_tween
	settings["message_speed"] = 50
	preview.apply_settings(settings)
	_expect(label.visible_characters == 4 and not old_tween.is_valid(), "Live speed changes must preserve characters and replace only the remaining tween.")
	view._reveal_tween.custom_step(0.1)
	_expect(label.visible_characters == 6 and label.text == AdvSettingsPreview.SAMPLE_MESSAGE, "Remaining characters must use the new speed without replacing the sample.")
	var same_tween := view._reveal_tween
	settings["bgm_volume"] = 0.1
	settings["system_menu_lock"] = false
	preview.apply_settings(settings)
	_expect(view._reveal_tween == same_tween and label.visible_characters == 6, "Unrelated settings must not restart the demo.")


func _test_replay(preview: AdvSettingsPreview, settings: Dictionary) -> void:
	var view := preview.get_node("%DialogueView") as AdvDialogueView
	var label := view.get_node("%MessageLabel") as RichTextLabel
	var timer := preview.get_node("%ReplayTimer") as Timer
	view.finish_reveal()
	_expect(not timer.is_stopped() and is_equal_approx(timer.wait_time, 0.3), "Full reveal must start the configured auto wait.")
	settings["auto_speed"] = 800
	preview.apply_settings(settings)
	_expect(is_equal_approx(timer.wait_time, 0.3) and label.visible_characters == -1, "An auto-speed edit must leave the current wait untouched.")
	await create_timer(0.05).timeout
	_expect(not view.is_revealing() and label.visible_characters == -1 and not timer.is_stopped(), "Replay must not start before the current auto wait.")
	var deadline := Time.get_ticks_msec() + 1000
	while not view.is_revealing() and Time.get_ticks_msec() < deadline:
		await process_frame
	_expect(view.is_revealing() and timer.is_stopped() and label.text == AdvSettingsPreview.SAMPLE_MESSAGE, "Auto-wait expiry must replay the same fixed sample.")
	view.finish_reveal()
	_expect(is_equal_approx(timer.wait_time, 0.8), "New auto speed must apply to the next wait.")


func _test_visibility(preview: AdvSettingsPreview) -> void:
	var view := preview.get_node("%DialogueView") as AdvDialogueView
	var label := view.get_node("%MessageLabel") as RichTextLabel
	var timer := preview.get_node("%ReplayTimer") as Timer
	preview.hide()
	_expect(timer.is_stopped() and not view.is_revealing(), "Hiding a waiting preview must cancel its replay.")
	preview.show()
	_expect(view.is_revealing() and label.visible_characters == 0, "Showing preview must begin at zero.")
	view._reveal_tween.custom_step(0.1)
	var count := label.visible_characters
	preview.hide()
	await create_timer(0.08).timeout
	_expect(not view.is_revealing() and timer.is_stopped() and label.visible_characters == count, "A hidden reveal must freeze without a background loop.")
	preview.show()
	_expect(view.is_revealing() and label.visible_characters == 0, "A canceled reveal must restart, not resume its hidden progress.")


func _test_input(preview: AdvSettingsPreview, viewport: SubViewport) -> void:
	var view := preview.get_node("%DialogueView") as AdvDialogueView
	var label := view.get_node("%MessageLabel") as RichTextLabel
	var panel := view.get_node("%MessagePanel") as PanelContainer
	var button := view.get_node("%MessageHideButton") as TextureButton
	var events: Array[String] = []
	view.hide_requested.connect(func() -> void: events.append("hide"))
	view.frame_gui_input.connect(func(_event: InputEvent) -> void: events.append("input"))
	view._reveal_tween.pause()
	var count := label.visible_characters
	var focus := root.gui_get_focus_owner()
	_expect(button.disabled and preview.mouse_filter == Control.MOUSE_FILTER_IGNORE and preview.focus_mode == Control.FOCUS_NONE, "Preview root and hide button must reject interaction.")
	for control in preview.find_children("*", "Control", true, false):
		_expect(control.mouse_filter == Control.MOUSE_FILTER_IGNORE and control.focus_mode == Control.FOCUS_NONE, "Preview descendant must ignore input: %s" % control.name)
	for mouse_button in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		var click := InputEventMouseButton.new()
		click.button_index = mouse_button
		click.pressed = true
		click.position = Vector2(800, 900)
		viewport.push_input(click)
		panel.gui_input.emit(click)
	for keycode in [KEY_SPACE, KEY_ENTER]:
		var key := InputEventKey.new()
		key.keycode = keycode
		key.pressed = true
		viewport.push_input(key)
	button.pressed.emit()
	await process_frame
	_expect(events.is_empty() and panel.visible and label.visible_characters == count, "Clicks, keys and synthetic hide requests must not advance or hide the sample.")
	_expect(root.gui_get_focus_owner() == focus, "Preview must not steal Settings focus.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
