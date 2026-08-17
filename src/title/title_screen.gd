class_name TitleScreen
extends Control


signal option_selected(option_id: StringName)
signal feature_requested(feature_id: StringName)
signal scenario_requested(request: ScenarioLaunchRequest)
signal exit_requested
signal exit_confirmation_changed(is_visible: bool)
signal menu_mode_changed(is_bonus_mode: bool)

const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const MENU_Y := 979.0
const BUTTON_SPACING := 12.0
const SAFE_AREA_PADDING_PIXELS := 24.0
const BUTTON_SCENE: PackedScene = preload("res://src/title/title_menu_button.tscn")

const CHARACTER_LAYERS: Array[Dictionary] = [
	{"flag": 25, "texture": preload("res://assets/ui/title/QD-13-motoka.png")},
	{"flag": 24, "texture": preload("res://assets/ui/title/QD-13-kazuha.png")},
	{"flag": 22, "texture": preload("res://assets/ui/title/QD-13-nao.png")},
	{"flag": 21, "texture": preload("res://assets/ui/title/QD-13-sora.png")},
	{"flag": 23, "texture": preload("res://assets/ui/title/QD-13-akira.png")},
]

@export_range(0.0, 3.0, 0.05) var reveal_seconds := 1.0
@export_range(0.0, 3.0, 0.05) var menu_fade_seconds := 0.5
@export var show_exit_button := true
@export var safe_area_padding_pixels := SAFE_AREA_PADDING_PIXELS

@onready var _design_root: Control = $DesignRoot
@onready var _character_layer: Control = $DesignRoot/CharacterLayer
@onready var _menu_layer: Control = $DesignRoot/MenuLayer
@onready var _version_label: Label = $DesignRoot/VersionLabel
@onready var _autosave_info: Label = $DesignRoot/AutosaveInfo
@onready var _white_cover: ColorRect = $WhiteCover

var _save_service: SaveService
var _main_buttons: Array[TitleMenuButton] = []
var _bonus_buttons: Array[TitleMenuButton] = []
var _active_controls: Array[Control] = []
var _back_button: Button
var _exit_overlay: ColorRect
var _exit_yes_button: Button
var _exit_no_button: Button
var _reveal_tween: Tween
var _bonus_mode := false
var _exit_confirmation_visible := false
var _scenario_notice: ScenarioUnavailableNotice


func configure(save_service: SaveService) -> void:
	_save_service = save_service


func _ready() -> void:
	InputActions.ensure_actions()
	if _save_service == null:
		_save_service = SaveService.new()
		add_child(_save_service)
	_build_character_layers()
	_build_menu()
	_build_exit_confirmation()
	_build_scenario_notice()
	_version_label.text = "version %s" % str(ProjectSettings.get_setting("application/config/version", "0.1.0"))
	_apply_design_transform()
	_start_reveal_animation()
	_resolve_initial_focus()


func _exit_tree() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_reveal_tween = null


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


func _build_character_layers() -> void:
	for entry in CHARACTER_LAYERS:
		if not _save_service.is_global_flag_set(int(entry.flag)):
			continue
		var layer := TextureRect.new()
		layer.name = "Character_%d" % int(entry.flag)
		layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.texture = entry.texture as Texture2D
		layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_character_layer.add_child(layer)


func _build_menu() -> void:
	var main_items := _build_main_items()
	for item in main_items:
		_main_buttons.append(_create_menu_button(item))
	_layout_buttons(_main_buttons)

	var bonus_items: Array[TitleMenuItem] = [
		TitleMenuItem.create(&"album", "相册", preload("res://assets/ui/title/QD-08.png"), true),
		TitleMenuItem.create(&"music", "音乐鉴赏", preload("res://assets/ui/title/QD-07.png"), true),
		TitleMenuItem.create(&"memories", "回忆", preload("res://assets/ui/title/QD-09.png"), true),
		TitleMenuItem.create(&"voice", "语音鉴赏", preload("res://assets/ui/title/QD-10.png"), true),
	]
	for item in bonus_items:
		_bonus_buttons.append(_create_menu_button(item))
	_layout_buttons(_bonus_buttons)

	_back_button = Button.new()
	_back_button.name = "BonusBackButton"
	_back_button.text = "返回标题"
	_back_button.tooltip_text = "返回标题菜单"
	_back_button.focus_mode = Control.FOCUS_ALL
	_back_button.custom_minimum_size = Vector2(180.0, 64.0)
	_back_button.position = Vector2(DESIGN_SIZE.x - 220.0, 36.0)
	_back_button.pressed.connect(_leave_bonus)
	_menu_layer.add_child(_back_button)
	_set_bonus_visibility(false)


func _build_main_items() -> Array[TitleMenuItem]:
	var items: Array[TitleMenuItem] = []
	if _save_service.has_autosave():
		items.append(TitleMenuItem.create(&"continue_game", "继续游戏", preload("res://assets/ui/title/QD-02.png")))
	items.append(TitleMenuItem.create(&"new_game", "新的开始", preload("res://assets/ui/title/QD-01.png")))
	items.append(TitleMenuItem.create(&"load_game", "读取存档", preload("res://assets/ui/title/QD-03.png")))
	items.append(TitleMenuItem.create(&"configuration", "环境设定", preload("res://assets/ui/title/QD-04.png")))
	if _save_service.is_global_flag_set(1):
		items.append(TitleMenuItem.create(&"bonus", "鉴赏", preload("res://assets/ui/title/QD-05.png")))
	if show_exit_button and not _is_mobile_platform():
		items.append(TitleMenuItem.create(&"exit_game", "结束游戏", preload("res://assets/ui/title/QD-06.png")))
	return items


func _create_menu_button(item: TitleMenuItem) -> TitleMenuButton:
	var button := BUTTON_SCENE.instantiate() as TitleMenuButton
	button.configure(item.id, item.label, item.texture)
	button.option_activated.connect(_on_option_activated)
	button.focus_entered.connect(func() -> void: _show_autosave_info(button))
	button.mouse_entered.connect(func() -> void: _show_autosave_info(button))
	button.focus_exited.connect(_hide_autosave_info)
	button.mouse_exited.connect(_hide_autosave_info)
	_menu_layer.add_child(button)
	return button


func _layout_buttons(buttons: Array[TitleMenuButton]) -> void:
	if buttons.is_empty():
		return
	var total_width := BUTTON_SPACING * float(buttons.size() - 1)
	for button in buttons:
		total_width += button.size.x
	var next_x := (DESIGN_SIZE.x - total_width) * 0.5
	for button in buttons:
		button.position = Vector2(next_x, MENU_Y)
		next_x += button.size.x + BUTTON_SPACING


func _set_bonus_visibility(enabled: bool) -> void:
	_bonus_mode = enabled
	for button in _main_buttons:
		button.visible = not enabled
	for button in _bonus_buttons:
		button.visible = enabled
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
		&"load_game", &"configuration", &"album", &"music", &"memories", &"voice":
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


func _build_exit_confirmation() -> void:
	_exit_overlay = ColorRect.new()
	_exit_overlay.name = "ExitConfirmationOverlay"
	_exit_overlay.color = Color(0.0, 0.0, 0.0, 0.72)
	_exit_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_exit_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_exit_overlay)

	var panel := PanelContainer.new()
	panel.name = "Dialog"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -350.0
	panel.offset_top = -155.0
	panel.offset_right = 350.0
	panel.offset_bottom = 155.0
	_exit_overlay.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 36)
	panel.add_child(box)
	var message := Label.new()
	message.text = "要结束游戏吗？"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.custom_minimum_size.y = 100.0
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(message)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 28)
	box.add_child(actions)
	_exit_yes_button = Button.new()
	_exit_yes_button.text = "结束游戏"
	_exit_yes_button.custom_minimum_size = Vector2(220.0, 72.0)
	_exit_yes_button.pressed.connect(_confirm_exit)
	actions.add_child(_exit_yes_button)
	_exit_no_button = Button.new()
	_exit_no_button.text = "取消"
	_exit_no_button.custom_minimum_size = Vector2(220.0, 72.0)
	_exit_no_button.pressed.connect(_hide_exit_confirmation)
	actions.add_child(_exit_no_button)
	_exit_overlay.visible = false


func _build_scenario_notice() -> void:
	_scenario_notice = ScenarioUnavailableNotice.new()
	_scenario_notice.name = "ScenarioUnavailableNotice"
	add_child(_scenario_notice)


func _show_scenario_notice(request: ScenarioLaunchRequest) -> void:
	if _scenario_notice != null:
		_scenario_notice.show_request(request)


func _show_exit_confirmation() -> void:
	if _is_mobile_platform():
		return
	_exit_confirmation_visible = true
	_exit_overlay.visible = true
	_exit_no_button.grab_focus()
	exit_confirmation_changed.emit(true)


func _hide_exit_confirmation() -> void:
	if not _exit_confirmation_visible:
		return
	_exit_confirmation_visible = false
	_exit_overlay.visible = false
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


func _apply_design_transform() -> void:
	if not is_instance_valid(_design_root):
		return
	var viewport_size := size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var safe_rect := _get_safe_area_rect(viewport_size)
	var scale := minf(safe_rect.size.x / DESIGN_SIZE.x, safe_rect.size.y / DESIGN_SIZE.y)
	_design_root.scale = Vector2.ONE * scale
	_design_root.position = safe_rect.position + (safe_rect.size - DESIGN_SIZE * scale) * 0.5


func _get_safe_area_rect(viewport_size: Vector2) -> Rect2:
	if not _is_mobile_platform():
		return Rect2(Vector2.ZERO, viewport_size)

	var fallback := maxf(0.0, safe_area_padding_pixels)
	var safe_area := DisplayServer.get_display_safe_area()
	if safe_area.size.x <= 0 or safe_area.size.y <= 0:
		return Rect2(Vector2(fallback, fallback), Vector2(
			maxf(1.0, viewport_size.x - fallback * 2.0),
			maxf(1.0, viewport_size.y - fallback * 2.0)
		))

	# Safe-area coordinates are reported in display pixels. Map them to the
	# viewport before fitting the fixed design canvas; if the platform cannot
	# report a display size, the conservative inset remains the fallback.
	var display_size := DisplayServer.screen_get_size()
	if display_size.x <= 0 or display_size.y <= 0:
		return Rect2(Vector2(fallback, fallback), Vector2(
			maxf(1.0, viewport_size.x - fallback * 2.0),
			maxf(1.0, viewport_size.y - fallback * 2.0)
		))
	var display_to_viewport := Vector2(
		viewport_size.x / float(display_size.x),
		viewport_size.y / float(display_size.y)
	)
	var safe_position := Vector2(safe_area.position) * display_to_viewport
	var safe_end := Vector2(safe_area.position + safe_area.size) * display_to_viewport
	safe_position.x = clampf(safe_position.x, 0.0, viewport_size.x)
	safe_position.y = clampf(safe_position.y, 0.0, viewport_size.y)
	safe_end.x = clampf(safe_end.x, safe_position.x, viewport_size.x)
	safe_end.y = clampf(safe_end.y, safe_position.y, viewport_size.y)
	var safe_size := safe_end - safe_position
	if safe_size.x <= 1.0 or safe_size.y <= 1.0:
		return Rect2(Vector2(fallback, fallback), Vector2(
			maxf(1.0, viewport_size.x - fallback * 2.0),
			maxf(1.0, viewport_size.y - fallback * 2.0)
		))
	return Rect2(safe_position, safe_size)


func _set_menu_alpha(alpha: float) -> void:
	var color := _menu_layer.modulate
	color.a = alpha
	_menu_layer.modulate = color


func _set_cover_alpha(alpha: float) -> void:
	var color := _white_cover.color
	color.a = alpha
	_white_cover.color = color


func _is_mobile_platform() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
