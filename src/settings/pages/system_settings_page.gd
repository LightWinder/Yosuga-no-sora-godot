class_name SystemSettingsPage
extends SettingsPageBase


## System-settings controller. The scene owns all visual nodes; this script
## only maps the source setting values to reusable choice groups and sliders.
const SYSTEM_TOGGLE_KEYS: Array[StringName] = [
	&"read_skip",
	&"voice_stop_on_click",
	&"lock_skip",
	&"lock_auto",
	&"route_guide",
]

var _system_toggle_choices: Array[SettingsChoiceGroup] = []

@onready var _system_toggle_buttons: Array = [
	[%ReadSkipYesChoice, %ReadSkipNoChoice],
	[%VoiceStopYesChoice, %VoiceStopNoChoice],
	[%LockSkipYesChoice, %LockSkipNoChoice],
	[%LockAutoYesChoice, %LockAutoNoChoice],
	[%RouteGuideYesChoice, %RouteGuideNoChoice],
]
@onready var _confirmation_buttons: Array[SettingsCheckChoiceButton] = [
	%LoadConfirmation,
	%OverwriteConfirmation,
	%DeleteConfirmation,
	%CopyConfirmation,
	%MoveConfirmation,
	%TitleConfirmation,
	%EndConfirmation,
	%SelectJumpConfirmation,
	%LogJumpConfirmation,
	%DefaultConfirmation,
	%ClearReadConfirmation,
]
@onready var _message_speed_slider: SettingsKnobSlider = %message_speed
@onready var _auto_speed_slider: SettingsKnobSlider = %auto_speed


func _ready() -> void:
	super._ready()
	_configure_system_toggle_choices()
	_configure_confirmation_choices()
	register_setting_slider(_message_speed_slider)
	_message_speed_slider.value_changed.connect(_on_message_speed_changed)
	register_setting_slider(_auto_speed_slider)
	_auto_speed_slider.value_changed.connect(_on_auto_speed_changed)


func sync_from(settings: Dictionary) -> void:
	for index in SYSTEM_TOGGLE_KEYS.size():
		_system_toggle_choices[index].select_value(_ui_enabled_for_system_toggle(index, settings))
	# Source maps slider trim inversely: speed = range - trim.
	_message_speed_slider.set_value_silent(100.0 - float(settings.get("message_speed", 5)))
	_auto_speed_slider.set_value_silent(100.0 - float(settings.get("auto_speed", 5000)) / 100.0)
	var confirmations: Dictionary = settings.get("confirmations", {})
	for index in SettingsModel.CONFIRMATION_KEYS.size():
		_set_confirmation_visual(index, bool(confirmations.get(SettingsModel.CONFIRMATION_KEYS[index], true)))


func set_system_toggle_for_test(key: String, enabled: bool) -> void:
	var index := SYSTEM_TOGGLE_KEYS.find(StringName(key))
	if index < 0:
		return
	_system_toggle_choices[index].select_value(enabled)
	_on_system_toggle_selected(enabled, index)


func set_confirmation_for_test(key: String, enabled: bool) -> void:
	var index := SettingsModel.CONFIRMATION_KEYS.find(key)
	if index < 0:
		return
	_set_confirmation_visual(index, enabled)
	_on_confirmation_toggled(enabled, index)


func _configure_system_toggle_choices() -> void:
	assert(_system_toggle_buttons.size() == SYSTEM_TOGGLE_KEYS.size())
	for index in SYSTEM_TOGGLE_KEYS.size():
		var buttons: Array = _system_toggle_buttons[index]
		assert(buttons.size() == 2)
		var group := SettingsChoiceGroup.new()
		group.add_choice(buttons[0] as SettingsChoiceButton, true)
		group.add_choice(buttons[1] as SettingsChoiceButton, false)
		group.value_selected.connect(_on_system_toggle_selected.bind(index))
		_system_toggle_choices.append(group)


func _configure_confirmation_choices() -> void:
	assert(_confirmation_buttons.size() == SettingsModel.CONFIRMATION_KEYS.size())
	for index in _confirmation_buttons.size():
		_confirmation_buttons[index].toggled.connect(_on_confirmation_toggled.bind(index))


func _on_system_toggle_selected(enabled: Variant, index: int) -> void:
	# The source stores readSkip inverted: false means "allow unread skip";
	# the other four switches use their UI value directly.
	emit_patch({SYSTEM_TOGGLE_KEYS[index]: _stored_value_for_system_toggle(index, bool(enabled))}, true)


func _on_message_speed_changed(value: float) -> void:
	emit_patch({"message_speed": int(100.0 - value)})


func _on_auto_speed_changed(value: float) -> void:
	emit_patch({"auto_speed": int((100.0 - value) * 100.0)})


func _on_confirmation_toggled(enabled: bool, index: int) -> void:
	emit_patch({"confirmations": {SettingsModel.CONFIRMATION_KEYS[index]: enabled}}, true)


func _set_confirmation_visual(index: int, enabled: bool) -> void:
	_confirmation_buttons[index].checked = enabled


func _ui_enabled_for_system_toggle(index: int, settings: Dictionary) -> bool:
	var stored_value := bool(settings.get(SYSTEM_TOGGLE_KEYS[index], false))
	return not stored_value if index == 0 else stored_value


func _stored_value_for_system_toggle(index: int, ui_enabled: bool) -> bool:
	return not ui_enabled if index == 0 else ui_enabled
