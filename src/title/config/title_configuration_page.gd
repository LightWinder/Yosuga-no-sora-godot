class_name TitleConfigurationPage
extends TitleVisualPage


signal settings_preview_changed(settings: Dictionary)
signal settings_commit_requested(settings: Dictionary)
signal status_changed(message: String)

const COMMIT_DELAY := 0.25

var _values: Dictionary = {}
var _tabs: Array[Button] = []
var _pages: Array[Control] = []
var _commit_timer: Timer
var _content: VBoxContainer
var _status: Label
var _sliders: Dictionary = {}
var _options: Dictionary = {}
var _pending_commit := false


func configure(settings: Dictionary) -> void:
	_values = TitleSettingsModel.normalize(settings)
	if is_inside_tree():
		_build_pages()


func _ready() -> void:
	super._ready()
	_commit_timer = Timer.new()
	_commit_timer.name = "ConfigDebounceTimer"
	_commit_timer.one_shot = true
	_commit_timer.wait_time = COMMIT_DELAY
	_commit_timer.timeout.connect(_commit)
	add_child(_commit_timer)
	_build_shell()
	_build_pages()


func _exit_tree() -> void:
	# Leaving Config while a keyboard/handle slider was still moving must not
	# discard the last preview.  The owner can safely persist this one snapshot
	# without coupling controls to SaveService or AudioServer.
	if _pending_commit:
		_commit()


func get_current_settings() -> Dictionary:
	return _values.duplicate(true)


func find_setting_slider(key: String) -> HSlider:
	return _sliders.get(key) as HSlider


func find_setting_option(key: String) -> OptionButton:
	return _options.get(key) as OptionButton


func _build_shell() -> void:
	var root := Control.new()
	root.name = "ConfigurationContent"
	root.position = Vector2(80.0, 120.0)
	root.size = Vector2(1760.0, 900.0)
	visual_canvas().add_child(root)
	add_design_texture(root, "res://assets/content/settings/title.png", Rect2(95, 18, 300, 52))
	add_design_label(root, "Audio / Screen / System · 完整 HD 设置", Rect2(830, 20, 700, 44), 24, Color(0.12, 0.30, 0.40, 1.0))
	for index in 3:
		var tab := Button.new()
		tab.text = ""
		tab.position = Vector2(95.0 + float(index) * 250.0, 85.0)
		tab.size = Vector2(205.0, 58.0)
		tab.focus_mode = Control.FOCUS_ALL
		var tab_image := TextureRect.new()
		tab_image.texture = load(["res://assets/content/settings/audio1.png", "res://assets/content/settings/graphics1.png", "res://assets/content/settings/systems1.png"][index]) as Texture2D
		tab_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tab_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tab_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tab_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tab.add_child(tab_image)
		tab.pressed.connect(_show_tab.bind(index))
		root.add_child(tab)
		_tabs.append(tab)
	_content = VBoxContainer.new()
	_content.name = "ConfigPageContent"
	_content.position = Vector2(190.0, 170.0)
	_content.size = Vector2(1420.0, 650.0)
	_content.add_theme_constant_override("separation", 12)
	_content.clip_contents = true
	root.add_child(_content)
	_status = Label.new()
	_status.position = Vector2(260.0, 835.0)
	_status.size = Vector2(1240.0, 45.0)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status)


func _build_pages() -> void:
	if _content == null:
		return
	if _commit_timer != null:
		_commit_timer.stop()
	_pending_commit = false
	_sliders.clear()
	_options.clear()
	for child in _content.get_children():
		child.queue_free()
	_pages.clear()
	_pages.append(_build_audio_page())
	_pages.append(_build_screen_page())
	_pages.append(_build_system_page())
	for page in _pages:
		_content.add_child(page)
	_show_tab(0)
	_status.text = "设置实时预览；拖动结束或键盘/手柄调整停止 250ms 后持久化。"


func _build_audio_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "AudioPage"
	var heading := Label.new()
	heading.text = "Audio · 6 个全局音量 + 9 个角色细节音量"
	page.add_child(heading)
	var global_fields := [
		["主音量", "master_volume"], ["语音", "voice_volume"], ["BGM", "bgm_volume"],
		["环境 SE", "env_se_volume"], ["SE", "se_volume"], ["Movie", "movie_volume"],
	]
	for field in global_fields:
		_add_slider(page, str(field[0]), str(field[1]), 0.0, 1.0, 0.01)
	for index in TitleSettingsModel.VOICE_DETAIL_NAMES.size():
		_add_slider(page, "角色语音 · " + TitleSettingsModel.VOICE_DETAIL_NAMES[index], "voice_detail_%d" % index, 0.0, 1.0, 0.01, index)
	_add_check(page, "静音 Master", "mute_master")
	_add_check(page, "静音 Voice", "mute_voice")
	_add_check(page, "静音 BGM", "mute_bgm")
	return page


func _build_screen_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "ScreenPage"
	var heading := Label.new()
	heading.text = "Screen · 窗口、分辨率、透明度、字体与显示选项"
	page.add_child(heading)
	_add_option(page, "窗口模式", "window_mode", ["windowed", "borderless", "fullscreen"], ["窗口", "无边框全屏", "全屏"])
	var width_row := _add_option(page, "窗口分辨率", "window_width", [1280, 1600, 1920], ["1280", "1600", "1920"])
	if _is_mobile_platform():
		width_row.visible = false
	_add_slider(page, "窗口透明度", "window_opacity", 0.2, 1.0, 0.01)
	_add_option(page, "字体", "font_type", [0, 1, 2, 3, 4, 5], ["黑体", "宋体", "楷体", "圆体", "仿宋", "方松"])
	_add_check(page, "显示人物头像", "portrait_visible")
	_add_check(page, "已读文字变色", "read_color")
	_add_check(page, "屏幕效果", "screen_effect")
	return page


func _build_system_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "SystemPage"
	var heading := Label.new()
	heading.text = "System · 5 个系统开关、速度与 11 个确认开关"
	page.add_child(heading)
	for field in [
		["已读跳过", "read_skip"], ["点击时停止语音", "voice_stop_on_click"], ["选择后解除跳过", "lock_skip"],
		["选择后自动播放", "lock_auto"], ["路线引导", "route_guide"],
	]:
		_add_check(page, str(field[0]), str(field[1]))
	_add_slider(page, "文字速度", "message_speed", 1.0, 10.0, 1.0)
	_add_slider(page, "自动播放等待（毫秒）", "auto_speed", 1000.0, 10000.0, 500.0)
	var label := Label.new()
	label.text = "确认窗口"
	page.add_child(label)
	for key in TitleSettingsModel.CONFIRMATION_KEYS:
		_add_confirmation_check(page, key)
	return page


func _add_slider(parent: Control, label_text: String, key: String, minimum: float, maximum: float, step: float, detail_index: int = -1) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 54.0
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 260.0
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value = _get_value(key, detail_index, 1.0)
	slider.value_changed.connect(_on_slider_changed.bind(key, detail_index))
	slider.drag_ended.connect(func(_changed: bool) -> void: _commit())
	_sliders[key] = slider
	row.add_child(slider)
	parent.add_child(row)
	return row


func _add_check(parent: Control, label_text: String, key: String) -> CheckButton:
	var check := CheckButton.new()
	check.text = label_text
	check.button_pressed = bool(_values.get(key, false))
	check.toggled.connect(_on_check_changed.bind(key))
	parent.add_child(check)
	return check


func _add_confirmation_check(parent: Control, key: String) -> CheckButton:
	var check := CheckButton.new()
	check.text = "确认：%s" % key
	var confirmations: Dictionary = _values.get("confirmations", {})
	check.button_pressed = bool(confirmations.get(key, true))
	check.toggled.connect(_on_confirmation_changed.bind(key))
	parent.add_child(check)
	return check


func _add_option(parent: Control, label_text: String, key: String, values: Array, labels: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 54.0
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 260.0
	row.add_child(label)
	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for index in values.size():
		option.add_item(str(labels[index]))
		option.set_item_metadata(index, values[index])
		if values[index] == _values.get(key):
			option.select(index)
	option.item_selected.connect(_on_option_changed.bind(option, key))
	_options[key] = option
	row.add_child(option)
	parent.add_child(row)
	return row


func _on_slider_changed(value: float, key: String, detail_index: int) -> void:
	if detail_index >= 0:
		var details: Array = _values.get("voice_detail_volumes", []).duplicate()
		if detail_index < details.size():
			details[detail_index] = value
		_values["voice_detail_volumes"] = details
	else:
		_values[key] = value
	_preview_and_debounce()


func _on_check_changed(value: bool, key: String) -> void:
	_values[key] = value
	_preview_and_debounce()
	_commit()


func _on_confirmation_changed(value: bool, key: String) -> void:
	var confirmations: Dictionary = _values.get("confirmations", {}).duplicate(true)
	confirmations[key] = value
	_values["confirmations"] = confirmations
	_preview_and_debounce()
	_commit()


func _on_option_changed(index: int, option: OptionButton, key: String) -> void:
	var value: Variant = option.get_item_metadata(index)
	_values[key] = value
	if key == "window_mode":
		_apply_window_mode(str(value))
	if key == "window_width":
		DisplayServer.window_set_size(Vector2i(int(value), int(float(value) * 9.0 / 16.0)))
	_preview_and_debounce()
	_commit()


func _preview_and_debounce() -> void:
	_pending_commit = true
	settings_preview_changed.emit(_values.duplicate(true))
	if _commit_timer != null:
		_commit_timer.start()


func _commit() -> void:
	if _commit_timer != null:
		_commit_timer.stop()
	_pending_commit = false
	settings_commit_requested.emit(_values.duplicate(true))


func _show_tab(index: int) -> void:
	for page_index in _pages.size():
		_pages[page_index].visible = page_index == index


func _get_value(key: String, detail_index: int, fallback: float) -> float:
	if detail_index >= 0:
		var details: Array = _values.get("voice_detail_volumes", [])
		return float(details[detail_index]) if detail_index < details.size() else fallback
	return float(_values.get(key, fallback))


func _apply_window_mode(mode: String) -> void:
	match mode:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		_:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _is_mobile_platform() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
