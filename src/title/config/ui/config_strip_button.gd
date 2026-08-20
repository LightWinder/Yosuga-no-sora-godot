class_name ConfigStripButton
extends Button


## Two/three-state strip button mirroring the source HDStripButton
## (normal / hover / disabled frames), used by the config footer.
var _normal_texture: Texture2D
var _hover_texture: Texture2D
var _disabled_texture: Texture2D
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


## first_state_width/last_state_width mirror HDStripButton: for three states the
## middle frame takes the remaining pixels; for two states the first width
## splits normal/hover.  Zero falls back to equal frames.
func configure_strip(strip_path: String, state_count := 2, first_state_width := 0, last_state_width := 0) -> void:
	var strip := load(strip_path) as Texture2D
	if strip == null:
		return
	var strip_width := strip.get_width()
	var strip_height := strip.get_height()
	var normal_width := first_state_width if first_state_width > 0 else strip_width / state_count
	var normal_region := Rect2(0, 0, normal_width, strip_height)
	var hover_region: Rect2
	var disabled_region: Rect2
	if state_count >= 3:
		var disabled_width := last_state_width if last_state_width > 0 else normal_width
		var hover_width := strip_width - normal_width - disabled_width
		hover_region = Rect2(normal_width, 0, hover_width, strip_height)
		disabled_region = Rect2(strip_width - disabled_width, 0, disabled_width, strip_height)
	else:
		var hover_width := strip_width - normal_width
		hover_region = Rect2(normal_width, 0, hover_width, strip_height)
		disabled_region = normal_region
	_normal_texture = _region(strip, normal_region)
	_hover_texture = _region(strip, hover_region)
	_disabled_texture = _region(strip, disabled_region)
	var cell := Vector2(
		maxf(normal_region.size.x, hover_region.size.x),
		float(strip_height)
	)
	custom_minimum_size = cell
	size = cell
	_refresh_visual()


func _region(atlas: Texture2D, region: Rect2) -> Texture2D:
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = region
	result.filter_clip = true
	return result


func _refresh_visual() -> void:
	if disabled:
		_show_frame(_disabled_texture)
	elif _pressed or _hovered or _focused:
		_show_frame(_hover_texture)
	else:
		_show_frame(_normal_texture)


func _show_frame(texture: Texture2D) -> void:
	_visual.texture = texture
	var frame_size := texture.get_size() if texture != null else Vector2.ZERO
	_visual.size = frame_size
	_visual.position = (size - frame_size) * 0.5
