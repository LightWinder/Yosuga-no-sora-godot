class_name ConfigToggleButton
extends Button


## Dual-image toggle mirroring the source HDToggleDualButton / HDToggleStripButton:
## a normal strip (normal + hover frames) plus a separate selected image.
var _selected := false

var selected: bool:
	get:
		return _selected
	set(value):
		_selected = value
		_refresh_visual()

var _normal_texture: Texture2D
var _hover_texture: Texture2D
var _selected_texture: Texture2D
var _selected_offset := Vector2.ZERO
var _visual: TextureRect
var _hovered := false
var _pressed := false
var _focused := false


func _init() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var flat := StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", flat)
	add_theme_stylebox_override("hover", flat)
	add_theme_stylebox_override("pressed", flat)
	add_theme_stylebox_override("focus", flat)
	add_theme_stylebox_override("disabled", flat)
	_visual = TextureRect.new()
	_visual.name = "Visual"
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_visual.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_visual)
	mouse_entered.connect(func() -> void: _hovered = true; _refresh_visual())
	mouse_exited.connect(func() -> void: _hovered = false; _refresh_visual())
	button_down.connect(func() -> void: _pressed = true; _refresh_visual())
	button_up.connect(func() -> void: _pressed = false; _refresh_visual())
	focus_entered.connect(func() -> void: _focused = true; _refresh_visual())
	focus_exited.connect(func() -> void: _focused = false; _refresh_visual())


## normal_width/hover_x/hover_width are expressed on the normal strip; the
## selected image is used whole.  Zero/negative values fall back to the source
## convention: normal = first half, hover = second half.
func configure_dual(
		normal_path: String,
		selected_path: String,
		normal_width := 0,
		hover_x := -1,
		hover_width := 0,
		selected_offset := Vector2.ZERO
) -> void:
	var strip := load(normal_path) as Texture2D
	var strip_width := strip.get_width() if strip != null else 0
	var strip_height := strip.get_height() if strip != null else 0
	var normal_w := normal_width if normal_width > 0 else strip_width / 2
	var hover_src_x := hover_x if hover_x >= 0 else normal_w
	var hover_w := hover_width if hover_width > 0 else strip_width - hover_src_x
	_normal_texture = _region(strip, Rect2(0, 0, normal_w, strip_height))
	_hover_texture = _region(strip, Rect2(hover_src_x, 0, hover_w, strip_height))
	_selected_texture = load(selected_path) as Texture2D
	_selected_offset = selected_offset
	_apply_cell_size()


## Three-frame strip where the third frame is the selected state (voice name buttons).
func configure_strip_toggle(strip_path: String) -> void:
	var strip := load(strip_path) as Texture2D
	var frame_width := strip.get_width() / 3 if strip != null else 0
	var strip_height := strip.get_height() if strip != null else 0
	_normal_texture = _region(strip, Rect2(0, 0, frame_width, strip_height))
	_hover_texture = _region(strip, Rect2(frame_width, 0, frame_width, strip_height))
	_selected_texture = _region(strip, Rect2(frame_width * 2, 0, frame_width, strip_height))
	_selected_offset = Vector2.ZERO
	_apply_cell_size()


func _region(atlas: Texture2D, region: Rect2) -> Texture2D:
	if atlas == null:
		return null
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = region
	result.filter_clip = true
	return result


func _apply_cell_size() -> void:
	var sizes: Array[Vector2] = []
	for texture in [_normal_texture, _hover_texture, _selected_texture]:
		if texture != null:
			sizes.append(texture.get_size())
	var cell := Vector2.ZERO
	for entry in sizes:
		cell = Vector2(maxf(cell.x, entry.x), maxf(cell.y, entry.y))
	cell += Vector2(absf(_selected_offset.x) * 2.0, absf(_selected_offset.y) * 2.0)
	custom_minimum_size = cell
	size = cell
	_refresh_visual()


func _refresh_visual() -> void:
	# A selected-but-noninteractive source control (the fixed Chinese language
	# option) must still render its selected artwork. Disabled only suppresses
	# hover/focus for unselected controls.
	if _selected:
		_show_frame(_selected_texture, _selected_offset)
	elif disabled:
		_show_frame(_normal_texture, Vector2.ZERO)
	elif _pressed or _hovered or _focused:
		_show_frame(_hover_texture, Vector2.ZERO)
	else:
		_show_frame(_normal_texture, Vector2.ZERO)


func _show_frame(texture: Texture2D, offset: Vector2) -> void:
	_visual.texture = texture
	var frame_size := texture.get_size() if texture != null else Vector2.ZERO
	_visual.size = frame_size
	_visual.position = (size - frame_size) * 0.5 + offset
