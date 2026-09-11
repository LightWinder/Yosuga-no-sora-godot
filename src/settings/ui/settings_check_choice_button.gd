@tool
class_name SettingsCheckChoiceButton
extends Button


## Live-text confirmation choice with a source-style checkbox drawn entirely
## from Canvas primitives. Native Button state remains the single source of
## truth for mouse, touch, keyboard focus and accessibility.
var _outer_box_style := StyleBoxFlat.new()
var _inner_box_style := StyleBoxFlat.new()
var _source_text := ""
var _display_text := ""

@export var checked: bool:
	get:
		return button_pressed
	set(value):
		set_pressed_no_signal(value)
		queue_redraw()


func _init() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _ready() -> void:
	toggle_mode = true
	toggled.connect(func(_value: bool) -> void: queue_redraw())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	_refresh_caption()
	queue_redraw()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_TRANSLATION_CHANGED, NOTIFICATION_THEME_CHANGED] and is_node_ready():
		_refresh_caption()
		queue_redraw()


func _refresh_caption() -> void:
	# Draw the caption ourselves so the "text + checkbox" pair stays one
	# centered group; the native Button text would center on the full width
	# and drift away from the checkbox. Keep the source string for
	# retranslation and accessibility.
	if not text.is_empty() and _source_text.is_empty():
		_source_text = text
		text = ""
	_display_text = tr(_source_text)
	accessibility_name = _source_text
	# Clearing the native text also clears the Button's own minimum width, so
	# reserve the group's span or grid columns collapse onto each other.
	var font := get_theme_font(&"font")
	if font != null:
		var font_size := get_theme_font_size(&"font_size")
		var text_width := font.get_string_size(_display_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		var group_width := text_width + float(get_theme_constant(&"check_gap")) + float(get_theme_constant(&"check_size"))
		custom_minimum_size = Vector2(
			maxf(group_width, 0.0),
			maxf(custom_minimum_size.y, 0.0)
		)


func _font_color() -> Color:
	match get_draw_mode():
		BaseButton.DRAW_DISABLED:
			return get_theme_color(&"font_disabled_color")
		BaseButton.DRAW_HOVER:
			return get_theme_color(&"font_hover_color")
		BaseButton.DRAW_PRESSED, BaseButton.DRAW_HOVER_PRESSED:
			return get_theme_color(&"font_pressed_color")
		_:
			if has_focus():
				return get_theme_color(&"font_focus_color")
			return get_theme_color(&"font_color")


func _draw() -> void:
	var box_size := float(get_theme_constant(&"check_size"))
	var gap := float(get_theme_constant(&"check_gap"))
	var font := get_theme_font(&"font")
	var font_size := get_theme_font_size(&"font_size")
	var text_width := font.get_string_size(_display_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var group_left := floorf((size.x - text_width - gap - box_size) * 0.5)
	var baseline := (size.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	var origin := Vector2(group_left, baseline)
	var outline_size := get_theme_constant(&"outline_size")
	if outline_size > 0:
		draw_string_outline(
			font,
			origin,
			_display_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			font_size,
			outline_size,
			get_theme_color(&"font_outline_color")
		)
	draw_string(
		font,
		origin,
		_display_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size,
		_font_color()
	)
	var box_position := Vector2(group_left + text_width + gap, floorf((size.y - box_size) * 0.5))
	_draw_checkbox(Rect2(box_position, Vector2.ONE * box_size))


func _draw_checkbox(rect: Rect2) -> void:
	var active := is_hovered() or has_focus()
	var fill_color_name := &"check_fill_active_color" if active else &"check_fill_color"
	var outer_width := get_theme_constant(&"check_outer_width")
	var inner_width := get_theme_constant(&"check_inner_width")
	var corner_radius := get_theme_constant(&"check_corner_radius")
	_outer_box_style.bg_color = get_theme_color(fill_color_name)
	_outer_box_style.border_color = get_theme_color(&"check_outer_color")
	_outer_box_style.set_border_width_all(outer_width)
	_outer_box_style.set_corner_radius_all(corner_radius)
	_inner_box_style.bg_color = Color.TRANSPARENT
	_inner_box_style.border_color = get_theme_color(&"check_inner_color")
	_inner_box_style.set_border_width_all(inner_width)
	_inner_box_style.set_corner_radius_all(maxi(0, corner_radius - outer_width))
	draw_style_box(_outer_box_style, rect)
	draw_style_box(_inner_box_style, rect.grow(-float(outer_width)))
	if not button_pressed:
		return

	var start := rect.position + rect.size * Vector2(0.18, 0.52)
	var joint := rect.position + rect.size * Vector2(0.43, 0.76)
	var end := rect.position + rect.size * Vector2(1.08, 0.08)
	var points := PackedVector2Array([start, joint, end])
	draw_polyline(points, get_theme_color(&"check_mark_color"), 5.0, true)
