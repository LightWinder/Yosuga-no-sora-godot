class_name SettingsChrome
extends Control


## Static navigation and overlay chrome for the settings window. The
## settings page owns data; this component owns only its tabs, footer, status
## message and modal presentation.
signal tab_selected(index: int)
signal reset_settings_requested
signal reset_read_requested
signal close_requested
signal confirmation_accepted(action: StringName)
signal confirmation_canceled(action: StringName)
signal confirmation_preference_changed(action: StringName, checked: bool)

enum Tab {
	DISPLAY,
	SYSTEM,
	AUDIO,
}

var _current_tab := Tab.DISPLAY
var _confirmation_action: StringName = &""
var _confirmation_return_focus: Control

@onready var _tabs: Array[SettingsTabButton] = [
	%DisplayTab,
	%SystemTab,
	%AudioTab,
]
@onready var _reset_settings_button: SettingsTextButton = $ResetSettings
@onready var _reset_read_button: SettingsTextButton = $ResetRead
@onready var _open_key_popup_button: SettingsTextButton = $OpenKeyPopup
@onready var _close_settings_button: SettingsTextButton = $CloseSettings
@onready var _status_label: Label = $SettingsStatus
@onready var _status_clear_timer: Timer = $StatusClearTimer
@onready var _key_popup: SettingsKeyPopup = $KeyPopup
@onready var _confirm_dialog: SettingsConfirmDialog = $SettingsConfirm


func _ready() -> void:
	_tabs[0].button_group.pressed.connect(_on_tab_button_pressed)
	_reset_settings_button.pressed.connect(func() -> void: reset_settings_requested.emit())
	_reset_read_button.pressed.connect(func() -> void: reset_read_requested.emit())
	_open_key_popup_button.pressed.connect(_on_key_popup_requested)
	_close_settings_button.pressed.connect(func() -> void: close_requested.emit())
	_status_clear_timer.timeout.connect(func() -> void: _status_label.text = "")
	_key_popup.close_requested.connect(close_key_popup)
	_key_popup.closed.connect(_on_key_popup_closed)
	_confirm_dialog.confirmed.connect(accept_confirmation)
	_confirm_dialog.canceled.connect(cancel_confirmation)
	_confirm_dialog.always_toggled.connect(_on_confirmation_preference_changed)
	_confirm_dialog.closed.connect(_on_confirmation_closed)
	select_tab(Tab.DISPLAY)


func select_tab(index: int) -> void:
	_current_tab = clampi(index, Tab.DISPLAY, Tab.AUDIO)
	for tab_index in _tabs.size():
		_tabs[tab_index].button_pressed = tab_index == _current_tab


func current_tab() -> int:
	return _current_tab


func grab_tab_focus() -> void:
	_tabs[_current_tab].grab_focus()


func show_status(message: String) -> void:
	_status_label.text = message
	_status_clear_timer.start()


func open_key_popup() -> void:
	_key_popup.open()


func close_key_popup() -> void:
	if not _key_popup.is_open():
		return
	_key_popup.close()


func is_key_popup_open() -> bool:
	return _key_popup.is_open()


func is_key_popup_active() -> bool:
	return _key_popup.is_active()


func open_confirmation(action: StringName, message: String, always_enabled: bool) -> void:
	_confirmation_action = action
	_confirmation_return_focus = _reset_settings_button if action == &"reset_settings" else _reset_read_button
	_confirm_dialog.open(message, always_enabled)


func accept_confirmation() -> void:
	if _confirmation_action.is_empty():
		return
	var action := _confirmation_action
	_confirmation_action = &""
	_confirm_dialog.close()
	confirmation_accepted.emit(action)


func cancel_confirmation() -> void:
	if _confirmation_action.is_empty():
		return
	var action := _confirmation_action
	_confirmation_action = &""
	_confirm_dialog.close()
	confirmation_canceled.emit(action)


func is_confirmation_open() -> bool:
	return _confirm_dialog.is_open()


func is_confirmation_active() -> bool:
	return _confirm_dialog.is_active()


func _on_tab_button_pressed(button: BaseButton) -> void:
	var index := _tabs.find(button)
	if index < 0:
		return
	select_tab(index)
	tab_selected.emit(index)


func _on_key_popup_requested() -> void:
	open_key_popup()


func _on_key_popup_closed() -> void:
	if _open_key_popup_button.is_visible_in_tree():
		_open_key_popup_button.grab_focus()


func _on_confirmation_closed() -> void:
	if _confirmation_return_focus != null and _confirmation_return_focus.is_visible_in_tree():
		_confirmation_return_focus.grab_focus()
	_confirmation_return_focus = null


func _on_confirmation_preference_changed(checked: bool) -> void:
	if not _confirmation_action.is_empty():
		confirmation_preference_changed.emit(_confirmation_action, checked)
