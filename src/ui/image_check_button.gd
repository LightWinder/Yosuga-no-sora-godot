class_name ImageCheckButton
extends Button


## Four-frame image checkbox retained for the source confirmation dialog.
var _checked := false

var checked: bool:
	get:
		return _checked
	set(value):
		_checked = value
		set_pressed_no_signal(value)
		_refresh_visual()

var _off_normal: Texture2D
var _off_hover: Texture2D
var _on_normal: Texture2D
var _on_hover: Texture2D
var _checked_offset := Vector2.ZERO
var _visual: TextureRect
var _hovered := false
var _focused := false


func _init() -> void:
	if theme_type_variation.is_empty():
		theme_type_variation = &"SettingsImageButton"
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	toggle_mode = true
	_visual = TextureRect.new()
	_visual.name = "Visual"
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_visual.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_visual)
	toggled.connect(_on_toggled)
	mouse_entered.connect(func() -> void: _hovered = true; _refresh_visual())
	mouse_exited.connect(func() -> void: _hovered = false; _refresh_visual())
	focus_entered.connect(func() -> void: _focused = true; _refresh_visual())
	focus_exited.connect(func() -> void: _focused = false; _refresh_visual())


## configure_checkbox(strip_path, off_normal, off_hover, on_normal, on_hover)
## regions may come from different strips; pass the same texture for each.
func configure_frames(
		off_normal: Texture2D,
		off_hover: Texture2D,
		on_normal: Texture2D,
		on_hover: Texture2D,
		checked_offset := Vector2.ZERO
) -> void:
	_off_normal = off_normal
	_off_hover = off_hover
	_on_normal = on_normal
	_on_hover = on_hover
	_checked_offset = checked_offset
	var cell := Vector2.ZERO
	for texture in [off_normal, off_hover, on_normal, on_hover]:
		if texture != null:
			cell = Vector2(maxf(cell.x, texture.get_size().x), maxf(cell.y, texture.get_size().y))
	if _on_normal != null:
		cell.x = maxf(cell.x, _on_normal.get_size().x + _checked_offset.x)
	custom_minimum_size = cell
	size = cell
	_refresh_visual()


func _on_toggled(value: bool) -> void:
	_checked = value
	_refresh_visual()


func _refresh_visual() -> void:
	if disabled:
		_show_frame(_off_normal)
	elif _checked:
		_show_frame(_on_hover if (_hovered or _focused) else _on_normal)
	else:
		_show_frame(_off_hover if (_hovered or _focused) else _off_normal)


func _show_frame(texture: Texture2D) -> void:
	_visual.texture = texture
	var frame_size := texture.get_size() if texture != null else Vector2.ZERO
	_visual.size = frame_size
	var x_offset := _checked_offset.x if not is_zero_approx(_checked_offset.x) else (size.x - frame_size.x) * 0.5
	_visual.position = Vector2(x_offset, (size.y - frame_size.y) * 0.5)
