@tool
class_name ConfirmationOverlay
extends Control


## Shared, scene-owned confirmation overlay. Owners provide the message and
## action labels, while the overlay owns modal focus and focus restoration.
signal confirmed
signal canceled

var _return_focus: Control

@onready var _confirm_button: Button = $Dialog/Margin/Content/Actions/Confirm
@onready var _cancel_button: Button = $Dialog/Margin/Content/Actions/Cancel
@onready var _message: Label = $Dialog/Margin/Content/Message


func _ready() -> void:
	_confirm_button.pressed.connect(func() -> void: confirmed.emit())
	_cancel_button.pressed.connect(func() -> void: canceled.emit())
	visible = false


func open(
		message: String = "要结束游戏吗？",
		confirm_text: String = "结束游戏",
		cancel_text: String = "取消"
) -> void:
	if not visible:
		var focus_owner := get_viewport().gui_get_focus_owner()
		if focus_owner != null and not is_ancestor_of(focus_owner):
			_return_focus = focus_owner
	_message.text = message
	_confirm_button.text = confirm_text
	_cancel_button.text = cancel_text
	visible = true
	_cancel_button.grab_focus()


func close() -> void:
	if not visible:
		return
	visible = false
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and is_ancestor_of(focus_owner):
		focus_owner.release_focus()
	var return_focus := _return_focus
	_return_focus = null
	if _can_restore_focus(return_focus):
		return_focus.call_deferred("grab_focus")


func _can_restore_focus(control: Control) -> bool:
	if not is_instance_valid(control) or not control.is_visible_in_tree():
		return false
	if control.focus_mode == Control.FOCUS_NONE:
		return false
	return not (control is BaseButton and (control as BaseButton).disabled)
