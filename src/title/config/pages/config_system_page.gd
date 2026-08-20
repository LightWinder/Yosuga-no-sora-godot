class_name ConfigSystemPage
extends ConfigPageBase


## System tab: five YES/NO system toggles, message/auto speed sliders and the
## eleven confirmation checkboxes.
const SYSTEM_ROOT := "res://assets/content/settings/system/"
const SYSTEM_TOGGLE_KEYS: Array[String] = ["read_skip", "voice_stop_on_click", "lock_skip", "lock_auto", "route_guide"]
const SYSTEM_YES_Y: Array[float] = [319.0, 384.0, 459.0, 534.0, 609.0]
const CONFIRM_POSITIONS: Array[Vector2] = [
	Vector2(1218, 419), Vector2(1427, 419), Vector2(1715, 419),
	Vector2(1290, 506), Vector2(1569, 506),
	Vector2(1290, 593), Vector2(1569, 593),
	Vector2(1330, 684), Vector2(1724, 684),
	Vector2(1330, 776), Vector2(1728, 776),
]

var _yes_buttons: Array[ConfigToggleButton] = []
var _no_buttons: Array[ConfigToggleButton] = []
var _confirm_buttons: Array[ConfigCheckButton] = []
var _message_speed_slider: ConfigKnobSlider
var _auto_speed_slider: ConfigKnobSlider


func _ready() -> void:
	super._ready()
	add_page_background(SYSTEM_ROOT + "bg.png")
	for index in SYSTEM_TOGGLE_KEYS.size():
		var y := SYSTEM_YES_Y[index]
		var yes := add_dual_toggle(SYSTEM_ROOT + "YES1.png", SYSTEM_ROOT + "YES2.png", Vector2(634, y), 77, 79, 77)
		var no := add_dual_toggle(SYSTEM_ROOT + "NO1.png", SYSTEM_ROOT + "NO2.png", Vector2(788, y), 59, 61, 59, Vector2(-4, 0))
		yes.pressed.connect(_on_yes_pressed.bind(index))
		no.pressed.connect(_on_no_pressed.bind(index))
		_yes_buttons.append(yes)
		_no_buttons.append(no)
	_message_speed_slider = add_slider("message_speed", Vector2(500, 742), Vector2(921, 742), 1.0, 1.0)
	_message_speed_slider.value_changed.connect(_on_message_speed_changed)
	_auto_speed_slider = add_slider("auto_speed", Vector2(500, 827), Vector2(921, 827), 1.0, 1.0)
	_auto_speed_slider.value_changed.connect(_on_auto_speed_changed)
	var checkbox_texture := load(SYSTEM_ROOT + "checkbox.png") as Texture2D
	var off_rect := Rect2(0, 0, checkbox_texture.get_height(), checkbox_texture.get_height())
	var on_rect := Rect2(checkbox_texture.get_height() * 2, 0, checkbox_texture.get_height() + 6, checkbox_texture.get_height())
	for index in TitleSettingsModel.CONFIRMATION_KEYS.size():
		var button := add_check_box(checkbox_texture, off_rect, off_rect, on_rect, on_rect, CONFIRM_POSITIONS[index], Vector2(3.0, 0.0))
		button.toggled.connect(_on_confirmation_toggled.bind(index))
		_confirm_buttons.append(button)


func sync_from(settings: Dictionary) -> void:
	for index in SYSTEM_TOGGLE_KEYS.size():
		var enabled := _ui_enabled_for_system_toggle(index, settings)
		_yes_buttons[index].selected = enabled
		_no_buttons[index].selected = not enabled
	# Source maps slider trim inversely: speed = range - trim.
	_message_speed_slider.set_value_silent(100.0 - float(settings.get("message_speed", 5)))
	_auto_speed_slider.set_value_silent(100.0 - float(settings.get("auto_speed", 5000)) / 100.0)
	var confirmations: Dictionary = settings.get("confirmations", {})
	for index in TitleSettingsModel.CONFIRMATION_KEYS.size():
		_confirm_buttons[index].checked = bool(confirmations.get(TitleSettingsModel.CONFIRMATION_KEYS[index], true))


func _on_yes_pressed(index: int) -> void:
	# The source stores readSkip inverted: 0 means "allow unread skip" while
	# the other four HD switches use a direct boolean value.
	emit_patch({SYSTEM_TOGGLE_KEYS[index]: _stored_value_for_system_toggle(index, true)}, true)


func _on_no_pressed(index: int) -> void:
	emit_patch({SYSTEM_TOGGLE_KEYS[index]: _stored_value_for_system_toggle(index, false)}, true)


func _on_message_speed_changed(value: float) -> void:
	emit_patch({"message_speed": int(100.0 - value)})


func _on_auto_speed_changed(value: float) -> void:
	emit_patch({"auto_speed": int((100.0 - value) * 100.0)})


func _on_confirmation_toggled(enabled: bool, index: int) -> void:
	emit_patch({"confirmations": {TitleSettingsModel.CONFIRMATION_KEYS[index]: enabled}}, true)


func set_system_toggle_for_test(key: String, enabled: bool) -> void:
	var index := SYSTEM_TOGGLE_KEYS.find(key)
	if index < 0:
		return
	var stored_value := _stored_value_for_system_toggle(index, enabled)
	emit_patch({key: stored_value}, true)
	_yes_buttons[index].selected = enabled
	_no_buttons[index].selected = not enabled


func set_confirmation_for_test(key: String, enabled: bool) -> void:
	var index := TitleSettingsModel.CONFIRMATION_KEYS.find(key)
	if index < 0:
		return
	_confirm_buttons[index].checked = enabled
	_on_confirmation_toggled(enabled, index)


func _ui_enabled_for_system_toggle(index: int, settings: Dictionary) -> bool:
	var stored_value := bool(settings.get(SYSTEM_TOGGLE_KEYS[index], false))
	return not stored_value if index == 0 else stored_value


func _stored_value_for_system_toggle(index: int, ui_enabled: bool) -> bool:
	return not ui_enabled if index == 0 else ui_enabled
