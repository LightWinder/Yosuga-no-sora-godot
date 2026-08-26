class_name StartupFlow
extends Node


signal scenario_requested(request: ScenarioLaunchRequest)
signal read_flags_reset_requested


enum Stage {
	BRAND_MOVIE,
	CONTENT_WARNING,
	TITLE,
}

const BRAND_MOVIE_SCENE: PackedScene = preload("res://src/intro/brand_movie_screen.tscn")
const CONTENT_WARNING_SCENE: PackedScene = preload("res://src/intro/content_warning_screen.tscn")
const TITLE_SCENE: PackedScene = preload("res://src/title/title_screen.tscn")
const TITLE_FEATURE_SCENE: PackedScene = preload("res://src/title/title_feature_screen.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://src/settings/settings_screen.tscn")

@onready var _screen_host: Control = $ScreenHost
@onready var _overlay_host: Control = $OverlayHost
@onready var _audio: StartupAudio = $StartupAudio
@onready var _save_service: SaveService = $SaveService

var current_stage := Stage.BRAND_MOVIE
var last_selected_option: StringName = &""
var last_content_request: TitleContentRequest
var last_scenario_request: ScenarioLaunchRequest
var _current_screen: Control
var _settings_overlay: SettingsScreen
var _prepared_settings_screen: SettingsScreen
var _settings_return_focus: Control
var _settings_prepared_once := false
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
	_screen_host.add_child(_current_screen)
	return _current_screen


## Opens settings above the current route. SettingsScreen copies the root
## backbuffer directly, so the scene behind it remains a genuinely live blur.
func open_settings() -> SettingsScreen:
	if is_instance_valid(_settings_overlay):
		return _settings_overlay

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
	_settings_overlay.read_flags_reset_requested.connect(func() -> void: read_flags_reset_requested.emit())
	if _settings_overlay.get_parent() != _overlay_host:
		_overlay_host.add_child(_settings_overlay)
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
	_set_current_screen_input_enabled(true)


func _set_current_screen_input_enabled(enabled: bool) -> void:
	if not is_instance_valid(_current_screen):
		return
	_current_screen.set_process_input(enabled)
	_current_screen.set_process_unhandled_input(enabled)


func _on_content_requested(request: TitleContentRequest) -> void:
	last_content_request = request


func _on_scenario_requested(request: ScenarioLaunchRequest) -> void:
	last_scenario_request = request
	scenario_requested.emit(request)
	# Gameplay is deliberately not started until the scenario runner is
	# migrated.  The typed signal/data seam keeps the Title independent of it.


func _on_exit_requested() -> void:
	get_tree().quit()
