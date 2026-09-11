@tool
class_name PageTabButton
extends Button


## Text-only settings navigation tab. The stable caption stays separate from
## the selected-state decoration so localization never has to include bullets.
@export var tab_label: String:
	set(value):
		tab_label = value
		_refresh_visual()

var _visual_text := ""
var _label_text := ""


func _init() -> void:
	if theme_type_variation.is_empty():
		theme_type_variation = &"SettingsTabButton"
	toggle_mode = true
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	toggled.connect(func(_pressed: bool) -> void: _refresh_visual())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(queue_redraw)


func _ready() -> void:
	if tab_label.is_empty():
		tab_label = text
	_refresh_visual()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_TRANSLATION_CHANGED, NOTIFICATION_THEME_CHANGED] and is_node_ready():
		_refresh_visual()


func _refresh_visual() -> void:
	if tab_label.is_empty():
		return
	_label_text = tr(tab_label)
	_visual_text = "• %s •" % _label_text if button_pressed else _label_text
	accessibility_name = _label_text
	# Native Button text contributes its current font size to the Container's
	# minimum-size pass. Draw the caption ourselves so selection can change its
	# visual scale without changing this button's reserved span.
	if not text.is_empty():
		text = ""
	_reserve_layout_width(_label_text)
	z_index = 1 if button_pressed else 0
	queue_redraw()


## Reserve the selected caption's span between its two bullet centers. In a
## gapless HBox, neighboring button edges then describe the same point: one
## tab's right bullet center is exactly the next tab's left bullet center.
func _reserve_layout_width(label: String) -> void:
	var font := get_theme_font(&"font")
	if font == null:
		return
	var font_size := maxi(
		get_theme_font_size(&"font_size"),
		get_theme_constant(&"selected_font_size")
	)
	if font_size <= 0:
		return
	var decorated_width := font.get_string_size(
		"• %s •" % label,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size
	).x
	var bullet_width := font.get_string_size(
		"•",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size
	).x
	custom_minimum_size.x = maxf(decorated_width - bullet_width, 0.0)


func visual_text() -> String:
	return _visual_text


func _draw() -> void:
	if _label_text.is_empty() or size.x <= 0.0 or size.y <= 0.0:
		return
	var font := get_theme_font(&"font")
	if font == null:
		return
	var font_size := get_theme_font_size(&"font_size")
	if button_pressed:
		font_size = maxi(font_size, get_theme_constant(&"selected_font_size"))
	if font_size <= 0:
		return
	var color := _current_font_color()
	_draw_centered_text(_label_text, size.x * 0.5, font, font_size, color)
	if button_pressed:
		_draw_centered_text("•", 0.0, font, font_size, color)
		_draw_centered_text("•", size.x, font, font_size, color)


func _draw_centered_text(value: String, center_x: float, font: Font, font_size: int, color: Color) -> void:
	var text_size := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var baseline := Vector2(
		center_x - text_size.x * 0.5,
		(size.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	)
	var outline_size := get_theme_constant(&"outline_size")
	if outline_size > 0:
		draw_string_outline(
			font,
			baseline,
			value,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			font_size,
			outline_size,
			get_theme_color(&"font_outline_color")
		)
	draw_string(
		font,
		baseline,
		value,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size,
		color
	)


func _current_font_color() -> Color:
	match get_draw_mode():
		BaseButton.DRAW_DISABLED:
			return get_theme_color(&"font_disabled_color")
		BaseButton.DRAW_PRESSED:
			return get_theme_color(&"font_pressed_color")
		BaseButton.DRAW_HOVER:
			return get_theme_color(&"font_hover_color")
		BaseButton.DRAW_HOVER_PRESSED:
			return get_theme_color(&"font_hover_pressed_color")
		_:
			# Focus and selection are independent states. A stale keyboard focus on
			# an inactive tab must not make it look like a second selected tab.
			return get_theme_color(&"font_color")
