class_name AdvQuickSettingsBackdrop
extends Control


## Source-style translucent vertical gradient. Keeping this separate from the
## interactive panel lets window_depth affect only the chrome, never labels or
## controls.
const TOP_COLOR := Color(57.0 / 255.0, 121.0 / 255.0, 144.0 / 255.0, 230.0 / 255.0)
const BOTTOM_COLOR := Color(126.0 / 255.0, 186.0 / 255.0, 206.0 / 255.0, 52.0 / 255.0)
const CORNER_RADIUS := 15.0

var _depth := 0.5


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func set_depth(value: float) -> void:
	_depth = clampf(value, 0.0, 1.0)
	queue_redraw()


func depth() -> float:
	return _depth


func _draw() -> void:
	var row_count := maxi(ceili(size.y), 1)
	var panel_width := maxf(size.x, 0.0)
	for row in row_count:
		var ratio := float(row) / float(maxi(row_count - 1, 1))
		var color := TOP_COLOR.lerp(BOTTOM_COLOR, ratio)
		color.a *= _depth
		var inset := _rounded_inset_for_row(float(row) + 0.5, size.y)
		var width := panel_width - inset * 2.0
		if width > 0.0:
			draw_rect(Rect2(inset, float(row), width, 1.0), color)


func _rounded_inset_for_row(center_y: float, panel_height: float) -> float:
	var distance_from_edge := minf(center_y, panel_height - center_y)
	if distance_from_edge >= CORNER_RADIUS:
		return 0.0
	var dy := CORNER_RADIUS - maxf(distance_from_edge, 0.0)
	return CORNER_RADIUS - sqrt(maxf(CORNER_RADIUS * CORNER_RADIUS - dy * dy, 0.0))
