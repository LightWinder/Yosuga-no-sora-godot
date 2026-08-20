extends SceneTree


const TITLE_SCENE: PackedScene = preload("res://src/title/title_screen.tscn")
const FEATURE_SCENE: PackedScene = preload("res://src/title/title_feature_screen.tscn")
const CONFIGURATION_SCENE: PackedScene = preload("res://src/title/config/title_configuration_screen.tscn")

var _failures: Array[String] = []


class MemorySaveService extends SaveService:
	var memory_autosave: SaveData
	var memory_profile: ProfileData = ProfileData.create_empty("0.1.0")
	var memory_flags: Dictionary = {}
	var settings_write_count := 0
	var settings_disk_read_count := 0
	var fail_settings_write := false

	func _ready() -> void:
		# Keep this contract test independent from the host's user:// location.
		_ready_for_io = true

	func has_autosave() -> bool:
		return memory_autosave != null

	func load_autosave() -> SaveData:
		return memory_autosave

	func clear_autosave() -> bool:
		memory_autosave = null
		return true

	func write_settings(settings: Dictionary) -> bool:
		settings_write_count += 1
		if fail_settings_write:
			last_error = "forced settings write failure"
			return false
		return super.write_settings(settings)

	func _read_dictionary(path: String) -> Dictionary:
		if path.ends_with("settings.json"):
			settings_disk_read_count += 1
		return super._read_dictionary(path)

	func load_profile() -> ProfileData:
		return memory_profile

	func get_autosave_summary() -> Dictionary:
		if memory_autosave == null:
			return {"valid": false}
		return {
			"valid": true,
			"scenario_id": memory_autosave.scenario_id,
			"label": memory_autosave.autosave_meta.get("label", ""),
		}

	func is_global_flag_set(flag_id: int) -> bool:
		return bool(memory_flags.get(flag_id, memory_profile.is_global_flag_set(flag_id)))


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_input_actions()
	_test_save_data_contract()
	_test_theme_font()
	await _test_save_service_round_trip()
	_test_export_presets()
	await _test_title_state()

	if _failures.is_empty():
		print("Title migration contract test passed.")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_input_actions() -> void:
	InputActions.ensure_actions()
	_expect(InputMap.has_action(InputActions.ADVANCE), "vn_advance must be registered.")
	_expect(InputMap.has_action(InputActions.CANCEL), "vn_cancel must be registered.")
	_expect(InputMap.has_action(InputActions.CONFIRM), "vn_confirm must be registered.")

	var key := InputEventKey.new()
	key.pressed = true
	key.physical_keycode = KEY_SPACE
	_expect(StartupInput.is_advance_event(key), "Space must advance.")
	key.echo = true
	_expect(not StartupInput.is_advance_event(key), "Key echo must not advance twice.")

	var left_click := InputEventMouseButton.new()
	left_click.pressed = true
	left_click.button_index = MOUSE_BUTTON_LEFT
	_expect(StartupInput.is_advance_event(left_click), "Primary mouse click must advance.")
	var emulated_left_click := InputEventMouseButton.new()
	emulated_left_click.pressed = true
	emulated_left_click.button_index = MOUSE_BUTTON_LEFT
	emulated_left_click.device = InputEvent.DEVICE_ID_EMULATION
	_expect(not StartupInput.is_advance_event(emulated_left_click), "Touch-emulated mouse must not advance a second time.")
	_expect(not StartupInput.is_confirm_event(emulated_left_click), "Touch-emulated mouse must not confirm a second time.")
	var emulated_right_click := InputEventMouseButton.new()
	emulated_right_click.pressed = true
	emulated_right_click.button_index = MOUSE_BUTTON_RIGHT
	emulated_right_click.device = InputEvent.DEVICE_ID_EMULATION
	_expect(not StartupInput.is_cancel_event(emulated_right_click), "Touch-emulated secondary mouse must not cancel a screen.")
	var wheel := InputEventMouseButton.new()
	wheel.pressed = true
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	_expect(not StartupInput.is_advance_event(wheel), "Mouse wheel must not advance.")
	var right_click := InputEventMouseButton.new()
	right_click.pressed = true
	right_click.button_index = MOUSE_BUTTON_RIGHT
	_expect(not StartupInput.is_advance_event(right_click), "Secondary mouse click must not advance.")
	var touch_down := InputEventScreenTouch.new()
	touch_down.pressed = true
	_expect(StartupInput.is_advance_event(touch_down), "Touch down must advance once.")
	var touch_up := InputEventScreenTouch.new()
	touch_up.pressed = false
	_expect(not StartupInput.is_advance_event(touch_up), "Touch release must not advance again.")


func _test_save_data_contract() -> void:
	var data := SaveData.create_empty("0.1.0")
	data.scenario_id = "00_z000"
	data.instruction_anchor = "hitret:42"
	data.set_global_flag(1)
	data.set_local_flag("choice_3")
	data.read_text_ids = ["00_z000:42"]
	data.autosave_meta = {"valid": true, "label": "列车"}
	var decoded := SaveData.from_dictionary(data.to_dictionary())
	_expect(decoded != null, "Current save data must round-trip.")
	if decoded != null:
		_expect(decoded.schema_version == SaveData.CURRENT_SCHEMA_VERSION, "Round-trip schema must be current.")
		_expect(decoded.is_global_flag_set(1), "Global route flag must survive round-trip.")
		_expect(decoded.instruction_anchor == "hitret:42", "Instruction anchor must survive round-trip.")

	var legacy := SaveData.from_dictionary({
		"version": 0,
		"game_version": "legacy",
		"scenario": "00_z000",
		"anchor": "hitret:7",
		"flags": {"1": true},
	})
	_expect(legacy != null, "Legacy schema must migrate.")
	if legacy != null:
		_expect(legacy.schema_version == SaveData.CURRENT_SCHEMA_VERSION, "Migrated schema must be current.")
		_expect(legacy.is_global_flag_set(1), "Legacy flags must migrate.")
	_expect(SaveData.from_dictionary({"schema_version": 999}) == null, "Future schema must be rejected.")


func _test_save_service_round_trip() -> void:
	var service := SaveService.new()
	var temporary_root := "/tmp/yosuga-godot-save-contract-%d" % OS.get_process_id()
	_clear_contract_directory(temporary_root)
	service.configure_storage(temporary_root)
	root.add_child(service)
	await process_frame
	var data := SaveData.create_empty("0.1.0")
	data.scenario_id = "00_z000"
	data.instruction_anchor = "hitret:first"
	data.autosave_meta = {"valid": true, "label": "atomic"}
	_expect(service.save_autosave(data), "SaveService must atomically write an autosave.")
	data.instruction_anchor = "hitret:second"
	_expect(service.save_autosave(data), "SaveService must safely overwrite the same autosave path.")
	var loaded := service.load_autosave()
	_expect(loaded != null, "SaveService must read the autosave it wrote.")
	if loaded != null:
		_expect(loaded.instruction_anchor == "hitret:second", "The newest autosave must win after overwrite.")
		_expect(service.has_autosave(), "A valid autosave must be discoverable by Title.")
	_expect(service.restore_autosave_backup(), "The previous autosave must be recoverable from backup.")
	var restored := service.load_autosave()
	if restored != null:
		_expect(restored.instruction_anchor == "hitret:first", "Backup restore must recover the prior autosave.")

	var profile := ProfileData.create_empty("0.1.0")
	profile.set_global_flag(1)
	profile.set_catalog_unlocked(TitleCatalog.MUSIC, "title_theme")
	_expect(service.save_profile(profile), "Profile progress must persist independently.")
	_expect(service.clear_autosave(), "Autosave cleanup must succeed.")
	_expect(service.is_global_flag_set(1), "Global progress must survive autosave deletion.")
	var corrupt_path := "%s/autosave.json" % temporary_root
	var corrupt_file := FileAccess.open(corrupt_path, FileAccess.WRITE)
	if corrupt_file != null:
		corrupt_file.store_string("{not valid json")
		corrupt_file.close()
	_expect(service.load_autosave() == null, "Corrupt JSON must be rejected without crashing.")
	_expect(not service.last_error.is_empty(), "Corrupt JSON must expose a recoverable error.")
	data.instruction_anchor = "hitret:recovered"
	_expect(service.save_autosave(data), "A corrupt save must be replaceable atomically.")
	service.free()
	await process_frame
	_clear_contract_directory(temporary_root)


func _clear_contract_directory(path: String) -> void:
	for filename in [
		"autosave.json", "autosave.json.bak", "autosave.json.tmp", "autosave.json.restore.tmp",
		"profile.json", "profile.json.bak", "profile.json.tmp", "profile.json.restore.tmp",
		"settings.json", "settings.json.bak", "settings.json.tmp", "settings.json.restore.tmp",
		"voice_favorites.json", "voice_favorites.json.bak", "voice_favorites.json.previous", "voice_favorites.json.tmp", "voice_favorites.json.restore.tmp",
	]:
		var file_path := "%s/%s" % [path, filename]
		if FileAccess.file_exists(file_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_export_presets() -> void:
	var text := FileAccess.get_file_as_string("res://export_presets.cfg")
	for preset_name in ["Windows Desktop", "macOS", "Android", "iOS"]:
		_expect(text.contains("name=\"%s\"" % preset_name), "Missing export preset: %s" % preset_name)
	_expect(text.contains("custom_features=\"mobile\""), "Mobile presets must carry a mobile feature tag.")
	_expect(text.contains("application/bundle_identifier"), "Apple presets must declare a bundle identifier without signing credentials.")


func _test_theme_font() -> void:
	var theme_path := "res://assets/themes/yosuga_theme.tres"
	var font_path := "res://assets/fonts/Xiaolai-Regular.fontdata"
	var attribution_path := "res://assets/fonts/Xiaolai-Regular-OFL-1.1.txt"
	_expect(FileAccess.file_exists(theme_path), "Project CJK theme must exist.")
	_expect(FileAccess.file_exists(font_path), "Standalone Xiaolai FontFile asset must exist.")
	_expect(FileAccess.file_exists(attribution_path), "Xiaolai font must ship with OFL 1.1 attribution.")
	_expect(str(ProjectSettings.get_setting("gui/theme/custom", "")) == theme_path, "Project must register the reusable CJK Theme globally.")
	var theme := load(theme_path) as Theme
	_expect(theme != null, "Project CJK Theme must load as a Theme resource.")
	if theme == null:
		return
	var font := theme.get_default_font()
	_expect(font != null, "Project CJK Theme must expose a default font.")
	if font == null:
		return
	var glyphs: Array[String] = ["环", "境", "设", "定", "删", "除", "存", "档"]
	for glyph in glyphs:
		var codepoint := glyph.unicode_at(0)
		_expect(font.has_char(codepoint), "Xiaolai default font must contain glyph U+%04X." % codepoint)


func _test_title_state() -> void:
	var service := MemorySaveService.new()
	var title_root := "/tmp/yosuga-godot-title-contract-%d" % OS.get_process_id()
	_clear_contract_directory(title_root)
	service.configure_storage(title_root)
	var autosave := SaveData.create_empty("0.1.0")
	autosave.scenario_id = "00_z000"
	autosave.autosave_meta = {"valid": true, "label": "测试自动存档"}
	service.memory_autosave = autosave
	service.memory_flags[1] = true
	service.memory_profile.set_global_flag(1)
	var title := TITLE_SCENE.instantiate() as TitleScreen
	title.configure(service)
	root.add_child(title)
	await process_frame
	var title_background := title.get_node("Background") as TextureRect
	_expect(title_background.get_parent() == title, "Title background must be independent from the safe-area content canvas.")
	_expect(is_equal_approx(title_background.anchor_right, 1.0) and is_equal_approx(title_background.anchor_bottom, 1.0), "Title background must fill the viewport anchors.")
	_expect(title_background.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "Title background must cover without stretching or exposing clear color.")
	var original_title_size := title.size
	title.set_size(Vector2(1280.0, 720.0))
	title._apply_design_transform()
	if not OS.has_feature("mobile"):
		var design_root := title.get_node("DesignRoot") as Control
		_expect(is_equal_approx(design_root.scale.x, 2.0 / 3.0), "Desktop 16:9 content must not receive an extra safe-area shrink.")
		_expect(design_root.position.length() < 0.01, "Desktop 16:9 content must be flush with the viewport when no safe area exists.")
	_expect(title_background.get_global_rect().size.is_equal_approx(Vector2(1280.0, 720.0)), "Title background must cover the complete 16:9 viewport.")
	title.set_size(original_title_size)
	title._apply_design_transform()
	var options := title.get_current_options()
	_expect(options.has(&"continue_game"), "Continue must appear when an autosave exists.")
	_expect(options.has(&"bonus"), "Bonus must appear after the cleared-game flag.")
	_expect(options.has(&"exit_game"), "Exit must appear on desktop.")
	_expect(title.get_menu_buttons().size() == 6, "Cleared save title menu must expose six desktop entries.")
	_expect(title.get_node_or_null("ExitConfirmationOverlay") == null, "Exit confirmation must remain lazy until requested.")
	_expect(title.get_node_or_null("ScenarioUnavailableNotice") == null, "Scenario notice must remain lazy until requested.")
	_expect_no_generated_node_names(title, "Title scene")
	var requested: Array[StringName] = []
	var scenario_requests: Array[ScenarioLaunchRequest] = []
	title.feature_requested.connect(func(feature_id: StringName) -> void: requested.append(feature_id))
	title.scenario_requested.connect(func(request: ScenarioLaunchRequest) -> void: scenario_requests.append(request))
	for button in title.get_menu_buttons():
		if button.option_id == &"continue_game":
			button.pressed.emit()
			break
	await process_frame
	_expect(scenario_requests.size() == 1, "Continue must emit one unified ScenarioLaunchRequest.")
	_expect(title.is_scenario_notice_visible(), "Continue must enter an explicit unavailable-runner notice.")
	var title_notice := title.get_node_or_null("ScenarioUnavailableNotice") as ScenarioUnavailableNotice
	_expect(title_notice != null and title_notice.scene_file_path.ends_with("scenario_unavailable_notice.tscn"), "Scenario notice must be a reusable scene instance.")
	_expect(scenario_requests[0].scenario_id == "00_z000", "Continue request must preserve save scenario.")
	var notice_escape := InputEventKey.new()
	notice_escape.pressed = true
	notice_escape.keycode = KEY_ESCAPE
	title._input(notice_escape)
	_expect(not title.is_scenario_notice_visible(), "Scenario notice must be dismissible without leaving the title.")
	for button in title.get_menu_buttons():
		if button.option_id == &"bonus":
			button.pressed.emit()
			break
	await process_frame
	_expect(title.is_bonus_mode(), "Bonus must enter the four-item submenu.")
	_expect(title.get_bonus_buttons().size() == 4, "Bonus must expose Album/Music/Memories/Voice.")
	var bonus_back := title.get_node("DesignRoot/MenuLayer/BonusBackButton") as Button
	bonus_back.pressed.emit()
	_expect(not title.is_bonus_mode(), "Bonus Back button must return through normal GUI.")
	for button in title.get_menu_buttons():
		if button.option_id == &"bonus":
			button.pressed.emit()
			break
	await process_frame
	var escape := InputEventKey.new()
	escape.pressed = true
	escape.keycode = KEY_ESCAPE
	title._input(escape)
	_expect(not title.is_bonus_mode(), "Escape must return from Bonus.")
	for button in title.get_menu_buttons():
		if button.option_id == &"exit_game":
			button.pressed.emit()
			break
	await process_frame
	_expect(title.is_exit_confirmation_visible(), "Exit must open its confirmation scene.")
	var exit_dialog := title.get_node_or_null("ExitConfirmationOverlay") as TitleExitConfirmation
	_expect(exit_dialog != null and exit_dialog.scene_file_path.ends_with("title_exit_confirmation.tscn"), "Exit confirmation must be a reusable scene instance.")
	var exit_escape := InputEventKey.new()
	exit_escape.pressed = true
	exit_escape.keycode = KEY_ESCAPE
	title._input(exit_escape)
	_expect(not title.is_exit_confirmation_visible(), "Escape must dismiss the exit confirmation scene.")
	for button in title.get_menu_buttons():
		if button.option_id == &"load_game":
			button.pressed.emit()
			break
	await process_frame
	_expect(requested.has(&"load_game"), "Load must emit a dedicated feature route.")
	title.free()
	await process_frame

	var manual_slot := SaveData.create_empty("0.1.0")
	manual_slot.scenario_id = "00_z001"
	manual_slot.instruction_anchor = "hitret:slot"
	manual_slot.autosave_meta = {"label": "手动槽位"}
	_expect(service.save_slot(0, manual_slot), "Load contract needs a real manual slot.")
	var feature := FEATURE_SCENE.instantiate() as TitleFeatureScreen
	feature.configure(&"load_game", service)
	var back_events: Array[bool] = []
	var feature_requests: Array[ScenarioLaunchRequest] = []
	feature.back_requested.connect(func() -> void: back_events.append(true))
	feature.scenario_requested.connect(func(request: ScenarioLaunchRequest) -> void: feature_requests.append(request))
	root.add_child(feature)
	await process_frame
	_expect(feature.feature_id == &"load_game", "Feature screen must preserve its route id.")
	_expect(feature.get_node_or_null("DeleteSaveConfirmation") == null, "Load confirmation must remain lazy until deletion is requested.")
	_expect(feature.get_node_or_null("ScenarioUnavailableNotice") == null, "Load scenario notice must remain lazy until continue is requested.")
	_expect(feature.get_node_or_null("VoiceCollectionService") == null, "Load route must not own the voice catalog service.")
	var load_list := feature.get_node("Content/EntryList") as VBoxContainer
	_expect(load_list.get_child_count() == 21, "Load must list autosave plus all 20 manual slots.")
	var load_select := (load_list.get_child(0) as HBoxContainer).get_child(0) as Button
	load_select.pressed.emit()
	await process_frame
	_expect(feature.get_node("Content/Primary").visible, "Load selection must reveal continue action.")
	var manual_delete := (load_list.get_child(1) as HBoxContainer).get_child(1) as Button
	manual_delete.pressed.emit()
	await process_frame
	_expect(feature.is_delete_confirmation_visible(), "Deleting a manual slot must ask for confirmation.")
	_expect(service.has_slot(0), "Cancel is not allowed to delete a manual slot.")
	feature.cancel_delete_confirmation()
	_expect(service.has_slot(0), "Canceled manual-slot deletion must preserve the file.")
	manual_delete.pressed.emit()
	await process_frame
	feature.confirm_delete_confirmation()
	await process_frame
	_expect(not service.has_slot(0), "Confirmed manual-slot deletion must refresh and remove the file.")
	_expect_no_generated_node_names(feature, "Load scene after list refresh")
	var autosave_delete := (load_list.get_child(0) as HBoxContainer).get_child(1) as Button
	autosave_delete.pressed.emit()
	await process_frame
	_expect(feature.is_delete_confirmation_visible(), "Deleting autosave must ask for confirmation.")
	feature.cancel_delete_confirmation()
	_expect(service.has_autosave(), "Canceled autosave deletion must preserve the autosave.")
	autosave_delete.pressed.emit()
	await process_frame
	feature.confirm_delete_confirmation()
	await process_frame
	_expect(not service.has_autosave(), "Confirmed autosave deletion must remove the autosave.")
	load_select = null
	var feature_back := feature.get_node("Content/Back") as Button
	feature_back.pressed.emit()
	_expect(back_events.size() == 1, "Feature Back button must emit its typed route signal.")
	feature.free()
	await process_frame

	var config := CONFIGURATION_SCENE.instantiate() as TitleConfigurationScreen
	config.configure(service)
	root.add_child(config)
	await process_frame
	var config_page := config.configuration_page()
	_expect(config_page != null, "Config must expose a dedicated HD window model.")
	_expect(config.get_node_or_null("Content") == null, "Configuration route must not retain hidden generic feature chrome.")
	_expect(config.scene_file_path.ends_with("title_configuration_screen.tscn"), "Configuration must be owned by a dedicated route scene.")
	_expect(config_page.scene_file_path.ends_with("title_configuration_page.tscn"), "Configuration editor must be a reusable scene instance.")
	_expect(config_page.find_setting_slider("master_volume") != null, "Config must expose master volume.")
	_expect(config_page.find_setting_slider("voice_volume") != null, "Config must expose voice volume.")
	_expect(config_page.find_setting_slider("movie_volume") != null, "Config must expose movie volume.")
	_expect(config_page.find_setting_slider("voice_detail") != null, "Config must expose the per-character voice slider.")
	_expect(config_page.find_setting_slider("window_depth") != null, "Config must expose the textbox depth slider.")
	_expect(config_page.screen_page().get_node_or_null("PageBackground") == null, "Screen config chrome must not regress to a baked 1920x1080 UI background.")
	_expect(config_page.find_setting_slider("window_depth").uses_vector_visual(), "Screen config slider must use resolution-independent drawing.")
	var screen_page := config_page.screen_page()
	_expect(screen_page.scene_file_path.ends_with("config_screen_page.tscn"), "Screen settings layout must be scene-owned instead of rebuilt by its controller.")
	var main_columns := screen_page.find_child("MainColumns", true, false) as HBoxContainer
	_expect(main_columns != null, "Screen config must organize its cards with a two-column container layout.")
	_expect(main_columns.find_child("LeftColumn", true, false) is VBoxContainer, "Screen config must expose a container-managed left column.")
	_expect(main_columns.find_child("RightColumn", true, false) is VBoxContainer, "Screen config must expose a container-managed right column.")
	_expect(screen_page.find_child("PreviewArtwork", true, false) != null, "Screen config must retain the scenic preview as artwork.")
	var font_selection_title := screen_page.find_child("FontSelectionTitle", true, false) as ConfigSectionTitle
	_expect(font_selection_title != null and font_selection_title.caption == "字体选择", "Screen headings must be rendered from live text.")
	_expect(font_selection_title.find_children("*", "TextureRect", true, false).is_empty(), "Screen headings must not regress to cropped source textures.")
	_expect(font_selection_title.get_child_count() == 2, "A section heading must own exactly its two reusable text layers.")
	_expect(font_selection_title.get_node_or_null("OuterKeyline") is Label and font_selection_title.get_node_or_null("Foreground") is Label, "Section heading stroke layers must remain explicit code-rendered labels.")
	var preview_artwork := screen_page.find_child("PreviewArtwork", true, false) as TextureRect
	var preview_region := preview_artwork.texture as AtlasTexture
	_expect(preview_region != null and preview_region.region.position.y >= 361.0, "Preview artwork must crop out the baked source heading before live text is overlaid.")
	var preview_textbox := screen_page.find_child("PreviewTextbox", true, false) as TextureRect
	var preview_avatar := screen_page.find_child("PreviewAvatar", true, false) as TextureRect
	_expect(preview_textbox != null and preview_textbox.texture != null, "Screen preview must retain the source textbox artwork.")
	_expect(preview_avatar != null and preview_avatar.texture != null and preview_avatar.size.x > 0.0, "Screen preview avatar artwork must have a visible rect.")
	_expect(config_page.get_node_or_null("VisualCanvas/ConfigConfirm/Message") is Label, "Config confirmation hierarchy must be declared by its reusable scene.")
	_expect_no_generated_node_names(config, "Configuration scene")
	_expect(config_page.find_setting_slider("message_speed") != null, "Config must expose message speed.")
	_expect(config_page.find_setting_slider("auto_speed") != null, "Config must expose auto speed.")
	_expect(config_page.audio_page() != null and config_page.audio_page().voice_button_count() == 9, "Config audio page must expose the nine source voice characters.")
	_expect(TitleSettingsModel.defaults().get("confirmations", {}).size() == 11, "Config must preserve all eleven confirmation toggles.")
	_expect(TitleSettingsModel.VOICE_DETAIL_NAMES.size() == 11, "Settings must preserve the eleven source VCID detail slots.")
	var source_defaults := TitleSettingsModel.defaults()
	_expect(is_equal_approx(float(source_defaults.get("bgm_volume", 0.0)), 0.5) and is_equal_approx(float(source_defaults.get("se_volume", 0.0)), 0.7), "Audio defaults must match the source System.tjs gains.")
	_expect(int(source_defaults.get("window_depth", -1)) == 50 and int(source_defaults.get("message_speed", -1)) == 5, "Screen/system defaults must preserve source units.")
	var normalized_edges := TitleSettingsModel.normalize({"window_mode": "borderless", "window_width": 1500, "font_type": 99, "mute_master": 1})
	_expect(str(normalized_edges.get("window_mode", "")) == "windowed" and int(normalized_edges.get("window_width", 0)) == 1600, "Unsupported desktop modes and widths must normalize to source HD choices.")
	_expect(int(normalized_edges.get("font_type", -1)) == 5 and normalized_edges.get("mute_master", false) == true, "Font and mute values must be clamped/normalized before persistence.")
	var preview_updates: Array[Dictionary] = []
	service.settings_preview_changed.connect(func(settings: Dictionary) -> void: preview_updates.append(settings))
	var writes_before_preview := service.settings_write_count
	var settings_reads_before_preview := service.settings_disk_read_count
	var master_slider := config_page.find_setting_slider("master_volume")
	master_slider.value = 42.0
	master_slider.value = 43.0
	master_slider.value = 44.0
	_expect(preview_updates.size() >= 3, "Config slider must preview each value change in real time.")
	_expect(service.settings_write_count == writes_before_preview, "Slider preview must not write settings for every value_changed.")
	_expect(service.settings_disk_read_count == settings_reads_before_preview, "Slider preview must use the settings snapshot without rereading disk.")
	await create_timer(0.4, true, false, true).timeout
	_expect(is_equal_approx(float(service.read_settings().get("master_volume", 0.0)), 0.44), "Config slider must persist after debounce.")
	_expect(service.settings_write_count == writes_before_preview + 1, "Debounced slider changes must persist once.")
	master_slider.value = 55.0
	master_slider.drag_ended.emit(true)
	_expect(service.settings_write_count == writes_before_preview + 2, "Ending a slider drag must commit the pending preview immediately.")
	await create_timer(0.3, true, false, true).timeout
	_expect(is_equal_approx(float(service.read_settings().get("master_volume", 0.0)), 0.55), "Drag-end commit must persist the final slider value.")

	config_page.screen_page().set_window_mode_for_test("fullscreen")
	_expect(str(service.read_settings().get("window_mode", "")) == "fullscreen", "Window mode must persist.")
	config_page.screen_page().set_window_mode_for_test("windowed")
	_expect(str(service.read_settings().get("window_mode", "")) == "windowed", "Window mode must revert.")
	config_page.screen_page().set_window_width_for_test(1920)
	_expect(int(service.read_settings().get("window_width", 0)) == 1920, "Window width must persist.")
	config_page.screen_page().set_window_width_for_test(1280)
	config_page.screen_page().set_font_for_test(3)
	_expect(int(service.read_settings().get("font_type", 0)) == 3, "Font type must persist.")
	config_page.screen_page().set_screen_toggle_for_test("portrait_visible", false)
	_expect(service.read_settings().get("portrait_visible", true) == false, "Screen toggles must persist.")
	_expect(not preview_avatar.visible, "Screen preview must hide the avatar immediately when portrait display is disabled.")
	config_page.screen_page().set_screen_toggle_for_test("portrait_visible", true)
	_expect(preview_avatar.visible, "Screen preview must restore the avatar immediately when portrait display is enabled.")
	config_page.system_page().set_system_toggle_for_test("read_skip", true)
	_expect(service.read_settings().get("read_skip", true) == false, "The source readSkip flag is inverted relative to the HD YES/NO label.")
	config_page.system_page().set_system_toggle_for_test("lock_auto", true)
	_expect(service.read_settings().get("lock_auto", false) == true, "System toggles must persist.")
	config_page.system_page().set_confirmation_for_test("delete", false)
	var confirmations_after: Dictionary = service.read_settings().get("confirmations", {})
	_expect(confirmations_after.get("delete", true) == false, "Confirmation toggles must persist.")
	_expect(confirmations_after.get("load", false) == true and confirmations_after.get("clear_read", false) == true, "Updating one confirmation must preserve the other source flags.")
	config_page.system_page().set_confirmation_for_test("delete", true)

	config_page.audio_page().select_voice(2)
	_expect(config_page.audio_page().selected_voice_detail_index() == 1, "Voice selection must map to the source VCID detail index.")
	var voice_slider := config_page.find_setting_slider("voice_detail")
	voice_slider.value = 30.0
	voice_slider.drag_ended.emit(true)
	var details: Array = service.read_settings().get("voice_detail_volumes", [])
	_expect(is_equal_approx(float(details[1]), 0.3), "Voice detail volume must persist at the source detail index.")

	var sample_files := TitleSettingsModel.VOICE_SAMPLE_FILES
	for detail_index in sample_files.size():
		_expect(FileAccess.file_exists("res://assets/audio/voice_samples/%s.ogg" % sample_files[detail_index]), "Voice sample must exist: %s" % sample_files[detail_index])
	_expect(FileAccess.file_exists("res://assets/content/confirm/bg.png"), "Confirm dialog background must exist.")
	_expect(FileAccess.file_exists("res://assets/content/confirm/yes.png"), "Confirm yes button must exist.")
	_expect(FileAccess.file_exists("res://assets/content/confirm/no.png"), "Confirm no button must exist.")
	_expect(FileAccess.file_exists("res://assets/content/confirm/ask_always.png"), "Confirm always-ask toggle must exist.")

	config_page.request_reset_settings()
	_expect(config_page.is_confirm_visible(), "Reset settings must ask when confirmations.default is enabled.")
	config_page.cancel_pending_action()
	_expect(not config_page.is_confirm_visible(), "Cancel must dismiss the reset confirm dialog.")
	var writes_before_reset := service.settings_write_count
	config_page.request_reset_settings()
	config_page.confirm_pending_action()
	_expect(service.settings_write_count == writes_before_reset + 1, "Confirmed reset must persist once.")
	var reset_values := service.read_settings()
	_expect(is_equal_approx(float(reset_values.get("master_volume", 0.0)), 1.0), "Reset settings must restore default volumes.")
	_expect(str(reset_values.get("window_mode", "")) == "windowed", "Reset settings must preserve window mode.")
	_expect(int(reset_values.get("window_width", 0)) == 1280, "Reset settings must preserve window width.")
	config_page.system_page().set_confirmation_for_test("default", false)
	var writes_before_silent_reset := service.settings_write_count
	config_page.request_reset_settings()
	_expect(not config_page.is_confirm_visible(), "Reset settings must skip the dialog when confirmations.default is disabled.")
	_expect(service.settings_write_count == writes_before_silent_reset + 1, "Silent reset must persist once.")
	var read_reset_events: Array[bool] = []
	var feature_read_reset_events: Array[bool] = []
	config_page.read_flags_reset_requested.connect(func() -> void: read_reset_events.append(true))
	config.read_flags_reset_requested.connect(func() -> void: feature_read_reset_events.append(true))
	config_page.request_reset_read()
	_expect(config_page.is_confirm_visible(), "Reset read flags must ask when confirmations.clear_read is enabled.")
	config_page.confirm_pending_action()
	_expect(read_reset_events.size() == 1, "Reset read flags must emit a typed seam request.")
	_expect(feature_read_reset_events.size() == 1, "Configuration feature must forward the read-reset request to StartupFlow.")

	service.fail_settings_write = true
	config_page.screen_page().set_font_for_test(4)
	var config_status := config_page.get_node("VisualCanvas/ConfigStatus") as Label
	_expect(config_status.text.contains("设置保存失败"), "A settings persistence failure must remain visible in the configuration window.")
	_expect(int(config_page.get_current_settings().get("font_type", -1)) == 0, "A failed settings write must roll the UI back to the durable snapshot.")
	service.fail_settings_write = false
	config_page.screen_page().set_font_for_test(0)

	var close_events: Array[bool] = []
	config_page.close_requested.connect(func() -> void: close_events.append(true))
	config_page.open_key_popup()
	_expect(config_page.is_key_popup_visible(), "Key config button must open the popup.")
	var popup_escape := InputEventKey.new()
	popup_escape.pressed = true
	popup_escape.keycode = KEY_ESCAPE
	config_page._input(popup_escape)
	_expect(not config_page.is_key_popup_visible(), "Cancel must close the key popup before closing the window.")
	_expect(close_events.is_empty(), "Popup dismissal must not close the whole config window.")
	var window_escape := InputEventKey.new()
	window_escape.pressed = true
	window_escape.keycode = KEY_ESCAPE
	config_page._input(window_escape)
	_expect(close_events.size() == 1, "Cancel must close the HD config window.")

	var legacy_settings := TitleSettingsModel.normalize({
		"schema_version": 2,
		"window_opacity": 0.6,
		"message_speed": 5,
		"voice_detail_volumes": [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2],
	})
	_expect(int(legacy_settings.get("window_depth", 0)) == 60, "Schema 2 window opacity must migrate to window depth.")
	_expect(int(legacy_settings.get("message_speed", 0)) == 50, "Schema 2 message speed must migrate to the source 0-100 scale.")
	var migrated_details: Array = legacy_settings.get("voice_detail_volumes", [])
	_expect(migrated_details.size() == 11, "Schema 2 voice details must migrate to eleven source slots.")
	_expect(is_equal_approx(float(migrated_details[0]), 1.0) and is_equal_approx(float(migrated_details[1]), 0.8) and is_equal_approx(float(migrated_details[2]), 0.9) and is_equal_approx(float(migrated_details[10]), 0.2), "Schema 2 voice detail order must remap to source VCID order.")
	config.free()
	await process_frame

	var manifest := TitleCatalog.load_manifest()
	_expect(manifest.load_error.is_empty(), "Title content manifest must load without error.")
	_expect(manifest.album_groups.size() == 6, "Album manifest must expose six HD character groups.")
	_expect(manifest.album_card_count() == 79, "Album manifest must expose 79 HD card groups.")
	_expect(manifest.album_variant_count() == 214, "Album manifest must expose 214 HD variants.")
	_expect(manifest.music_tracks.size() == 21, "Music manifest must expose 21 tracks.")
	_expect(manifest.memory_entries.size() == 24, "Memories manifest must expose 24 entries.")
	_expect(manifest.album_groups[0].cards[9].unlock_flag == 1033, "EA10 must use CgFlag 1033, not HCG flag 1.")
	_expect(manifest.album_groups[1].cards[8].unlock_flag == 1087, "EB10 must use CgFlag 1087, not HCG flag 1.")
	var album_ids: Dictionary = {}
	var variant_ids: Dictionary = {}
	for group in manifest.album_groups:
		_expect(not album_ids.has(group.group_id), "Album group IDs must be unique: %s" % group.group_id)
		album_ids[group.group_id] = true
		for card in group.cards:
			_expect(not variant_ids.has(card.card_id), "Album card IDs must be unique: %s" % card.card_id)
			variant_ids[card.card_id] = true
			_expect(card.unlock_flag > 0, "Every Album card must carry a real source unlock flag.")
			for variant in card.variants:
				_expect(not variant_ids.has(variant.variant_id), "Album variant IDs must be unique: %s" % variant.variant_id)
				variant_ids[variant.variant_id] = true
				_expect(FileAccess.file_exists(variant.texture_path), "Album variant asset must exist: %s" % variant.texture_path)
	var music_ids: Dictionary = {}
	for track in manifest.music_tracks:
		_expect(not music_ids.has(track.track_id), "Music IDs must be unique: %s" % track.track_id)
		music_ids[track.track_id] = true
		_expect(FileAccess.file_exists(track.stream_path), "Music manifest asset must exist: %s" % track.stream_path)
		if track.track_id != &"BGM01" and track.track_id != &"BGM02_S":
			_expect(track.loop_enabled and track.loop_sample > 0, "BGM03-BGM21 must preserve source .sli loop points: %s" % track.track_id)
	var memory_ids: Dictionary = {}
	for memory in manifest.memory_entries:
		_expect(not memory_ids.has(memory.entry_id), "Memory IDs must be unique: %s" % memory.entry_id)
		memory_ids[memory.entry_id] = true
		_expect(FileAccess.file_exists(memory.thumbnail_path), "Memory thumbnail asset must exist: %s" % memory.thumbnail_path)
		if memory.is_video():
			_expect(memory.video_path.ends_with(".ogv"), "Video manifest must use Godot-decodable OGV: %s" % memory.video_path)
			_expect(FileAccess.file_exists(memory.video_path), "Memory video asset must exist: %s" % memory.video_path)

	for flag_id in range(1001, 1010):
		service.memory_profile.set_global_flag(flag_id)
	var album := FEATURE_SCENE.instantiate() as TitleFeatureScreen
	album.configure(&"album", service)
	var content_requests: Array[TitleContentRequest] = []
	album.content_requested.connect(func(request: TitleContentRequest) -> void: content_requests.append(request))
	root.add_child(album)
	await process_frame
	var album_page := album.get_node("Content/EntryList/AlbumPage") as TitleAlbumPage
	_expect(album_page.scene_file_path.ends_with("title_album_page.tscn"), "Album route must instantiate its dedicated page scene.")
	_expect(album.get_node_or_null("VoiceCollectionService") == null, "Album route must not allocate the voice catalog service.")
	_expect(album_page.group_count() == 6 and album_page.card_count() == 79, "Album page must expose the full source grid model.")
	_expect(album_page.open_card_for_test(0, 0), "Unlocked Album card must open the full-screen viewer.")
	_expect(album_page.get_viewer().variant_count() == 8, "Viewer must filter differences by profile flags.")
	_expect(content_requests.size() == 1 and content_requests[0].catalog_id == TitleCatalog.ALBUM, "Album viewer must emit a typed album request.")
	_expect(content_requests[0].group_id == &"sora", "Album request must preserve source group id.")
	var viewer := album_page.get_viewer()
	var first_variant_id := viewer.current_variant().variant_id
	var right_key := InputEventKey.new()
	right_key.pressed = true
	right_key.keycode = KEY_RIGHT
	viewer._input(right_key)
	_expect(viewer.current_variant().variant_id != first_variant_id, "Album viewer right input must advance one difference.")
	var left_key := InputEventKey.new()
	left_key.pressed = true
	left_key.keycode = KEY_LEFT
	viewer._input(left_key)
	_expect(viewer.current_variant().variant_id == first_variant_id, "Album viewer left input must return to the prior difference.")
	var viewer_right_click := InputEventMouseButton.new()
	viewer_right_click.pressed = true
	viewer_right_click.button_index = MOUSE_BUTTON_RIGHT
	viewer._input(viewer_right_click)
	_expect(not viewer.visible, "Album viewer right-click must close only the viewer.")
	_expect(album_page.get_viewer() != null, "Closing Album viewer must preserve the Album page.")
	album.free()
	await process_frame

	var music := FEATURE_SCENE.instantiate() as TitleFeatureScreen
	music.configure(&"music", service)
	root.add_child(music)
	await process_frame
	var music_page := music.get_node("Content/EntryList/MusicPage") as TitleMusicPage
	_expect(music_page.scene_file_path.ends_with("title_music_page.tscn"), "Music route must instantiate its dedicated page scene.")
	_expect(music.get_node_or_null("VoiceCollectionService") == null, "Music route must not allocate the voice catalog service.")
	_expect(music_page.track_count() == 21, "Music page must expose all source tracks.")
	music_page.select_track(0)
	await process_frame
	_expect(music_page.selected_track().track_id == &"BGM01", "Music page must switch to the selected track.")
	music_page.select_track(1)
	_expect(music_page.selected_track().track_id == &"BGM03", "Music page must switch tracks without a static sample.")
	music_page.stop()
	# Dummy audio releases Ogg playback objects on a mix tick rather than the
	# same frame; drain it before freeing the page so the contract remains
	# leak-sensitive instead of masking a live player.
	await create_timer(0.1, true, false, true).timeout
	music.queue_free()
	await process_frame

	var memories := FEATURE_SCENE.instantiate() as TitleFeatureScreen
	memories.configure(&"memories", service)
	var memory_requests: Array[ScenarioLaunchRequest] = []
	memories.scenario_requested.connect(func(request: ScenarioLaunchRequest) -> void: memory_requests.append(request))
	root.add_child(memories)
	await process_frame
	var memories_page := memories.get_node("Content/EntryList/MemoriesPage") as TitleMemoriesPage
	_expect(memories_page.scene_file_path.ends_with("title_memories_page.tscn"), "Memories route must instantiate its dedicated page scene.")
	_expect(memories.get_node_or_null("VoiceCollectionService") == null, "Memories route must not allocate the voice catalog service.")
	_expect(memories_page.entry_count() == 24 and memories_page.adv_count() == 18 and memories_page.video_count() == 6, "Memories page must separate 18 ADV seams and six videos.")
	memories.free()
	await process_frame

	var voice_feature := FEATURE_SCENE.instantiate() as TitleFeatureScreen
	voice_feature.configure(&"voice", service)
	root.add_child(voice_feature)
	await process_frame
	var voice_page := voice_feature.get_node("Content/EntryList/VoicePage") as TitleVoicePage
	_expect(voice_page.scene_file_path.ends_with("title_voice_page.tscn"), "Voice route must instantiate its dedicated page scene.")
	_expect(voice_feature.get_node_or_null("VoiceCollectionService") is VoiceCollectionService, "Voice service must be named and scoped only to the voice route.")
	_expect_no_generated_node_names(voice_feature, "Voice scene")
	voice_feature.free()
	await process_frame

	var voice_path := "%s/voice_favorites.json" % title_root
	var voice_service := VoiceCollectionService.new()
	voice_service.configure_storage(voice_path)
	root.add_child(voice_service)
	await process_frame
	var voice := VoiceFavorite.create("fixture.voice", "res://assets/audio/system_voice/NO080001.ogg", "测试语音", "fixture")
	_expect(voice_service.add_favorite(voice), "Voice collection must persist a user favorite.")
	_expect(not voice_service.add_favorite(voice), "Voice collection must deduplicate the same favorite.")
	var duplicate_path := VoiceFavorite.create("fixture.voice.other", voice.voice_path, "重复路径")
	_expect(not voice_service.add_favorite(duplicate_path), "Voice collection must deduplicate duplicate voice paths.")
	var second_voice := VoiceFavorite.create("fixture.voice.second", "res://assets/audio/system_voice/AK080001.ogg", "第二条")
	_expect(voice_service.add_favorite(second_voice), "Voice collection must rotate a backup on the second write.")
	_expect(voice_service.count() == 2, "Voice collection must keep two unique favorites after duplicate checks.")
	var corrupt := FileAccess.open(voice_path, FileAccess.WRITE)
	corrupt.store_string("{broken")
	corrupt.close()
	var voice_reload := VoiceCollectionService.new()
	voice_reload.configure_storage(voice_path)
	root.add_child(voice_reload)
	await process_frame
	_expect(voice_reload.count() == 0, "Corrupt voice JSON must be rejected without inventing entries.")
	_expect(FileAccess.get_file_as_string(voice_path) == "{broken", "Corrupt voice JSON must not be overwritten on read.")
	_expect(voice_reload.restore_backup(), "Voice collection must restore its last valid backup without deleting the corrupt file.")
	_expect(voice_reload.count() == 1, "Voice backup restore must recover the prior valid collection.")
	_expect(FileAccess.file_exists("%s.bak" % voice_path), "Voice restore must preserve the replaced corrupt file as a backup.")
	_expect(voice_reload.remove_favorite("fixture.voice"), "Voice favorite deletion must persist.")
	voice_reload.free()
	voice_service.free()
	service.free()
	_clear_contract_directory(title_root)
	await process_frame

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _expect_no_generated_node_names(scene_root: Node, context: String) -> void:
	var pending: Array[Node] = [scene_root]
	while not pending.is_empty():
		var current: Node = pending.pop_back()
		_expect(not String(current.name).begins_with("@"), "%s contains an auto-generated node name: %s" % [context, current.name])
		for child in current.get_children():
			pending.append(child)
