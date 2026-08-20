class_name TitleVisualPage
extends Control


## Shared 1920×1080 presentation surface for the HD Title sub-pages.
##
## The data/page controllers remain ordinary Controls; only their visual
## children are placed below `visual_canvas()`.  This keeps source artwork in
## design coordinates while the canvas handles desktop/mobile safe-area
## fitting in one place.
const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const MOBILE_SAFE_FALLBACK := 24.0

var _visual_canvas: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_visual_canvas = get_node_or_null("VisualCanvas") as Control
	if _visual_canvas == null:
		_visual_canvas = Control.new()
		_visual_canvas.name = "VisualCanvas"
		_visual_canvas.position = Vector2.ZERO
		_visual_canvas.size = DESIGN_SIZE
		_visual_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(_visual_canvas)
	resized.connect(_apply_visual_transform)
	_apply_visual_transform()


func visual_canvas() -> Control:
	return _visual_canvas


func set_visual_background(texture_path: String) -> TextureRect:
	var background := get_node_or_null("VisualBackground") as TextureRect
	if background == null:
		background = TextureRect.new()
		background.name = "VisualBackground"
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(background)
		move_child(background, 0)
	background.texture = load(texture_path) as Texture2D
	return background


func add_design_texture(
		parent: Node,
		texture_path: String,
		rect: Rect2,
		stretch_mode: TextureRect.StretchMode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
) -> TextureRect:
	var texture := TextureRect.new()
	texture.name = "%sTexture%02d" % [texture_path.get_file().get_basename().to_pascal_case(), parent.get_child_count()]
	texture.texture = load(texture_path) as Texture2D
	texture.position = rect.position
	texture.size = rect.size
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = stretch_mode
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture)
	return texture


func add_design_label(
		parent: Node,
		text_value: String,
		rect: Rect2,
		font_size: int = 24,
		color := Color.WHITE
) -> Label:
	var label := Label.new()
	label.name = "DesignLabel%02d" % parent.get_child_count()
	label.text = text_value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.27, 0.38, 0.9))
	label.add_theme_constant_override("outline_size", 4)
	parent.add_child(label)
	return label


func add_design_button(parent: Node, rect: Rect2, text_value: String, font_size := 24) -> Button:
	var button := Button.new()
	button.name = "DesignButton%02d" % parent.get_child_count()
	button.position = rect.position
	button.size = rect.size
	button.text = text_value
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color(0.1, 0.32, 0.46, 1.0))
	button.add_theme_stylebox_override("normal", _style_box(Color(0.40, 0.68, 0.80, 0.82), Color(0.95, 0.98, 1.0, 0.9), 2, 12))
	button.add_theme_stylebox_override("hover", _style_box(Color(0.76, 0.90, 0.95, 0.96), Color(0.05, 0.48, 0.68, 1.0), 3, 12))
	button.add_theme_stylebox_override("pressed", _style_box(Color(0.25, 0.52, 0.68, 1.0), Color.WHITE, 3, 12))
	button.add_theme_stylebox_override("focus", _style_box(Color(0.68, 0.88, 0.95, 1.0), Color(0.03, 0.42, 0.62, 1.0), 4, 12))
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	parent.add_child(button)
	return button


func _style_box(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	return style


func _apply_visual_transform() -> void:
	if _visual_canvas == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var safe_rect := _safe_rect(size)
	var scale := minf(safe_rect.size.x / DESIGN_SIZE.x, safe_rect.size.y / DESIGN_SIZE.y)
	_visual_canvas.scale = Vector2.ONE * scale
	_visual_canvas.position = safe_rect.position + (safe_rect.size - DESIGN_SIZE * scale) * 0.5


func _safe_rect(viewport_size: Vector2) -> Rect2:
	if not _is_mobile_platform():
		return Rect2(Vector2.ZERO, viewport_size)
	var fallback := MOBILE_SAFE_FALLBACK
	var safe_area := DisplayServer.get_display_safe_area()
	var display_size := DisplayServer.screen_get_size()
	if safe_area.size.x <= 0.0 or safe_area.size.y <= 0.0 or display_size.x <= 0 or display_size.y <= 0:
		return Rect2(Vector2(fallback, fallback), Vector2(
			maxf(1.0, viewport_size.x - fallback * 2.0),
			maxf(1.0, viewport_size.y - fallback * 2.0)
		))
	var factor := Vector2(viewport_size.x / float(display_size.x), viewport_size.y / float(display_size.y))
	var position := Vector2(safe_area.position) * factor
	var end := Vector2(safe_area.position + safe_area.size) * factor
	position.x = clampf(position.x, 0.0, viewport_size.x)
	position.y = clampf(position.y, 0.0, viewport_size.y)
	end.x = clampf(end.x, position.x, viewport_size.x)
	end.y = clampf(end.y, position.y, viewport_size.y)
	var result := Rect2(position, end - position)
	if result.size.x <= 1.0 or result.size.y <= 1.0:
		return Rect2(Vector2(fallback, fallback), Vector2(
			maxf(1.0, viewport_size.x - fallback * 2.0),
			maxf(1.0, viewport_size.y - fallback * 2.0)
		))
	return result


func _is_mobile_platform() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
