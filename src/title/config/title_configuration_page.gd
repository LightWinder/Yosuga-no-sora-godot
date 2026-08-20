class_name TitleConfigurationPage
extends TitleVisualPage


## HD 环境设定 window shell: frame background, three image tabs, footer strip
## buttons, key popup, confirm dialog and reset flows.  Pages emit typed
## patches; the shell owns values, preview emission and debounced persistence.
signal settings_preview_changed(settings: Dictionary)
signal settings_commit_requested(settings: Dictionary)
signal status_changed(message: String)
signal close_requested
signal read_flags_reset_requested

const COMMIT_DELAY := 0.25
const SETTINGS_ROOT := "res://assets/content/settings/"
const TAB_BUTTONS: Array[Dictionary] = [
	{"normal": "graphics1.png", "selected": "graphics2.png", "pos": Vector2(1165, 190)},
	{"normal": "systems1.png", "selected": "systems2.png", "pos": Vector2(1370, 190)},
	{"normal": "audio1.png", "selected": "audio2.png", "pos": Vector2(1565, 190)},
]

enum Tab {
	SCREEN,
	SYSTEM,
	AUDIO,
}

var _values: Dictionary = {}
var _commit_timer: Timer
var _status_clear_timer: Timer
var _pending_commit := false
var _tabs: Array[ConfigToggleButton] = []
var _screen_page: ConfigScreenPage
var _system_page: ConfigSystemPage
var _audio_page: ConfigAudioPage
var _current_tab := Tab.SCREEN
var _sliders: Dictionary = {}
var _key_popup: Control
var _confirm_dialog: ConfigConfirmDialog
var _voice_sample: ConfigVoiceSample
var _status_label: Label
var _pending_action: StringName = &""


func configure(settings: Dictionary) -> void:
	_values = TitleSettingsModel.normalize(settings)
	if is_inside_tree():
		_sync_pages()


func _ready() -> void:
	super._ready()
	set_visual_background(SETTINGS_ROOT + "bg.png")
	_commit_timer = Timer.new()
	_commit_timer.name = "ConfigCommitTimer"
	_commit_timer.one_shot = true
	_commit_timer.wait_time = COMMIT_DELAY
	_commit_timer.timeout.connect(_commit)
	add_child(_commit_timer)
	_status_clear_timer = Timer.new()
	_status_clear_timer.name = "StatusClearTimer"
	_status_clear_timer.one_shot = true
	_status_clear_timer.wait_time = 4.0
	_status_clear_timer.timeout.connect(func() -> void: _status_label.text = "")
	add_child(_status_clear_timer)
	_voice_sample = ConfigVoiceSample.new()
	_voice_sample.name = "VoiceSample"
	add_child(_voice_sample)
	_build_tabs()
	_build_pages()
	_build_footer()
	_build_status_label()
	_build_key_popup()
	_build_confirm_dialog()
	_sync_pages()
	_show_tab(0)
	if not _tabs.is_empty():
		_tabs[0].grab_focus()


func _exit_tree() -> void:
	if _pending_commit:
		_commit()


func _input(event: InputEvent) -> void:
	if _confirm_dialog != null and _confirm_dialog.is_open():
		return
	if _key_popup != null and _key_popup.visible:
		if StartupInput.is_cancel_event(event):
			_close_key_popup()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var key := event as InputEventKey
		if key.keycode == KEY_LEFT or key.keycode == KEY_RIGHT:
			if _step_active_slider(key):
				get_viewport().set_input_as_handled()
			return
	if StartupInput.is_cancel_event(event):
		close_requested.emit()
		get_viewport().set_input_as_handled()


## --- Public API ---

func get_current_settings() -> Dictionary:
	return _values.duplicate(true)


func find_setting_slider(key: String) -> ConfigKnobSlider:
	return _sliders.get(key) as ConfigKnobSlider


func screen_page() -> ConfigScreenPage:
	return _screen_page


func system_page() -> ConfigSystemPage:
	return _system_page


func audio_page() -> ConfigAudioPage:
	return _audio_page


func show_tab(index: int) -> void:
	_show_tab(index)


func current_tab() -> int:
	return _current_tab


func grab_config_focus() -> void:
	if not _tabs.is_empty():
		_tabs[clampi(_current_tab, 0, _tabs.size() - 1)].grab_focus()


func open_key_popup() -> void:
	if _key_popup != null:
		_key_popup.visible = true


func close_key_popup() -> void:
	_close_key_popup()


func is_key_popup_visible() -> bool:
	return _key_popup != null and _key_popup.visible


func is_confirm_visible() -> bool:
	return _confirm_dialog != null and _confirm_dialog.is_open()


func report_error(message: String) -> void:
	_set_status(message)


func request_reset_settings() -> void:
	if not bool(_values.get("confirmations", {}).get("default", true)):
		_run_reset_settings()
		return
	_pending_action = &"reset_settings"
	_open_confirm("要初始化设定吗？", "default")


func request_reset_read() -> void:
	if not bool(_values.get("confirmations", {}).get("clear_read", true)):
		_run_reset_read()
		return
	_pending_action = &"reset_read"
	_open_confirm("要初始化已读情报吗？", "clear_read")


func confirm_pending_action() -> void:
	_run_pending_action()


func cancel_pending_action() -> void:
	_pending_action = &""
	_confirm_dialog.close()
	_set_status("已取消。")


## --- Builders ---

func _build_tabs() -> void:
	for index in TAB_BUTTONS.size():
		var entry: Dictionary = TAB_BUTTONS[index]
		var tab := ConfigToggleButton.new()
		tab.configure_dual(SETTINGS_ROOT + str(entry.normal), SETTINGS_ROOT + str(entry.selected))
		tab.position = entry.pos
		tab.pressed.connect(_on_tab_pressed.bind(index))
		visual_canvas().add_child(tab)
		_tabs.append(tab)


func _build_pages() -> void:
	_screen_page = ConfigScreenPage.new()
	_screen_page.name = "ScreenPage"
	_attach_page(_screen_page)
	_system_page = ConfigSystemPage.new()
	_system_page.name = "SystemPage"
	_attach_page(_system_page)
	_audio_page = ConfigAudioPage.new()
	_audio_page.name = "AudioPage"
	_audio_page.sample_requested.connect(_on_voice_sample_requested)
	_attach_page(_audio_page)


func _attach_page(page: ConfigPageBase) -> void:
	page.patch_requested.connect(_on_patch)
	visual_canvas().add_child(page)
	_collect_sliders(page)


func _collect_sliders(page: ConfigPageBase) -> void:
	for slider in page.setting_sliders():
		_sliders[slider.name] = slider
		slider.drag_ended.connect(func(_changed: bool) -> void: _commit())


func _build_footer() -> void:
	_add_footer_button("reset_seetting.png", Vector2(42, 1037), request_reset_settings)
	_add_footer_button("reset_text.png", Vector2(245, 1037), request_reset_read)
	_add_footer_button("key.png", Vector2(520, 1037), open_key_popup, 3, 105, 105)
	_add_footer_button("title.png", Vector2(1607, 995), func() -> void: close_requested.emit())


func _add_footer_button(
		texture_name: String,
		position_value: Vector2,
		callback: Callable,
		state_count := 2,
		first_state_width := 0,
		last_state_width := 0
) -> ConfigStripButton:
	var button := ConfigStripButton.new()
	button.configure_strip(SETTINGS_ROOT + texture_name, state_count, first_state_width, last_state_width)
	button.position = position_value
	button.pressed.connect(callback)
	visual_canvas().add_child(button)
	return button


func _build_status_label() -> void:
	_status_label = Label.new()
	_status_label.name = "ConfigStatus"
	_status_label.position = Vector2(460, 955)
	_status_label.size = Vector2(1000, 40)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 24)
	_status_label.add_theme_color_override("font_color", Color.WHITE)
	_status_label.add_theme_color_override("font_outline_color", Color(0.05, 0.08, 0.12, 0.9))
	_status_label.add_theme_constant_override("outline_size", 4)
	visual_canvas().add_child(_status_label)


func _build_key_popup() -> void:
	_key_popup = Control.new()
	_key_popup.name = "KeyPopup"
	_key_popup.position = Vector2.ZERO
	_key_popup.size = TitleVisualPage.DESIGN_SIZE
	_key_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	_key_popup.visible = false
	var image := TextureRect.new()
	image.name = "KeyPopupImage"
	image.position = Vector2(568, 191)
	image.texture = load(SETTINGS_ROOT + "key_popup.png") as Texture2D
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_key_popup.add_child(image)
	_key_popup.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
			_close_key_popup()
	)
	visual_canvas().add_child(_key_popup)


func _build_confirm_dialog() -> void:
	_confirm_dialog = ConfigConfirmDialog.new()
	_confirm_dialog.name = "ConfigConfirm"
	_confirm_dialog.confirmed.connect(_on_confirm_confirmed)
	_confirm_dialog.canceled.connect(cancel_pending_action)
	_confirm_dialog.always_toggled.connect(_on_confirm_always_toggled)
	visual_canvas().add_child(_confirm_dialog)


## --- State flow ---

func _sync_pages() -> void:
	for page in _all_pages():
		page.sync_from(_values)


func _all_pages() -> Array[ConfigPageBase]:
	var pages: Array[ConfigPageBase] = []
	for page in [_screen_page, _system_page, _audio_page]:
		if page != null:
			pages.append(page)
	return pages


func _show_tab(index: int) -> void:
	if _tabs.is_empty() or _screen_page == null or _system_page == null or _audio_page == null:
		return
	index = clampi(index, 0, _tabs.size() - 1)
	_current_tab = index
	for tab_index in _tabs.size():
		_tabs[tab_index].selected = tab_index == index
	_screen_page.visible = index == Tab.SCREEN
	_system_page.visible = index == Tab.SYSTEM
	_audio_page.visible = index == Tab.AUDIO
	if _key_popup != null and _key_popup.visible:
		_close_key_popup()


func _on_tab_pressed(index: int) -> void:
	_show_tab(index)


func _on_patch(patch: Dictionary, immediate: bool) -> void:
	for key in patch:
		# Confirmation controls emit a one-key dictionary. Merge it into the
		# existing map instead of replacing the other ten source flags.
		if key == "confirmations" and patch[key] is Dictionary:
			var confirmations: Dictionary = _values.get("confirmations", {}).duplicate(true)
			for confirmation_key in patch[key]:
				confirmations[confirmation_key] = patch[key][confirmation_key]
			_values[key] = confirmations
		else:
			_values[key] = patch[key]
	_values = TitleSettingsModel.normalize(_values)
	# Keep previews (portrait/read-colour/window depth) and selected states in
	# sync for keyboard, touch, and programmatic changes alike. All page sync
	# setters are silent, so this does not create signal recursion.
	_sync_pages()
	_preview_and_debounce()
	if immediate:
		_commit()


func _preview_and_debounce() -> void:
	_pending_commit = true
	settings_preview_changed.emit(_values.duplicate(true))
	if _commit_timer != null:
		_commit_timer.start()


func _commit() -> void:
	if not _pending_commit:
		return
	if _commit_timer != null:
		_commit_timer.stop()
	_pending_commit = false
	settings_commit_requested.emit(_values.duplicate(true))


func _on_voice_sample_requested(detail_index: int) -> void:
	var details: Array = _values.get("voice_detail_volumes", [])
	var volume := 1.0
	if detail_index < details.size():
		volume = float(details[detail_index])
	_voice_sample.play_detail(detail_index, volume)


## --- Popup / confirm / reset ---

func _close_key_popup() -> void:
	if _key_popup != null:
		_key_popup.visible = false


func _open_confirm(message: String, confirmation_key: String) -> void:
	_confirm_dialog.open(message, bool(_values.get("confirmations", {}).get(confirmation_key, true)))


func _on_confirm_confirmed() -> void:
	_run_pending_action()


func _on_confirm_always_toggled(checked: bool) -> void:
	var key := _confirmation_key_for_action()
	if key.is_empty():
		return
	var confirmations: Dictionary = _values.get("confirmations", {}).duplicate(true)
	confirmations[key] = checked
	_values["confirmations"] = confirmations
	_sync_pages()
	_preview_and_debounce()
	_commit()


func _confirmation_key_for_action() -> String:
	match _pending_action:
		&"reset_settings":
			return "default"
		&"reset_read":
			return "clear_read"
	return ""


func _run_pending_action() -> void:
	var action := _pending_action
	_pending_action = &""
	_confirm_dialog.close()
	match action:
		&"reset_settings":
			_run_reset_settings()
		&"reset_read":
			_run_reset_read()


func _run_reset_settings() -> void:
	var preserved_mode: Variant = _values.get("window_mode", "windowed")
	var preserved_width: Variant = _values.get("window_width", 1280)
	_values = TitleSettingsModel.defaults()
	_values["window_mode"] = preserved_mode
	_values["window_width"] = preserved_width
	_sync_pages()
	# Report the optimistic UI action first. If persistence fails, the owner
	# reports the write error afterward and it remains visible to the user.
	_set_status("已恢复初始设定。")
	_preview_and_debounce()
	_commit()


func _run_reset_read() -> void:
	read_flags_reset_requested.emit()
	_set_status("已读情报初始化请求已发出（正文运行层待迁移）。")


func _set_status(message: String) -> void:
	status_changed.emit(message)
	_status_label.text = message
	_status_clear_timer.start()


## --- Slider keyboard routing ---

func _step_active_slider(key: InputEventKey) -> bool:
	var slider := _find_active_slider()
	if slider == null or slider.disabled:
		return false
	var delta := (slider.max_value - slider.min_value) / (10.0 if key.shift_pressed else 20.0)
	if key.keycode == KEY_LEFT:
		slider.step_by(-delta)
	else:
		slider.step_by(delta)
	return true


func _find_active_slider() -> ConfigKnobSlider:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner is ConfigKnobSlider:
		return focus_owner as ConfigKnobSlider
	for slider in _sliders.values():
		if (slider as ConfigKnobSlider).is_hovered():
			return slider as ConfigKnobSlider
	return null
