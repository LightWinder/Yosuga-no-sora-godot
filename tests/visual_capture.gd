extends SceneTree


const SCENES: Dictionary = {
	&"brand": preload("res://src/intro/brand_movie_screen.tscn"),
	&"warning": preload("res://src/intro/content_warning_screen.tscn"),
	&"title": preload("res://src/title/title_screen.tscn"),
	&"title_press": preload("res://src/title/title_screen.tscn"),
}
const FEATURE_SCENE: PackedScene = preload("res://src/title/title_feature_screen.tscn")
const FEATURE_ROUTES: Dictionary = {
	&"album": &"album",
	&"music": &"music",
	&"memories": &"memories",
	&"voice": &"voice",
	&"config": &"configuration",
	&"load": &"load_game",
}


class CaptureSaveService extends SaveService:
	var capture_profile := ProfileData.create_empty("visual-capture")
	var capture_settings := TitleSettingsModel.defaults()

	func _ready() -> void:
		_ready_for_io = true

	func load_profile() -> ProfileData:
		return capture_profile

	func read_settings() -> Dictionary:
		return capture_settings.duplicate(true)

	func write_settings(settings: Dictionary) -> bool:
		capture_settings = TitleSettingsModel.normalize(settings)
		settings_changed.emit(capture_settings.duplicate(true))
		return true

	func preview_settings(settings: Dictionary) -> void:
		var preview := capture_settings.duplicate(true)
		for key in settings:
			preview[key] = settings[key]
		settings_preview_changed.emit(TitleSettingsModel.normalize(preview))

	func is_global_flag_set(flag_id: int) -> bool:
		return capture_profile.is_global_flag_set(flag_id)


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() < 3 or arguments.size() > 4:
		push_error("Usage: -- <brand|warning|title|title_press|album|music|memories|voice|config|load> <output.png> <delay_seconds> [config_tab:0|1|2]")
		quit(2)
		return

	var screen_name := StringName(arguments[0])
	if not SCENES.has(screen_name) and not FEATURE_ROUTES.has(screen_name):
		push_error("Unknown startup screen: %s" % screen_name)
		quit(2)
		return

	var screen: Control
	if FEATURE_ROUTES.has(screen_name):
		var service := CaptureSaveService.new()
		_unlock_capture_content(service.capture_profile)
		root.add_child(service)
		screen = FEATURE_SCENE.instantiate() as TitleFeatureScreen
		(screen as TitleFeatureScreen).configure(FEATURE_ROUTES[screen_name], service)
	else:
		var scene := SCENES[screen_name] as PackedScene
		screen = scene.instantiate() as Control
	root.add_child(screen)
	await create_timer(float(arguments[2])).timeout
	if screen_name == &"config" and arguments.size() == 4:
		var config_page := (screen as TitleFeatureScreen).get_node("ConfigurationPage") as TitleConfigurationPage
		if config_page == null:
			push_error("ConfigurationPage was not created before visual capture.")
			quit(1)
			return
		var tab := clampi(int(arguments[3]), 0, 2)
		config_page.show_tab(tab)
		await process_frame
	if FEATURE_ROUTES.has(screen_name) and screen_name != &"config":
		var feature := screen as TitleFeatureScreen
		var panel := feature.get_node("Center/Panel") as Control
		var entries := feature.get_node("Center/Panel/Margin/Content/EntryScroll") as Control
		var back := feature.get_node("Center/Panel/Margin/Content/Back") as Control
		print("Layout probe: panel=", panel.get_global_rect(), " entries=", entries.get_global_rect(), " back=", back.get_global_rect())
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
