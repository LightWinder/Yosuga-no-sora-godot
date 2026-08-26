class_name ScenarioUnavailableNotice
extends Control


signal dismissed

@onready var _message: Label = $Dialog/Margin/Content/Message
@onready var _close: Button = $Dialog/Margin/Content/Close


func _ready() -> void:
	_close.pressed.connect(hide_notice)
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
