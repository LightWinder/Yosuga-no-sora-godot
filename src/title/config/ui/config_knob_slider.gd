class_name ConfigKnobSlider
extends Control


## Horizontal (or trapezoid) knob slider mirroring the source
## HDTrapezoidSlider/SliderH: a 3-frame knob strip drawn along a track, with the
## knob scale optionally growing from min to max as the value rises.
signal value_changed(value: float)
signal drag_ended(value_changed: bool)

const KNOB_TEXTURE: Texture2D = preload("res://assets/content/settings/slider_knob.png")
const FRAME_COUNT := 3

var min_value := 0.0
var max_value := 100.0
var knob_min_scale := 1.0
var knob_max_scale := 1.0
var disabled := false
var _value := 0.0
var _track_from := Vector2.ZERO
var _track_to := Vector2.ZERO
var _frame_size := Vector2.ZERO
var _hovered := false
var _dragging := false

var value: float:
	get:
		return _value
	set(next):
		var clamped := clampf(next, min_value, max_value)
		if not is_equal_approx(clamped, _value):
			_value = clamped
			value_changed.emit(_value)
		queue_redraw()


## Track endpoints are in this control's parent coordinate space; the control
## positions/sizes itself around them with enough room for the largest knob.
func configure_track(from: Vector2, to: Vector2, min_scale := 1.0, max_scale := 1.0) -> void:
	_track_from = from
	_track_to = to
	knob_min_scale = min_scale
	knob_max_scale = max_scale
	_frame_size = Vector2(
		float(KNOB_TEXTURE.get_width()) / FRAME_COUNT,
		float(KNOB_TEXTURE.get_height())
	)
	var max_knob := _frame_size * max_scale
	var margin := max_knob * 0.5 + Vector2(2.0, 2.0)
	var top_left := Vector2(minf(from.x, to.x), minf(from.y, to.y)) - margin
	var bottom_right := Vector2(maxf(from.x, to.x), maxf(from.y, to.y)) + margin
	position = top_left
	size = bottom_right - top_left
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(func() -> void: queue_redraw())
	focus_exited.connect(func() -> void: queue_redraw())
func set_value_silent(next: float) -> void:
	_value = clampf(next, min_value, max_value)
	queue_redraw()


func set_value_range(minimum: float, maximum: float) -> void:
	min_value = minimum
	max_value = maximum
	set_value_silent(_value)


func step_by(delta: float) -> void:
	value = _value + delta


func is_hovered() -> bool:
	return _hovered


func _on_mouse_entered() -> void:
	_hovered = true
	queue_redraw()


func _on_mouse_exited() -> void:
	_hovered = false
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if disabled:
		return
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_LEFT:
			if button.pressed:
				_dragging = true
				_set_value_from_x(button.position.x)
				accept_event()
			elif _dragging:
				_dragging = false
				drag_ended.emit(true)
				accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_set_value_from_x((event as InputEventMouseMotion).position.x)
		accept_event()
	elif event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var key := event as InputEventKey
		if key.keycode == KEY_LEFT or key.keycode == KEY_RIGHT:
			var delta := (max_value - min_value) / (10.0 if key.shift_pressed else 20.0)
			value = _value + (delta if key.keycode == KEY_RIGHT else -delta)
			accept_event()


func _set_value_from_x(local_x: float) -> void:
	var from := _track_from - position
	var to := _track_to - position
	if is_equal_approx(to.x, from.x):
		return
	var t := clampf((local_x - from.x) / (to.x - from.x), 0.0, 1.0)
	value = roundf(lerpf(min_value, max_value, t))


func _draw() -> void:
	if KNOB_TEXTURE == null:
		return
	var t := 0.0
	if not is_equal_approx(max_value, min_value):
		t = clampf((_value - min_value) / (max_value - min_value), 0.0, 1.0)
	var from := _track_from - position
	var to := _track_to - position
	var center := from.lerp(to, t)
	var scale := lerpf(knob_min_scale, knob_max_scale, t)
	var knob_size := _frame_size * scale
	var frame := 1 if (_hovered or has_focus()) else 0
	if disabled:
		frame = 2
	var region := Rect2(_frame_size.x * frame, 0.0, _frame_size.x, _frame_size.y)
	draw_texture_rect_region(
		KNOB_TEXTURE,
		Rect2(center - knob_size * 0.5, knob_size),
		region
	)
