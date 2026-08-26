extends SceneTree


const SCENES: Dictionary = {
	&"brand": preload("res://src/intro/brand_movie_screen.tscn"),
	&"warning": preload("res://src/intro/content_warning_screen.tscn"),
	&"title": preload("res://src/title/title_screen.tscn"),
	&"title_press": preload("res://src/title/title_screen.tscn"),
}
const FEATURE_SCENE: PackedScene = preload("res://src/title/title_feature_screen.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://src/settings/settings_screen.tscn")
const FEATURE_ROUTES: Dictionary = {
	&"album": &"album",
	&"music": &"music",
	&"memories": &"memories",
	&"voice": &"voice",
	&"load": &"load_game",
}


class CaptureSaveService extends SaveService:
	var capture_profile := ProfileData.create_empty("visual-capture")

	func _ready() -> void:
		_ready_for_io = true

	func load_profile() -> ProfileData:
		return capture_profile

	func is_global_flag_set(flag_id: int) -> bool:
		return capture_profile.is_global_flag_set(flag_id)


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
		push_error("Usage: -- <brand|warning|title|title_press|album|music|memories|voice|settings|load> <output.png> <delay_seconds> [settings_tab:0|1|2] [settings_overlay:key_popup|key_popup_closing|reset_confirm|reset_confirm_closing]")
		quit(2)
		return

	var screen_name := StringName(arguments[0])
	if not SCENES.has(screen_name) and not FEATURE_ROUTES.has(screen_name) and screen_name != &"settings":
		push_error("Unknown startup screen: %s" % screen_name)
		quit(2)
		return

	var screen: Control
	if screen_name == &"settings":
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
	elif FEATURE_ROUTES.has(screen_name):
		var service := CaptureSaveService.new()
		service.name = "CaptureSaveService"
		_unlock_capture_content(service.capture_profile)
		root.add_child(service)
		screen = FEATURE_SCENE.instantiate() as TitleFeatureScreen
		(screen as TitleFeatureScreen).configure(FEATURE_ROUTES[screen_name], service)
	else:
		var scene := SCENES[screen_name] as PackedScene
		screen = scene.instantiate() as Control
	root.add_child(screen)
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
