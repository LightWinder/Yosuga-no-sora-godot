class_name StartupFlow
extends Node


signal scenario_requested(request: ScenarioLaunchRequest)
signal read_flags_reset_requested


enum Stage {
	BRAND_MOVIE,
	CONTENT_WARNING,
	TITLE,
	ADV,
}

const BRAND_MOVIE_SCENE: PackedScene = preload("res://src/intro/brand_movie_screen.tscn")
const CONTENT_WARNING_SCENE: PackedScene = preload("res://src/intro/content_warning_screen.tscn")
const TITLE_SCENE: PackedScene = preload("res://src/title/title_screen.tscn")
const TITLE_FEATURE_SCENE: PackedScene = preload("res://src/title/title_feature_screen.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://src/settings/settings_screen.tscn")
const ADV_SCENE: PackedScene = preload("res://src/adv/adv_screen.tscn")

@onready var _screen_host: Control = $ScreenHost
@onready var _overlay_host: Control = $OverlayLayer/OverlayHost
@onready var _load_transition_cover: TextureRect = $OverlayLayer/LoadTransitionCover
@onready var _audio: StartupAudio = $StartupAudio
@onready var _save_service: SaveService = $SaveService

@export_range(0.0, 2.0, 0.05) var load_cover_enter_seconds := 0.3
@export_range(0.0, 2.0, 0.05) var load_cover_leave_seconds := 0.5

var current_stage := Stage.BRAND_MOVIE
var last_selected_option: StringName = &""
var last_content_request: TitleContentRequest
var last_scenario_request: ScenarioLaunchRequest
var _current_screen: Control
var _settings_overlay: SettingsScreen
var _prepared_settings_screen: SettingsScreen
var _settings_return_focus: Control
var _settings_prepared_once := false
var _route_transitioning := false
var _load_transition_tween: Tween
var _screen_settings := DisplaySettingsService.new()
var _settings_repository := SettingsRepository.new()


func _ready() -> void:
	InputActions.ensure_actions()
	_settings_repository.settings_changed.connect(_audio.apply_settings)
	_settings_repository.settings_changed.connect(_screen_settings.apply)
	_settings_repository.settings_preview_changed.connect(_audio.apply_settings)
	_settings_repository.settings_preview_changed.connect(_screen_settings.apply)
	var settings := _settings_repository.read_settings()
	_audio.apply_settings(settings)
	_screen_settings.apply(settings)
	_show_brand_movie()


func _exit_tree() -> void:
	_kill_load_transition_tween()
	if is_instance_valid(_audio):
		_audio.stop_all()
	if is_instance_valid(_prepared_settings_screen):
		_prepared_settings_screen.free()
	_prepared_settings_screen = null


func _show_brand_movie() -> void:
	current_stage = Stage.BRAND_MOVIE
	var screen := _replace_screen(BRAND_MOVIE_SCENE) as BrandMovieScreen
	screen.brand_call_requested.connect(_audio.play_random_brand_call)
	screen.finished.connect(_show_content_warning, CONNECT_ONE_SHOT)


func _show_content_warning() -> void:
	current_stage = Stage.CONTENT_WARNING
	var screen := _replace_screen(CONTENT_WARNING_SCENE) as ContentWarningScreen
	screen.finished.connect(_show_title, CONNECT_ONE_SHOT)


func _show_title() -> void:
	current_stage = Stage.TITLE
	var screen := _replace_screen(TITLE_SCENE) as TitleScreen
	screen.option_selected.connect(_on_title_option_selected)
	screen.feature_requested.connect(_show_title_feature)
	screen.scenario_requested.connect(_on_scenario_requested)
	screen.exit_requested.connect(_on_exit_requested)
	_audio.play_title_bgm()
	_audio.play_random_title_call()
	call_deferred("_prepare_settings_screen")


func _replace_screen(scene: PackedScene) -> Control:
	_close_settings_overlay(false)
	if is_instance_valid(_current_screen):
		if _current_screen.get_parent() == _screen_host:
			_screen_host.remove_child(_current_screen)
		_current_screen.queue_free()

	_current_screen = scene.instantiate() as Control
	if _current_screen is TitleScreen:
		(_current_screen as TitleScreen).configure(_save_service)
	elif _current_screen is TitleFeatureScreen:
		(_current_screen as TitleFeatureScreen).configure(last_selected_option, _save_service)
	elif _current_screen is SettingsScreen:
		(_current_screen as SettingsScreen).configure(_settings_repository)
	elif _current_screen is AdvScreen:
		(_current_screen as AdvScreen).configure(last_scenario_request, _save_service, _settings_repository)
	_screen_host.add_child(_current_screen)
	return _current_screen


## Opens settings above the current route. SettingsScreen copies the root
## backbuffer directly, so the scene behind it remains a genuinely live blur.
func open_settings() -> SettingsScreen:
	if is_instance_valid(_settings_overlay):
		return _settings_overlay

	# Capture before the overlay hides the source dialogue/menu chrome.
	var preview_presentation: Dictionary = {}
	if _current_screen is AdvScreen:
		preview_presentation = (_current_screen as AdvScreen).capture_preview_presentation()
	_set_adv_route_overlay_active(true)
	_settings_return_focus = get_viewport().gui_get_focus_owner()
	get_viewport().gui_release_focus()
	_set_current_screen_input_enabled(false)

	if is_instance_valid(_prepared_settings_screen):
		_settings_overlay = _prepared_settings_screen
		_prepared_settings_screen = null
	else:
		_settings_prepared_once = true
		_settings_overlay = SETTINGS_SCENE.instantiate() as SettingsScreen
		_settings_overlay.configure(_settings_repository)
	_settings_overlay.back_requested.connect(func() -> void: _close_settings_overlay(), CONNECT_ONE_SHOT)
	_settings_overlay.read_flags_reset_requested.connect(_clear_read_flags)
	if _settings_overlay.get_parent() != _overlay_host:
		_overlay_host.add_child(_settings_overlay)
	_configure_settings_preview(_settings_overlay, preview_presentation)
	_overlay_host.move_child(_settings_overlay, _overlay_host.get_child_count() - 1)
	_settings_overlay.activate()
	if _current_screen is TitleScreen:
		(_current_screen as TitleScreen).play_subscreen_exit()
	return _settings_overlay


func _prepare_settings_screen() -> void:
	if _settings_prepared_once or is_instance_valid(_settings_overlay) or is_instance_valid(_prepared_settings_screen):
		return
	_settings_prepared_once = true
	_prepared_settings_screen = SETTINGS_SCENE.instantiate() as SettingsScreen
	_prepared_settings_screen.configure(_settings_repository)
	_prepared_settings_screen.prepare_hidden()
	_overlay_host.add_child(_prepared_settings_screen)
	_configure_settings_preview(_prepared_settings_screen)


func _configure_settings_preview(screen: SettingsScreen, presentation: Dictionary = {}) -> void:
	var page := screen.settings_page().display_page()
	var settings := screen.settings_page().get_current_settings()
	var preview := page.preview_content() as AdvScreen
	if preview == null:
		preview = ADV_SCENE.instantiate() as AdvScreen
		preview.name = "AdvPreview"
		preview.configure_preview(settings, presentation)
		page.install_preview(preview, preview.apply_preview_settings)
	elif not presentation.is_empty():
		preview.refresh_preview(settings, presentation)
	else:
		preview.apply_preview_settings(settings)


func _on_title_option_selected(option_id: StringName) -> void:
	last_selected_option = option_id


func _show_title_feature(feature_id: StringName) -> void:
	last_selected_option = feature_id
	if feature_id == &"settings":
		open_settings()
		return
	_open_title_feature_after_transition(feature_id)


func _open_title_feature_after_transition(feature_id: StringName) -> void:
	var source_title := _current_screen as TitleScreen
	if source_title != null:
		get_viewport().gui_release_focus()
		_set_current_screen_input_enabled(false)
		await source_title.play_subscreen_exit()
		if _current_screen != source_title or is_instance_valid(_settings_overlay):
			return
	var screen := _replace_screen(TITLE_FEATURE_SCENE) as TitleFeatureScreen
	screen.back_requested.connect(_show_title)
	screen.bonus_back_requested.connect(_show_title_bonus)
	screen.scenario_requested.connect(_on_scenario_requested)
	screen.content_requested.connect(_on_content_requested)


func _show_title_bonus() -> void:
	_show_title()
	var title := _current_screen as TitleScreen
	if title != null:
		title.call_deferred("show_bonus_menu")


func _close_settings_overlay(restore_focus := true) -> void:
	if not is_instance_valid(_settings_overlay):
		return
	if restore_focus:
		_close_settings_overlay_animated()
		return
	_discard_settings_overlay()


func _close_settings_overlay_animated() -> void:
	var overlay := _settings_overlay
	await overlay.play_close_transition()
	if not is_instance_valid(overlay) or overlay != _settings_overlay:
		return
	_settings_overlay = null
	if overlay.get_parent() == _overlay_host:
		_overlay_host.remove_child(overlay)
	overlay.queue_free()

	var source_title := _current_screen as TitleScreen
	if source_title != null:
		await source_title.play_subscreen_return()
		if _current_screen != source_title:
			return
	_set_adv_route_overlay_active(false)
	_set_current_screen_input_enabled(true)

	var return_focus := _settings_return_focus
	_settings_return_focus = null
	if is_instance_valid(return_focus) and return_focus.is_visible_in_tree():
		return_focus.call_deferred("grab_focus")


func _discard_settings_overlay() -> void:
	var overlay := _settings_overlay
	_settings_overlay = null
	if overlay.get_parent() == _overlay_host:
		_overlay_host.remove_child(overlay)
	overlay.queue_free()
	_settings_return_focus = null
	_set_adv_route_overlay_active(false)
	_set_current_screen_input_enabled(true)


func _set_current_screen_input_enabled(enabled: bool) -> void:
	if not is_instance_valid(_current_screen):
		return
	_current_screen.set_process_input(enabled)
	_current_screen.set_process_unhandled_input(enabled)


func _set_adv_route_overlay_active(active: bool) -> void:
	var adv := _current_screen as AdvScreen
	if adv != null:
		adv.set_route_overlay_active(active)


func _clear_read_flags() -> void:
	var profile := _save_service.load_profile()
	if profile == null:
		profile = ProfileData.create_empty(str(ProjectSettings.get_setting("application/config/version", "")))
	profile.read_text_ids.clear()
	_save_service.save_profile(profile)
	if _current_screen is AdvScreen:
		(_current_screen as AdvScreen).clear_read_state()
	read_flags_reset_requested.emit()


func _on_content_requested(request: TitleContentRequest) -> void:
	last_content_request = request


func _on_scenario_requested(request: ScenarioLaunchRequest) -> void:
	if _route_transitioning:
		return
	if request != null and request.save_data == null and not request.save_path.is_empty():
		var loaded := _save_service.load_path(request.save_path)
		if loaded != null:
			request.save_data = loaded
			request.scenario_id = loaded.scenario_id
			request.instruction_anchor = loaded.instruction_anchor
	last_scenario_request = request
	scenario_requested.emit(request)
	if request != null and request.is_new_game() and _current_screen is TitleScreen:
		_transition_title_to_adv()
	elif (
		request != null
		and request.kind == ScenarioLaunchRequest.RequestKind.CONTINUE
		and current_stage == Stage.TITLE
	):
		_transition_saved_title_to_adv()
	else:
		_show_adv()


func _transition_title_to_adv() -> void:
	var source_title := _current_screen as TitleScreen
	if source_title == null:
		_show_adv()
		return
	_route_transitioning = true
	get_viewport().gui_release_focus()
	_set_current_screen_input_enabled(false)
	_audio.fade_out_title_bgm(5000)
	await source_title.play_game_exit()
	if _current_screen != source_title:
		_route_transitioning = false
		return
	_show_adv(false)
	_route_transitioning = false


## The source Continue/Load path does not reuse New Game's long Title fade.
## ADVScreen.load instead raises FRM_0501 for 300 ms, restores the complete
## saved presentation behind it, then reveals the ready ADV scene over 500 ms.
func _transition_saved_title_to_adv() -> void:
	var source_screen := _current_screen
	if not is_instance_valid(source_screen):
		_show_adv()
		return
	_route_transitioning = true
	get_viewport().gui_release_focus()
	_set_current_screen_input_enabled(false)
	_audio.stop_all()
	_load_transition_cover.visible = true
	_load_transition_cover.modulate.a = 0.0
	await _tween_load_transition_cover(1.0, load_cover_enter_seconds)
	if _current_screen != source_screen:
		_finish_load_transition()
		return

	_show_adv(false)
	_set_current_screen_input_enabled(false)
	# Keep the source cover opaque until the restored ADV tree has produced one
	# complete frame; this prevents Title or a partially restored stage leaking.
	await get_tree().process_frame
	await _tween_load_transition_cover(0.0, load_cover_leave_seconds)
	_finish_load_transition()


func _tween_load_transition_cover(target_alpha: float, duration: float) -> void:
	_kill_load_transition_tween()
	if duration <= 0.0:
		_load_transition_cover.modulate.a = target_alpha
		return
	var tween := create_tween()
	_load_transition_tween = tween
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_load_transition_cover, "modulate:a", target_alpha, duration)
	await tween.finished
	if _load_transition_tween == tween:
		_load_transition_tween = null


func _finish_load_transition() -> void:
	_kill_load_transition_tween()
	_load_transition_cover.modulate.a = 0.0
	_load_transition_cover.visible = false
	_route_transitioning = false
	_set_current_screen_input_enabled(true)


func _kill_load_transition_tween() -> void:
	if _load_transition_tween != null and _load_transition_tween.is_valid():
		_load_transition_tween.kill()
	_load_transition_tween = null


func _show_adv(stop_startup_audio := true) -> void:
	current_stage = Stage.ADV
	if stop_startup_audio:
		_audio.stop_all()
	var screen := _replace_screen(ADV_SCENE) as AdvScreen
	screen.title_requested.connect(_return_to_title_from_adv)
	screen.settings_requested.connect(open_settings)
	screen.scenario_finished.connect(_return_to_title_from_adv)


func _return_to_title_from_adv() -> void:
	if _route_transitioning:
		return
	var source_adv := _current_screen as AdvScreen
	if source_adv == null:
		_show_title()
		return
	_route_transitioning = true
	get_viewport().gui_release_focus()
	_set_current_screen_input_enabled(false)
	await source_adv.play_title_exit()
	if _current_screen != source_adv:
		_route_transitioning = false
		return
	_route_transitioning = false
	_show_title()


func _on_exit_requested() -> void:
	get_tree().quit()
