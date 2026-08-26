@tool
class_name SettingsTabButton
extends Button


## Text-only settings navigation tab. The stable caption stays separate from
## the selected-state decoration so localization never has to include bullets.
@export var tab_label: String:
	set(value):
		tab_label = value
		_refresh_visual()


func _init() -> void:
	if theme_type_variation.is_empty():
		theme_type_variation = &"SettingsTabButton"
	toggle_mode = true
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	toggled.connect(func(_pressed: bool) -> void: _refresh_visual())


func _ready() -> void:
	if tab_label.is_empty():
		tab_label = text
	_refresh_visual()


func _refresh_visual() -> void:
	if tab_label.is_empty():
		return
	text = "• %s •" % tab_label if button_pressed else tab_label
	if button_pressed:
		var selected_size := get_theme_constant(&"selected_font_size")
		if selected_size > 0:
			add_theme_font_size_override(&"font_size", selected_size)
	else:
		remove_theme_font_size_override(&"font_size")
