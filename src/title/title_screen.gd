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
const SCENARIO_NOTICE_SCENE: PackedScene = preload("res://src/title/components/scenario_unavailable_notice.tscn")
const EXIT_CONFIRMATION_SCENE: PackedScene = preload("res://src/title/title_exit_confirmation.tscn")

const CHARACTER_NODE_FLAGS := {
	&"CharacterMotoka": 25,
	&"CharacterKazuha": 24,
	&"CharacterNao": 22,
	&"CharacterSora": 21,
	&"CharacterAkira": 23,
}

@export_range(0.0, 3.0, 0.05) var reveal_seconds := 1.0
@export_range(0.0, 3.0, 0.05) var menu_fade_seconds := 0.5
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
@onready var _declared_main_buttons: Array[TitleMenuButton] = [
	%ContinueGame,
	%NewGame,
	%LoadGame,
	%Settings,
	%Bonus,
	%ExitGame,
]
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

var _save_service: SaveService
var _main_buttons: Array[TitleMenuButton] = []
var _bonus_buttons: Array[TitleMenuButton] = []
var _active_controls: Array[Control] = []
var _exit_confirmation: TitleExitConfirmation
var _reveal_tween: Tween
var _bonus_mode := false
var _exit_confirmation_visible := false
var _scenario_notice: ScenarioUnavailableNotice
var _subscreen_tween: Tween
var _subscreen_departed := false
var _bottom_chrome_rest_position := Vector2.ZERO


func configure(save_service: SaveService) -> void:
	_save_service = save_service


func _ready() -> void:
	InputActions.ensure_actions()
	if _save_service == null:
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	_configure_character_layers()
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
	if _subscreen_tween != null and _subscreen_tween.is_valid():
		_subscreen_tween.kill()
	_subscreen_tween = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_design_transform()


func _input(event: InputEvent) -> void:
	if _scenario_notice != null and _scenario_notice.visible:
		if StartupInput.is_cancel_event(event):
			_scenario_notice.hide_notice()
			get_viewport().set_input_as_handled()
		return
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


func show_bonus_menu() -> void:
	_enter_bonus()


func is_exit_confirmation_visible() -> bool:
	return _exit_confirmation_visible


func is_scenario_notice_visible() -> bool:
	return is_instance_valid(_scenario_notice) and _scenario_notice.visible


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


## Reverses play_subscreen_exit when a transparent overlay such as settings
## closes and the same Title instance becomes interactive again.
func play_subscreen_return() -> void:
	if not _subscreen_departed:
		return
	if _subscreen_tween != null and _subscreen_tween.is_valid():
		var departure_tween := _subscreen_tween
		await departure_tween.finished
	_subscreen_departed = false
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
	for layer_name in CHARACTER_NODE_FLAGS:
		var layer := _character_layer.get_node(NodePath(String(layer_name))) as TextureRect
		layer.visible = _save_service.is_global_flag_set(int(CHARACTER_NODE_FLAGS[layer_name]))


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
			return _save_service.is_global_flag_set(1)
		&"exit_game":
				return show_exit_button and not DesignViewportLayout.is_mobile_platform()
	return true


func _connect_menu_button(button: TitleMenuButton) -> void:
	button.option_activated.connect(_on_option_activated)
	button.focus_entered.connect(func() -> void: _show_autosave_info(button))
	button.mouse_entered.connect(func() -> void: _show_autosave_info(button))
	button.focus_exited.connect(_hide_autosave_info)
	button.mouse_exited.connect(_hide_autosave_info)


func _set_bonus_visibility(enabled: bool) -> void:
	_bonus_mode = enabled
	_main_menu_center.visible = not enabled
	_bonus_menu_center.visible = enabled
	_back_button.visible = enabled
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
				var request := ScenarioLaunchRequest.from_save(data, SaveService.AUTOSAVE_PATH)
				scenario_requested.emit(request)
				_show_scenario_notice(request)
			else:
				feature_requested.emit(&"load_game")
		&"new_game":
			# Gameplay is intentionally left as an integration seam for the next
			# migration phase.
			pass
		&"load_game", &"settings", &"album", &"music", &"memories", &"voice":
			feature_requested.emit(option_id)
		&"exit_game":
			_show_exit_confirmation()


func _enter_bonus() -> void:
	if _bonus_mode:
		return
	_set_bonus_visibility(true)
	if not _bonus_buttons.is_empty():
		_bonus_buttons[0].grab_focus()


func _leave_bonus() -> void:
	if not _bonus_mode:
		return
	_set_bonus_visibility(false)
	if not _main_buttons.is_empty():
		_main_buttons[0].grab_focus()


func _ensure_exit_confirmation() -> void:
	if is_instance_valid(_exit_confirmation):
		return
	_exit_confirmation = EXIT_CONFIRMATION_SCENE.instantiate() as TitleExitConfirmation
	_exit_confirmation.confirmed.connect(_confirm_exit)
	_exit_confirmation.canceled.connect(_hide_exit_confirmation)
	add_child(_exit_confirmation)


func _ensure_scenario_notice() -> void:
	if is_instance_valid(_scenario_notice):
		return
	_scenario_notice = SCENARIO_NOTICE_SCENE.instantiate() as ScenarioUnavailableNotice
	add_child(_scenario_notice)


func _show_scenario_notice(request: ScenarioLaunchRequest) -> void:
	_ensure_scenario_notice()
	_scenario_notice.show_request(request)


func _show_exit_confirmation() -> void:
	if DesignViewportLayout.is_mobile_platform():
		return
	_ensure_exit_confirmation()
	_exit_confirmation_visible = true
	_exit_confirmation.open()
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
	var label := str(summary.get("label", ""))
	if label.is_empty():
		label = str(summary.get("scenario_id", "自动存档"))
	_autosave_info.text = "自动存档：%s" % label
	_autosave_info.visible = true


func _hide_autosave_info() -> void:
	_autosave_info.visible = false


func _resolve_initial_focus() -> void:
	if not _main_buttons.is_empty():
		_main_buttons[0].grab_focus()


func _start_reveal_animation() -> void:
	_set_menu_alpha(0.0)
	_set_cover_alpha(1.0)
	_reveal_tween = create_tween().set_parallel(true)
	_reveal_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_reveal_tween.tween_property(_white_cover, "color:a", 0.0, reveal_seconds)
	_reveal_tween.tween_property(_menu_layer, "modulate:a", 1.0, menu_fade_seconds)


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
	_set_menu_alpha(1.0)


func _kill_subscreen_tween() -> void:
	if _subscreen_tween != null and _subscreen_tween.is_valid():
		_subscreen_tween.kill()
	_subscreen_tween = null


func _set_menu_interaction_enabled(enabled: bool) -> void:
	for control in _active_controls:
		if control is BaseButton:
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
