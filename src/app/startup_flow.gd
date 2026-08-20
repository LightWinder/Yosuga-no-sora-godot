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
const TITLE_CONFIGURATION_SCENE: PackedScene = preload("res://src/title/config/title_configuration_screen.tscn")

@onready var _screen_host: Control = $ScreenHost
@onready var _audio: StartupAudio = $StartupAudio
@onready var _save_service: SaveService = $SaveService

var current_stage := Stage.BRAND_MOVIE
var last_selected_option: StringName = &""
var last_content_request: TitleContentRequest
var last_scenario_request: ScenarioLaunchRequest
var _current_screen: Control
var _screen_settings := TitleScreenSettingsService.new()


func _ready() -> void:
	InputActions.ensure_actions()
	_save_service.settings_changed.connect(_audio.apply_settings)
	_save_service.settings_changed.connect(_screen_settings.apply)
	_save_service.settings_preview_changed.connect(_audio.apply_settings)
	_save_service.settings_preview_changed.connect(_screen_settings.apply)
	var settings := _save_service.read_settings()
	_audio.apply_settings(settings)
	_screen_settings.apply(settings)
	_show_brand_movie()


func _exit_tree() -> void:
	if is_instance_valid(_audio):
		_audio.stop_all()


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


func _replace_screen(scene: PackedScene) -> Control:
	if is_instance_valid(_current_screen):
		if _current_screen.get_parent() == _screen_host:
			_screen_host.remove_child(_current_screen)
		_current_screen.queue_free()

	_current_screen = scene.instantiate() as Control
	if _current_screen is TitleScreen:
		(_current_screen as TitleScreen).configure(_save_service)
	elif _current_screen is TitleFeatureScreen:
		(_current_screen as TitleFeatureScreen).configure(last_selected_option, _save_service)
	elif _current_screen is TitleConfigurationScreen:
		(_current_screen as TitleConfigurationScreen).configure(_save_service)
	_screen_host.add_child(_current_screen)
	return _current_screen


func _on_title_option_selected(option_id: StringName) -> void:
	last_selected_option = option_id


func _show_title_feature(feature_id: StringName) -> void:
	last_selected_option = feature_id
	if feature_id == &"configuration":
		var configuration := _replace_screen(TITLE_CONFIGURATION_SCENE) as TitleConfigurationScreen
		configuration.back_requested.connect(_show_title)
		configuration.read_flags_reset_requested.connect(func() -> void: read_flags_reset_requested.emit())
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


func _on_content_requested(request: TitleContentRequest) -> void:
	last_content_request = request


func _on_scenario_requested(request: ScenarioLaunchRequest) -> void:
	last_scenario_request = request
	scenario_requested.emit(request)
	# Gameplay is deliberately not started until the scenario runner is
	# migrated.  The typed signal/data seam keeps the Title independent of it.


func _on_exit_requested() -> void:
	get_tree().quit()
