class_name AdvHistoryView
extends Control


signal close_requested
signal title_requested
signal jump_requested(index: int)
signal voice_replay_requested(voice_id: String)
signal voice_favorite_requested(index: int)

const ROW_HEIGHT := 138.0
const ACTION_SIZE := Vector2(116.0, 48.0)
const PANEL_OFFSET_Y := 22.0

@export_range(0.0, 1.0, 0.01) var open_transition_seconds := 0.22
@export_range(0.0, 1.0, 0.01) var close_transition_seconds := 0.15

@onready var _shade: ColorRect = $Shade
@onready var _panel: PanelContainer = $Panel
@onready var _scroll: ScrollContainer = %HistoryScroll
@onready var _list: VBoxContainer = %HistoryList
@onready var _title_button: Button = %HistoryTitle
@onready var _close_button: Button = %HistoryClose

var _entries: Array[Dictionary] = []
var _panel_rest_position := Vector2.ZERO
var _transition_tween: Tween
var _closing := false


func _ready() -> void:
	_panel_rest_position = _panel.position
	_title_button.pressed.connect(func() -> void: title_requested.emit())
	_close_button.pressed.connect(func() -> void: close_requested.emit())
	_rebuild_rows()


func _exit_tree() -> void:
	_kill_transition()


func set_entries(entries: Array[Dictionary]) -> void:
	_entries.assign(entries)
	if is_node_ready():
		_rebuild_rows()


func open() -> void:
	_kill_transition()
	_closing = false
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_set_closing_input_passthrough(false)
	_shade.modulate.a = 0.0
	_panel.modulate.a = 0.0
	_panel.position = _panel_rest_position + Vector2(0.0, PANEL_OFFSET_Y)
	if open_transition_seconds <= 0.0:
		_finish_open()
		return
	var tween := create_tween().set_parallel(true)
	_transition_tween = tween
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_shade, "modulate:a", 1.0, open_transition_seconds)
	tween.tween_property(_panel, "modulate:a", 1.0, open_transition_seconds)
	tween.tween_property(_panel, "position", _panel_rest_position, open_transition_seconds)
	tween.finished.connect(func() -> void:
		if _transition_tween == tween:
			_transition_tween = null
			_finish_open()
	)


func close(instant := false) -> void:
	if not visible or _closing:
		return
	_closing = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_closing_input_passthrough(true)
	_kill_transition()
	if instant or close_transition_seconds <= 0.0:
		_finish_close()
		return
	var tween := create_tween().set_parallel(true)
	_transition_tween = tween
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_shade, "modulate:a", 0.0, close_transition_seconds)
	tween.tween_property(_panel, "modulate:a", 0.0, close_transition_seconds)
	tween.tween_property(
		_panel,
		"position",
		_panel_rest_position + Vector2(0.0, PANEL_OFFSET_Y),
		close_transition_seconds
	)
	tween.finished.connect(func() -> void:
		if _transition_tween == tween:
			_transition_tween = null
			_finish_close()
	)


func is_closing() -> bool:
	return _closing


func _finish_open() -> void:
	_shade.modulate.a = 1.0
	_panel.modulate.a = 1.0
	_panel.position = _panel_rest_position
	_close_button.grab_focus()
	_scroll_to_latest()


func _finish_close() -> void:
	visible = false
	_closing = false
	_shade.modulate.a = 1.0
	_panel.modulate.a = 1.0
	_panel.position = _panel_rest_position
	_set_closing_input_passthrough(false)


func _scroll_to_latest() -> void:
	await get_tree().process_frame
	if not is_inside_tree() or not visible:
		return
	var bar := _scroll.get_v_scroll_bar()
	bar.value = bar.max_value


func _rebuild_rows() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	if _entries.is_empty():
		var empty_label := Label.new()
		empty_label.custom_minimum_size = Vector2(0.0, 560.0)
		empty_label.text = tr("还没有文本履历")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 32)
		empty_label.modulate.a = 0.72
		_list.add_child(empty_label)
		return
	for entry in _entries:
		_list.add_child(_make_row(entry))
	if visible:
		_scroll_to_latest()


func _make_row(entry: Dictionary) -> Control:
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(0.0, ROW_HEIGHT)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.15, 0.19, 0.68)
	style.border_width_bottom = 2
	style.border_color = Color(0.44, 0.77, 0.84, 0.28)
	style.content_margin_left = 24.0
	style.content_margin_right = 18.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	row.add_theme_stylebox_override("panel", style)

	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 22)
	row.add_child(content)

	var speaker := Label.new()
	speaker.custom_minimum_size = Vector2(185.0, 0.0)
	speaker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	speaker.text = _display_speaker(str(entry.get("speaker", "")))
	speaker.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speaker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	speaker.theme_type_variation = &"AdvSpeakerLabel"
	speaker.add_theme_font_size_override("font_size", 31)
	content.add_child(speaker)

	var separator := VSeparator.new()
	separator.modulate = Color(0.65, 0.9, 0.96, 0.48)
	content.add_child(separator)

	var message := Label.new()
	message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message.text = str(entry.get("message", ""))
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0))
	message.add_theme_color_override("font_outline_color", Color(0.01, 0.08, 0.11, 0.92))
	message.add_theme_constant_override("outline_size", 3)
	message.add_theme_font_size_override("font_size", 29)
	content.add_child(message)

	var actions := HBoxContainer.new()
	actions.custom_minimum_size = Vector2(372.0, 0.0)
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 8)
	content.add_child(actions)

	var voice_id := str(entry.get("voice_id", ""))
	var entry_index := int(entry.get("index", -1))
	if not voice_id.is_empty():
		var replay := _make_action_button("▶ %s" % tr("语音"), tr("重播当前语音"))
		replay.pressed.connect(func() -> void: voice_replay_requested.emit(voice_id))
		actions.add_child(replay)
		var favorite := _make_action_button("♡", tr("收藏当前语音"))
		favorite.pressed.connect(func() -> void: voice_favorite_requested.emit(entry_index))
		actions.add_child(favorite)
	if bool(entry.get("can_jump", false)):
		var jump := _make_action_button("↩", tr("[跳转到这里]"))
		jump.pressed.connect(func() -> void: jump_requested.emit(entry_index))
		actions.add_child(jump)
	return row


func _make_action_button(label: String, tooltip: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = ACTION_SIZE
	button.text = label
	button.tooltip_text = tooltip
	button.theme_type_variation = &"SharedPrimaryActionButton"
	button.add_theme_font_size_override("font_size", 22)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return button


func _display_speaker(speaker: String) -> String:
	var normalized := speaker.strip_edges()
	if normalized.is_empty() or normalized in ["心の声", "語り", "モノローグ"]:
		return tr("旁白")
	return normalized


func _kill_transition() -> void:
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = null


func _set_closing_input_passthrough(passthrough: bool) -> void:
	_shade.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE if passthrough else Control.MOUSE_FILTER_STOP
	)
	_panel.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE if passthrough else Control.MOUSE_FILTER_STOP
	)
	_scroll.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE if passthrough else Control.MOUSE_FILTER_STOP
	)
	_title_button.disabled = passthrough
	_close_button.disabled = passthrough
	for button in _list.find_children("*", "Button", true, false):
		(button as Button).disabled = passthrough
