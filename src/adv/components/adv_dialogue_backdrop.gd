@tool
class_name AdvDialogueBackdrop
extends Control
## Code-drawn translucent cyan frame with the source-style upper separator
## and small logo at the left. The backdrop intentionally has no cloud motif.


const DESIGN_SIZE := Vector2(1920.0, 320.0)
const TOP_COLOR := Color(0.49, 0.73, 0.81, 1.0)
const MID_COLOR := Color(0.22, 0.47, 0.56, 1.0)
const BOTTOM_COLOR := Color(0.49, 0.73, 0.81, 1.0)
const LOGO_FONT: Font = preload("res://assets/themes/fonts/settings_choice_font.tres")
const LOGO_TITLE := "ヨスガノソラ"
const LOGO_SUBTITLE := "In solitude, where we are least alone."

var _frame_opacity := 1.0
var _logo_plate_style := StyleBoxFlat.new()


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func set_frame_opacity(value: float) -> void:
	_frame_opacity = clampf(value, 0.0, 1.0)
	queue_redraw()


func frame_opacity() -> float:
	return _frame_opacity


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0 or is_zero_approx(_frame_opacity):
		return
	draw_set_transform(Vector2.ZERO, 0.0, size / DESIGN_SIZE)
	_draw_gradient()
	_draw_logo()
	draw_set_transform(Vector2.ZERO)


func _draw_gradient() -> void:
	for y in range(0, 65, 2):
		var ratio := float(y) / 64.0
		var color := TOP_COLOR.lerp(MID_COLOR, ratio)
		color.a = 0.45 * pow(ratio, 0.65) * _frame_opacity
		draw_rect(Rect2(0.0, float(y), DESIGN_SIZE.x, 2.0), color)
	# The two-pixel clear seam is intentional and reproduces the bright line
	# made by the original frame revealing the scene underneath.
	for y in range(67, 320, 2):
		var ratio := float(y - 67) / 253.0
		var color := MID_COLOR.lerp(BOTTOM_COLOR, ratio)
		color.a = _lower_alpha(float(y)) * _frame_opacity
		draw_rect(Rect2(0.0, float(y), DESIGN_SIZE.x, 2.0), color)


func _lower_alpha(y: float) -> float:
	if y <= 100.0:
		return lerpf(0.45, 0.65, (y - 67.0) / 33.0)
	if y <= 200.0:
		return lerpf(0.65, 0.81, (y - 100.0) / 100.0)
	return lerpf(0.81, 1.0, (y - 200.0) / 120.0)


func _draw_logo() -> void:
	var plate_color := Color(0.89, 0.97, 0.99, 0.25 * _frame_opacity)
	_logo_plate_style.bg_color = plate_color
	_logo_plate_style.set_corner_radius_all(6)
	draw_style_box(_logo_plate_style, Rect2(42.0, 150.0, 327.0, 44.0))
	var title_baseline := Vector2(59.0, 188.0)
	draw_string_outline(
		LOGO_FONT,
		title_baseline,
		LOGO_TITLE,
		HORIZONTAL_ALIGNMENT_LEFT,
		295.0,
		40,
		2,
		Color(0.91, 0.98, 1.0, 0.20 * _frame_opacity)
	)
	draw_string(
		LOGO_FONT,
		title_baseline,
		LOGO_TITLE,
		HORIZONTAL_ALIGNMENT_LEFT,
		295.0,
		40,
		Color(0.30, 0.57, 0.66, 0.42 * _frame_opacity)
	)
	draw_string_outline(
		LOGO_FONT,
		Vector2(42.0, 216.0),
		LOGO_SUBTITLE,
		HORIZONTAL_ALIGNMENT_LEFT,
		335.0,
		14,
		1,
		Color(0.25, 0.53, 0.63, 0.42 * _frame_opacity)
	)
	draw_string(
		LOGO_FONT,
		Vector2(42.0, 216.0),
		LOGO_SUBTITLE,
		HORIZONTAL_ALIGNMENT_LEFT,
		335.0,
		14,
		Color(0.90, 0.98, 1.0, 0.58 * _frame_opacity)
	)
