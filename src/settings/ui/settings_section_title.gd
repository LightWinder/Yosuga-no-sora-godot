@tool
class_name SettingsSectionTitle
extends Control


## Scalable recreation of the source settings heading: a cyan marker and
## fading strip behind white text with a blue stroke and a thin white keyline.
## Only vector canvas primitives and the project font are used, so the heading
## stays sharp when the 1920x1080 design surface is scaled on high-DPI screens.
@export var caption: String = "":
	set(value):
		caption = value
		_refresh_preview()
@export_range(0, 128, 1) var font_size_override := 0:
	set(value):
		font_size_override = value
		_refresh_preview()

var _font_size := 44
@onready var _strip: TextureRect = %GradientStrip
@onready var _outer_keyline: Label = %OuterKeyline
@onready var _foreground: Label = %Foreground


func _ready() -> void:
	resized.connect(_layout_children)
	_refresh_preview()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_node_ready():
		_refresh_preview()


func _refresh_preview() -> void:
	if not is_node_ready():
		return
	for label in [_outer_keyline, _foreground]:
		label.text = caption
		if font_size_override > 0:
			label.add_theme_font_size_override("font_size", font_size_override)
		else:
			label.remove_theme_font_size_override("font_size")
	_font_size = _foreground.get_theme_font_size(&"font_size")
	_strip.texture = get_theme_icon(&"strip")
	_strip.modulate = get_theme_color(&"strip_color")
	_layout_children()


func _layout_children() -> void:
	if not is_node_ready():
		return
	var font := _foreground.get_theme_font(&"font")
	var text_offset_x := float(get_theme_constant(&"text_offset_x"))
	var fade_padding := float(get_theme_constant(&"strip_fade_padding"))
	var strip_height := float(get_theme_constant(&"strip_height"))
	var text_width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1.0, _font_size).x
	var strip_width := minf(size.x, text_offset_x + text_width + fade_padding)
	_strip.position = Vector2(0.0, floorf((size.y - strip_height) * 0.5) + 1.0)
	_strip.size = Vector2(maxf(0.0, strip_width), strip_height)
	var label_size := Vector2(maxf(0.0, size.x - text_offset_x), size.y)
	for label in [_outer_keyline, _foreground]:
		label.position = Vector2(text_offset_x, 0.0)
		label.size = label_size
