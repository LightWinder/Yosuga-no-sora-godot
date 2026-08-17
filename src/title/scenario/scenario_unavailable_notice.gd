class_name ScenarioUnavailableNotice
extends Control


signal dismissed

var _message: Label
var _close: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	visible = false


func show_request(request: ScenarioLaunchRequest) -> void:
	if _message == null:
		return
	_message.text = "正文运行层待迁移\n\n%s\n\n当前请求已经通过 typed seam 发出，但 Godot ADV runner 尚未接入。" % (request.summary() if request != null else "未知场景请求")
	visible = true
	_close.grab_focus()


func hide_notice() -> void:
	if visible:
		visible = false
		dismissed.emit()


func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -430.0
	panel.offset_top = -210.0
	panel.offset_right = 430.0
	panel.offset_bottom = 210.0
	add_child(panel)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 32)
	box.add_theme_constant_override("separation", 24)
	panel.add_child(box)
	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_message)
	_close = Button.new()
	_close.text = "返回"
	_close.custom_minimum_size.y = 64.0
	_close.pressed.connect(hide_notice)
	box.add_child(_close)
