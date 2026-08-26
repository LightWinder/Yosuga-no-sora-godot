class_name SettingsChoiceButton
extends SettingsSelectableButton


## Source-like text option: the label remains vector text while selection,
## hover and keyboard focus render as the thin cyan glow band seen in the HD
## reference. No rounded card or bitmap state strip is required.
var _hovered := false
var _pointer_pressed := false
var _focused := false
var _highlight: TextureRect


func _init() -> void:
	if theme_type_variation.is_empty():
		theme_type_variation = &"SettingsChoiceButton"
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_highlight = TextureRect.new()
	_highlight.name = "StateGlow"
	_highlight.show_behind_parent = true
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_highlight.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_highlight.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(_highlight)
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	button_down.connect(_set_pointer_pressed.bind(true))
	button_up.connect(_set_pointer_pressed.bind(false))
	focus_entered.connect(_set_focused.bind(true))
	focus_exited.connect(_set_focused.bind(false))
	resized.connect(_layout_highlight)


func _ready() -> void:
	_highlight.texture = get_theme_icon(&"state_glow")
	_layout_highlight()
	_refresh_visual()


func refresh_visual() -> void:
	_refresh_visual()


func _selection_changed() -> void:
	_refresh_visual()


func _set_hovered(value: bool) -> void:
	_hovered = value
	_refresh_visual()


func _set_pointer_pressed(value: bool) -> void:
	_pointer_pressed = value
	_refresh_visual()


func _set_focused(value: bool) -> void:
	_focused = value
	_refresh_visual()


func _layout_highlight() -> void:
	if _highlight == null:
		return
	var font := get_theme_font("font")
	var font_size := get_theme_font_size("font_size")
	var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var highlight_width := minf(size.x - 8.0, text_width + 62.0)
	var highlight_height := maxf(14.0, size.y * 0.40)
	_highlight.position = Vector2((size.x - highlight_width) * 0.5, (size.y - highlight_height) * 0.55)
	_highlight.size = Vector2(highlight_width, highlight_height)


func _refresh_visual() -> void:
	if _highlight == null:
		return
	var active := selected or _hovered or _pointer_pressed or _focused
	_highlight.visible = active and not disabled
	if not _highlight.visible:
		return
	var strength := 1.0 if selected else 0.22
	_highlight.modulate = Color(1.0, 1.0, 1.0, strength)
