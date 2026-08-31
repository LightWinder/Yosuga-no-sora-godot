class_name AdvScreen
extends DesignCanvasPage


signal title_requested
signal settings_requested
signal scenario_finished

const SAVE_LOAD_PAGE_SCENE: PackedScene = preload("res://src/save_load/save_load_page.tscn")
const CHOICE_BUTTON_SCENE: PackedScene = preload("res://src/adv/components/adv_choice_button.tscn")
const SPEAKER_NAME_MANIFEST := "res://assets/content/adv/ui/speaker_name_manifest.csv"
const SPEAKER_NAME_DIRECTORY := "res://assets/content/adv/ui/name"
const SYSTEM_MENU_SHOWN_X := 1602.0
const SYSTEM_MENU_HIDDEN_X := 1860.0
const SYSTEM_MENU_SLIDE_SECONDS := 0.2
const PLAYER_CHROME_TRANSITION_SECONDS := 0.3
const PLAYER_CHROME_HIDE_OFFSET_Y := 120.0
const MAX_CHOICE_CHECKPOINTS := 64
const PRESENTATION_TAGS: Array[StringName] = [
	&"playbgm", &"stopbgm", &"pausebgm", &"restartbgm",
	&"playse", &"stopse", &"playenvse", &"stopenvse",
	&"blackout", &"whiteout", &"flash", &"hide", &"show",
	&"messageframe", &"movewindow", &"font",
	&"waitupdate", &"waitaction", &"waitcamera",
	&"waitse", &"waitenvse", &"waitbgm", &"waitvoice", &"hitwait",
	&"eyecatch", &"playmovie", &"staffroll",
]

@export_range(0.0, 4.0, 0.05) var title_exit_seconds := 2.0
@export_range(0.0, 2.0, 0.05) var title_exit_audio_seconds := 1.0
@export_range(0.0, 1.0, 0.05) var title_exit_chrome_seconds := 0.3

@onready var _runtime: KrkrScenarioRuntime = %ScenarioRuntime
@onready var _stage_director: AdvStageDirector = %StageDirector
@onready var _screen_tint: ColorRect = %ScreenTint
@onready var _eye_catch_overlay: PanelContainer = %EyeCatchOverlay
@onready var _eye_catch_date_black: ColorRect = %EyeCatchDateBlack
@onready var _eye_catch_top_band: ColorRect = %EyeCatchTopBand
@onready var _eye_catch_bottom_band: ColorRect = %EyeCatchBottomBand
@onready var _eye_catch_logo: TextureRect = %EyeCatchLogo
@onready var _message_panel: PanelContainer = %MessagePanel
@onready var _speaker_label: Label = %SpeakerLabel
@onready var _speaker_name_image: TextureRect = %SpeakerNameImage
@onready var _message_label: RichTextLabel = %MessageLabel
@onready var _portrait: TextureRect = %Portrait
@onready var _message_hide_button: TextureButton = %MessageHideButton
@onready var _system_menu: Control = %SystemMenu
@onready var _system_menu_recall_button: TextureButton = %SystemMenuRecallButton
@onready var _system_menu_auto_hide_timer: Timer = %SystemMenuAutoHideTimer
@onready var _auto_indicator_timer: Timer = %AutoIndicatorTimer
@onready var _auto_mode_indicator: TextureRect = %AutoModeIndicator
@onready var _previous_choice_button: TextureButton = %PreviousChoiceButton
@onready var _next_choice_button: TextureButton = %NextChoiceButton
@onready var _save_button: BaseButton = %SaveButton
@onready var _load_button: BaseButton = %LoadButton
@onready var _quick_save_button: BaseButton = %QuickSaveButton
@onready var _quick_load_button: BaseButton = %QuickLoadButton
@onready var _history_button: BaseButton = %HistoryButton
@onready var _auto_button: BaseButton = %AutoButton
@onready var _skip_button: BaseButton = %SkipButton
@onready var _settings_button: BaseButton = %SettingsButton
@onready var _menu_lock_button: TextureButton = %MenuLockButton
@onready var _title_button: BaseButton = %TitleButton
@onready var _choice_overlay: Control = %ChoiceOverlay
@onready var _choice_list: VBoxContainer = %ChoiceList
@onready var _history_overlay: Control = %HistoryOverlay
@onready var _history_text: RichTextLabel = %HistoryText
@onready var _history_close: Button = %HistoryClose
@onready var _feature_overlay: Control = %FeatureOverlay
@onready var _feature_host: Control = %FeatureHost
@onready var _status: Label = %Status
@onready var _title_confirmation: ConfirmationOverlay = %TitleConfirmation
@onready var _movie_layer: Control = %MovieLayer
@onready var _movie_player: VideoStreamPlayer = %MoviePlayer
@onready var _movie_skip: Button = %MovieSkip
@onready var _bgm_players: Array[AudioStreamPlayer] = [%BgmPlayer, %BgmPlayer2]
@onready var _voice_players: Array[AudioStreamPlayer] = [
	%VoicePlayer, %VoicePlayer2, %VoicePlayer3, %VoicePlayer4, %VoicePlayer5,
]
@onready var _se_player: AudioStreamPlayer = %SePlayer
@onready var _env_player: AudioStreamPlayer = %EnvPlayer
@onready var _route_exit_cover: ColorRect = %RouteExitCover
@onready var _route_exit_blocker: Control = %RouteExitBlocker

var _launch_request: ScenarioLaunchRequest
var _save_service: SaveService
var _settings_repository: SettingsRepository
var _progress_catalog: AdvProgressCatalog
var _runtime_settings: Dictionary = {}
var _current_message := ""
var _current_speaker := ""
var _current_anchor := ""
var _typewriter_tween: Tween
var _auto_enabled := false
var _skip_enabled := false
var _auto_generation := 0
var _history_entries: Array[String] = []
var _active_save_load: SaveLoadPage
var _effect_tween: Tween
var _effect_finish_action: Callable
var _message_visibility_tween: Tween
var _eye_catch_tween: Tween
var _eye_catch_is_date := false
var _eye_catch_stage_committed := false
var _choice_tween: Tween
var _waiting_action_target := ""
var _bgm_pause_position := 0.0
var _bgm_asset := ""
var _environment_asset := ""
var _active_bgm_player: AudioStreamPlayer
var _audio_fade_tweens: Dictionary = {}
var _default_message_font_size := 50
var _current_message_font_size := 50
var _pending_font_size := 0
var _message_frame_type := "0"
var _current_message_already_read := false
var _message_speed_milliseconds := 5
var _auto_wait_seconds := 5.0
var _allow_unread_skip := false
var _stop_voice_on_advance := false
var _preserve_skip_after_choice := false
var _preserve_auto_after_choice := false
var _route_guide_enabled := true
var _speaker_name_textures: Dictionary = {}
var _system_menu_locked := true
var _system_menu_pointer_inside := false
var _system_menu_slide_tween: Tween
var _player_chrome_tween: Tween
var _player_chrome_manually_hidden := false
var _player_chrome_overlay_depth := 0
var _restore_player_chrome_after_overlay := false
var _message_panel_rest_position := Vector2.ZERO
var _system_menu_rest_position := Vector2.ZERO
var _message_panel_rest_modulate := Color.WHITE
var _system_menu_rest_modulate := Color.WHITE
var _auto_indicator_frame := 0
var _choice_checkpoints: Array[Dictionary] = []
var _choice_history_position := 0
var _restoring_choice_checkpoint := false
var _restoring_navigation_checkpoint := false
var _jumping_to_next_choice := false
var _choice_jump_continue_scheduled := false
var _choice_jump_rollback: Dictionary = {}
var _choice_jump_screen_effects_overridden := false
var _choice_jump_bgm_target: Dictionary = {}
var _choice_jump_environment_target: Dictionary = {}
var _choice_jump_stage_instructions: Array[KrkrScenarioInstruction] = []
var _route_exit_tween: Tween
var _route_exiting := false
var _preview_only := false
var _message_panel_style: StyleBoxTexture


## Settings always shows the same fixed sample, independent of the active route.
## Configure before entering the tree: this path never starts a scenario,
## connects gameplay actions, creates services, or restores audio.
func configure_preview(settings: Dictionary) -> void:
	assert(not is_inside_tree())
	_preview_only = true
	_runtime_settings = SettingsModel.normalize(settings)
	process_mode = Node.PROCESS_MODE_DISABLED


func _initialize_preview() -> void:
	_stage_director.restore_presentation({"background": "EA01E"})
	_current_speaker = "穹"
	_current_message = "……别把我当小孩子，明明我和你一般大的。"
	_current_message_already_read = true
	_apply_runtime_settings(_runtime_settings)
	_present_current_dialogue(true)
	_disable_preview_input(self)


func apply_preview_settings(settings: Dictionary) -> void:
	assert(_preview_only)
	_apply_runtime_settings(settings)


func _disable_preview_input(node: Node) -> void:
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	node.set_process_unhandled_key_input(false)
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		(node as Control).focus_mode = Control.FOCUS_NONE
		(node as Control).tooltip_text = ""
	for child in node.get_children(true):
		_disable_preview_input(child)


func configure(
		request: ScenarioLaunchRequest,
		save_service: SaveService,
		settings_repository: SettingsRepository = null
) -> void:
	_launch_request = request
	_save_service = save_service
	_settings_repository = settings_repository


func _ready() -> void:
	super._ready()
	# Opacity belongs to the frame alone, never the text/portrait children, and
	# a preview must not mutate the Theme resource used by the running game.
	_message_panel_style = _message_panel.get_theme_stylebox("panel").duplicate() as StyleBoxTexture
	_message_panel.add_theme_stylebox_override("panel", _message_panel_style)
	if _preview_only:
		_load_speaker_name_textures()
		_initialize_preview()
		return
	InputActions.ensure_actions()
	_progress_catalog = AdvProgressCatalog.load_default()
	if not _progress_catalog.load_error.is_empty():
		push_error(_progress_catalog.load_error)
	_active_bgm_player = _bgm_players[0]
	_load_speaker_name_textures()
	_connect_controls()
	_connect_runtime()
	_connect_stage_director()
	if _save_service == null:
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	if _settings_repository == null:
		_settings_repository = SettingsRepository.new()
	_settings_repository.settings_changed.connect(_apply_runtime_settings)
	_settings_repository.settings_preview_changed.connect(_apply_runtime_settings)
	_apply_runtime_settings(_settings_repository.read_settings())
	if _launch_request == null:
		_launch_request = ScenarioLaunchRequest.new_game()
	_start_request()


func _exit_tree() -> void:
	_kill_typewriter()
	_kill_effect_tween()
	_kill_tween(_message_visibility_tween)
	_kill_tween(_eye_catch_tween)
	_kill_tween(_choice_tween)
	_kill_tween(_system_menu_slide_tween)
	_kill_tween(_player_chrome_tween)
	_kill_tween(_route_exit_tween)
	_system_menu_auto_hide_timer.stop()
	_auto_indicator_timer.stop()
	_auto_generation += 1
	var audio_players: Array[AudioStreamPlayer] = [_se_player, _env_player]
	audio_players.append_array(_bgm_players)
	audio_players.append_array(_voice_players)
	for player in audio_players:
		if is_instance_valid(player):
			_kill_audio_fade(player)
			player.stop()
			player.stream = null
	if is_instance_valid(_movie_player):
		_movie_player.stop()
		_movie_player.stream = null


func _unhandled_input(event: InputEvent) -> void:
	if _preview_only:
		return
	if _route_exiting:
		if StartupInput.is_advance_event(event) or StartupInput.is_cancel_event(event):
			get_viewport().set_input_as_handled()
		return
	if _jumping_to_next_choice:
		if StartupInput.is_advance_event(event) or StartupInput.is_cancel_event(event):
			get_viewport().set_input_as_handled()
		return
	if _movie_layer.visible:
		if StartupInput.is_advance_event(event) or StartupInput.is_cancel_event(event):
			_finish_movie()
			get_viewport().set_input_as_handled()
		return
	if _feature_overlay.visible:
		if StartupInput.is_cancel_event(event):
			_close_save_load()
			get_viewport().set_input_as_handled()
		return
	if _title_confirmation.visible:
		if StartupInput.is_cancel_event(event):
			_cancel_title_confirmation()
			get_viewport().set_input_as_handled()
		return
	if _history_overlay.visible:
		if StartupInput.is_cancel_event(event) or StartupInput.is_advance_event(event):
			_close_history()
			get_viewport().set_input_as_handled()
		return
	if _player_chrome_tween != null and _player_chrome_tween.is_valid():
		if StartupInput.is_advance_event(event) or StartupInput.is_cancel_event(event):
			get_viewport().set_input_as_handled()
		return
	if _player_chrome_manually_hidden:
		if StartupInput.is_advance_event(event) or StartupInput.is_cancel_event(event):
			_show_player_chrome_manually()
			get_viewport().set_input_as_handled()
		return
	if _choice_overlay.visible:
		return
	if StartupInput.is_advance_event(event):
		_advance_story()
		get_viewport().set_input_as_handled()
	elif StartupInput.is_cancel_event(event):
		if not _system_menu.visible or not is_equal_approx(_system_menu.position.x, SYSTEM_MENU_SHOWN_X):
			_system_menu.visible = true
			_show_system_menu()
		else:
			_suspend_system_menu()
		get_viewport().set_input_as_handled()


func runtime() -> KrkrScenarioRuntime:
	return _runtime


func current_message() -> String:
	return _current_message


## Reproduces ADVScreen.returnTo(): selection UI ends immediately, player
## chrome leaves in 300 ms, all ADV audio fades for one second, and the stage
## reaches black after two seconds before the composition root changes routes.
func play_title_exit() -> void:
	if _route_exiting:
		if _route_exit_tween != null and _route_exit_tween.is_valid():
			await _route_exit_tween.finished
		return
	_route_exiting = true
	get_viewport().gui_release_focus()
	_stop_player_chrome_automation()
	_cancel_choice_jump()
	_kill_tween(_choice_tween)
	_choice_tween = null
	_choice_overlay.visible = false
	_clear_choice_buttons()
	_history_overlay.visible = false
	_route_exit_blocker.visible = true
	if _message_panel.visible or _system_menu.visible:
		_set_player_chrome_visible(false, title_exit_chrome_seconds)
	_fade_out_route_audio(int(round(title_exit_audio_seconds * 1000.0)))
	_route_exit_cover.visible = true
	_route_exit_cover.modulate.a = 0.0
	if title_exit_seconds <= 0.0:
		_route_exit_cover.modulate.a = 1.0
		return
	var tween := create_tween()
	_route_exit_tween = tween
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_route_exit_cover, "modulate:a", 1.0, title_exit_seconds)
	await tween.finished
	if _route_exit_tween == tween:
		_route_exit_tween = null


func is_route_exiting() -> bool:
	return _route_exiting


## Route-level overlays use this seam so the live ADV backdrop does not retain
## dialogue chrome beneath Settings. Returning restores it synchronously.
func set_route_overlay_active(active: bool) -> void:
	if active:
		_enter_player_chrome_overlay()
	else:
		_leave_player_chrome_overlay()


func _connect_controls() -> void:
	_previous_choice_button.pressed.connect(_jump_to_previous_choice)
	_next_choice_button.pressed.connect(_jump_to_next_choice)
	_save_button.pressed.connect(_open_save_load.bind(SaveLoadPage.Mode.SAVE))
	_load_button.pressed.connect(_open_save_load.bind(SaveLoadPage.Mode.LOAD))
	_quick_save_button.pressed.connect(_quick_save)
	_quick_load_button.pressed.connect(_quick_load)
	_history_button.pressed.connect(_open_history)
	_auto_button.toggled.connect(_set_auto_enabled)
	_skip_button.toggled.connect(_set_skip_enabled)
	_message_hide_button.pressed.connect(_hide_player_chrome_manually)
	_message_panel.gui_input.connect(_on_message_panel_gui_input)
	_settings_button.pressed.connect(func() -> void: settings_requested.emit())
	_menu_lock_button.toggled.connect(_on_system_menu_lock_toggled)
	_title_button.pressed.connect(_request_title)
	_system_menu.mouse_entered.connect(_on_system_menu_mouse_entered)
	_system_menu.mouse_exited.connect(_on_system_menu_mouse_exited)
	_system_menu_recall_button.pressed.connect(_show_system_menu)
	_system_menu_recall_button.mouse_entered.connect(_show_system_menu)
	_system_menu_auto_hide_timer.timeout.connect(_hide_system_menu)
	_auto_indicator_timer.timeout.connect(_advance_auto_indicator)
	_history_close.pressed.connect(_close_history)
	_title_confirmation.confirmed.connect(_confirm_title)
	_title_confirmation.canceled.connect(_cancel_title_confirmation)
	_movie_player.finished.connect(_finish_movie)
	_movie_skip.pressed.connect(_finish_movie)
	for voice_player in _voice_players:
		voice_player.finished.connect(_on_voice_finished)
	_se_player.finished.connect(_resume_audio_wait.bind(&"se"))
	_env_player.finished.connect(_resume_audio_wait.bind(&"envse"))
	for bgm_player in _bgm_players:
		bgm_player.finished.connect(_on_bgm_finished)


func _on_message_panel_gui_input(event: InputEvent) -> void:
	if not StartupInput.is_advance_event(event) and not StartupInput.is_cancel_event(event):
		return
	_unhandled_input(event)
	accept_event()


func _connect_runtime() -> void:
	_runtime.dialogue_ready.connect(_on_dialogue_ready)
	_runtime.choices_ready.connect(_on_choices_ready)
	_runtime.instruction_executed.connect(_on_instruction_executed)
	_runtime.scenario_changed.connect(func(id: String) -> void: _status.text = "SCENARIO  %s" % id)
	_runtime.runtime_error.connect(_on_runtime_error)
	_runtime.playback_finished.connect(_on_playback_finished)
	_runtime.external_skip_requested.connect(_on_external_skip_requested)


func _connect_stage_director() -> void:
	_stage_director.missing_asset.connect(_report_missing)
	_stage_director.cg_presented.connect(_on_cg_presented)
	_stage_director.character_presented.connect(_on_character_presented)
	_stage_director.transition_finished.connect(_on_transition_finished)
	_stage_director.action_finished.connect(_on_action_finished)
	_stage_director.camera_finished.connect(_on_camera_finished)


func _on_cg_presented(resource_id: String) -> void:
	_register_content_progress(_progress_catalog.flags_for_cg(resource_id))


func _on_character_presented(resource_id: String) -> void:
	_register_content_progress(_progress_catalog.flags_for_character(resource_id))


func _register_content_progress(flag_ids: Array[int]) -> void:
	if _launch_request != null and _launch_request.is_recollection():
		return
	for flag_id in flag_ids:
		_runtime.global_flags[str(flag_id)] = true


func _start_request() -> void:
	var seed := _launch_request.save_data
	if seed == null:
		seed = SaveData.create_empty(str(ProjectSettings.get_setting("application/config/version", "")))
	_restore_choice_navigation(seed)
	var profile := _save_service.load_profile()
	if profile != null:
		seed.global_flags = profile.global_flags.duplicate(true)
		for read_id in profile.read_text_ids:
			if not seed.read_text_ids.has(read_id):
				seed.read_text_ids.append(read_id)
	_restore_presentation(seed.presentation)
	var scenario_id := _launch_request.scenario_id
	if scenario_id.is_empty():
		scenario_id = "00_z000"
	var started := _runtime.start_scenario(
		scenario_id,
		_launch_request.instruction_anchor,
		seed,
		_launch_request.is_recollection(),
		_launch_request.start_label
	)
	if not started:
		_status.text = "无法启动剧本 %s" % scenario_id
		_status.visible = true


func _on_dialogue_ready(
		speaker: String,
		message: String,
		voice_id: String,
		anchor: String,
		already_read: bool
) -> void:
	var reveal_initial_dialogue := _launch_request.is_new_game() and _current_anchor.is_empty()
	if _jumping_to_next_choice:
		_choice_jump_stage_instructions.append(_choice_jump_stage_boundary())
	else:
		_stage_director.commit_pending()
	_current_speaker = speaker
	_current_message = message
	_current_anchor = anchor
	_current_message_already_read = already_read
	# Font is a one-dialogue command in the source. Consume it even while a
	# next-choice scan suppresses intermediate rendering, otherwise an earlier
	# small-font line leaks into the final pre-choice dialogue.
	_current_message_font_size = (
		_pending_font_size if _pending_font_size > 0 else _default_message_font_size
	)
	_pending_font_size = 0
	if _jumping_to_next_choice:
		_message_panel.visible = false
		_suspend_system_menu()
		_schedule_choice_jump_continue()
		return
	var restored_navigation := _restoring_navigation_checkpoint
	_restoring_navigation_checkpoint = false
	_message_panel.visible = true
	_system_menu.visible = true
	_show_system_menu(true)
	_present_current_dialogue(false)
	_start_typewriter()
	if not restored_navigation:
		_append_history(speaker, message)
	_play_voice(voice_id)
	if not restored_navigation:
		_write_autosave()
	if reveal_initial_dialogue:
		# Source MessageFrame starts hidden; outputMessage reveals it over 300 ms
		# alongside the first CG update. Save the settled frame before animating.
		_message_panel.modulate.a = 0.0
		_system_menu.modulate.a = 0.0
		_set_message_visible(true)
	_refresh_choice_navigation_buttons()
	if _skip_enabled and _can_skip_current_message():
		_schedule_advance(0.06)
	else:
		_try_schedule_auto_advance()


func _start_typewriter() -> void:
	_kill_typewriter()
	_auto_generation += 1
	_message_label.visible_characters = 0
	var character_count := _message_label.get_total_character_count()
	if character_count <= 0:
		_finish_typewriter()
		return
	_typewriter_tween = create_tween()
	_typewriter_tween.tween_property(
		_message_label,
		"visible_characters",
		character_count,
		_typewriter_duration()
	)
	_typewriter_tween.finished.connect(_finish_typewriter)


func _typewriter_duration() -> float:
	if _message_speed_milliseconds <= 0:
		return 0.001
	return maxf(
		float(_message_label.get_total_character_count() * _message_speed_milliseconds) / 1000.0,
		0.01
	)


func _finish_typewriter() -> void:
	_message_label.visible_characters = -1
	_typewriter_tween = null
	_try_schedule_auto_advance()


func _kill_typewriter() -> void:
	if _typewriter_tween != null and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
	_typewriter_tween = null


func _advance_story(force_progress: bool = false) -> void:
	_auto_generation += 1
	if _stop_voice_on_advance:
		_stop_voice()
	if _runtime.is_waiting_external():
		_runtime.advance()
		return
	if _stage_director.is_transitioning():
		_stage_director.finish_transition()
	if _stage_director.is_camera_moving():
		_stage_director.finish_camera_move()
	if _message_label.visible_characters >= 0:
		_kill_typewriter()
		_finish_typewriter()
		if not force_progress:
			return
	_runtime.advance()


func _schedule_advance(delay: float) -> void:
	_auto_generation += 1
	var generation := _auto_generation
	get_tree().create_timer(delay).timeout.connect(
		func() -> void:
			if generation != _auto_generation or not is_inside_tree():
				return
			_advance_story(true)
	)


func _on_choices_ready(choices: Array[Dictionary]) -> void:
	var completed_choice_jump := _jumping_to_next_choice
	if completed_choice_jump:
		_stage_director.apply_navigation_instructions(_choice_jump_stage_instructions)
		_choice_jump_stage_instructions.clear()
		_restore_choice_jump_dialogue()
	else:
		_stage_director.commit_pending()
	var restored_checkpoint := _restoring_choice_checkpoint
	_restoring_choice_checkpoint = false
	_jumping_to_next_choice = false
	_choice_jump_continue_scheduled = false
	if completed_choice_jump:
		_apply_choice_jump_audio_targets()
	_choice_jump_rollback.clear()
	if not restored_checkpoint:
		if _choice_history_position < _choice_checkpoints.size():
			_choice_checkpoints.resize(_choice_history_position)
		var runtime_checkpoint := _runtime.build_navigation_checkpoint()
		if not runtime_checkpoint.is_empty():
			_choice_checkpoints.append({
				"runtime": runtime_checkpoint,
				"presentation": _capture_presentation(),
			})
			if _choice_checkpoints.size() > MAX_CHOICE_CHECKPOINTS:
				_choice_checkpoints.pop_front()
			_choice_history_position = _choice_checkpoints.size() - 1
	# Source ADV writes its temporary save immediately before StartSelect so a
	# load always returns to the decision instead of skipping past it.
	_write_autosave()
	if not _preserve_skip_after_choice:
		_set_skip_enabled(false)
		_skip_button.set_pressed_no_signal(false)
	if not _preserve_auto_after_choice:
		_set_auto_enabled(false)
		_auto_button.set_pressed_no_signal(false)
	_clear_choice_buttons()
	_choice_overlay.visible = true
	_choice_overlay.modulate.a = 0.0
	_populate_choice_buttons(choices, _choice_route_hints_enabled())
	if completed_choice_jump:
		_choice_overlay.modulate.a = 1.0
	else:
		_choice_tween = create_tween()
		_choice_tween.tween_property(_choice_overlay, "modulate:a", 1.0, 0.3)
		_choice_tween.finished.connect(func() -> void: _choice_tween = null)
	get_viewport().gui_release_focus()
	# Refresh after the checkpoint cursor and jump state have both settled.
	_refresh_choice_navigation_buttons()
	if completed_choice_jump:
		_finish_choice_jump_transition()


func _choice_route_hints_enabled() -> bool:
	var route_flags_are_clear := true
	for flag_id in ["1", "2", "3", "4"]:
		if bool(_runtime.local_flags.get(flag_id, false)):
			route_flags_are_clear = false
			break
	return _route_guide_enabled and route_flags_are_clear


func _populate_choice_buttons(choices: Array[Dictionary], show_route_hints: bool) -> void:
	for index in choices.size():
		var choice := choices[index]
		var button := CHOICE_BUTTON_SCENE.instantiate() as AdvChoiceButton
		button.name = "Choice%02d" % (index + 1)
		_choice_list.add_child(button)
		button.configure(
			index,
			str(choice.get("text", "选项 %d" % (index + 1))),
			str(choice.get("hint", "")),
			show_route_hints
		)
		button.set_choice_disabled(bool(choice.get("disabled", false)))
		button.pressed.connect(_select_choice.bind(index))


func _restore_choice_jump_dialogue() -> void:
	if _message_visibility_tween != null and _message_visibility_tween.is_valid():
		_message_visibility_tween.kill()
	_message_visibility_tween = null
	_message_panel.visible = true
	_message_panel.modulate.a = 1.0
	_system_menu.visible = true
	_system_menu.modulate.a = 1.0
	_show_system_menu(true)
	_present_current_dialogue(true)


func _present_current_dialogue(reveal_all: bool) -> void:
	_update_dialogue_chrome(_current_speaker)
	_refresh_message_appearance()
	_message_label.text = _current_message
	if reveal_all:
		_message_label.visible_characters = -1


func _refresh_message_appearance() -> void:
	_message_panel_style.modulate_color.a = float(_runtime_settings.get("window_depth", 50)) / 100.0
	_message_label.add_theme_font_size_override(
		"normal_font_size", _current_message_font_size
	)
	_message_label.add_theme_color_override(
		"default_color",
		Color(0.72, 0.91, 1.0, 1.0)
		if _current_message_already_read and bool(_runtime_settings.get("read_color", true))
		else Color(0.98, 0.995, 1.0, 1.0)
	)


func _select_choice(index: int) -> void:
	var selected_button := _choice_list.get_child(index) as AdvChoiceButton
	if selected_button != null:
		_append_history("■选项■", "选择了《%s》选项。" % selected_button.choice_text)
	for child in _choice_list.get_children():
		(child as Button).disabled = true
	_kill_tween(_choice_tween)
	_choice_tween = create_tween()
	_choice_tween.tween_property(_choice_overlay, "modulate:a", 0.0, 0.3)
	await _choice_tween.finished
	_choice_tween = null
	_choice_overlay.visible = false
	_choice_overlay.modulate.a = 1.0
	_message_panel.visible = true
	_system_menu.visible = true
	_show_system_menu(true)
	_clear_choice_buttons()
	if _choice_history_position < _choice_checkpoints.size() - 1:
		_choice_checkpoints.resize(_choice_history_position + 1)
	_choice_history_position = _choice_checkpoints.size()
	_runtime.choose(index)


func _clear_choice_buttons() -> void:
	for child in _choice_list.get_children():
		_choice_list.remove_child(child)
		child.queue_free()


func _capture_presentation() -> Dictionary:
	return _build_save_snapshot().presentation.duplicate(true)


func _jump_to_previous_choice() -> void:
	if (
		_choice_checkpoints.is_empty()
		or _choice_history_position <= 0
		or _launch_request.is_recollection()
	):
		return
	var target_index := clampi(
		_choice_history_position - 1,
		0,
		_choice_checkpoints.size() - 1
	)
	_restore_choice_checkpoint(target_index)


func _restore_choice_checkpoint(target_index: int) -> void:
	if target_index < 0 or target_index >= _choice_checkpoints.size():
		return
	var checkpoint := _choice_checkpoints[target_index]
	var runtime_checkpoint: Variant = checkpoint.get("runtime", {})
	var presentation: Variant = checkpoint.get("presentation", {})
	if not runtime_checkpoint is Dictionary or not presentation is Dictionary:
		return
	_cancel_choice_jump()
	_stop_voice()
	_kill_typewriter()
	_clear_choice_buttons()
	_choice_overlay.visible = false
	_stage_director.clear()
	_restore_presentation(presentation)
	_choice_history_position = target_index
	_restoring_choice_checkpoint = true
	if not _runtime.restore_navigation_checkpoint(runtime_checkpoint):
		_restoring_choice_checkpoint = false
		_status.text = "无法恢复上一选项"
		_status.visible = true


func _jump_to_next_choice() -> void:
	if (
		_jumping_to_next_choice
		or _launch_request.is_recollection()
		or bool(_runtime.parameters.get("select_terminated", false))
		or not _runtime.is_waiting_for_dialogue()
	):
		return
	var runtime_checkpoint := _runtime.build_navigation_checkpoint()
	if runtime_checkpoint.is_empty():
		return
	_choice_jump_rollback = {
		"runtime": runtime_checkpoint,
		"presentation": _capture_presentation(),
	}
	_jumping_to_next_choice = true
	_choice_jump_continue_scheduled = false
	_set_auto_enabled(false)
	_auto_button.set_pressed_no_signal(false)
	_set_skip_enabled(false)
	_skip_button.set_pressed_no_signal(false)
	_stop_voice()
	_stop_audio_immediate(_se_player)
	_kill_typewriter()
	_capture_choice_jump_audio_targets()
	_choice_jump_stage_instructions.clear()
	_refresh_choice_navigation_buttons()
	_begin_choice_jump_transition()


func _begin_choice_jump_transition() -> void:
	# The source jump scanner buffers presentation commands and commits only the
	# resulting frame. Keep that work inside this input frame: there is no loading
	# artwork and no visible traversal through intermediate dialogue boundaries.
	_choice_jump_screen_effects_overridden = true
	_stage_director.set_screen_effects_enabled(false)
	_continue_choice_jump()


func _schedule_choice_jump_continue() -> void:
	if not _jumping_to_next_choice or _choice_jump_continue_scheduled:
		return
	_choice_jump_continue_scheduled = true
	_continue_choice_jump.call_deferred()


func _continue_choice_jump() -> void:
	_choice_jump_continue_scheduled = false
	var boundary_budget := 50000
	while _jumping_to_next_choice and boundary_budget > 0:
		boundary_budget -= 1
		match _runtime.pause_reason():
			KrkrScenarioRuntime.PauseReason.DIALOGUE:
				_runtime.advance()
			KrkrScenarioRuntime.PauseReason.TIMER:
				_runtime.finish_timer_wait_for_navigation()
			KrkrScenarioRuntime.PauseReason.EXTERNAL:
				_finish_external_for_choice_jump(_runtime.external_wait_reason())
			KrkrScenarioRuntime.PauseReason.CHOICE:
				return
			KrkrScenarioRuntime.PauseReason.FINISHED:
				_abort_choice_jump()
				return
			_:
				_abort_choice_jump()
				return
	if _jumping_to_next_choice:
		_schedule_choice_jump_continue()


func _finish_external_for_choice_jump(wait_reason: StringName) -> void:
	var pause_before := _runtime.pause_reason()
	_on_external_skip_requested(wait_reason)
	if _runtime.pause_reason() == pause_before and _runtime.is_waiting_external(wait_reason):
		_runtime.resume_external(wait_reason)


func _cancel_choice_jump() -> void:
	_jumping_to_next_choice = false
	_choice_jump_continue_scheduled = false
	_choice_jump_rollback.clear()
	_clear_choice_jump_audio_targets()
	_choice_jump_stage_instructions.clear()
	_restore_choice_jump_screen_effects()
	_refresh_choice_navigation_buttons()


func _abort_choice_jump() -> void:
	if not _jumping_to_next_choice:
		return
	_jumping_to_next_choice = false
	_choice_jump_continue_scheduled = false
	if _choice_jump_rollback.is_empty():
		_clear_choice_jump_audio_targets()
		_choice_jump_stage_instructions.clear()
		_restore_choice_jump_screen_effects()
		return
	_restore_choice_jump_rollback.call_deferred()


func _restore_choice_jump_rollback() -> void:
	if _choice_jump_rollback.is_empty():
		_clear_choice_jump_audio_targets()
		_choice_jump_stage_instructions.clear()
		_restore_choice_jump_screen_effects()
		return
	var rollback := _choice_jump_rollback.duplicate(true)
	_choice_jump_rollback.clear()
	var runtime_checkpoint: Variant = rollback.get("runtime", {})
	var presentation: Variant = rollback.get("presentation", {})
	if not runtime_checkpoint is Dictionary or not presentation is Dictionary:
		_clear_choice_jump_audio_targets()
		_choice_jump_stage_instructions.clear()
		_restore_choice_jump_screen_effects()
		return
	_clear_choice_jump_audio_targets()
	_choice_jump_stage_instructions.clear()
	_stage_director.clear()
	_restore_presentation(presentation)
	_restoring_navigation_checkpoint = true
	if not _runtime.restore_navigation_checkpoint(runtime_checkpoint):
		_restoring_navigation_checkpoint = false
	_restore_choice_jump_screen_effects()
	_status.text = "后续没有可跳转的选项"
	_status.visible = true


func _finish_choice_jump_transition() -> void:
	_restore_choice_jump_screen_effects()


func _restore_choice_jump_screen_effects() -> void:
	if not _choice_jump_screen_effects_overridden:
		return
	_choice_jump_screen_effects_overridden = false
	_stage_director.set_screen_effects_enabled(bool(_runtime_settings.get("screen_effect", true)))


func _capture_choice_jump_audio_targets() -> void:
	var bgm_volume := 1.0
	var bgm_paused := false
	if is_instance_valid(_active_bgm_player):
		bgm_volume = db_to_linear(_active_bgm_player.volume_db)
		bgm_paused = _active_bgm_player.stream_paused
	_choice_jump_bgm_target = {
		"changed": false,
		"file": _bgm_asset,
		"position": _bgm_pause_position,
		"volume": bgm_volume,
		"paused": bgm_paused,
	}
	_choice_jump_environment_target = {
		"changed": false,
		"file": _environment_asset,
		"volume": db_to_linear(_env_player.volume_db),
	}


## Navigation scanning must never dispatch audible transient commands. Persistent
## channels are reduced to a final target and applied exactly once at StartSelect.
func _buffer_choice_jump_presentation(instruction: KrkrScenarioInstruction) -> bool:
	if _stage_director.handles(instruction.tag_name):
		_choice_jump_stage_instructions.append(instruction)
		return true
	match instruction.tag_name:
		&"blackout", &"whiteout":
			_choice_jump_stage_instructions.append(instruction)
			return true
		&"playbgm":
			_choice_jump_bgm_target = {
				"changed": true,
				"file": instruction.string_argument("file"),
				"position": instruction.float_argument("pos", 0.0) / 1000.0,
				"volume": instruction.float_argument("vol", 100.0) / 100.0,
				"paused": false,
			}
			return true
		&"stopbgm":
			_choice_jump_bgm_target["changed"] = true
			_choice_jump_bgm_target["file"] = ""
			_choice_jump_bgm_target["position"] = 0.0
			_choice_jump_bgm_target["paused"] = false
			return true
		&"pausebgm":
			_choice_jump_bgm_target["changed"] = true
			_choice_jump_bgm_target["paused"] = true
			return true
		&"restartbgm":
			_choice_jump_bgm_target["changed"] = true
			_choice_jump_bgm_target["paused"] = false
			return true
		&"playenvse":
			_choice_jump_environment_target = {
				"changed": true,
				"file": instruction.string_argument("file"),
				"volume": instruction.float_argument("vol", 100.0) / 100.0,
			}
			return true
		&"stopenvse":
			var requested_id := instruction.string_argument("id")
			var target_file := str(_choice_jump_environment_target.get("file", ""))
			if requested_id.is_empty() or requested_id.to_lower() == target_file.to_lower():
				_choice_jump_environment_target["changed"] = true
				_choice_jump_environment_target["file"] = ""
			return true
		&"playse", &"stopse", &"waitse", &"waitenvse", &"waitbgm", &"waitvoice", &"hitwait":
			return true
		&"playmovie", &"staffroll", &"eyecatch":
			# These are transient boundaries, not part of the reconstructed target frame.
			# In particular, never start a movie player just to skip it immediately.
			return true
		&"flash", &"hide", &"show", &"waitupdate", &"waitaction", &"waitcamera":
			return true
	return false


func _choice_jump_stage_boundary() -> KrkrScenarioInstruction:
	var no_flags: Array[StringName] = []
	return KrkrScenarioInstruction.tag(&"update", {}, no_flags, 0, "")


func _apply_choice_jump_audio_targets() -> void:
	if bool(_choice_jump_bgm_target.get("changed", false)):
		var bgm_file := str(_choice_jump_bgm_target.get("file", ""))
		if bgm_file.is_empty():
			_stop_bgm(0)
		elif (
			_bgm_asset.to_lower() != bgm_file.to_lower()
			or not is_instance_valid(_active_bgm_player)
			or _active_bgm_player.stream == null
			or not _active_bgm_player.playing
		):
			_play_bgm(
				bgm_file,
				0,
				float(_choice_jump_bgm_target.get("volume", 1.0)),
				maxf(float(_choice_jump_bgm_target.get("position", 0.0)), 0.0)
			)
		elif is_instance_valid(_active_bgm_player):
			_active_bgm_player.volume_db = linear_to_db(
				maxf(float(_choice_jump_bgm_target.get("volume", 1.0)), 0.0001)
			)
		if is_instance_valid(_active_bgm_player) and not bgm_file.is_empty():
			_active_bgm_player.stream_paused = bool(_choice_jump_bgm_target.get("paused", false))

	if bool(_choice_jump_environment_target.get("changed", false)):
		var environment_file := str(_choice_jump_environment_target.get("file", ""))
		if environment_file.is_empty():
			_environment_asset = ""
			_stop_audio_immediate(_env_player)
		elif _environment_asset.to_lower() != environment_file.to_lower() or not _env_player.playing:
			_stop_audio_immediate(_env_player)
			_play_environment(
				environment_file,
				0,
				float(_choice_jump_environment_target.get("volume", 1.0))
			)
		else:
			_env_player.volume_db = linear_to_db(
				maxf(float(_choice_jump_environment_target.get("volume", 1.0)), 0.0001)
			)
	_clear_choice_jump_audio_targets()


func _clear_choice_jump_audio_targets() -> void:
	_choice_jump_bgm_target.clear()
	_choice_jump_environment_target.clear()


func _on_instruction_executed(instruction: KrkrScenarioInstruction) -> void:
	if _jumping_to_next_choice and _buffer_choice_jump_presentation(instruction):
		return
	if _stage_director.execute(instruction):
		return
	match instruction.tag_name:
		&"playbgm":
			_play_bgm(
				instruction.string_argument("file"),
				instruction.int_argument("fade", 1000),
				instruction.float_argument("vol", 100.0) / 100.0,
				instruction.float_argument("pos", 0.0) / 1000.0
			)
		&"stopbgm":
			_stop_bgm(instruction.int_argument("fade", 3000))
		&"pausebgm":
			if is_instance_valid(_active_bgm_player):
				_bgm_pause_position = _active_bgm_player.get_playback_position()
				_active_bgm_player.stream_paused = true
		&"restartbgm":
			if is_instance_valid(_active_bgm_player):
				_active_bgm_player.stream_paused = false
				if not _active_bgm_player.playing and _active_bgm_player.stream != null:
					_active_bgm_player.play(_bgm_pause_position)
		&"playse":
			_play_sound_effect(instruction)
		&"stopse":
			_stop_audio_with_fade(_se_player, instruction.int_argument("fade", 1000), &"se")
		&"playenvse":
			_play_environment(
				instruction.string_argument("file"),
				instruction.int_argument("fade", 2000),
				instruction.float_argument("vol", 100.0) / 100.0
			)
		&"stopenvse":
			_stop_environment(instruction)
		&"blackout":
			_start_color_out(instruction, Color.BLACK, "BLACK")
		&"whiteout":
			_start_color_out(instruction, Color.WHITE, "WHITE")
		&"flash":
			_start_flash(instruction)
		&"hide":
			_set_message_visible(false, instruction)
		&"show":
			_set_message_visible(true, instruction)
		&"messageframe":
			_apply_message_frame(instruction.string_argument("type"))
		&"movewindow":
			_message_panel.position = Vector2(
				instruction.float_argument("x"), instruction.float_argument("y")
			)
		&"font":
			_pending_font_size = instruction.int_argument("face", instruction.int_argument("size", 0))
		&"waitupdate":
			_wait_for_transition(instruction)
		&"waitaction":
			_wait_for_action(instruction)
		&"waitcamera":
			_wait_for_camera(instruction)
		&"waitse":
			_wait_for_audio(&"se", _se_player)
		&"waitenvse":
			_wait_for_audio(&"envse", _env_player)
		&"waitbgm":
			if _is_bgm_playing():
				_runtime.suspend_external(&"bgm", true)
		&"waitvoice", &"hitwait":
			if _is_voice_playing():
				_runtime.suspend_external(&"voice", true)
		&"eyecatch":
			_start_eye_catch(instruction)
		&"playmovie":
			_play_movie(instruction.string_argument("file"))
		&"staffroll":
			_play_staff_roll(instruction.string_argument("id"))


func _resolver() -> AdvAssetResolver:
	return _stage_director.asset_resolver()


func _play_voice(resource_id: String) -> void:
	_stop_voice()
	if resource_id.is_empty():
		return
	var voice_ids := resource_id.split("/", false)
	for index in mini(voice_ids.size(), _voice_players.size()):
		var voice_id := voice_ids[index].strip_edges()
		var stream := _resolver().stream_for_voice(voice_id)
		if stream == null:
			_report_missing("语音", voice_id)
			continue
		var player := _voice_players[index]
		player.volume_db = linear_to_db(_voice_detail_volume(voice_id))
		_play_audio(player, stream)


func _stop_voice() -> void:
	for player in _voice_players:
		player.stop()


func _is_voice_playing() -> bool:
	for player in _voice_players:
		if player.playing:
			return true
	return false


func _play_bgm(
	resource_id: String,
	fade_milliseconds: int = 1000,
	volume: float = 1.0,
	position_seconds: float = 0.0
) -> void:
	var source := _resolver().stream_for_bgm(resource_id)
	if source == null:
		_report_missing("音乐", resource_id)
		return
	if (
		_bgm_asset.to_lower() == resource_id.to_lower()
		and is_instance_valid(_active_bgm_player)
		and _active_bgm_player.playing
	):
		return
	_bgm_asset = resource_id
	var stream := source.duplicate() as AudioStream
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	var previous_player := _active_bgm_player if is_instance_valid(_active_bgm_player) else null
	var next_player := _next_bgm_player(previous_player)
	_stop_audio_immediate(next_player)
	next_player.stream = stream
	var target_volume_db := linear_to_db(maxf(volume, 0.0001))
	var fade := maxi(fade_milliseconds, 0)
	next_player.volume_db = -80.0 if fade > 0 else target_volume_db
	next_player.play(maxf(position_seconds, 0.0))
	_active_bgm_player = next_player
	_bgm_pause_position = maxf(position_seconds, 0.0)
	if previous_player != null and previous_player != next_player and previous_player.playing:
		_fade_audio(previous_player, -80.0, fade, true, &"bgm")
	_fade_audio(next_player, target_volume_db, fade, false)


func _stop_bgm(fade_milliseconds: int = 0) -> void:
	for player in _bgm_players:
		if player.playing or player.stream != null:
			_stop_audio_with_fade(player, fade_milliseconds, &"bgm")
	_bgm_pause_position = 0.0
	_bgm_asset = ""


func _play_sound_effect(instruction: KrkrScenarioInstruction) -> void:
	var resource_id := instruction.string_argument("file")
	var stream := _resolver().stream_for_effect(resource_id)
	if stream == null:
		_report_missing("音效", resource_id)
		return
	_kill_audio_fade(_se_player)
	_se_player.volume_db = linear_to_db(maxf(instruction.float_argument("vol", 100.0) / 100.0, 0.0001))
	_play_audio(_se_player, stream)


func _play_environment(resource_id: String, fade_milliseconds: int = 2000, volume: float = 1.0) -> void:
	var source := _resolver().stream_for_effect(resource_id)
	if source == null:
		_report_missing("环境音", resource_id)
		return
	_kill_audio_fade(_env_player)
	_environment_asset = resource_id
	var stream := source.duplicate() as AudioStream
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	var target_volume_db := linear_to_db(maxf(volume, 0.0001))
	var fade := maxi(fade_milliseconds, 0)
	_env_player.volume_db = -80.0 if fade > 0 else target_volume_db
	_play_audio(_env_player, stream)
	_fade_audio(_env_player, target_volume_db, fade, false)


func _stop_environment(instruction: KrkrScenarioInstruction) -> void:
	var requested_id := instruction.string_argument("id")
	if not requested_id.is_empty() and requested_id.to_lower() != _environment_asset.to_lower():
		return
	_environment_asset = ""
	_stop_audio_with_fade(_env_player, instruction.int_argument("fade", 3000), &"envse")


func _play_audio(player: AudioStreamPlayer, stream: AudioStream) -> void:
	if stream == null:
		return
	player.stream = stream
	player.play()


func _next_bgm_player(previous_player: AudioStreamPlayer) -> AudioStreamPlayer:
	for player in _bgm_players:
		if player != previous_player:
			return player
	return _bgm_players[0]


func _is_bgm_playing() -> bool:
	for player in _bgm_players:
		if player.playing:
			return true
	return false


func _fade_audio(
	player: AudioStreamPlayer,
	target_volume_db: float,
	milliseconds: int,
	stop_after: bool,
	wait_reason: StringName = &""
) -> void:
	_kill_audio_fade(player)
	if milliseconds <= 0:
		player.volume_db = target_volume_db
		if stop_after:
			_stop_audio_immediate(player)
			_resume_audio_wait_if_finished(wait_reason)
		return
	var tween := create_tween()
	_audio_fade_tweens[player] = tween
	tween.tween_property(player, "volume_db", target_volume_db, float(milliseconds) / 1000.0)
	tween.finished.connect(
		func() -> void:
			if _audio_fade_tweens.get(player) == tween:
				_audio_fade_tweens.erase(player)
			if stop_after:
				_stop_audio_immediate(player)
				_resume_audio_wait_if_finished(wait_reason)
	)


func _stop_audio_with_fade(
	player: AudioStreamPlayer,
	fade_milliseconds: int,
	wait_reason: StringName
) -> void:
	if not player.playing and player.stream == null:
		_resume_audio_wait_if_finished(wait_reason)
		return
	_fade_audio(player, -80.0, maxi(fade_milliseconds, 0), true, wait_reason)


func _stop_audio_immediate(player: AudioStreamPlayer) -> void:
	_kill_audio_fade(player)
	player.stop()
	player.stream_paused = false
	player.stream = null
	player.volume_db = 0.0


func _fade_out_route_audio(fade_milliseconds: int) -> void:
	for player in _bgm_players:
		_stop_audio_with_fade(player, fade_milliseconds, &"")
	for player in _voice_players:
		_stop_audio_with_fade(player, fade_milliseconds, &"")
	_stop_audio_with_fade(_se_player, fade_milliseconds, &"")
	_stop_audio_with_fade(_env_player, fade_milliseconds, &"")
	_bgm_pause_position = 0.0
	_bgm_asset = ""
	_environment_asset = ""


func _kill_audio_fade(player: AudioStreamPlayer) -> void:
	var tween := _audio_fade_tweens.get(player) as Tween
	if tween != null and tween.is_valid():
		tween.kill()
	_audio_fade_tweens.erase(player)


func _resume_audio_wait_if_finished(wait_reason: StringName) -> void:
	if wait_reason.is_empty():
		return
	match wait_reason:
		&"bgm":
			if _is_bgm_playing():
				return
		&"se":
			if _se_player.playing:
				return
		&"envse":
			if _env_player.playing:
				return
	_resume_audio_wait(wait_reason)


func _on_bgm_finished() -> void:
	_resume_audio_wait_if_finished(&"bgm")


func _start_color_out(instruction: KrkrScenarioInstruction, color: Color, background_id: String) -> void:
	_kill_effect_tween()
	_runtime.suspend_external(&"flash", not instruction.has_flag("hitcancel"))
	_screen_tint.color = color
	_screen_tint.modulate.a = 0.0
	var duration := maxf(float(instruction.int_argument("time", 1000)) / 1000.0, 0.001)
	_effect_finish_action = func() -> void:
		var flags: Array[StringName] = []
		var cg := KrkrScenarioInstruction.tag(&"cg", {"file": background_id}, flags, 0, "")
		_stage_director.execute(cg)
		_stage_director.commit_pending(null, true)
	_effect_tween = create_tween()
	_effect_tween.tween_property(_screen_tint, "modulate:a", 1.0, duration)
	_effect_tween.finished.connect(_complete_effect)


func _start_flash(instruction: KrkrScenarioInstruction) -> void:
	_kill_effect_tween()
	_runtime.suspend_external(&"flash", not instruction.has_flag("hitcancel"))
	var color := Color.WHITE
	match instruction.string_argument("color", "WHITE").to_upper():
		"RED": color = Color(1.0, 0.08, 0.05)
		"BLUE": color = Color(0.08, 0.3, 1.0)
	_screen_tint.color = color
	_screen_tint.modulate.a = 1.0
	_effect_finish_action = Callable()
	var duration := maxf(float(instruction.int_argument("leave", 500)) / 1000.0, 0.001)
	_effect_tween = create_tween()
	_effect_tween.tween_property(_screen_tint, "modulate:a", 0.0, duration)
	_effect_tween.finished.connect(_complete_effect)


func _complete_effect() -> void:
	if _effect_tween != null and _effect_tween.is_valid():
		_effect_tween.kill()
	_effect_tween = null
	if _effect_finish_action.is_valid():
		_effect_finish_action.call()
	_effect_finish_action = Callable()
	_screen_tint.modulate.a = 0.0
	_runtime.resume_external(&"flash")


func _kill_effect_tween() -> void:
	if _effect_tween != null and _effect_tween.is_valid():
		_effect_tween.kill()
	_effect_tween = null
	_effect_finish_action = Callable()


func _wait_for_transition(instruction: KrkrScenarioInstruction) -> void:
	if _stage_director.is_transitioning():
		_runtime.suspend_external(&"transition", not instruction.has_flag("hitcancel"))


func _wait_for_action(instruction: KrkrScenarioInstruction) -> void:
	var target_id := instruction.string_argument("id")
	if target_id.is_empty() or not _stage_director.is_action_running(target_id):
		return
	# The source engine deliberately ignores WaitAction for count=-1 loops:
	# they have no natural completion and must remain stoppable by later tags.
	if _stage_director.is_action_looping(target_id):
		return
	_waiting_action_target = target_id
	_runtime.suspend_external(&"action", not instruction.has_flag("hitcancel"))


func _wait_for_camera(instruction: KrkrScenarioInstruction) -> void:
	if _stage_director.is_camera_moving():
		_runtime.suspend_external(&"camera", not instruction.has_flag("hitcancel"))


func _wait_for_audio(wait_reason: StringName, player: AudioStreamPlayer) -> void:
	if player.playing:
		_runtime.suspend_external(wait_reason, true)


func _on_transition_finished() -> void:
	_runtime.resume_external(&"transition")
	_try_schedule_auto_advance()


func _on_action_finished(_target_id: String) -> void:
	if _runtime.is_waiting_external(&"action") and not _stage_director.is_action_running(_waiting_action_target):
		_waiting_action_target = ""
		_runtime.resume_external(&"action")


func _on_camera_finished() -> void:
	_runtime.resume_external(&"camera")
	_try_schedule_auto_advance()


func _on_external_skip_requested(wait_reason: StringName) -> void:
	match wait_reason:
		&"transition":
			_stage_director.finish_transition()
		&"action":
			_stage_director.stop_action(_waiting_action_target)
		&"camera":
			_stage_director.finish_camera_move()
		&"flash":
			_complete_effect()
		&"message":
			_finish_message_visibility()
		&"se":
			_stop_audio_immediate(_se_player)
			_runtime.resume_external(&"se")
		&"envse":
			_stop_audio_immediate(_env_player)
			_environment_asset = ""
			_runtime.resume_external(&"envse")
		&"bgm":
			_stop_bgm(0)
			_runtime.resume_external(&"bgm")
		&"voice":
			_stop_voice()
			_runtime.resume_external(&"voice")
		&"eyecatch":
			_finish_eye_catch()
		&"movie":
			_finish_movie()


func _resume_audio_wait(wait_reason: StringName) -> void:
	_runtime.resume_external(wait_reason)
	_try_schedule_auto_advance()


func _on_voice_finished() -> void:
	if not _is_voice_playing():
		_resume_audio_wait(&"voice")


func _try_schedule_auto_advance() -> void:
	if not _auto_enabled or not _runtime.is_waiting_for_dialogue():
		return
	if _message_label.visible_characters >= 0:
		return
	if _is_voice_playing() or _stage_director.is_transitioning() or _stage_director.is_camera_moving():
		return
	_schedule_advance(_auto_wait_seconds)


func _set_message_visible(show_message: bool, instruction: KrkrScenarioInstruction = null) -> void:
	if _message_visibility_tween != null and _message_visibility_tween.is_valid():
		_message_visibility_tween.kill()
	_message_visibility_tween = null
	_message_panel.visible = true
	_system_menu.visible = true
	if show_message:
		_show_system_menu(true)
	else:
		_system_menu_auto_hide_timer.stop()
		_system_menu_recall_button.visible = false
	var target_alpha := 1.0 if show_message else 0.0
	# Next-choice navigation executes presentation commands without exposing their
	# intermediate frames. Commit the final visibility immediately so no tween can
	# outlive the jump and mutate the scene after StartSelect has been reached.
	if _jumping_to_next_choice:
		_message_panel.modulate.a = target_alpha
		_system_menu.modulate.a = target_alpha
		_message_panel.visible = show_message
		_system_menu.visible = show_message
		if show_message:
			_show_system_menu(true)
		else:
			_suspend_system_menu()
		return
	_message_visibility_tween = create_tween().set_parallel()
	_message_visibility_tween.tween_property(_message_panel, "modulate:a", target_alpha, 0.3)
	_message_visibility_tween.tween_property(_system_menu, "modulate:a", target_alpha, 0.3)
	_message_visibility_tween.finished.connect(
		func() -> void:
			_message_visibility_tween = null
			_message_panel.visible = show_message
			_system_menu.visible = show_message
			if show_message:
				_show_system_menu(true)
			else:
				_suspend_system_menu()
			_runtime.resume_external(&"message")
	)
	if instruction != null and instruction.has_flag("wait"):
		_runtime.suspend_external(&"message", false)


func _finish_message_visibility() -> void:
	if _message_visibility_tween != null and _message_visibility_tween.is_valid():
		_message_visibility_tween.custom_step(1.0)
	_message_visibility_tween = null
	_runtime.resume_external(&"message")


func _apply_message_frame(frame_type: String) -> void:
	_message_frame_type = "0" if frame_type.is_empty() else frame_type
	if frame_type == "10" or frame_type == "ノベル":
		_message_panel.position = Vector2.ZERO
		_message_panel.size = Vector2(1920.0, 1080.0)
	else:
		_message_panel.position = Vector2(0.0, 760.0)
		_message_panel.size = Vector2(1920.0, 320.0)


func _start_eye_catch(instruction: KrkrScenarioInstruction) -> void:
	if instruction.int_argument("bgmstop", 1) != 0:
		_stop_bgm(1000)
	_stop_audio_immediate(_se_player)
	_environment_asset = ""
	_stop_audio_with_fade(_env_player, 1000, &"")
	_stop_voice()
	if _skip_enabled:
		return
	_eye_catch_is_date = instruction.string_argument("type").to_upper() == "DATE"
	_eye_catch_stage_committed = false
	_message_panel.visible = false
	_suspend_system_menu()
	_reset_eye_catch_visuals()
	_eye_catch_overlay.visible = true
	_runtime.suspend_external(&"eyecatch", true)
	_eye_catch_tween = create_tween()
	if _eye_catch_is_date:
		_build_date_eye_catch_tween(_eye_catch_tween)
	else:
		_build_time_eye_catch_tween(_eye_catch_tween)
	_eye_catch_tween.finished.connect(_finish_eye_catch)


func _build_time_eye_catch_tween(tween: Tween) -> void:
	_eye_catch_top_band.visible = true
	_eye_catch_bottom_band.visible = true
	tween.tween_method(_set_eye_catch_band_progress, 0.0, 1.0, 1.0)
	tween.tween_interval(0.5)
	_eye_catch_logo.visible = true
	tween.tween_property(_eye_catch_logo, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.5)
	tween.tween_callback(_commit_eye_catch_stage.bind(false))
	tween.tween_interval(2.0)
	tween.tween_method(_set_eye_catch_band_progress, 1.0, 0.0, 1.0)
	tween.parallel().tween_property(_eye_catch_logo, "modulate:a", 0.0, 1.0)


func _build_date_eye_catch_tween(tween: Tween) -> void:
	_eye_catch_date_black.visible = true
	tween.tween_property(_eye_catch_date_black, "modulate:a", 1.0, 3.0)
	tween.tween_interval(0.5)
	_eye_catch_logo.visible = true
	tween.tween_property(_eye_catch_logo, "modulate:a", 1.0, 1.0)
	tween.tween_interval(0.5)
	tween.tween_callback(_commit_eye_catch_stage.bind(false))
	tween.tween_interval(2.0)
	tween.tween_property(_eye_catch_date_black, "modulate:a", 0.0, 3.0)
	tween.parallel().tween_property(_eye_catch_logo, "modulate:a", 0.0, 3.0)


func _set_eye_catch_band_progress(progress: float) -> void:
	_eye_catch_top_band.size.x = 1920.0 * progress
	_eye_catch_bottom_band.position.x = 1920.0 * (1.0 - progress)
	_eye_catch_bottom_band.size.x = 1920.0 * progress


func _commit_eye_catch_stage(instant: bool) -> void:
	if _eye_catch_stage_committed:
		return
	_eye_catch_stage_committed = true
	var flags: Array[StringName] = []
	if _eye_catch_is_date:
		_stage_director.execute(KrkrScenarioInstruction.tag(
			&"cg", {"file": "BLACK"}, flags, 0, ""
		))
	var update_instruction := KrkrScenarioInstruction.tag(
		&"update",
		{"time": 0 if instant or _eye_catch_is_date else 1000},
		flags,
		0,
		""
	)
	_stage_director.commit_pending(update_instruction, instant or _eye_catch_is_date)


func _reset_eye_catch_visuals() -> void:
	_eye_catch_overlay.modulate = Color.WHITE
	_eye_catch_date_black.visible = false
	_eye_catch_date_black.modulate.a = 0.0
	_eye_catch_top_band.visible = false
	_eye_catch_top_band.position = Vector2.ZERO
	_eye_catch_top_band.size = Vector2(0.0, 120.0)
	_eye_catch_bottom_band.visible = false
	_eye_catch_bottom_band.position = Vector2(1920.0, 960.0)
	_eye_catch_bottom_band.size = Vector2(0.0, 120.0)
	_eye_catch_logo.visible = false
	_eye_catch_logo.modulate.a = 0.0


func _finish_eye_catch() -> void:
	if _eye_catch_tween != null and _eye_catch_tween.is_valid():
		_eye_catch_tween.kill()
	_eye_catch_tween = null
	_commit_eye_catch_stage(true)
	if _stage_director.is_transitioning():
		_stage_director.finish_transition()
	_eye_catch_overlay.visible = false
	_reset_eye_catch_visuals()
	_runtime.resume_external(&"eyecatch")


func _play_movie(resource_id: String) -> void:
	var path := _resolver().path_for_video(resource_id)
	if path.is_empty():
		_report_missing("视频", resource_id)
		_runtime.resume_external(&"movie")
		return
	var stream := ResourceLoader.load(path, "VideoStream") as VideoStream
	if stream == null:
		_report_missing("视频", resource_id)
		_runtime.resume_external(&"movie")
		return
	_movie_player.stream = stream
	_movie_layer.visible = true
	_movie_player.play()


func _play_staff_roll(route_id: String) -> void:
	var video_ids := {
		"穹": "staff_roll_sora",
		"奈緒": "staff_roll_nao",
		"奈绪": "staff_roll_nao",
		"瑛": "staff_roll_akira",
		"一葉": "staff_roll_kazuha",
		"一叶": "staff_roll_kazuha",
		"初佳": "staff_roll_motoka",
	}
	var video_id := str(video_ids.get(route_id, ""))
	if video_id.is_empty():
		_report_missing("片尾", route_id)
		_runtime.resume_external(&"movie")
		return
	_play_movie(video_id)


func _finish_movie() -> void:
	if not _movie_layer.visible:
		return
	_movie_player.stop()
	_movie_layer.visible = false
	_runtime.resume_external(&"movie")


func _append_history(speaker: String, message: String) -> void:
	var entry := message if speaker.is_empty() or speaker == "心の声" else "%s\n%s" % [speaker, message]
	_history_entries.append(entry)
	if _history_entries.size() > 200:
		_history_entries.pop_front()
	_history_text.text = "\n\n".join(_history_entries)


func _open_history() -> void:
	if _history_overlay.visible:
		return
	_enter_player_chrome_overlay()
	_history_overlay.visible = true
	_history_text.scroll_to_line(maxi(_history_text.get_line_count() - 1, 0))
	_history_close.grab_focus()


func _close_history() -> void:
	if not _history_overlay.visible:
		return
	_history_overlay.visible = false
	_leave_player_chrome_overlay()
	_history_button.grab_focus()


func _open_save_load(mode: SaveLoadPage.Mode) -> void:
	if is_instance_valid(_active_save_load):
		return
	_enter_player_chrome_overlay()
	var payload := _build_save_snapshot()
	_active_save_load = SAVE_LOAD_PAGE_SCENE.instantiate() as SaveLoadPage
	_active_save_load.name = "InGameSaveLoadPage"
	_active_save_load.configure(mode, _save_service, payload)
	_active_save_load.back_requested.connect(_close_save_load)
	_active_save_load.load_requested.connect(_load_from_save_page)
	_active_save_load.save_completed.connect(func(_slot: int) -> void: _close_save_load())
	_feature_host.add_child(_active_save_load)
	_feature_overlay.visible = true


func _quick_save() -> void:
	_write_autosave()


func _quick_load() -> void:
	var data := _save_service.load_autosave()
	if data == null:
		_status.text = "没有可读取的快速存档"
		_status.visible = true
		return
	_load_from_save_page(data, _save_service.autosave_path())


func _close_save_load() -> void:
	if not _feature_overlay.visible and not is_instance_valid(_active_save_load):
		return
	_feature_overlay.visible = false
	if is_instance_valid(_active_save_load):
		_feature_host.remove_child(_active_save_load)
		_active_save_load.queue_free()
	_active_save_load = null
	_leave_player_chrome_overlay()


func _hide_player_chrome_manually() -> void:
	if _player_chrome_overlay_depth > 0 or not _message_panel.visible:
		return
	if _message_visibility_tween != null and _message_visibility_tween.is_valid():
		_finish_message_visibility()
	_stop_player_chrome_automation()
	_player_chrome_manually_hidden = true
	_set_player_chrome_visible(false, PLAYER_CHROME_TRANSITION_SECONDS)


func _show_player_chrome_manually() -> void:
	if not _player_chrome_manually_hidden:
		return
	_player_chrome_manually_hidden = false
	_set_player_chrome_visible(true, PLAYER_CHROME_TRANSITION_SECONDS)


func _enter_player_chrome_overlay() -> void:
	# Do not preserve a partial opening fade as the dialogue's return opacity,
	# or let its completion callback reveal chrome behind an active overlay.
	if _message_visibility_tween != null and _message_visibility_tween.is_valid():
		_finish_message_visibility()
	_stop_player_chrome_automation()
	if _player_chrome_overlay_depth == 0:
		_restore_player_chrome_after_overlay = (
			_message_panel.visible
			and _message_panel.modulate.a > 0.0
			and not _player_chrome_manually_hidden
		)
		if _restore_player_chrome_after_overlay:
			_set_player_chrome_visible(false, 0.0)
	_player_chrome_overlay_depth += 1


func _leave_player_chrome_overlay() -> void:
	if _player_chrome_overlay_depth <= 0:
		return
	_player_chrome_overlay_depth -= 1
	if _player_chrome_overlay_depth > 0:
		return
	var should_restore := _restore_player_chrome_after_overlay
	_restore_player_chrome_after_overlay = false
	if should_restore:
		_set_player_chrome_visible(true, 0.0)


func _stop_player_chrome_automation() -> void:
	_set_auto_enabled(false)
	_auto_button.set_pressed_no_signal(false)
	_set_skip_enabled(false)
	_skip_button.set_pressed_no_signal(false)


func _set_player_chrome_visible(show_chrome: bool, duration: float) -> void:
	_kill_tween(_player_chrome_tween)
	_player_chrome_tween = null
	_system_menu_auto_hide_timer.stop()
	_system_menu_recall_button.visible = false
	_kill_tween(_system_menu_slide_tween)
	_system_menu_slide_tween = null

	if show_chrome:
		_message_panel.visible = true
		_system_menu.visible = true
		_message_panel.position = _message_panel_rest_position
		_system_menu.position = _system_menu_rest_position
		_message_panel.modulate = _message_panel_rest_modulate
		_system_menu.modulate = _system_menu_rest_modulate
		if duration > 0.0:
			_message_panel.position.y += PLAYER_CHROME_HIDE_OFFSET_Y
			_system_menu.position.y += PLAYER_CHROME_HIDE_OFFSET_Y
			_message_panel.modulate.a = 0.0
			_system_menu.modulate.a = 0.0
	else:
		_message_panel_rest_position = _message_panel.position
		_system_menu_rest_position = Vector2(SYSTEM_MENU_SHOWN_X, _system_menu.position.y)
		_message_panel_rest_modulate = _message_panel.modulate
		_system_menu_rest_modulate = _system_menu.modulate

	if duration <= 0.0:
		_finish_player_chrome_visibility(show_chrome)
		return

	var tween := create_tween().set_parallel()
	_player_chrome_tween = tween
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT if show_chrome else Tween.EASE_IN
	)
	var message_target := _message_panel_rest_position
	var menu_target := _system_menu_rest_position
	var message_alpha := _message_panel_rest_modulate.a
	var menu_alpha := _system_menu_rest_modulate.a
	if not show_chrome:
		message_target.y += PLAYER_CHROME_HIDE_OFFSET_Y
		menu_target.x = _system_menu.position.x
		menu_target.y += PLAYER_CHROME_HIDE_OFFSET_Y
		message_alpha = 0.0
		menu_alpha = 0.0
	tween.tween_property(_message_panel, "position", message_target, duration)
	tween.tween_property(_system_menu, "position", menu_target, duration)
	tween.tween_property(_message_panel, "modulate:a", message_alpha, duration)
	tween.tween_property(_system_menu, "modulate:a", menu_alpha, duration)
	tween.finished.connect(
		func() -> void:
			if _player_chrome_tween != tween:
				return
			_player_chrome_tween = null
			_finish_player_chrome_visibility(show_chrome)
	)


func _finish_player_chrome_visibility(show_chrome: bool) -> void:
	_message_panel.position = _message_panel_rest_position
	_system_menu.position = _system_menu_rest_position
	_message_panel.modulate = _message_panel_rest_modulate
	_system_menu.modulate = _system_menu_rest_modulate
	_message_panel.visible = show_chrome
	_system_menu.visible = show_chrome
	if show_chrome:
		_show_system_menu(true)
	else:
		_system_menu_recall_button.visible = false


func _load_from_save_page(data: SaveData, _path: String) -> void:
	_close_save_load()
	_launch_request = ScenarioLaunchRequest.from_save(data)
	_cancel_choice_jump()
	_choice_checkpoints.clear()
	_choice_history_position = 0
	_kill_tween(_choice_tween)
	_choice_tween = null
	_clear_choice_buttons()
	_choice_overlay.visible = false
	_choice_overlay.modulate.a = 1.0
	_stage_director.clear()
	_history_entries.clear()
	_history_text.text = ""
	_start_request()


func _build_save_snapshot() -> SaveData:
	var data := _runtime.build_save_data(str(ProjectSettings.get_setting("application/config/version", "")))
	data.choice_navigation_stack = _persistent_choice_navigation_stack()
	data.choice_navigation_position = clampi(
		_choice_history_position, 0, data.choice_navigation_stack.size()
	)
	data.presentation = _stage_director.presentation_state()
	data.presentation["speaker"] = _current_speaker
	data.presentation["message"] = _current_message
	data.presentation["message_already_read"] = _current_message_already_read
	data.presentation["message_font_size"] = _current_message_font_size
	data.presentation["message_font_bound"] = true
	data.presentation["message_frame_type"] = _message_frame_type
	data.presentation["message_frame_position"] = [_message_panel.position.x, _message_panel.position.y]
	data.presentation["message_frame_visible"] = _message_panel.visible
	data.presentation["message_frame_alpha"] = _message_panel.modulate.a
	data.presentation["bgm"] = {
		"file": _bgm_asset,
		"position": _active_bgm_player.get_playback_position() if is_instance_valid(_active_bgm_player) and _active_bgm_player.playing else _bgm_pause_position,
		"paused": _active_bgm_player.stream_paused if is_instance_valid(_active_bgm_player) else false,
	}
	data.presentation["environment_audio"] = {
		"file": _environment_asset,
		"position": _env_player.get_playback_position() if _env_player.playing else 0.0,
	}
	data.autosave_meta["label"] = _current_message.left(42)
	return data


func _persistent_choice_navigation_stack() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for checkpoint in _choice_checkpoints:
		var persisted := checkpoint.duplicate(true)
		var runtime_checkpoint: Variant = persisted.get("runtime", {})
		if runtime_checkpoint is Dictionary:
			# Read IDs are accumulated independently and can contain thousands of
			# entries. Keeping them once in SaveData avoids multiplying save size by
			# every visited choice while preserving all read progress on restore.
			runtime_checkpoint.erase("read_text_ids")
			persisted["runtime"] = runtime_checkpoint
		result.append(persisted)
	return result


func _restore_choice_navigation(data: SaveData) -> void:
	_choice_checkpoints.clear()
	_choice_history_position = 0
	if data == null:
		return
	for saved_checkpoint in data.choice_navigation_stack:
		if _choice_checkpoints.size() >= MAX_CHOICE_CHECKPOINTS:
			break
		var runtime_checkpoint: Variant = saved_checkpoint.get("runtime", {})
		var presentation: Variant = saved_checkpoint.get("presentation", {})
		if not runtime_checkpoint is Dictionary or not presentation is Dictionary:
			continue
		if (
			str(runtime_checkpoint.get("scenario_id", "")).is_empty()
			or int(runtime_checkpoint.get("instruction_index", -1)) < 0
		):
			continue
		_choice_checkpoints.append(saved_checkpoint.duplicate(true))
	_choice_history_position = clampi(
		data.choice_navigation_position, 0, _choice_checkpoints.size()
	)


func _restore_presentation(presentation: Dictionary) -> void:
	_stage_director.restore_presentation(presentation)
	_current_speaker = str(presentation.get("speaker", ""))
	_current_message = str(presentation.get("message", ""))
	_current_message_already_read = bool(presentation.get("message_already_read", false))
	# Checkpoints written by the old scanner could contain a font leaked from an
	# unrelated skipped line. Only trust sizes explicitly marked as dialogue-bound.
	var restored_font_size := _default_message_font_size
	if bool(presentation.get("message_font_bound", false)):
		restored_font_size = int(presentation.get("message_font_size", restored_font_size))
	_current_message_font_size = (
		restored_font_size if restored_font_size > 0 else _default_message_font_size
	)
	_pending_font_size = 0
	_present_current_dialogue(true)
	_apply_message_frame(str(presentation.get("message_frame_type", "0")))
	var message_position: Variant = presentation.get("message_frame_position", [])
	if message_position is Array and message_position.size() >= 2:
		_message_panel.position = Vector2(float(message_position[0]), float(message_position[1]))
	_message_panel.visible = bool(presentation.get("message_frame_visible", true))
	_message_panel.modulate.a = float(presentation.get("message_frame_alpha", 1.0))
	_system_menu.visible = _message_panel.visible
	_system_menu.modulate.a = _message_panel.modulate.a
	if _message_panel.visible:
		_show_system_menu(true)
	else:
		_suspend_system_menu()
	_stop_bgm(0)
	var bgm: Variant = presentation.get("bgm", {})
	if bgm is Dictionary:
		var bgm_file := str(bgm.get("file", ""))
		if not bgm_file.is_empty():
			_play_bgm(bgm_file, 0, 1.0, maxf(float(bgm.get("position", 0.0)), 0.0))
			var bgm_position := maxf(float(bgm.get("position", 0.0)), 0.0)
			if bool(bgm.get("paused", false)):
				_bgm_pause_position = bgm_position
				_active_bgm_player.stream_paused = true
	_stop_audio_immediate(_env_player)
	_environment_asset = ""
	var environment_audio: Variant = presentation.get("environment_audio", {})
	if environment_audio is Dictionary:
		var environment_file := str(environment_audio.get("file", ""))
		if not environment_file.is_empty():
			_play_environment(environment_file, 0)
			var environment_position := maxf(float(environment_audio.get("position", 0.0)), 0.0)
			if environment_position > 0.0:
				_env_player.seek(environment_position)


func _write_autosave() -> void:
	if _launch_request.is_recollection():
		return
	_save_service.save_autosave(_build_save_snapshot())
	var profile := _save_service.load_profile()
	if profile == null:
		profile = ProfileData.create_empty()
	if profile.global_flags != _runtime.global_flags or profile.read_text_ids != _runtime.read_text_ids:
		profile.global_flags = _runtime.global_flags.duplicate(true)
		profile.read_text_ids = _runtime.read_text_ids.duplicate()
		_save_service.save_profile(profile)


func _set_auto_enabled(enabled: bool) -> void:
	_auto_enabled = enabled
	_auto_mode_indicator.visible = enabled
	if enabled:
		_auto_indicator_timer.start()
	else:
		_auto_indicator_timer.stop()
		_auto_indicator_frame = 0
		_set_auto_indicator_frame(0)
	if enabled and _runtime.is_waiting_for_dialogue():
		_try_schedule_auto_advance()
	elif not enabled:
		_auto_generation += 1


func _set_skip_enabled(enabled: bool) -> void:
	_skip_enabled = enabled
	if enabled and _can_skip_current_message() and _runtime.is_waiting_for_dialogue():
		_schedule_advance(0.06)


func _advance_auto_indicator() -> void:
	if not _auto_enabled:
		_auto_indicator_timer.stop()
		return
	_auto_indicator_frame = (_auto_indicator_frame + 1) % 12
	_set_auto_indicator_frame(_auto_indicator_frame)


func _set_auto_indicator_frame(frame: int) -> void:
	var atlas := _auto_mode_indicator.texture as AtlasTexture
	if atlas != null:
		atlas.region = Rect2(float(frame * 40), 0.0, 40.0, 40.0)


func _on_system_menu_lock_toggled(unlocked: bool) -> void:
	_set_system_menu_locked(not unlocked)
	if _settings_repository != null:
		_settings_repository.write_settings({"system_menu_lock": not unlocked})


func _set_system_menu_locked(locked: bool) -> void:
	_system_menu_locked = locked
	_menu_lock_button.set_pressed_no_signal(not locked)
	_menu_lock_button.tooltip_text = "解锁系统菜单" if locked else "锁定系统菜单"
	if locked:
		_show_system_menu()
	else:
		_restart_system_menu_auto_hide()


func _on_system_menu_mouse_entered() -> void:
	_system_menu_pointer_inside = true
	_system_menu_auto_hide_timer.stop()


func _on_system_menu_mouse_exited() -> void:
	_system_menu_pointer_inside = false
	_restart_system_menu_auto_hide()


func _show_system_menu(instant := false) -> void:
	_system_menu_auto_hide_timer.stop()
	_system_menu_recall_button.visible = false
	_kill_tween(_system_menu_slide_tween)
	_system_menu_slide_tween = null
	_system_menu.visible = true
	if instant or is_equal_approx(_system_menu.position.x, SYSTEM_MENU_SHOWN_X):
		_system_menu.position.x = SYSTEM_MENU_SHOWN_X
		_restart_system_menu_auto_hide()
		return
	_system_menu_slide_tween = create_tween()
	_system_menu_slide_tween.tween_property(
		_system_menu,
		"position:x",
		SYSTEM_MENU_SHOWN_X,
		SYSTEM_MENU_SLIDE_SECONDS
	)
	_system_menu_slide_tween.finished.connect(
		func() -> void:
			_system_menu_slide_tween = null
			_restart_system_menu_auto_hide()
	)


func _hide_system_menu() -> void:
	if (
		_system_menu_locked
		or _system_menu_pointer_inside
		or not _system_menu.visible
		or not _message_panel.visible
		or _choice_overlay.visible
		or _jumping_to_next_choice
	):
		return
	_kill_tween(_system_menu_slide_tween)
	_system_menu_slide_tween = create_tween()
	_system_menu_slide_tween.tween_property(
		_system_menu,
		"position:x",
		SYSTEM_MENU_HIDDEN_X,
		SYSTEM_MENU_SLIDE_SECONDS
	)
	_system_menu_slide_tween.finished.connect(
		func() -> void:
			_system_menu_slide_tween = null
			if not _system_menu_locked and _system_menu.visible:
				_system_menu_recall_button.visible = true
	)


func _restart_system_menu_auto_hide() -> void:
	_system_menu_auto_hide_timer.stop()
	if (
		_system_menu_locked
		or _system_menu_pointer_inside
		or not _system_menu.visible
		or not _message_panel.visible
		or _choice_overlay.visible
		or _jumping_to_next_choice
		or _player_chrome_manually_hidden
		or _player_chrome_overlay_depth > 0
		or (_player_chrome_tween != null and _player_chrome_tween.is_valid())
		or not is_equal_approx(_system_menu.position.x, SYSTEM_MENU_SHOWN_X)
	):
		return
	_system_menu_auto_hide_timer.start()


func _suspend_system_menu() -> void:
	_system_menu_auto_hide_timer.stop()
	_system_menu_recall_button.visible = false
	_kill_tween(_system_menu_slide_tween)
	_system_menu_slide_tween = null
	_system_menu.visible = false


func _refresh_choice_navigation_buttons() -> void:
	var previous_enabled := (
		not _choice_checkpoints.is_empty()
		and _choice_history_position > 0
		and not _launch_request.is_recollection()
		and not _jumping_to_next_choice
	)
	var next_enabled := (
		not _launch_request.is_recollection()
		and not bool(_runtime.parameters.get("select_terminated", false))
		and _runtime.is_waiting_for_dialogue()
		and not _jumping_to_next_choice
	)
	_previous_choice_button.disabled = not previous_enabled
	_previous_choice_button.modulate.a = 1.0 if previous_enabled else 0.38
	_next_choice_button.disabled = not next_enabled
	_next_choice_button.modulate.a = 1.0 if next_enabled else 0.38


func clear_read_state() -> void:
	_runtime.read_text_ids.clear()
	_current_message_already_read = false


func _can_skip_current_message() -> bool:
	return _current_message_already_read or _allow_unread_skip


func _apply_runtime_settings(settings: Dictionary) -> void:
	_runtime_settings = SettingsModel.normalize(settings)
	_message_speed_milliseconds = int(_runtime_settings.get("message_speed", 5))
	_auto_wait_seconds = float(_runtime_settings.get("auto_speed", 5000)) / 1000.0
	_allow_unread_skip = not bool(_runtime_settings.get("read_skip", true))
	_stop_voice_on_advance = bool(_runtime_settings.get("voice_stop_on_click", false))
	_preserve_skip_after_choice = bool(_runtime_settings.get("lock_skip", false))
	_preserve_auto_after_choice = bool(_runtime_settings.get("lock_auto", false))
	if not _preview_only:
		_set_system_menu_locked(bool(_runtime_settings.get("system_menu_lock", true)))
	_route_guide_enabled = bool(_runtime_settings.get("route_guide", true))
	_update_portrait(_current_speaker)
	_refresh_message_appearance()
	if is_instance_valid(_stage_director):
		_stage_director.set_screen_effects_enabled(bool(_runtime_settings.get("screen_effect", true)))


func _load_speaker_name_textures() -> void:
	_speaker_name_textures.clear()
	var file := FileAccess.open(SPEAKER_NAME_MANIFEST, FileAccess.READ)
	if file == null:
		return
	var first_row := true
	while not file.eof_reached():
		var row := file.get_csv_line()
		if first_row:
			first_row = false
			continue
		if row.size() < 2 or row[0].is_empty() or row[1].is_empty() or row[1] == "nothing.png":
			continue
		var texture_path := "%s/%s" % [SPEAKER_NAME_DIRECTORY, row[1]]
		var texture := ResourceLoader.load(texture_path, "Texture2D") as Texture2D
		if texture != null:
			_speaker_name_textures[_normalize_speaker_name(row[0])] = texture


func _update_dialogue_chrome(speaker: String) -> void:
	var normalized := _normalize_speaker_name(speaker)
	var is_monologue := normalized.is_empty() or normalized in ["心の声", "語り", "モノローグ"]
	var name_texture := _speaker_name_textures.get(normalized) as Texture2D
	_speaker_name_image.texture = name_texture
	_speaker_name_image.visible = not is_monologue and name_texture != null
	_speaker_label.text = speaker
	_speaker_label.visible = not is_monologue and name_texture == null
	_update_portrait(speaker)


func _update_portrait(speaker: String) -> void:
	if not is_instance_valid(_portrait) or not is_instance_valid(_stage_director):
		return
	var show_portrait := bool(_runtime_settings.get("portrait_visible", true))
	var texture := _stage_director.portrait_texture_for_speaker(speaker) if show_portrait else null
	_portrait.texture = texture
	_portrait.visible = texture != null


func _normalize_speaker_name(speaker: String) -> String:
	return speaker.strip_edges().replace("＆", "&")


func _voice_detail_volume(resource_id: String) -> float:
	var prefix := resource_id.strip_edges().left(2).to_upper()
	var detail_ids: Array[String] = SettingsModel.VOICE_DETAIL_IDS
	var index := detail_ids.find(prefix)
	var values: Variant = _runtime_settings.get("voice_detail_volumes", [])
	if index < 0 or not values is Array or index >= values.size():
		return 1.0
	return maxf(float(values[index]), 0.0001)


func _kill_tween(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()


func _request_title() -> void:
	if _title_confirmation.visible:
		return
	_enter_player_chrome_overlay()
	_title_confirmation.open("确定返回标题吗？\n当前进度已写入自动存档。", "返回标题", "继续游戏")


func _confirm_title() -> void:
	_title_confirmation.close()
	_leave_player_chrome_overlay()
	title_requested.emit()


func _cancel_title_confirmation() -> void:
	if not _title_confirmation.visible:
		return
	_title_confirmation.close()
	_leave_player_chrome_overlay()


func _on_runtime_error(message: String) -> void:
	if _jumping_to_next_choice and not _choice_jump_rollback.is_empty():
		_abort_choice_jump()
	_status.text = message
	_status.visible = true
	push_error(message)


func _on_playback_finished() -> void:
	if _jumping_to_next_choice and not _choice_jump_rollback.is_empty():
		_abort_choice_jump()
		return
	_write_autosave()
	_status.text = "剧本播放结束"
	_status.visible = true
	scenario_finished.emit()


func _report_missing(kind: String, resource_id: String) -> void:
	_status.text = "%s资源未导入：%s" % [kind, resource_id]
	_status.visible = true
