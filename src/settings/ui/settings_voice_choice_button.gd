@tool
class_name SettingsVoiceChoiceButton
extends SettingsSelectableButton


## Source-style audio character option. The translucent fill and both rounded
## keylines come from a reusable 2x SVG while the native Button keeps live text,
## focus, and input semantics.
@onready var _background: TextureRect = %Background


func _init() -> void:
	if theme_type_variation.is_empty():
		theme_type_variation = &"SettingsVoiceChoiceButton"
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_refresh_visual)
	mouse_exited.connect(_refresh_visual)
	button_down.connect(_refresh_visual)
	button_up.connect(_refresh_visual)
	focus_entered.connect(_refresh_visual)
	focus_exited.connect(_refresh_visual)


func _ready() -> void:
	_refresh_visual()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_node_ready():
		_refresh_visual()


func _selection_changed() -> void:
	_refresh_visual()


func _refresh_visual() -> void:
	if not is_node_ready() or _background == null:
		return
	var interactive := is_hovered() or has_focus() or get_draw_mode() == BaseButton.DRAW_PRESSED
	if disabled:
		_background.modulate = Color(0.78, 0.86, 0.9, 0.46)
	elif selected:
		_background.modulate = Color(0.76, 0.94, 1.0, 1.0)
	elif interactive:
		_background.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		_background.modulate = Color(1.0, 1.0, 1.0, 0.88)
