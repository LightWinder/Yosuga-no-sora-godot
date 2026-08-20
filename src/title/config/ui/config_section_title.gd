class_name ConfigSectionTitle
extends Control


## Scalable recreation of the source configuration heading: a cyan marker and
## fading strip behind white text with a blue stroke and a thin white keyline.
## Only vector canvas primitives and the project font are used, so the heading
## stays sharp when the 1920x1080 design surface is scaled on high-DPI screens.
const STRIP_COLOR := Color("#57a4cd")
const TEXT_COLOR := Color(0.98, 1.0, 1.0, 1.0)
const TEXT_OFFSET_X := 10.0
const STROKE_COLOR := Color("#2e8aa9")
const OUTER_KEYLINE_SIZE := 20
const INNER_STROKE_SIZE := 14
const STRIP_HEIGHT := 38.0

@export var caption: String = ""
@export var font_size := ConfigVisualTokens.SECTION_TITLE_FONT_SIZE

var _font_size := 44
var _outer_keyline: Label
var _foreground: Label


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false
	_outer_keyline = _create_label("OuterKeyline", TEXT_COLOR, OUTER_KEYLINE_SIZE)
	add_child(_outer_keyline)
	_foreground = _create_label("Foreground", STROKE_COLOR, INNER_STROKE_SIZE)
	add_child(_foreground)
	resized.connect(_layout_labels)


func _ready() -> void:
	_font_size = font_size
	_update_labels()
	queue_redraw()


func configure(text_value: String, rect: Rect2, font_size := 44) -> void:
	caption = text_value
	position = rect.position
	size = rect.size
	self.font_size = font_size
	_font_size = font_size
	_update_labels()
	queue_redraw()


func _draw() -> void:
	var font := ConfigVisualTokens.section_title_font()
	var text_width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1.0, _font_size).x
	var strip_top := floorf((size.y - STRIP_HEIGHT) * 0.5) + 1.0
	var strip_bottom := strip_top + STRIP_HEIGHT
	var fade_start := 0.0
	var fade_end := minf(size.x, TEXT_OFFSET_X + text_width + 40.0)

	draw_polygon(
		PackedVector2Array([
			Vector2(fade_start, strip_top),
			Vector2(fade_end, strip_top),
			Vector2(fade_end, strip_bottom),
			Vector2(fade_start, strip_bottom),
		]),
		PackedColorArray([
			STRIP_COLOR,
			Color(STRIP_COLOR.r, STRIP_COLOR.g, STRIP_COLOR.b, 0.0),
			Color(STRIP_COLOR.r, STRIP_COLOR.g, STRIP_COLOR.b, 0.0),
			STRIP_COLOR,
		])
	)


func _create_label(node_name: String, outline: Color, outline_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", ConfigVisualTokens.section_title_font())
	label.add_theme_color_override("font_color", TEXT_COLOR)
	label.add_theme_color_override("font_outline_color", outline)
	label.add_theme_constant_override("outline_size", outline_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _update_labels() -> void:
	for label in [_outer_keyline, _foreground]:
		label.text = caption
		label.add_theme_font_size_override("font_size", _font_size)
	_layout_labels()


func _layout_labels() -> void:
	var label_size := Vector2(maxf(0.0, size.x - TEXT_OFFSET_X), size.y)
	for label in [_outer_keyline, _foreground]:
		label.position = Vector2(TEXT_OFFSET_X, 0.0)
		label.size = label_size
