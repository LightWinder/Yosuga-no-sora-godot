@tool
class_name SettingsVoiceChoiceButton
extends SettingsSelectableButton


## Source-style audio character option. The translucent fill and both rounded
## keylines are drawn from Theme tokens, so no sliced button textures are used.
var _outer_style := StyleBoxFlat.new()
var _inner_style := StyleBoxFlat.new()


func _init() -> void:
	if theme_type_variation.is_empty():
		theme_type_variation = &"SettingsVoiceChoiceButton"
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(queue_redraw)


func _ready() -> void:
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()


func _selection_changed() -> void:
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var interactive := is_hovered() or has_focus() or get_draw_mode() == BaseButton.DRAW_PRESSED
	var outer_color := get_theme_color(&"voice_outer_color")
	var inner_color := get_theme_color(&"voice_inner_color")
	var fill_color := get_theme_color(&"voice_fill_color")
	if selected:
		outer_color = get_theme_color(&"voice_outer_selected_color")
		inner_color = get_theme_color(&"voice_inner_selected_color")
		fill_color = get_theme_color(&"voice_fill_selected_color")
	elif interactive:
		outer_color = get_theme_color(&"voice_outer_hover_color")
		fill_color = get_theme_color(&"voice_fill_hover_color")
	_configure_outer_style(fill_color, outer_color)
	_configure_inner_style(inner_color)
	var horizontal_inset := float(get_theme_constant(&"voice_horizontal_inset"))
	var vertical_inset := float(get_theme_constant(&"voice_vertical_inset"))
	var outer_rect := Rect2(
		Vector2(horizontal_inset, vertical_inset),
		size - Vector2(horizontal_inset * 2.0, vertical_inset * 2.0)
	)
	if outer_rect.size.x <= 0.0 or outer_rect.size.y <= 0.0:
		return
	draw_style_box(_outer_style, outer_rect)
	var inner_inset := float(get_theme_constant(&"voice_inner_inset"))
	var inner_rect := outer_rect.grow(-inner_inset)
	if inner_rect.size.x > 0.0 and inner_rect.size.y > 0.0:
		draw_style_box(_inner_style, inner_rect)


func _configure_outer_style(fill_color: Color, border_color: Color) -> void:
	_outer_style.bg_color = fill_color
	_outer_style.border_color = border_color
	_outer_style.set_border_width_all(get_theme_constant(&"voice_outer_width"))
	_outer_style.set_corner_radius_all(get_theme_constant(&"voice_corner_radius"))
	_outer_style.anti_aliasing = true
	_outer_style.shadow_color = get_theme_color(&"voice_selected_shadow_color") if selected else Color.TRANSPARENT
	_outer_style.shadow_size = get_theme_constant(&"voice_selected_shadow_size") if selected else 0
	_outer_style.shadow_offset = Vector2(0.0, 2.0)


func _configure_inner_style(border_color: Color) -> void:
	_inner_style.bg_color = Color.TRANSPARENT
	_inner_style.border_color = border_color
	_inner_style.set_border_width_all(get_theme_constant(&"voice_inner_width"))
	var radius := maxi(0, get_theme_constant(&"voice_corner_radius") - get_theme_constant(&"voice_inner_inset"))
	_inner_style.set_corner_radius_all(radius)
	_inner_style.anti_aliasing = true
