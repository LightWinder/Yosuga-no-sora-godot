class_name TitleScreen
extends Control


signal option_selected(option_id: StringName)
signal feature_requested(feature_id: StringName)
signal scenario_requested(request: ScenarioLaunchRequest)
signal exit_requested
signal exit_confirmation_changed(is_visible: bool)
signal menu_mode_changed(is_bonus_mode: bool)

const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const SAFE_AREA_PADDING_PIXELS := 24.0
const CONFIRMATION_OVERLAY_SCENE: PackedScene = preload("res://src/ui/confirmation_overlay.tscn")

@export_range(0.0, 3.0, 0.05) var reveal_seconds := 1.0
@export_range(0.0, 3.0, 0.05) var menu_fade_seconds := 0.5
@export_range(0.0, 5.0, 0.05) var game_exit_seconds := 3.0
@export_range(0.0, 1.0, 0.01) var bonus_transition_seconds := 0.3
@export_range(0.0, 96.0, 1.0) var bonus_transition_offset_y := 32.0
@export_range(0.0, 1.0, 0.01) var subscreen_exit_seconds := 0.18
@export_range(0.0, 1.0, 0.01) var subscreen_return_seconds := 0.32
@export_range(0.0, 400.0, 1.0) var subscreen_exit_offset_y := 180.0
@export var show_exit_button := true
@export var safe_area_padding_pixels := SAFE_AREA_PADDING_PIXELS

@onready var _design_root: Control = $DesignRoot
@onready var _character_layer: Control = $DesignRoot/CharacterLayer
@onready var _logo: TextureRect = $DesignRoot/Logo
@onready var _bottom_chrome: Control = $DesignRoot/BottomChrome
@onready var _menu_layer: Control = $DesignRoot/BottomChrome/MenuLayer
@onready var _main_menu_center: CenterContainer = $DesignRoot/BottomChrome/MenuLayer/MainMenuCenter
@onready var _bonus_menu_center: CenterContainer = $DesignRoot/BottomChrome/MenuLayer/BonusMenuCenter
# Source Title.tjs setLayout order: Continue, Start, Load, Config, Bonus, End.
@onready var _declared_main_buttons: Array[TitleMenuButton] = [
	%ContinueGame,
	%NewGame,
	%LoadGame,
	%Settings,
	%Bonus,
	%ExitGame,
]
# Source Title.tjs appreciation order: Album, Music, Memories, Voice.
@onready var _declared_bonus_buttons: Array[TitleMenuButton] = [
	%Album,
	%Music,
	%Memories,
	%Voice,
]
@onready var _back_button: Button = %BonusBackButton
@onready var _version_label: Label = $DesignRoot/BottomChrome/VersionLabel
@onready var _autosave_info: Label = $DesignRoot/BottomChrome/AutosaveInfo
@onready var _blur_warmup: Control = $BlurWarmup
@onready var _white_cover: ColorRect = $WhiteCover

var _settings_repository: SettingsRepository
var _save_service: SaveService
var _main_buttons: Array[TitleMenuButton] = []
var _bonus_buttons: Array[TitleMenuButton] = []
var _active_controls: Array[Control] = []
var _exit_confirmation: ConfirmationOverlay
var _reveal_tween: Tween
var _game_exit_tween: Tween
var _bonus_transition_tween: Tween
var _bonus_mode := false
var _exit_confirmation_visible := false
var _subscreen_tween: Tween
var _subscreen_departed := false
var _bottom_chrome_rest_position := Vector2.ZERO
var _main_menu_rest_position := Vector2.ZERO
var _bonus_menu_rest_position := Vector2.ZERO


func configure(save_service: SaveService, settings_repository: SettingsRepository = null) -> void:
	_settings_repository = settings_repository
	_save_service = save_service


func _ready() -> void:
	if _settings_repository == null:
		_settings_repository = SettingsRepository.new()
	InputActions.ensure_actions()
	if _save_service == null:
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	_configure_character_layers()
	_main_menu_rest_position = _main_menu_center.position
	_bonus_menu_rest_position = _bonus_menu_center.position
	_configure_menu()
	_bottom_chrome_rest_position = _bottom_chrome.position
	_version_label.text = "version %s" % str(ProjectSettings.get_setting("application/config/version", "0.1.0"))
	_apply_design_transform()
	_start_reveal_animation()
	_finish_blur_warmup_after_first_draw()
	_resolve_initial_focus()


func _exit_tree() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_reveal_tween = null
	if _game_exit_tween != null and _game_exit_tween.is_valid():
		_game_exit_tween.kill()
	_game_exit_tween = null
	_kill_bonus_transition()
	if _subscreen_tween != null and _subscreen_tween.is_valid():
		_subscreen_tween.kill()
	_subscreen_tween = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_design_transform()


func _input(event: InputEvent) -> void:
	if StartupInput.is_cancel_event(event):
		if _exit_confirmation_visible:
			_hide_exit_confirmation()
			get_viewport().set_input_as_handled()
		elif _bonus_mode:
			_leave_bonus()
			get_viewport().set_input_as_handled()
		return


func _unhandled_input(event: InputEvent) -> void:
	if _exit_confirmation_visible:
		return
	if _active_controls.is_empty() or get_viewport().gui_get_focus_owner() != null:
		return
	if InputActions.is_pressed(event, InputActions.CONFIRM):
		_active_controls[0].grab_focus()
		get_viewport().set_input_as_handled()


func get_menu_buttons() -> Array[TitleMenuButton]:
	return _main_buttons.duplicate()


func get_bonus_buttons() -> Array[TitleMenuButton]:
	return _bonus_buttons.duplicate()


func get_current_options() -> Array[StringName]:
	var result: Array[StringName] = []
	for control in _active_controls:
		if control is TitleMenuButton:
			result.append((control as TitleMenuButton).option_id)
	return result


func is_bonus_mode() -> bool:
	return _bonus_mode


func is_bonus_transitioning() -> bool:
	return _bonus_transition_tween != null


func show_bonus_menu() -> void:
	# The source recreates Title with fBonus=true and calls enterBonus(0).
	_enter_bonus(0.0)


func is_exit_confirmation_visible() -> bool:
	return _exit_confirmation_visible


## Mirrors the source Title scene's deferred New Game hand-off: the complete
## title remains alive and fades away over the route's black base before
## StartupFlow is allowed to construct ADV.
func play_game_exit() -> void:
	if _game_exit_tween != null and _game_exit_tween.is_valid():
		await _game_exit_tween.finished
		return
	_set_menu_interaction_enabled(false)
	_finish_reveal_animation()
	_kill_subscreen_tween()
	get_viewport().gui_release_focus()
	if game_exit_seconds <= 0.0:
		modulate.a = 0.0
		return
	var tween := create_tween()
	_game_exit_tween = tween
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.0, game_exit_seconds)
	await tween.finished
	if _game_exit_tween == tween:
		_game_exit_tween = null


## Semantic transition used by the route coordinator before presenting any
## Title-owned child screen. Title keeps ownership of its internal node motion.
func play_subscreen_exit() -> void:
	if _subscreen_departed:
		return
	_subscreen_departed = true
	_set_menu_interaction_enabled(false)
	_finish_reveal_animation()
	_kill_subscreen_tween()
	var tween := create_tween().set_parallel(true)
	_subscreen_tween = tween
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(
		_bottom_chrome,
		"position",
		_bottom_chrome_rest_position + Vector2(0.0, subscreen_exit_offset_y),
		subscreen_exit_seconds
	)
	tween.tween_property(_logo, "modulate:a", 0.0, subscreen_exit_seconds * 0.8)
	await tween.finished
	if _subscreen_tween == tween:
		_subscreen_tween = null


## Enter transparent overlays immediately while retaining the original
## animated departure API for other routes.
func hide_for_subscreen() -> void:
	_subscreen_departed = true
	_set_menu_interaction_enabled(false)
	_finish_reveal_animation()
	_kill_subscreen_tween()
	_bottom_chrome.position = _bottom_chrome_rest_position + Vector2(0.0, subscreen_exit_offset_y)
	_bottom_chrome.visible = false
	_logo.modulate.a = 0.0


## Reverses play_subscreen_exit when a transparent overlay such as settings
## closes and the same Title instance becomes interactive again.
func play_subscreen_return() -> void:
	if not _subscreen_departed:
		return
	if _subscreen_tween != null and _subscreen_tween.is_valid():
		var departure_tween := _subscreen_tween
		await departure_tween.finished
	_subscreen_departed = false
	# Keep input locked until the return completes, but restore the normal
	# button artwork before it becomes visible and starts moving into place.
	_set_menu_interaction_enabled(false, false)
	_bottom_chrome.visible = true
	_kill_subscreen_tween()
	var tween := create_tween().set_parallel(true)
	_subscreen_tween = tween
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		_bottom_chrome,
		"position",
		_bottom_chrome_rest_position,
		subscreen_return_seconds
	)
	tween.tween_property(_logo, "modulate:a", 1.0, subscreen_return_seconds)
	await tween.finished
	if _subscreen_tween == tween:
		_subscreen_tween = null
	_set_menu_interaction_enabled(true)


func is_subscreen_departed() -> bool:
	return _subscreen_departed


func _configure_character_layers() -> void:
	var character_flags := RouteProgress.title_character_flags()
	for layer_name: StringName in character_flags:
		var layer := _character_layer.get_node(NodePath(String(layer_name))) as TextureRect
		layer.visible = _save_service.is_global_flag_set(int(character_flags[layer_name]))


func _configure_menu() -> void:
	_main_buttons.clear()
	_bonus_buttons.clear()
	for button in _declared_main_buttons:
		button.visible = _is_main_option_available(button.option_id)
		if button.visible:
			_main_buttons.append(button)
			_connect_menu_button(button)
	for button in _declared_bonus_buttons:
		_bonus_buttons.append(button)
		_connect_menu_button(button)
	_back_button.pressed.connect(_leave_bonus)
	_set_bonus_visibility(false)


func _is_main_option_available(option_id: StringName) -> bool:
	match option_id:
		&"continue_game":
			return _save_service.has_autosave()
		&"bonus":
			return _save_service.is_global_flag_set(RouteProgress.CLEARED_GAME_FLAG)
		&"exit_game":
				return show_exit_button and not DesignViewportLayout.is_mobile_platform()
	return true


func _connect_menu_button(button: TitleMenuButton) -> void:
	button.option_activated.connect(_on_option_activated)
	button.focus_entered.connect(func() -> void: _show_autosave_info(button))
	button.mouse_entered.connect(func() -> void: _show_autosave_info(button))
	button.focus_exited.connect(_hide_autosave_info)
	button.mouse_exited.connect(_hide_autosave_info)


func _set_bonus_visibility(enabled: bool, focus_first: bool = false) -> void:
	_kill_bonus_transition()
	_bonus_mode = enabled
	_main_menu_center.visible = not enabled
	_bonus_menu_center.visible = enabled
	_back_button.visible = enabled
	_main_menu_center.position = _main_menu_rest_position
	_bonus_menu_center.position = _bonus_menu_rest_position
	_set_control_alpha(_main_menu_center, 1.0)
	_set_control_alpha(_bonus_menu_center, 1.0)
	_set_control_alpha(_back_button, 1.0)
	_update_active_controls(enabled)
	_set_menu_mode_interaction_enabled(enabled, true)
	if focus_first:
		_focus_first_active_control()


func _update_active_controls(enabled: bool) -> void:
	_active_controls.clear()
	if enabled:
		for button in _bonus_buttons:
			_active_controls.append(button)
		_active_controls.append(_back_button)
	else:
		for button in _main_buttons:
			_active_controls.append(button)
	_configure_focus_neighbors()
	menu_mode_changed.emit(enabled)


func _set_menu_mode_interaction_enabled(bonus_enabled: bool, interaction_enabled: bool) -> void:
	for button in _declared_main_buttons:
		button.set_interaction_disabled(bonus_enabled or not interaction_enabled, false)
	for button in _declared_bonus_buttons:
		button.set_interaction_disabled(not bonus_enabled or not interaction_enabled, false)
	_back_button.disabled = not bonus_enabled or not interaction_enabled


func _configure_focus_neighbors() -> void:
	if _active_controls.is_empty():
		return
	for index in _active_controls.size():
		var control := _active_controls[index]
		var previous := _active_controls[posmod(index - 1, _active_controls.size())]
		var next := _active_controls[(index + 1) % _active_controls.size()]
		control.focus_neighbor_left = control.get_path_to(previous)
		control.focus_neighbor_right = control.get_path_to(next)


func _on_option_activated(option_id: StringName) -> void:
	option_selected.emit(option_id)
	match option_id:
		&"bonus":
			_enter_bonus()
		&"continue_game":
			var data := _save_service.load_autosave()
			if data != null:
				var request := ScenarioLaunchRequest.from_save(data, _save_service.autosave_path())
				scenario_requested.emit(request)
			else:
				feature_requested.emit(&"load_game")
		&"new_game":
			scenario_requested.emit(ScenarioLaunchRequest.new_game())
		&"load_game", &"settings", &"album", &"music", &"memories", &"voice":
			feature_requested.emit(option_id)
		&"exit_game":
			_show_exit_confirmation()


func _enter_bonus(duration: float = bonus_transition_seconds) -> void:
	if _bonus_mode or _bonus_transition_tween != null:
		return
	_play_bonus_transition(true, duration)


func _leave_bonus() -> void:
	if not _bonus_mode or _bonus_transition_tween != null:
		return
	_play_bonus_transition(false, bonus_transition_seconds)


## Mirrors Title.tjs enterBonus/leaveBonus: the outgoing row fades while
## moving down 32 px, and the incoming row rises from the same offset.
func _play_bonus_transition(entering_bonus: bool, duration: float) -> void:
	_finish_reveal_animation()
	_hide_autosave_info()
	get_viewport().gui_release_focus()
	_bonus_mode = entering_bonus
	_update_active_controls(entering_bonus)
	_set_menu_mode_interaction_enabled(entering_bonus, false)

	var outgoing := _main_menu_center if entering_bonus else _bonus_menu_center
	var incoming := _bonus_menu_center if entering_bonus else _main_menu_center
	var outgoing_rest := _main_menu_rest_position if entering_bonus else _bonus_menu_rest_position
	var incoming_rest := _bonus_menu_rest_position if entering_bonus else _main_menu_rest_position
	outgoing.visible = true
	incoming.visible = true
	outgoing.position = outgoing_rest
	incoming.position = incoming_rest + Vector2(0.0, bonus_transition_offset_y)
	_set_control_alpha(outgoing, 1.0)
	_set_control_alpha(incoming, 0.0)
	_back_button.visible = true
	_set_control_alpha(_back_button, 0.0 if entering_bonus else 1.0)

	if duration <= 0.0:
		_finish_bonus_transition(entering_bonus)
		return
	var tween := create_tween().set_parallel(true)
	_bonus_transition_tween = tween
	# Sprite.tjs uses acceleration=2 for motion (quadratic ease-out), while
	# opacity is interpolated directly from the normalized activation tick.
	tween.tween_property(outgoing, "position", outgoing_rest + Vector2(0.0, bonus_transition_offset_y), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(outgoing, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(incoming, "position", incoming_rest, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(incoming, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(_back_button, "modulate:a", 1.0 if entering_bonus else 0.0, duration).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(func() -> void:
		if _bonus_transition_tween != tween:
			return
		_bonus_transition_tween = null
		_finish_bonus_transition(entering_bonus)
	)


func _finish_bonus_transition(entering_bonus: bool) -> void:
	_main_menu_center.visible = not entering_bonus
	_bonus_menu_center.visible = entering_bonus
	_main_menu_center.position = _main_menu_rest_position
	_bonus_menu_center.position = _bonus_menu_rest_position
	_set_control_alpha(_main_menu_center, 1.0)
	_set_control_alpha(_bonus_menu_center, 1.0)
	_back_button.visible = entering_bonus
	_set_control_alpha(_back_button, 1.0)
	_set_menu_mode_interaction_enabled(entering_bonus, true)
	_focus_first_active_control()


func _focus_first_active_control() -> void:
	if not _active_controls.is_empty():
		_active_controls[0].grab_focus()


func _kill_bonus_transition() -> void:
	if _bonus_transition_tween != null and _bonus_transition_tween.is_valid():
		_bonus_transition_tween.kill()
	_bonus_transition_tween = null


func _set_control_alpha(control: CanvasItem, alpha: float) -> void:
	var color := control.modulate
	color.a = alpha
	control.modulate = color


func _ensure_exit_confirmation() -> void:
	if is_instance_valid(_exit_confirmation):
		return
	_exit_confirmation = CONFIRMATION_OVERLAY_SCENE.instantiate() as ConfirmationOverlay
	_exit_confirmation.name = "ExitConfirmationOverlay"
	_exit_confirmation.confirmed.connect(_confirm_exit)
	_exit_confirmation.canceled.connect(_hide_exit_confirmation)
	_exit_confirmation.always_toggled.connect(func(enabled: bool) -> void:
		if not _settings_repository.set_confirmation_enabled("end", enabled):
			push_error(_settings_repository.last_error)
	)
	add_child(_exit_confirmation)


func _show_exit_confirmation() -> void:
	if DesignViewportLayout.is_mobile_platform():
		return
	if not _settings_repository.confirmation_enabled("end") and not Input.is_key_pressed(KEY_SHIFT):
		exit_requested.emit()
		return
	_ensure_exit_confirmation()
	_exit_confirmation_visible = true
	_exit_confirmation.open("要结束游戏吗？", "结束游戏", "取消", true, _settings_repository.confirmation_enabled("end"))
	exit_confirmation_changed.emit(true)


func _hide_exit_confirmation() -> void:
	if not _exit_confirmation_visible:
		return
	_exit_confirmation_visible = false
	_exit_confirmation.close()
	exit_confirmation_changed.emit(false)


func _confirm_exit() -> void:
	_hide_exit_confirmation()
	exit_requested.emit()


func _show_autosave_info(button: TitleMenuButton) -> void:
	if button.option_id != &"continue_game" or not _save_service.has_autosave():
		return
	var summary := _save_service.get_autosave_summary()
	var comment := str(summary.get("comment", ""))
	if comment.is_empty():
		comment = str(summary.get("scenario_id", "自动存档"))
	_autosave_info.text = "自动存档：%s" % comment
	_autosave_info.visible = true


func _hide_autosave_info() -> void:
	_autosave_info.visible = false


func _resolve_initial_focus() -> void:
	if not _main_buttons.is_empty():
		_main_buttons[0].grab_focus()


func _start_reveal_animation() -> void:
	_set_menu_alpha(0.0)
	_white_cover.visible = true
	_set_cover_alpha(1.0)
	var tween := create_tween().set_parallel(true)
	_reveal_tween = tween
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_white_cover, "color:a", 0.0, reveal_seconds)
	tween.tween_property(_menu_layer, "modulate:a", 1.0, menu_fade_seconds)
	tween.finished.connect(
		func() -> void:
			if _reveal_tween != tween:
				return
			_reveal_tween = null
			_white_cover.visible = false
	)


func _finish_blur_warmup_after_first_draw() -> void:
	# This two-pixel probe compiles the exact screen-texture shader used by
	# settings and allocates its viewport mip chain before the first click.
	await RenderingServer.frame_post_draw
	if is_instance_valid(_blur_warmup):
		_blur_warmup.visible = false


func _finish_reveal_animation() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_reveal_tween = null
	_set_cover_alpha(0.0)
	_white_cover.visible = false
	_set_menu_alpha(1.0)


func _kill_subscreen_tween() -> void:
	if _subscreen_tween != null and _subscreen_tween.is_valid():
		_subscreen_tween.kill()
	_subscreen_tween = null


func _set_menu_interaction_enabled(enabled: bool, show_disabled_visual := true) -> void:
	for control in _active_controls:
		if control is TitleMenuButton:
			(control as TitleMenuButton).set_interaction_disabled(not enabled, show_disabled_visual)
		elif control is BaseButton:
			(control as BaseButton).disabled = not enabled


func _apply_design_transform() -> void:
	DesignViewportLayout.apply(_design_root, size, DESIGN_SIZE, safe_area_padding_pixels)


func _set_menu_alpha(alpha: float) -> void:
	var color := _menu_layer.modulate
	color.a = alpha
	_menu_layer.modulate = color


func _set_cover_alpha(alpha: float) -> void:
	var color := _white_cover.color
	color.a = alpha
	_white_cover.color = color
