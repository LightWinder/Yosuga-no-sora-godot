class_name TextActionButton
extends Button


## Resolution-independent text button used by settings footer actions
## and popup controls. Labels remain editable/localizable text; only the
## decorative artwork elsewhere in the screen stays texture based.
var _hovered := false
var _focused := false


func _init() -> void:
	if theme_type_variation.is_empty():
		theme_type_variation = &"SettingsFooterButton"
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	focus_entered.connect(_set_focused.bind(true))
	focus_exited.connect(_set_focused.bind(false))


func _ready() -> void:
	_refresh_outline()


func _set_hovered(value: bool) -> void:
	_hovered = value
	_refresh_outline()


func _set_focused(value: bool) -> void:
	_focused = value
	_refresh_outline()


func _refresh_outline() -> void:
	if (_hovered or _focused) and not disabled:
		add_theme_color_override("font_outline_color", get_theme_color(&"hover_outline_color"))
	else:
		remove_theme_color_override("font_outline_color")
