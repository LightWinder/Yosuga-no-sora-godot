@tool
class_name SettingsCheckChoiceButton
extends Button


## Live-text confirmation choice with a source-style checkbox drawn entirely
## from Canvas primitives. Native Button state remains the single source of
## truth for mouse, touch, keyboard focus and accessibility.
var _outer_box_style := StyleBoxFlat.new()
var _inner_box_style := StyleBoxFlat.new()

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
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()


func _draw() -> void:
	var box_size := float(get_theme_constant(&"check_size"))
	var gap := float(get_theme_constant(&"check_gap"))
	var font := get_theme_font(&"font")
	var font_size := get_theme_font_size(&"font_size")
	var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var text_center_x := (size.x - box_size - gap) * 0.5
	var box_position := Vector2(
		text_center_x + text_width * 0.5 + gap,
		floorf((size.y - box_size) * 0.5)
	)
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
