class_name DisplaySettingsPage
extends SettingsPageBase


## Display-settings controller. The scene owns the complete visual hierarchy;
## this script only groups choices, translates UI values and updates preview
## state.
const WINDOW_MODES: Array[String] = ["fullscreen", "windowed"]
const RESOLUTION_WIDTHS: Array[int] = [1920, 1600, 1280]
const FONT_TYPES: Array[int] = [2, 4, 0, 3, 5, 1]

const WINDOW_MODE_KEY := &"window_mode"
const WINDOW_WIDTH_KEY := &"window_width"
const FONT_TYPE_KEY := &"font_type"
const WINDOW_DEPTH_KEY := &"window_depth"
const PORTRAIT_VISIBLE_KEY := &"portrait_visible"
const READ_COLOR_KEY := &"read_color"
const SCREEN_EFFECT_KEY := &"screen_effect"

var _window_mode_choices := SettingsChoiceGroup.new()
var _resolution_choices := SettingsChoiceGroup.new()
var _font_choices := SettingsChoiceGroup.new()
var _toggle_choices: Dictionary[StringName, SettingsChoiceGroup] = {}

@onready var _window_mode_buttons: Array[SettingsChoiceButton] = [
	%FullscreenChoice,
	%WindowedChoice,
]
@onready var _resolution_buttons: Array[SettingsChoiceButton] = [
	%Resolution1920Choice,
	%Resolution1600Choice,
	%Resolution1280Choice,
]
@onready var _font_buttons: Array[SettingsChoiceButton] = [
	%FontGothicChoice,
	%FontSongChoice,
	%FontRoundedChoice,
	%FontKaiChoice,
	%FontFangSongChoice,
	%FontBitmapSongChoice,
]
@onready var _portrait_buttons: Array[SettingsChoiceButton] = [
	%PortraitOnChoice,
	%PortraitOffChoice,
]
@onready var _read_color_buttons: Array[SettingsChoiceButton] = [
	%ReadColorOnChoice,
	%ReadColorOffChoice,
]
@onready var _screen_effect_buttons: Array[SettingsChoiceButton] = [
	%ScreenEffectOnChoice,
	%ScreenEffectOffChoice,
]
@onready var _opacity_slider: SettingsKnobSlider = %window_depth
@onready var _preview_textbox: TextureRect = %PreviewTextbox
@onready var _preview_avatar: TextureRect = %PreviewAvatar
@onready var _preview_text: Label = %PreviewText


func _ready() -> void:
	super._ready()
	_configure_window_choices()
	_configure_font_choices()
	_configure_screen_toggles()
	register_setting_slider(_opacity_slider)
	_opacity_slider.value_changed.connect(_on_opacity_changed)
	if _is_mobile_platform():
		_set_desktop_window_controls_visible(false)


func sync_from(settings: Dictionary) -> void:
	_window_mode_choices.select_value(str(settings.get(WINDOW_MODE_KEY, "windowed")))
	_resolution_choices.select_value(int(settings.get(WINDOW_WIDTH_KEY, 1280)))
	_font_choices.select_value(int(settings.get(FONT_TYPE_KEY, 0)))
	for key in _toggle_choices:
		_toggle_choices[key].select_value(bool(settings.get(key, true)))
	_opacity_slider.set_value_silent(float(settings.get(WINDOW_DEPTH_KEY, 50)))
	_refresh_preview(settings)


func select_window_mode(mode: String) -> void:
	var normalized := "fullscreen" if mode == "fullscreen" else "windowed"
	emit_patch({WINDOW_MODE_KEY: normalized}, true)


func select_resolution(width: int) -> void:
	if RESOLUTION_WIDTHS.has(width):
		emit_patch({WINDOW_WIDTH_KEY: width}, true)


func select_font(font_type: int) -> void:
	if FONT_TYPES.has(font_type):
		emit_patch({FONT_TYPE_KEY: font_type}, true)


func set_screen_toggle(key: StringName, enabled: bool) -> void:
	if _toggle_choices.has(key):
		emit_patch({key: enabled}, true)


func _configure_window_choices() -> void:
	assert(_window_mode_buttons.size() == WINDOW_MODES.size())
	for index in _window_mode_buttons.size():
		_window_mode_choices.add_choice(_window_mode_buttons[index], WINDOW_MODES[index])
	_window_mode_choices.value_selected.connect(_on_window_mode_selected)

	assert(_resolution_buttons.size() == RESOLUTION_WIDTHS.size())
	for index in _resolution_buttons.size():
		_resolution_choices.add_choice(_resolution_buttons[index], RESOLUTION_WIDTHS[index])
	_resolution_choices.value_selected.connect(_on_resolution_selected)


func _configure_font_choices() -> void:
	assert(_font_buttons.size() == FONT_TYPES.size())
	for index in _font_buttons.size():
		_font_choices.add_choice(_font_buttons[index], FONT_TYPES[index])
	_font_choices.value_selected.connect(_on_font_selected)


func _configure_screen_toggles() -> void:
	_toggle_choices[PORTRAIT_VISIBLE_KEY] = _create_boolean_group(PORTRAIT_VISIBLE_KEY, _portrait_buttons)
	_toggle_choices[READ_COLOR_KEY] = _create_boolean_group(READ_COLOR_KEY, _read_color_buttons)
	_toggle_choices[SCREEN_EFFECT_KEY] = _create_boolean_group(SCREEN_EFFECT_KEY, _screen_effect_buttons)


func _create_boolean_group(key: StringName, buttons: Array[SettingsChoiceButton]) -> SettingsChoiceGroup:
	assert(buttons.size() == 2)
	var group := SettingsChoiceGroup.new()
	group.add_choice(buttons[0], true)
	group.add_choice(buttons[1], false)
	group.value_selected.connect(_on_screen_toggle_selected.bind(key))
	return group


func _on_window_mode_selected(value: Variant) -> void:
	emit_patch({WINDOW_MODE_KEY: str(value)}, true)


func _on_resolution_selected(value: Variant) -> void:
	emit_patch({WINDOW_WIDTH_KEY: int(value)}, true)


func _on_font_selected(value: Variant) -> void:
	emit_patch({FONT_TYPE_KEY: int(value)}, true)


func _on_opacity_changed(value: float) -> void:
	emit_patch({WINDOW_DEPTH_KEY: int(value)})
	_preview_textbox.modulate.a = value / 100.0


func _on_screen_toggle_selected(value: Variant, key: StringName) -> void:
	emit_patch({key: bool(value)}, true)


func _refresh_preview(settings: Dictionary) -> void:
	_preview_textbox.modulate.a = float(settings.get(WINDOW_DEPTH_KEY, 50)) / 100.0
	_preview_avatar.visible = bool(settings.get(PORTRAIT_VISIBLE_KEY, true))
	var read_color_enabled := bool(settings.get(READ_COLOR_KEY, true))
	var text_color := Color(0.55, 0.72, 0.92, 1.0) if read_color_enabled else Color.WHITE
	_preview_text.add_theme_color_override("font_color", text_color)


func _set_desktop_window_controls_visible(visible_value: bool) -> void:
	_window_mode_choices.set_visible(visible_value)
	_resolution_choices.set_visible(visible_value)


func _is_mobile_platform() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
