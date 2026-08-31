extends SceneTree


const TITLE_SCENE: PackedScene = preload("res://src/title/title_screen.tscn")
const FEATURE_SCENE: PackedScene = preload("res://src/title/title_feature_screen.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://src/settings/settings_screen.tscn")
const ADV_SCENE: PackedScene = preload("res://src/adv/adv_screen.tscn")
const SAVE_LOAD_PAGE_SCENE: PackedScene = preload("res://src/save_load/save_load_page.tscn")

var _failures: Array[String] = []


class MemorySaveService extends SaveService:
	var memory_autosave: SaveData
	var memory_profile: ProfileData = ProfileData.create_empty("0.1.0")
	var memory_flags: Dictionary = {}

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


class MemorySettingsRepository extends SettingsRepository:
	var settings_write_count := 0
	var settings_disk_read_count := 0
	var fail_settings_write := false

	func write_settings(settings: Dictionary) -> bool:
		settings_write_count += 1
		if fail_settings_write:
			last_error = "forced settings write failure"
			return false
		return super.write_settings(settings)

	func _read_dictionary(path: String) -> Dictionary:
		settings_disk_read_count += 1
		return super._read_dictionary(path)


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
	_expect(bool(ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch", true)), "Touch-to-mouse emulation must use Godot's enabled default or an explicit true value.")

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
	data.choice_history = [2, 1]
	data.choice_navigation_stack = [{
		"runtime": {"scenario_id": "00_z000", "instruction_index": 42},
		"presentation": {"background": "B27A"},
	}]
	data.choice_navigation_position = 1
	data.read_text_ids = ["00_z000:42"]
	data.autosave_meta = {"valid": true, "label": "列车"}
	var decoded := SaveData.from_dictionary(data.to_dictionary())
	_expect(decoded != null, "Current save data must round-trip.")
	if decoded != null:
		_expect(decoded.schema_version == SaveData.CURRENT_SCHEMA_VERSION, "Round-trip schema must be current.")
		_expect(decoded.is_global_flag_set(1), "Global route flag must survive round-trip.")
		_expect(decoded.instruction_anchor == "hitret:42", "Instruction anchor must survive round-trip.")
		_expect(decoded.choice_history == [2, 1], "Source selection history must survive round-trip.")
		_expect(
			decoded.choice_navigation_stack.size() == 1
			and decoded.choice_navigation_position == 1,
			"Previous-choice navigation stack and cursor must survive save round-trip."
		)

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
		_expect(
			legacy.choice_navigation_stack.is_empty()
			and legacy.choice_navigation_position == 0,
			"Legacy saves must migrate with an empty previous-choice stack."
		)
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
	var choice_font_path := "res://assets/themes/fonts/settings_choice_font.tres"
	var section_title_font_path := "res://assets/themes/fonts/settings_section_title_font.tres"
	var attribution_path := "res://assets/fonts/Xiaolai-Regular-OFL-1.1.txt"
	_expect(FileAccess.file_exists(theme_path), "Project CJK theme must exist.")
	_expect(FileAccess.file_exists(font_path), "Standalone Xiaolai FontFile asset must exist.")
	_expect(FileAccess.file_exists(choice_font_path), "Settings choice FontVariation must exist.")
	_expect(FileAccess.file_exists(section_title_font_path), "Settings section-title FontVariation must exist.")
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
	var choice_font := load(choice_font_path) as FontVariation
	var section_title_font := load(section_title_font_path) as FontVariation
	_expect(choice_font != null and section_title_font != null, "Settings FontVariation resources must load independently.")
	_expect(theme.get_type_variation_base(&"SettingsChoiceButton") == &"Button", "Choice styles must be exposed as a Button Theme variation.")
	_expect(theme.get_type_variation_base(&"SettingsFooterButton") == &"SharedActionButton", "Settings footer styles must derive from the neutral action-button Theme variation.")
	_expect(theme.get_type_variation_base(&"SettingsKnobSlider") == &"HSlider", "Slider styles must extend Godot's native HSlider Theme type.")
	_expect(theme.get_type_variation_base(&"SettingsSectionTitle") == &"Control", "Section-title drawing tokens must be exposed as a Control Theme variation.")
	_expect(theme.get_type_variation_base(&"ConfirmationOverlayPanel") == &"SharedGlassPanel", "Shared confirmation chrome must use a neutral Theme variation.")
	_expect(theme.get_type_variation_base(&"SaveLoadSlotButton") == &"Button", "Save/Load slot visuals must be exposed as a Button Theme variation.")
	var glyphs: Array[String] = ["环", "境", "设", "定", "删", "除", "存", "档"]
	for glyph in glyphs:
		var codepoint := glyph.unicode_at(0)
		_expect(font.has_char(codepoint), "Xiaolai default font must contain glyph U+%04X." % codepoint)


func _test_title_state() -> void:
	var service := MemorySaveService.new()
	var settings_repository := MemorySettingsRepository.new()
	var title_root := "/tmp/yosuga-godot-title-contract-%d" % OS.get_process_id()
	_clear_contract_directory(title_root)
	service.configure_storage(title_root)
	settings_repository.configure_storage("%s/settings.json" % title_root)
	var autosave := SaveData.create_empty("0.1.0")
	autosave.scenario_id = "00_z000"
	autosave.autosave_meta = {"valid": true, "label": "测试自动存档"}
	service.memory_autosave = autosave
	service.memory_flags[1] = true
	service.memory_profile.set_global_flag(1)
	var title := TITLE_SCENE.instantiate() as TitleScreen
	_expect(is_equal_approx(title.game_exit_seconds, 3.0), "New Game must retain the source Title's three-second route departure.")
	_expect(title.subscreen_exit_seconds < title.subscreen_return_seconds, "Title child-screen departure must be faster than its return animation.")
	title.subscreen_exit_seconds = 0.01
	title.subscreen_return_seconds = 0.01
	title.configure(service)
	root.add_child(title)
	await process_frame
	_expect((title.get_node("WhiteCover") as ColorRect).visible, "Title route entry must reveal the scene through its source white cover.")
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
	var declared_main_row := title.get_node("DesignRoot/BottomChrome/MenuLayer/MainMenuCenter/MainMenuRow") as HBoxContainer
	_expect(declared_main_row.get_child_count() == 6, "Title main-menu buttons must be declared by title_screen.tscn.")
	for declared_button in declared_main_row.get_children():
		_expect(declared_button is TitleMenuButton and declared_button.scene_file_path.ends_with("title_menu_button.tscn"), "Every Title action must be a scene-owned TitleMenuButton instance.")
	var declared_characters := title.get_node("DesignRoot/CharacterLayer") as Control
	_expect(declared_characters.get_child_count() == 5, "Title character variants must be declared by title_screen.tscn.")
	var blur_warmup := title.get_node_or_null("BlurWarmup") as Control
	_expect(blur_warmup != null and blur_warmup.get_node_or_null("BackBufferCopy") is BackBufferCopy, "Title must prewarm the live background-blur pipeline before settings is opened.")
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
	_expect(title.get_node_or_null("ScenarioUnavailableNotice") == null, "Continue must route directly to ADV without an obsolete unavailable notice.")
	_expect(scenario_requests[0].scenario_id == "00_z000", "Continue request must preserve save scenario.")
	_expect(scenario_requests[0].save_path == service.autosave_path(), "Continue must use the configured SaveService autosave path.")
	_expect(scenario_requests[0].save_data == autosave, "Continue request must carry the decoded SaveData for route-independent restore.")
	for button in title.get_menu_buttons():
		if button.option_id == &"bonus":
			button.pressed.emit()
			break
	await process_frame
	_expect(title.is_bonus_mode(), "Bonus must enter the four-item submenu.")
	_expect(title.get_bonus_buttons().size() == 4, "Bonus must expose Album/Music/Memories/Voice.")
	var bonus_back := title.get_node("DesignRoot/BottomChrome/MenuLayer/BonusBackButton") as Button
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
	var exit_button: TitleMenuButton
	for button in title.get_menu_buttons():
		if button.option_id == &"exit_game":
			exit_button = button
			break
	exit_button.grab_focus()
	exit_button.pressed.emit()
	await process_frame
	_expect(title.is_exit_confirmation_visible(), "Exit must open its confirmation scene.")
	var exit_dialog := title.get_node_or_null("ExitConfirmationOverlay") as ConfirmationOverlay
	_expect(exit_dialog != null and exit_dialog.scene_file_path.ends_with("confirmation_overlay.tscn"), "Exit confirmation must use the shared scene-owned overlay.")
	var exit_escape := InputEventKey.new()
	exit_escape.pressed = true
	exit_escape.keycode = KEY_ESCAPE
	title._input(exit_escape)
	_expect(not title.is_exit_confirmation_visible(), "Escape must dismiss the exit confirmation scene.")
	await process_frame
	_expect(root.gui_get_focus_owner() == exit_button, "Closing the shared confirmation overlay must restore Title focus.")
	for button in title.get_menu_buttons():
		if button.option_id == &"load_game":
			button.pressed.emit()
			break
	await process_frame
	_expect(requested.has(&"load_game"), "Load must emit a dedicated feature route.")
	await title.play_subscreen_exit()
	var title_bottom_chrome := title.get_node("DesignRoot/BottomChrome") as Control
	var title_logo := title.get_node("DesignRoot/Logo") as TextureRect
	_expect(title.is_subscreen_departed() and title_bottom_chrome.position.y > 0.0, "Title child-screen API must slide the complete bottom chrome below the viewport.")
	_expect(is_zero_approx(title_logo.modulate.a), "Title child-screen API must fade out the logo.")
	await title.play_subscreen_return()
	_expect(not title.is_subscreen_departed() and is_zero_approx(title_bottom_chrome.position.y), "Title child-screen return API must restore the same bottom chrome instance.")
	_expect(is_equal_approx(title_logo.modulate.a, 1.0), "Title child-screen return API must restore the logo.")
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
	_expect(feature.get_node_or_null("ScenarioUnavailableNotice") == null, "Load route must not construct the retired unavailable-runner notice.")
	_expect(feature.get_node_or_null("VoiceCollectionService") == null, "Load route must not own the voice catalog service.")
	var load_list := feature.get_node("Content/EntryList") as VBoxContainer
	_expect(load_list.get_child_count() == 1, "Load route must own one reusable save/load page scene.")
	var load_page := feature.load_page()
	_expect(load_page != null and load_page.scene_file_path.ends_with("save_load_page.tscn"), "Load content must be a dedicated static TSCN page.")
	_expect(load_page.slot_cards().size() == 12, "Load page must keep one static 4×3 slot-card page in the scene tree.")
	_expect(load_page.size.is_equal_approx(load_list.size), "Embedded save/load content must expand to the complete feature-page viewport.")
	var load_select := load_page.slot_cards()[0]
	load_select.pressed.emit()
	await process_frame
	var page_primary := load_page.get_node("VisualCanvas/Footer/Primary") as Button
	_expect(not page_primary.disabled, "Selecting a valid save must enable the page-owned continue action.")
	var manual_select := load_page.slot_cards()[1]
	manual_select.pressed.emit()
	var page_delete := load_page.get_node("VisualCanvas/Footer/Delete") as Button
	page_delete.pressed.emit()
	await process_frame
	_expect(feature.is_delete_confirmation_visible(), "Deleting a manual slot must ask for confirmation.")
	_expect(load_page.get_node("VisualCanvas/ConfirmationOverlay").scene_file_path.ends_with("confirmation_overlay.tscn"), "Save deletion must reuse the shared scene-owned confirmation component.")
	_expect(service.has_slot(0), "Cancel is not allowed to delete a manual slot.")
	feature.cancel_delete_confirmation()
	_expect(service.has_slot(0), "Canceled manual-slot deletion must preserve the file.")
	page_delete.pressed.emit()
	await process_frame
	feature.confirm_delete_confirmation()
	await process_frame
	_expect(not service.has_slot(0), "Confirmed manual-slot deletion must refresh and remove the file.")
	_expect_no_generated_node_names(feature, "Load scene after list refresh")
	load_select.pressed.emit()
	page_delete.pressed.emit()
	await process_frame
	_expect(feature.is_delete_confirmation_visible(), "Deleting autosave must ask for confirmation.")
	feature.cancel_delete_confirmation()
	_expect(service.has_autosave(), "Canceled autosave deletion must preserve the autosave.")
	page_delete.pressed.emit()
	await process_frame
	feature.confirm_delete_confirmation()
	await process_frame
	_expect(not service.has_autosave(), "Confirmed autosave deletion must remove the autosave.")
	var next_save_page := load_page.get_node("VisualCanvas/Main/PageNavigation/NextPage") as Button
	next_save_page.pressed.emit()
	await process_frame
	_expect(load_page.slot_cards()[0].slot_id == 11, "Second save page must start at manual slot 12.")
	_expect(load_page.slot_cards()[8].slot_id == 19, "Second save page must expose manual slot 20.")
	_expect(load_page.slot_cards()[9].disabled, "Unused cells on the final save page must stay disabled.")
	load_select = null
	var feature_back := load_page.get_node("VisualCanvas/Footer/Back") as Button
	feature_back.pressed.emit()
	_expect(back_events.size() == 1, "Feature Back button must emit its typed route signal.")
	feature.free()
	await process_frame

	var save_payload := SaveData.create_empty("0.1.0")
	save_payload.scenario_id = "00_z002"
	save_payload.instruction_anchor = "hitret:save-mode"
	save_payload.autosave_meta = {"label": "存档模式契约"}
	var save_page := SAVE_LOAD_PAGE_SCENE.instantiate() as SaveLoadPage
	save_page.configure(SaveLoadPage.Mode.SAVE, service, save_payload)
	root.add_child(save_page)
	await process_frame
	_expect(save_page.slot_cards()[0].disabled, "Save mode must reserve the autosave entry for the runtime autosave flow.")
	_expect(root.gui_get_focus_owner() == save_page.slot_cards()[1], "Save mode must focus the first enabled manual slot instead of disabled autosave.")
	_expect((save_page.get_node("VisualCanvas/Footer/Back") as Button).text == "返回游戏", "An in-game save/load page must expose the correct return destination.")
	var save_target := save_page.slot_cards()[1]
	save_target.pressed.emit()
	var save_primary := save_page.get_node("VisualCanvas/Footer/Primary") as Button
	_expect(not save_primary.disabled, "Selecting an empty manual slot must enable the save action.")
	save_primary.pressed.emit()
	await process_frame
	_expect(service.has_slot(0), "The reusable page's save mode must write the selected manual slot.")
	save_target.grab_focus()
	save_primary.pressed.emit()
	await process_frame
	_expect(save_page.is_delete_confirmation_visible(), "Overwriting an occupied slot must ask for confirmation.")
	save_page.cancel_delete_confirmation()
	await process_frame
	_expect(root.gui_get_focus_owner() == save_target, "Closing a save confirmation must restore keyboard/controller focus to its invoking slot.")
	var load_mode_button := save_page.get_node("VisualCanvas/ModeTabs/LoadMode") as Button
	_expect(not load_mode_button.disabled, "An in-game save page must allow switching to read mode.")
	load_mode_button.pressed.emit()
	await process_frame
	_expect(save_page.mode == SaveLoadPage.Mode.LOAD, "The reusable save page must switch to read mode without rebuilding its scene tree.")
	var save_mode_button := save_page.get_node("VisualCanvas/ModeTabs/SaveMode") as Button
	_expect(not save_mode_button.disabled, "Read mode must allow returning to save mode while a live SaveData payload exists.")
	save_mode_button.pressed.emit()
	await process_frame
	_expect(save_page.mode == SaveLoadPage.Mode.SAVE, "The reusable page must return to save mode with the same payload.")
	_expect(service.clear_slot(0), "Save-mode contract cleanup must remove its manual slot.")
	save_page.free()
	await process_frame

	var settings := SETTINGS_SCENE.instantiate() as SettingsScreen
	settings.open_transition_seconds = 0.01
	settings.close_transition_seconds = 0.01
	settings.configure(settings_repository)
	root.add_child(settings)
	await process_frame
	var settings_page := settings.settings_page()
	var preview := ADV_SCENE.instantiate() as AdvScreen
	preview.name = "AdvPreview"
	preview.configure_preview(settings_page.get_current_settings())
	settings_page.display_page().install_preview(preview, preview.apply_preview_settings)
	_expect(settings_page != null, "Settings must expose a dedicated HD window model.")
	_expect(settings.get_node_or_null("Content") == null, "Settings route must not retain hidden generic feature chrome.")
	_expect(settings.scene_file_path.ends_with("settings_screen.tscn"), "Settings must be owned by a dedicated route scene.")
	var settings_background_copy := settings.get_node_or_null("BackBufferCopy") as BackBufferCopy
	_expect(settings_background_copy != null and settings_background_copy.copy_mode == BackBufferCopy.COPY_MODE_VIEWPORT, "Settings must copy the live route rendered behind it every frame.")
	var settings_background_blur := settings.get_node_or_null("BackgroundBlur") as ColorRect
	_expect(settings_background_blur != null and settings_background_blur.material is ShaderMaterial, "Settings must render its live route backdrop through a screen-reading blur shader.")
	_expect(settings_page.scene_file_path.ends_with("settings_page.tscn"), "Settings editor must be a reusable scene instance.")
	_expect(settings_page.display_page().visible and not settings_page.system_page().visible and not settings_page.audio_page().visible, "Settings must reveal only the selected page after its runtime tab initialization.")
	_expect(settings_page.find_setting_slider("master_volume") != null, "Settings must expose master volume.")
	_expect(settings_page.find_setting_slider("voice_volume") != null, "Settings must expose voice volume.")
	_expect(settings_page.find_setting_slider("movie_volume") != null, "Settings must expose movie volume.")
	_expect(settings_page.find_setting_slider("voice_detail") != null, "Settings must expose the per-character voice slider.")
	_expect(settings_page.find_setting_slider("window_depth") != null, "Settings must expose the textbox depth slider.")
	_expect(settings_page.display_page().get_node_or_null("PageBackground") == null, "Screen settings chrome must not regress to a baked 1920x1080 UI background.")
	_expect(settings_page.system_page().get_node_or_null("PageBackground") == null, "System settings chrome must be rendered by live scene controls, not a baked page background.")
	_expect(settings_page.audio_page().get_node_or_null("PageBackground") == null, "Audio settings chrome must be rendered by live scene controls, not a baked page background.")
	var window_depth_slider := settings_page.find_setting_slider("window_depth")
	_expect(window_depth_slider is HSlider and window_depth_slider.scene_file_path.ends_with("settings_knob_slider.tscn"), "Screen settings slider must instantiate the reusable native HSlider scene.")
	var display_page := settings_page.display_page()
	_expect(display_page.scene_file_path.ends_with("display_settings_page.tscn"), "Screen settings layout must be scene-owned instead of rebuilt by its controller.")
	var fullscreen_choice := display_page.get_node_or_null("%FullscreenChoice") as SettingsChoiceButton
	_expect(fullscreen_choice != null, "Screen choices must be declared by the scene and exposed with unique names.")
	_expect(fullscreen_choice != null and fullscreen_choice.theme_type_variation == &"SettingsChoiceButtonLarge", "Choice sizes must select a semantic Theme variation instead of applying script-side font overrides.")
	_expect(display_page.get_node_or_null("%window_depth") is SettingsKnobSlider, "Screen depth slider must be declared by the scene.")
	var main_columns := display_page.find_child("MainColumns", true, false) as HBoxContainer
	_expect(main_columns != null, "Screen settings must organize its cards with a two-column container layout.")
	var system_columns := settings_page.system_page().find_child("MainColumns", true, false) as HBoxContainer
	var audio_columns := settings_page.audio_page().find_child("MainColumns", true, false) as HBoxContainer
	var display_columns_rect := Rect2(main_columns.position, main_columns.size)
	settings_page.show_tab(SettingsChrome.Tab.SYSTEM)
	await process_frame
	await process_frame
	var system_columns_rect := Rect2(system_columns.position, system_columns.size)
	settings_page.show_tab(SettingsChrome.Tab.AUDIO)
	await process_frame
	await process_frame
	var audio_columns_rect := Rect2(audio_columns.position, audio_columns.size)
	settings_page.show_tab(SettingsChrome.Tab.DISPLAY)
	await process_frame
	await process_frame
	display_columns_rect = Rect2(main_columns.position, main_columns.size)
	_expect(system_columns != null and system_columns_rect.is_equal_approx(display_columns_rect), "Switching from screen to system settings must not move the inner-frame boundary.")
	_expect(audio_columns != null and audio_columns_rect.is_equal_approx(display_columns_rect), "Switching from screen to audio settings must not move the inner-frame boundary.")
	var display_rect := Rect2(Vector2.ZERO, display_page.size)
	var columns_rect := display_columns_rect
	var frame_insets := Vector4(
		columns_rect.position.x - display_rect.position.x,
		columns_rect.position.y - display_rect.position.y,
		display_rect.position.x + display_rect.size.x - columns_rect.position.x - columns_rect.size.x,
		display_rect.position.y + display_rect.size.y - columns_rect.position.y - columns_rect.size.y
	)
	_expect(frame_insets.is_equal_approx(Vector4.ZERO), "Settings MainColumns must fill the content-area page supplied by the outer PanelContainer.")
	var left_column := main_columns.find_child("LeftColumn", true, false) as VBoxContainer
	_expect(left_column != null, "Screen settings must expose a container-managed left column.")
	_expect(left_column.get_theme_constant(&"separation") == 10, "Screen settings left-column cards must use one uniform container separation.")
	_expect(left_column.find_child("Gap01", false, false) == null and left_column.find_child("Gap03", false, false) == null and left_column.find_child("Gap05", false, false) == null, "Screen settings must not emulate container spacing with inconsistent spacer nodes.")
	var right_column := main_columns.find_child("RightColumn", true, false) as VBoxContainer
	_expect(right_column != null, "Screen settings must expose a container-managed right column.")
	var textbox_card := left_column.find_child("TextboxOpacityCard", false, false) as Control
	var font_card := left_column.find_child("FontSelectionCard", false, false) as Control
	var upper_row := right_column.find_child("UpperRow", false, false) as Control
	var lower_row := right_column.find_child("LowerRow", false, false) as Control
	var left_divider_center := (textbox_card.get_global_rect().end.y + font_card.get_global_rect().position.y) * 0.5
	var right_divider_center := (upper_row.get_global_rect().end.y + lower_row.get_global_rect().position.y) * 0.5
	_expect(is_equal_approx(left_divider_center, right_divider_center), "Screen settings left and right horizontal dividers must remain aligned.")
	_expect(display_page.find_child("PreviewArtwork", true, false) != null, "Screen settings must retain the scenic preview as artwork.")
	var font_selection_title := display_page.find_child("FontSelectionTitle", true, false) as SettingsSectionTitle
	_expect(font_selection_title != null and font_selection_title.caption == "字体选择", "Screen headings must be rendered from live text.")
	_expect(font_selection_title.scene_file_path.ends_with("settings_section_title.tscn"), "Section headings must be reusable scene instances that preview in the editor.")
	_expect(font_selection_title.get_child_count() == 3, "A section heading must own its static gradient strip and two text layers.")
	_expect(font_selection_title.get_node_or_null("GradientStrip") is TextureRect, "Section heading gradient must be a scene-owned node.")
	_expect(font_selection_title.get_node_or_null("OuterKeyline") is Label and font_selection_title.get_node_or_null("Foreground") is Label, "Section heading stroke layers must remain explicit scene-owned labels.")
	var preview_artwork := display_page.find_child("PreviewArtwork", true, false) as TextureRect
	var preview_card := display_page.find_child("PreviewCard", true, false) as PanelContainer
	var preview_background := preview_card.get_node("Background") as Panel
	var preview_padding := preview_card.get_node("Padding") as MarginContainer
	var preview_content := preview_padding.get_node("BusinessContent") as Control
	var preview_mask_style := preview_card.get_theme_stylebox(&"panel") as StyleBoxFlat
	var preview_background_style := preview_background.get_theme_stylebox(&"panel") as StyleBoxFlat
	_expect(preview_card != null and preview_card.scene_file_path.is_empty(), "The preview frame must be authored directly in the display page scene.")
	_expect(preview_card.clip_children == CanvasItem.CLIP_CHILDREN_ONLY, "Only the preview frame must retain rounded descendant clipping.")
	_expect(preview_mask_style != null and is_equal_approx(preview_mask_style.bg_color.a, 1.0), "The inline preview mask must stay opaque so child colors retain their original intensity.")
	_expect(preview_background_style != null and is_equal_approx(preview_background_style.bg_color.a, 0.7), "The inline preview background must retain the shared 70% alpha appearance.")
	_expect(is_equal_approx(preview_content.modulate.a, 1.0), "Preview content must retain full opacity.")
	_expect(preview_padding.get_theme_constant(&"margin_left") == 16 and preview_padding.get_theme_constant(&"margin_top") == 16, "The inline preview frame must retain its 16 px padding.")
	_expect(not preview_content.clip_contents, "Preview content must leave clipping to the rounded outer mask.")
	_expect(preview_artwork.texture is ViewportTexture, "The preview must render the real ADV scene, not a second hand-assembled dialogue frame.")
	_expect(preview.scene_file_path.ends_with("adv_screen.tscn"), "Settings preview must reuse the exact gameplay scene.")
	var preview_viewport := preview.get_viewport() as SubViewport
	_expect(preview_viewport != null and preview_viewport.gui_disable_input, "The preview viewport must reject GUI input.")
	_expect(preview.process_mode == Node.PROCESS_MODE_DISABLED and not preview.is_processing_unhandled_input(), "The preview must never process gameplay or input.")
	_expect(preview.get_node_or_null("SaveService") == null, "Rendering a preview must not construct a persistence service.")
	_expect(preview.runtime().build_navigation_checkpoint().is_empty(), "Rendering a preview must not start the scenario runtime.")
	for player in preview.find_children("*", "AudioStreamPlayer", true, false):
		_expect(not player.playing and player.stream == null, "Preview must not load or play any audio.")
	for control in preview.find_children("*", "Control", true, false):
		_expect(control.mouse_filter == Control.MOUSE_FILTER_IGNORE and control.focus_mode == Control.FOCUS_NONE, "All preview controls must reject pointer and keyboard focus: %s" % control.name)
	_expect(preview_artwork.material is ShaderMaterial, "Preview artwork must use a resolution-independent rounded mask.")
	var preview_texture_size := preview_artwork.texture.get_size()
	var preview_source_aspect := preview_texture_size.x / preview_texture_size.y
	_expect(absf(preview_source_aspect - 16.0 / 9.0) < 0.01, "Preview artwork must retain the full source 16:9 composition.")
	var preview_textbox := preview.get_node("%MessagePanel") as PanelContainer
	var preview_avatar := preview.get_node("%Portrait") as TextureRect
	var preview_message := preview.get_node("%MessageLabel") as RichTextLabel
	_expect(preview_textbox.theme_type_variation == &"AdvMessagePanel", "Preview must use the real ADV message Theme.")
	_expect(preview_avatar.texture != null and preview_avatar.visible, "Preview must use the real ADV dialogue portrait.")
	var preview_message_before := preview.current_message()
	var preview_focus_before := root.gui_get_focus_owner()
	var preview_click := InputEventMouseButton.new()
	preview_click.button_index = MOUSE_BUTTON_LEFT
	preview_click.pressed = true
	preview_click.position = Vector2(1760.0, 950.0)
	preview_viewport.push_input(preview_click)
	var preview_key := InputEventAction.new()
	preview_key.action = &"vn_advance"
	preview_key.pressed = true
	preview_viewport.push_input(preview_key)
	preview._unhandled_input(preview_key)
	(preview.get_node("%QuickSaveButton") as BaseButton).pressed.emit()
	(preview.get_node("%SettingsButton") as BaseButton).pressed.emit()
	(preview.get_node("%MessageHideButton") as BaseButton).pressed.emit()
	await process_frame
	_expect(preview.current_message() == preview_message_before and preview_textbox.visible, "Preview clicks and advance input must not advance or hide dialogue.")
	_expect(root.gui_get_focus_owner() == preview_focus_before, "Preview input must not steal focus from Settings.")
	_expect(not (preview.get_node("%FeatureOverlay") as Control).visible, "Preview menu clicks must not open any gameplay overlay.")
	var preview_style := preview_textbox.get_theme_stylebox("panel") as StyleBoxTexture
	var shared_style := load("res://assets/themes/adv/message_panel.tres") as StyleBoxTexture
	window_depth_slider.value = 25.0
	_expect(is_equal_approx(preview_style.modulate_color.a, 0.25), "Opacity slider must update the real ADV frame immediately.")
	_expect(is_equal_approx(preview_message.modulate.a, 1.0) and is_equal_approx(preview_avatar.modulate.a, 1.0), "Frame opacity must not fade the text or portrait.")
	_expect(is_equal_approx(shared_style.modulate_color.a, 1.0), "Preview changes must not mutate the shared Theme StyleBox.")
	display_page.set_screen_toggle(&"read_color", false)
	_expect(preview_message.get_theme_color("default_color").is_equal_approx(Color(0.98, 0.995, 1.0, 1.0)), "Read-color setting must refresh the real ADV text immediately.")
	display_page.set_screen_toggle(&"read_color", true)
	window_depth_slider.value = 50.0
	var preview_saved_state := {
		"background": "EA01E", "speaker": "穹", "message": "只读快照测试",
		"bgm": {"file": "BGM05", "position": 2.0},
		"environment_audio": {"file": "se270", "position": 1.0},
		"camera_world_position": [0.0, 30.0, -128.0],
		"camera_move": {"start_world_position": [0.0, 0.0, -128.0], "target_world_position": [0.0, 90.0, -128.0], "duration_milliseconds": 1000},
		"preview_choices": [{"text": "不可操作的选项", "hint": "穹"}],
		"preview_route_hints": true,
	}
	preview.refresh_preview(settings_page.get_current_settings(), preview_saved_state)
	var preview_choice_list := preview.get_node("%ChoiceList") as VBoxContainer
	_expect(preview_choice_list.get_child_count() == 1, "Preview must retain visible choices using the real choice component.")
	var preview_choice := preview_choice_list.get_child(0) as AdvChoiceButton
	_expect(preview_choice.mouse_filter == Control.MOUSE_FILTER_IGNORE and preview_choice.focus_mode == Control.FOCUS_NONE, "Dynamically restored preview choices must also reject input.")
	preview_choice.pressed.emit()
	await create_timer(0.1).timeout
	_expect(preview.current_message() == "只读快照测试" and (preview.get_node("%ChoiceOverlay") as Control).visible, "Even a directly emitted preview choice signal must not select a branch.")
	for player in preview.find_children("*", "AudioStreamPlayer", true, false):
		_expect(not player.playing and player.stream == null, "Saved BGM/environment state must be ignored, not played or muted by preview.")
	var frozen_camera := preview.get_node("%StageDirector") as AdvStageDirector
	_expect(frozen_camera.presentation_state().get("camera_world_position") == [0.0, 30.0, -128.0], "Preview must preserve the captured camera position without restarting its move.")
	_expect(preview.runtime().build_navigation_checkpoint().is_empty(), "Preview choices must not create gameplay history or progress.")
	preview.refresh_preview(settings_page.get_current_settings(), {})
	var system_page := settings_page.system_page()
	_expect(system_page.scene_file_path.ends_with("system_settings_page.tscn"), "System settings layout must be owned by its page scene.")
	_expect(system_page.find_child("MainColumns", true, false) is HBoxContainer, "System settings must use the same container-managed card layout as screen settings.")
	var behavior_card := system_page.find_child("BehaviorCard", true, false) as PanelContainer
	_expect(behavior_card != null and behavior_card.clip_contents, "System behavior settings must use an inline square-clipped PanelContainer.")
	_expect(behavior_card != null and behavior_card.get_node_or_null("BusinessContent") != null, "System card content must be owned directly by the page scene.")
	_expect(system_page.find_child("BehaviorTitle", true, false) is SettingsSectionTitle, "System headings must reuse the live-text section title.")
	_expect(system_page.get_node_or_null("%ReadSkipYesChoice") is SettingsChoiceButton, "System YES/NO options must be scene-owned live-text choices.")
	var load_confirmation := system_page.get_node_or_null("%LoadConfirmation") as SettingsCheckChoiceButton
	_expect(load_confirmation != null, "System confirmations must use the reusable code-drawn checkbox component.")
	_expect(load_confirmation != null and load_confirmation.scene_file_path.ends_with("settings_check_choice_button.tscn"), "System confirmation checkboxes must be reusable scene instances.")
	_expect(load_confirmation != null and load_confirmation.toggle_mode, "System confirmation checkboxes must retain native toggle-button semantics.")
	_expect(load_confirmation != null and load_confirmation.find_child("StateGlow", false, false) == null, "Confirmation checkboxes must not render the screen-choice glow band.")
	var confirmation_grid := system_page.find_child("ConfirmationGrid", true, false) as GridContainer
	_expect(confirmation_grid != null and confirmation_grid.columns == 3, "System confirmations must retain the compact three-column layout.")
	_expect(confirmation_grid != null and confirmation_grid.get_child_count() == SettingsModel.CONFIRMATION_KEYS.size(), "The confirmation grid must expose all source options.")
	var audio_page := settings_page.audio_page()
	_expect(audio_page.scene_file_path.ends_with("audio_settings_page.tscn"), "Audio settings layout must be owned by its page scene.")
	_expect(audio_page.find_child("MainColumns", true, false) is HBoxContainer, "Audio settings must use the same container-managed card layout as screen settings.")
	var character_volume_card := audio_page.find_child("CharacterVolumeCard", true, false) as PanelContainer
	_expect(character_volume_card != null and character_volume_card.clip_contents, "Character volume settings must use an inline square-clipped PanelContainer.")
	_expect(character_volume_card != null and character_volume_card.get_node_or_null("BusinessContent") != null, "Audio card content must be owned directly by the page scene.")
	_expect(audio_page.find_child("CharacterVolumeTitle", true, false) is SettingsSectionTitle, "Audio headings must reuse the live-text section title.")
	var sora_voice := audio_page.get_node_or_null("%SoraVoice") as SettingsVoiceChoiceButton
	_expect(sora_voice != null, "Voice choices must use the reusable code-drawn audio option component.")
	_expect(sora_voice != null and sora_voice.scene_file_path.ends_with("settings_voice_choice_button.tscn"), "Voice choices must be reusable scene instances instead of sliced name textures.")
	_expect(sora_voice != null and sora_voice.find_child("StateGlow", false, false) == null, "Audio voice choices must draw their own rounded keylines without the screen-choice glow band.")
	_expect(audio_page.get_node_or_null("%VoicePortrait") is TextureRect, "Character portraits must remain scene-owned content artwork.")
	var footer_labels := {
		"ResetSettings": "初始化设置",
		"ResetRead": "初始化已读文本",
		"OpenKeyPopup": "快捷键",
		"CloseSettings": "回到标题",
	}
	var chrome := settings_page.get_node("VisualCanvas/Chrome") as SettingsChrome
	_expect(chrome != null and chrome.scene_file_path.ends_with("settings_chrome.tscn"), "Settings navigation and overlays must be owned by a static chrome scene.")
	for button_name in footer_labels:
		var footer_button := chrome.get_node(button_name) as SettingsTextButton
		_expect(footer_button != null and footer_button.text == footer_labels[button_name], "Settings footer action %s must be code-rendered text." % button_name)
		_expect(footer_button != null and str(footer_button.theme_type_variation).begins_with("SettingsFooter"), "Settings footer action %s must use a semantic Theme variation." % button_name)
		if button_name != "CloseSettings":
			_expect(footer_button.get_theme_stylebox(&"normal") is StyleBoxEmpty and footer_button.get_theme_stylebox(&"hover") is StyleBoxEmpty and footer_button.get_theme_stylebox(&"pressed") is StyleBoxEmpty and footer_button.get_theme_stylebox(&"focus") is StyleBoxEmpty, "Text-only footer action %s must stay frameless in every interactive state." % button_name)
	var close_settings := chrome.get_node("CloseSettings") as SettingsTextButton
	_expect(close_settings.theme_type_variation == &"SettingsFooterPrimaryButton", "Scene-specific Theme variations must survive script initialization and editor property reordering.")
	var tabs_row := chrome.get_node("TabsRow") as HBoxContainer
	var display_tab := chrome.get_node("%DisplayTab") as SettingsTabButton
	var system_tab := chrome.get_node("%SystemTab") as SettingsTabButton
	var audio_tab := chrome.get_node("%AudioTab") as SettingsTabButton
	_expect(tabs_row.get_child_count() == 3 and tabs_row.get_theme_constant(&"separation") == 0, "Settings tabs must occupy three equal, gapless layout slots.")
	var display_slot_width := (display_tab.get_parent() as Control).size.x
	var system_slot_width := (system_tab.get_parent() as Control).size.x
	var audio_slot_width := (audio_tab.get_parent() as Control).size.x
	_expect(absf(display_slot_width - system_slot_width) <= 1.0 and absf(system_slot_width - audio_slot_width) <= 1.0, "Settings tab slots must remain equal width apart from unavoidable whole-pixel distribution.")
	_expect(display_tab.tab_label == "画面" and system_tab.tab_label == "系统" and audio_tab.tab_label == "音频", "Settings tabs must serialize localizable live text instead of texture artwork.")
	_expect(display_tab.text == "• 画面 •" and system_tab.text == "系统" and audio_tab.text == "音频", "The selected settings tab decoration must be generated from live text.")
	_expect(display_tab.theme_type_variation == &"SettingsTabButton", "Settings tabs must obtain typography and interaction states from a semantic Theme variation.")
	_expect(display_tab.button_group == system_tab.button_group and system_tab.button_group == audio_tab.button_group, "Settings tabs must use one native exclusive ButtonGroup.")
	var key_popup := chrome.get_node("KeyPopup") as SettingsKeyPopup
	_expect(key_popup != null and key_popup.shortcut_count() == 11, "Shortcut popup must expose the eleven source keyboard actions as live text.")
	_expect(key_popup is SettingsModal, "Settings overlays must share the reusable modal motion implementation.")
	_expect(key_popup.get_node_or_null("BackBufferCopy") is BackBufferCopy, "Shortcut popup must capture the page behind it before applying blur.")
	var popup_blur := key_popup.get_node_or_null("BlurLayer") as ColorRect
	_expect(popup_blur != null and popup_blur.material is ShaderMaterial, "Shortcut popup must render its blurred backdrop with a screen-reading ShaderMaterial.")
	var popup_panel := key_popup.get_node("Center/PopupPanel") as PanelContainer
	_expect(popup_panel.theme_type_variation == &"SettingsPopupPanel", "Shortcut popup chrome must come from its Theme variation.")
	_expect(key_popup.get_node_or_null("Center/PopupPanel/Margin/Content/ShortcutRows") is GridContainer, "Shortcut popup layout must be owned by its reusable scene.")
	_expect(key_popup.find_child("KeyPopupImage", true, false) == null, "Shortcut popup must not regress to the baked key_popup texture.")
	var confirm_dialog := chrome.get_node("SettingsConfirm") as SettingsConfirmDialog
	_expect(confirm_dialog is SettingsModal and confirm_dialog.get_node_or_null("BackBufferCopy") is BackBufferCopy, "Settings confirmation must reuse the same blurred modal presentation.")
	_expect(confirm_dialog.get_node_or_null("DialogContent/Center/Main/Message") is Label, "Settings confirmation hierarchy must be declared by its reusable scene.")
	_expect_no_generated_node_names(settings, "Settings scene")
	_expect(settings_page.find_setting_slider("message_speed") != null, "Settings must expose message speed.")
	_expect(settings_page.find_setting_slider("auto_speed") != null, "Settings must expose auto speed.")
	_expect(settings_page.audio_page() != null and settings_page.audio_page().voice_button_count() == 9, "Audio settings page must expose the nine source voice characters.")
	_expect(SettingsModel.defaults().get("confirmations", {}).size() == 11, "Settings must preserve all eleven confirmation toggles.")
	_expect(SettingsModel.VOICE_DETAIL_NAMES.size() == 11, "Settings must preserve the eleven source VCID detail slots.")
	var source_defaults := SettingsModel.defaults()
	_expect(is_equal_approx(float(source_defaults.get("bgm_volume", 0.0)), 0.5) and is_equal_approx(float(source_defaults.get("se_volume", 0.0)), 0.7), "Audio defaults must match the source System.tjs gains.")
	_expect(int(source_defaults.get("window_depth", -1)) == 50 and int(source_defaults.get("message_speed", -1)) == 5, "Screen/system defaults must preserve source units.")
	var normalized_edges := SettingsModel.normalize({"window_mode": "borderless", "window_width": 1500, "font_type": 99, "mute_master": 1})
	_expect(str(normalized_edges.get("window_mode", "")) == "windowed" and int(normalized_edges.get("window_width", 0)) == 1600, "Unsupported desktop modes and widths must normalize to source HD choices.")
	_expect(int(normalized_edges.get("font_type", -1)) == 5 and normalized_edges.get("mute_master", false) == true, "Font and mute values must be clamped/normalized before persistence.")
	var preview_updates: Array[Dictionary] = []
	settings_repository.settings_preview_changed.connect(func(settings: Dictionary) -> void: preview_updates.append(settings))
	var writes_before_preview := settings_repository.settings_write_count
	var settings_reads_before_preview := settings_repository.settings_disk_read_count
	var master_slider := settings_page.find_setting_slider("master_volume")
	master_slider.value = 42.0
	master_slider.value = 43.0
	master_slider.value = 44.0
	_expect(preview_updates.size() >= 3, "Settings slider must preview each value change in real time.")
	_expect(settings_repository.settings_write_count == writes_before_preview, "Slider preview must not write settings for every value_changed.")
	_expect(settings_repository.settings_disk_read_count == settings_reads_before_preview, "Slider preview must use the settings snapshot without rereading disk.")
	await create_timer(0.4, true, false, true).timeout
	_expect(is_equal_approx(float(settings_repository.read_settings().get("master_volume", 0.0)), 0.44), "Settings slider must persist after debounce.")
	_expect(settings_repository.settings_write_count == writes_before_preview + 1, "Debounced slider changes must persist once.")
	master_slider.value = 55.0
	master_slider.drag_ended.emit(true)
	_expect(settings_repository.settings_write_count == writes_before_preview + 2, "Ending a slider drag must commit the pending preview immediately.")
	await create_timer(0.3, true, false, true).timeout
	_expect(is_equal_approx(float(settings_repository.read_settings().get("master_volume", 0.0)), 0.55), "Drag-end commit must persist the final slider value.")

	settings_page.display_page().select_window_mode("fullscreen")
	_expect(str(settings_repository.read_settings().get("window_mode", "")) == "fullscreen", "Window mode must persist.")
	settings_page.display_page().select_window_mode("windowed")
	_expect(str(settings_repository.read_settings().get("window_mode", "")) == "windowed", "Window mode must revert.")
	settings_page.display_page().select_resolution(1920)
	_expect(int(settings_repository.read_settings().get("window_width", 0)) == 1920, "Window width must persist.")
	settings_page.display_page().select_resolution(1280)
	settings_page.display_page().select_font(3)
	_expect(int(settings_repository.read_settings().get("font_type", 0)) == 3, "Font type must persist.")
	settings_page.display_page().set_screen_toggle(&"portrait_visible", false)
	_expect(settings_repository.read_settings().get("portrait_visible", true) == false, "Screen toggles must persist.")
	_expect(not preview_avatar.visible, "Screen preview must hide the avatar immediately when portrait display is disabled.")
	settings_page.display_page().set_screen_toggle(&"portrait_visible", true)
	_expect(preview_avatar.visible, "Screen preview must restore the avatar immediately when portrait display is enabled.")
	settings_page.system_page().set_system_toggle_for_test("read_skip", true)
	_expect(settings_repository.read_settings().get("read_skip", true) == false, "The source readSkip flag is inverted relative to the HD YES/NO label.")
	settings_page.system_page().set_system_toggle_for_test("lock_auto", true)
	_expect(settings_repository.read_settings().get("lock_auto", false) == true, "System toggles must persist.")
	settings_page.system_page().set_confirmation_for_test("delete", false)
	var confirmations_after: Dictionary = settings_repository.read_settings().get("confirmations", {})
	_expect(confirmations_after.get("delete", true) == false, "Confirmation toggles must persist.")
	_expect(confirmations_after.get("load", false) == true and confirmations_after.get("clear_read", false) == true, "Updating one confirmation must preserve the other source flags.")
	settings_page.system_page().set_confirmation_for_test("delete", true)

	settings_page.audio_page().select_voice(2)
	_expect(settings_page.audio_page().selected_voice_detail_index() == 1, "Voice selection must map to the source VCID detail index.")
	var voice_slider := settings_page.find_setting_slider("voice_detail")
	voice_slider.value = 30.0
	voice_slider.drag_ended.emit(true)
	var details: Array = settings_repository.read_settings().get("voice_detail_volumes", [])
	_expect(is_equal_approx(float(details[1]), 0.3), "Voice detail volume must persist at the source detail index.")

	var sample_files := SettingsModel.VOICE_SAMPLE_FILES
	for detail_index in sample_files.size():
		_expect(FileAccess.file_exists("res://assets/audio/voice_samples/%s.ogg" % sample_files[detail_index]), "Voice sample must exist: %s" % sample_files[detail_index])
	_expect(FileAccess.file_exists("res://assets/content/confirm/bg.png"), "Confirm dialog background must exist.")
	_expect(FileAccess.file_exists("res://assets/content/confirm/yes.png"), "Confirm yes button must exist.")
	_expect(FileAccess.file_exists("res://assets/content/confirm/no.png"), "Confirm no button must exist.")
	_expect(FileAccess.file_exists("res://assets/content/confirm/ask_always.png"), "Confirm always-ask toggle must exist.")

	settings_page.request_reset_settings()
	_expect(settings_page.is_confirm_visible(), "Reset settings must ask when confirmations.default is enabled.")
	settings_page.cancel_pending_action()
	_expect(not settings_page.is_confirm_visible(), "Cancel must dismiss the reset confirm dialog.")
	var writes_before_reset := settings_repository.settings_write_count
	settings_page.request_reset_settings()
	settings_page.confirm_pending_action()
	_expect(settings_repository.settings_write_count == writes_before_reset + 1, "Confirmed reset must persist once.")
	var reset_values := settings_repository.read_settings()
	_expect(is_equal_approx(float(reset_values.get("master_volume", 0.0)), 1.0), "Reset settings must restore default volumes.")
	_expect(str(reset_values.get("window_mode", "")) == "windowed", "Reset settings must preserve window mode.")
	_expect(int(reset_values.get("window_width", 0)) == 1280, "Reset settings must preserve window width.")
	settings_page.system_page().set_confirmation_for_test("default", false)
	var writes_before_silent_reset := settings_repository.settings_write_count
	settings_page.request_reset_settings()
	_expect(not settings_page.is_confirm_visible(), "Reset settings must skip the dialog when confirmations.default is disabled.")
	_expect(settings_repository.settings_write_count == writes_before_silent_reset + 1, "Silent reset must persist once.")
	var read_reset_events: Array[bool] = []
	var feature_read_reset_events: Array[bool] = []
	settings_page.read_flags_reset_requested.connect(func() -> void: read_reset_events.append(true))
	settings.read_flags_reset_requested.connect(func() -> void: feature_read_reset_events.append(true))
	settings_page.request_reset_read()
	_expect(settings_page.is_confirm_visible(), "Reset read flags must ask when confirmations.clear_read is enabled.")
	settings_page.confirm_pending_action()
	_expect(read_reset_events.size() == 1, "Reset read flags must emit a typed seam request.")
	_expect(feature_read_reset_events.size() == 1, "Settings feature must forward the read-reset request to StartupFlow.")

	settings_repository.fail_settings_write = true
	settings_page.display_page().select_font(4)
	var settings_status := chrome.get_node("SettingsStatus") as Label
	_expect(settings_status.text.contains("设置保存失败"), "A settings persistence failure must remain visible in the settings window.")
	_expect(int(settings_page.get_current_settings().get("font_type", -1)) == 0, "A failed settings write must roll the UI back to the durable snapshot.")
	settings_repository.fail_settings_write = false
	settings_page.display_page().select_font(0)
	# The preceding confirmation may still be fading out even though its
	# logical action has completed. Do not overlap two modal transitions in the
	# same synthetic test frame.
	await create_timer(0.2, true, false, true).timeout

	var close_events: Array[bool] = []
	settings_page.close_requested.connect(func() -> void: close_events.append(true))
	settings_page.open_key_popup()
	_expect(settings_page.is_key_popup_visible(), "Key settings button must open the popup.")
	_expect(is_zero_approx(popup_blur.modulate.a), "Modal blur must start transparent until the first live back-buffer frame is available.")
	await create_timer(0.08, true, false, true).timeout
	_expect(popup_blur.modulate.a > 0.0 and popup_blur.modulate.a < 1.0, "Modal blur must fade in over the live settings page instead of flashing an opaque frame.")
	var popup_escape := InputEventKey.new()
	popup_escape.pressed = true
	popup_escape.keycode = KEY_ESCAPE
	settings_page._input(popup_escape)
	_expect(not settings_page.is_key_popup_visible(), "Cancel must close the key popup before closing the window.")
	_expect(close_events.is_empty(), "Popup dismissal must not close the whole settings window.")
	_expect(key_popup.visible, "Closing a settings modal must keep it rendered while the exit animation plays.")
	await create_timer(0.2, true, false, true).timeout
	_expect(not key_popup.visible, "Settings modal must hide after its exit animation finishes.")
	var window_escape := InputEventKey.new()
	window_escape.pressed = true
	window_escape.keycode = KEY_ESCAPE
	settings_page._input(window_escape)
	_expect(close_events.size() == 1, "Cancel must close the HD settings window.")

	var legacy_settings := SettingsModel.normalize({
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
	settings.free()
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
