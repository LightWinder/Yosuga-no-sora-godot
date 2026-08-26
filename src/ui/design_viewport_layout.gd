class_name DesignViewportLayout
extends RefCounted


static func apply(
		canvas: Control,
		viewport_size: Vector2,
		design_size: Vector2,
		mobile_fallback: float
) -> void:
	if canvas == null or viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var safe_area := safe_rect(viewport_size, mobile_fallback)
	var scale_factor := minf(
		safe_area.size.x / design_size.x,
		safe_area.size.y / design_size.y
	)
	canvas.scale = Vector2.ONE * scale_factor
	canvas.position = safe_area.position + (safe_area.size - design_size * scale_factor) * 0.5


static func safe_rect(viewport_size: Vector2, mobile_fallback: float) -> Rect2:
	if not is_mobile_platform():
		return Rect2(Vector2.ZERO, viewport_size)
	var fallback := maxf(0.0, mobile_fallback)
	var display_safe_area := DisplayServer.get_display_safe_area()
	var display_size := DisplayServer.screen_get_size()
	if display_safe_area.size.x <= 0 or display_safe_area.size.y <= 0 or display_size.x <= 0 or display_size.y <= 0:
		return _fallback_rect(viewport_size, fallback)
	var display_to_viewport := Vector2(
		viewport_size.x / float(display_size.x),
		viewport_size.y / float(display_size.y)
	)
	var safe_position := Vector2(display_safe_area.position) * display_to_viewport
	var safe_end := Vector2(display_safe_area.position + display_safe_area.size) * display_to_viewport
	safe_position.x = clampf(safe_position.x, 0.0, viewport_size.x)
	safe_position.y = clampf(safe_position.y, 0.0, viewport_size.y)
	safe_end.x = clampf(safe_end.x, safe_position.x, viewport_size.x)
	safe_end.y = clampf(safe_end.y, safe_position.y, viewport_size.y)
	var result := Rect2(safe_position, safe_end - safe_position)
	return result if result.size.x > 1.0 and result.size.y > 1.0 else _fallback_rect(viewport_size, fallback)


static func is_mobile_platform() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")


static func _fallback_rect(viewport_size: Vector2, fallback: float) -> Rect2:
	return Rect2(
		Vector2(fallback, fallback),
		Vector2(
			maxf(1.0, viewport_size.x - fallback * 2.0),
			maxf(1.0, viewport_size.y - fallback * 2.0)
		)
	)
