extends SceneTree


const SCENES: Dictionary = {
	&"brand": preload("res://src/intro/brand_movie_screen.tscn"),
	&"warning": preload("res://src/intro/content_warning_screen.tscn"),
	&"title": preload("res://src/title/title_screen.tscn"),
	&"title_press": preload("res://src/title/title_screen.tscn"),
}
const FEATURE_SCENE: PackedScene = preload("res://src/title/title_feature_screen.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://src/settings/settings_screen.tscn")
const SAVE_LOAD_PAGE_SCENE: PackedScene = preload("res://src/save_load/save_load_page.tscn")
const ADV_SCENE: PackedScene = preload("res://src/adv/adv_screen.tscn")
const ADV_SETTINGS_PREVIEW_SCENE: PackedScene = preload("res://src/adv/preview/adv_settings_preview.tscn")
const FEATURE_ROUTES: Dictionary = {
	&"album": &"album",
	&"music": &"music",
	&"memories": &"memories",
	&"voice": &"voice",
	&"load": &"load_game",
}


class CaptureSaveService extends SaveService:
	var capture_profile := ProfileData.create_empty("visual-capture")
	var capture_autosave: SaveData
	var capture_slots: Dictionary = {}

	func _init() -> void:
		capture_autosave = _sample_save("雨后的教室", "hitret:auto", 0, true)
		for slot_id in [0, 1, 3, 4, 7, 10, 14, 18]:
			capture_slots[slot_id] = _sample_save(
				["列车上的重逢", "穹的房间", "夏日祭前夜", "湖畔散步", "放学后的约定", "旧校舍", "盛夏午后", "通往未来"][capture_slots.size()],
				"hitret:%03d" % (slot_id * 17 + 12),
				(slot_id + 1) * 3700,
				slot_id % 3 != 1
			)

	func _ready() -> void:
		_ready_for_io = true

	func load_profile() -> ProfileData:
		return capture_profile

	func load_autosave() -> SaveData:
		return capture_autosave

	func load_slot(slot_id: int) -> SaveData:
		return capture_slots.get(slot_id) as SaveData

	func save_autosave(data: SaveData) -> bool:
		capture_autosave = data
		save_changed.emit(-1, true)
		return true

	func save_profile(profile: ProfileData) -> bool:
		capture_profile = profile
		save_changed.emit(-2, false)
		return true

	func is_global_flag_set(flag_id: int) -> bool:
		return capture_profile.is_global_flag_set(flag_id)

	func _sample_save(label: String, anchor: String, age: int, with_thumbnail: bool) -> SaveData:
		var data := SaveData.create_empty("visual-capture")
		data.scenario_id = "00_z%03d" % (age % 1000)
		data.instruction_anchor = anchor
		data.autosave_meta = {"valid": true}
		data.comment = label
		data.saved_at_unix = Time.get_unix_time_from_system() - age
		if with_thumbnail:
			data.presentation = {"thumbnail_path": "res://assets/ui/title/FRM_0511_title_background.png"}
		return data


class CaptureSettingsRepository extends SettingsRepository:
	var capture_settings := SettingsModel.defaults()

	func read_settings() -> Dictionary:
		return capture_settings.duplicate(true)

	func write_settings(settings: Dictionary) -> bool:
		capture_settings = SettingsModel.normalize(settings)
		settings_changed.emit(capture_settings.duplicate(true))
		return true

	func preview_settings(settings: Dictionary) -> void:
		var preview := capture_settings.duplicate(true)
		for key in settings:
			preview[key] = settings[key]
		settings_preview_changed.emit(SettingsModel.normalize(preview))


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() < 3 or arguments.size() > 5:
		push_error("Usage: -- <brand|warning|title|title_press|adv|adv_choice|album|music|memories|voice|settings|load|save> <output.png> <delay_seconds> [locked|adv_anchor:hitret:N|settings_tab:0|1|2|overlay:delete_confirm|overwrite_confirm] [settings_overlay:key_popup|key_popup_closing|reset_confirm|reset_confirm_closing]")
		quit(2)
		return

	var screen_name := StringName(arguments[0])
	if not SCENES.has(screen_name) and not FEATURE_ROUTES.has(screen_name) and screen_name not in [&"settings", &"save", &"adv", &"adv_choice"]:
		push_error("Unknown startup screen: %s" % screen_name)
		quit(2)
		return

	var screen: Control
	if screen_name in [&"adv", &"adv_choice"]:
		var service := CaptureSaveService.new()
		service.name = "CaptureSaveService"
		root.add_child(service)
		var request := ScenarioLaunchRequest.new_game()
		if arguments.size() >= 4 and arguments[3].begins_with("hitret:"):
			var seed := SaveData.create_empty("visual-capture")
			seed.scenario_id = "00_z000"
			seed.instruction_anchor = arguments[3]
			request = ScenarioLaunchRequest.from_save(seed)
		screen = ADV_SCENE.instantiate() as AdvScreen
		(screen as AdvScreen).configure(request, service)
	elif screen_name == &"settings":
		var service := CaptureSaveService.new()
		var settings_repository := CaptureSettingsRepository.new()
		service.name = "CaptureSaveService"
		_unlock_capture_content(service.capture_profile)
		root.add_child(service)
		var title_scene := SCENES[&"title"] as PackedScene
		var title_backdrop := title_scene.instantiate() as TitleScreen
		title_backdrop.configure(service)
		title_backdrop.reveal_seconds = 0.0
		title_backdrop.menu_fade_seconds = 0.0
		root.add_child(title_backdrop)
		screen = SETTINGS_SCENE.instantiate() as SettingsScreen
		(screen as SettingsScreen).configure(settings_repository)
	elif screen_name == &"save":
		var service := CaptureSaveService.new()
		service.name = "CaptureSaveService"
		root.add_child(service)
		var title_backdrop := (SCENES[&"title"] as PackedScene).instantiate() as TitleScreen
		title_backdrop.configure(service)
		title_backdrop.reveal_seconds = 0.0
		title_backdrop.menu_fade_seconds = 0.0
		root.add_child(title_backdrop)
		var payload := service._sample_save("当前剧情状态", "hitret:current", 0, true)
		screen = SAVE_LOAD_PAGE_SCENE.instantiate() as SaveLoadPage
		(screen as SaveLoadPage).configure(SaveLoadPage.Mode.SAVE, service, payload)
	elif FEATURE_ROUTES.has(screen_name):
		var service := CaptureSaveService.new()
		service.name = "CaptureSaveService"
		if arguments.size() < 4 or arguments[3] != "locked":
			_unlock_capture_content(service.capture_profile)
		root.add_child(service)
		screen = FEATURE_SCENE.instantiate() as TitleFeatureScreen
		(screen as TitleFeatureScreen).configure(FEATURE_ROUTES[screen_name], service)
	else:
		var scene := SCENES[screen_name] as PackedScene
		screen = scene.instantiate() as Control
	root.add_child(screen)
	if screen_name == &"settings":
		var page := (screen as SettingsScreen).settings_page()
		var preview := ADV_SETTINGS_PREVIEW_SCENE.instantiate() as AdvSettingsPreview
		preview.name = "AdvPreview"
		preview.configure(page.get_current_settings())
		page.display_page().install_preview(preview)
		page.settings_preview_changed.connect(preview.apply_settings)
	if screen_name == &"adv_choice":
		(screen as AdvScreen)._on_choices_ready([
			{"text": "不过，我觉得这就是有意思的地方", "hint": "一叶", "disabled": false},
			{"text": "捉弄过头的话，是不是不大好啊", "hint": "初佳", "disabled": false},
		])
	# Keep captures deterministic and prevent the host pointer from leaving a
	# random card in hover/tooltip state.
	Input.warp_mouse(Vector2(12.0, 12.0))
	await process_frame
	if screen_name == &"save":
		var save_page := screen as SaveLoadPage
		save_page.slot_cards()[1].pressed.emit()
	await create_timer(float(arguments[2])).timeout
	if screen_name == &"settings" and arguments.size() == 4:
		var settings_page := (screen as SettingsScreen).settings_page()
		if settings_page == null:
			push_error("SettingsPage was not created before visual capture.")
			quit(1)
			return
		var tab := clampi(int(arguments[3]), 0, 2)
		settings_page.show_tab(tab)
		await create_timer(0.3).timeout
	if screen_name == &"settings" and arguments.size() == 5:
		var settings_page := (screen as SettingsScreen).settings_page()
		var overlay_capture_delay := 0.3
		match arguments[4]:
			"key_popup":
				settings_page.open_key_popup()
			"key_popup_closing":
				settings_page.open_key_popup()
				await create_timer(0.3).timeout
				settings_page.close_key_popup()
				overlay_capture_delay = 0.08
			"reset_confirm":
				settings_page.request_reset_settings()
			"reset_confirm_closing":
				settings_page.request_reset_settings()
				await create_timer(0.3).timeout
				settings_page.cancel_pending_action()
				overlay_capture_delay = 0.08
			_:
				push_error("Unknown settings overlay: %s" % arguments[4])
				quit(2)
				return
		await create_timer(overlay_capture_delay).timeout
	if FEATURE_ROUTES.has(screen_name):
		var feature := screen as TitleFeatureScreen
		var content := feature.get_node("Content") as Control
		var entries := feature.get_node("Content/EntryList") as Control
		var back := feature.get_node("Content/Back") as Control
		print("Layout probe: content=", content.get_global_rect(), " entries=", entries.get_global_rect(), " back=", back.get_global_rect())
		if screen_name == &"load" and arguments.size() >= 4:
			if arguments[3] != "delete_confirm":
				push_error("Unknown load overlay: %s" % arguments[3])
				quit(2)
				return
			var save_load_page := feature.load_page()
			(save_load_page.get_node("VisualCanvas/PageLayout/FooterMargin/Footer/Delete") as Button).pressed.emit()
			await create_timer(0.25).timeout
	if screen_name == &"save" and arguments.size() >= 4:
		if arguments[3] != "overwrite_confirm":
			push_error("Unknown save overlay: %s" % arguments[3])
			quit(2)
			return
		((screen as SaveLoadPage).get_node("VisualCanvas/PageLayout/FooterMargin/Footer/Primary") as Button).pressed.emit()
		await create_timer(0.25).timeout
	if screen_name == &"title_press":
		var title := screen as TitleScreen
		title.get_menu_buttons()[0].play_press_feedback()
		await create_timer(0.04).timeout
	await process_frame

	var image := root.get_texture().get_image()
	if image == null:
		push_error("The active display driver cannot provide a render texture.")
		quit(1)
		return

	var error := image.save_png(arguments[1])
	for child in root.get_children():
		child.queue_free()
	await process_frame
	if error == OK:
		print("Visual capture saved to: ", arguments[1])
		quit(0)
		return

	push_error("Unable to save visual capture: %s" % error_string(error))
	quit(1)


func _unlock_capture_content(profile: ProfileData) -> void:
	profile.set_global_flag(1)
	for flag_id in range(11, 16):
		profile.set_global_flag(flag_id)
	for flag_id in range(51, 56):
		profile.set_global_flag(flag_id)
	for flag_id in range(61, 65):
		profile.set_global_flag(flag_id)
	for flag_id in range(71, 74):
		profile.set_global_flag(flag_id)
	for flag_id in range(81, 84):
		profile.set_global_flag(flag_id)
	for flag_id in range(91, 94):
		profile.set_global_flag(flag_id)
	for flag_id in range(1001, 1284):
		profile.set_global_flag(flag_id)
