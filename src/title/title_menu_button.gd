@tool
class_name TitleMenuButton
extends Button


signal option_activated(option_id: StringName)

@export_range(0.8, 1.0, 0.01) var pressed_scale := 0.94
@export_range(1.0, 1.2, 0.01) var release_overshoot_scale := 1.04
@export_range(0.01, 0.5, 0.01) var press_seconds := 0.06
@export_range(0.01, 0.5, 0.01) var release_seconds := 0.16
@export_range(0.0, 96.0, 1.0) var touch_hit_padding := 24.0

@export_group("Content")
@export var option_id: StringName = &""
@export var display_name := "":
	set(value):
		display_name = value
		if is_node_ready():
			tooltip_text = display_name
@export var caption := "新的开始":
	set(value):
		caption = value
		queue_redraw()
@export var english_caption := "NEW GAME":
	set(value):
		english_caption = value
		queue_redraw()
@export var tile_angles := PackedFloat32Array([-2.0, 2.0, -1.0, 2.5]):
	set(value):
		tile_angles = value
		queue_redraw()

var _scale_tween: Tween
var _show_disabled_visual := true
var _locked_highlighted := false
var _glow_phase := 0.0


func _ready() -> void:
	tooltip_text = display_name
	_refresh_pivot()
	_sync_min_width()
	resized.connect(_refresh_pivot)
	mouse_entered.connect(_sync_glow_animation)
	mouse_exited.connect(_sync_glow_animation)
	focus_entered.connect(_sync_glow_animation)
	focus_exited.connect(_sync_glow_animation)
	set_process(false)
	if Engine.is_editor_hint():
		return
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)


func _exit_tree() -> void:
	_kill_scale_tween()


func _process(delta: float) -> void:
	if not is_visually_highlighted():
		set_process(false)
		_glow_phase = 0.0
		return
	var period := maxf(float(get_theme_constant(&"glow_pulse_period_ms")) / 1000.0, 0.1)
	_glow_phase = fmod(_glow_phase + delta * TAU / period, TAU)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_sync_min_width()
		queue_redraw()


## Tiles keep the themed size no matter how many glyphs the caption has; the
## button hugs its caption so the centered container rows render every title
## at one uniform tile size across languages. The themed gap keeps adjacent
## rotated tiles from touching, preserving the staggered hand-placed look.
func _sync_min_width() -> void:
	var caption_text := tr(caption)
	var inset := float(get_theme_constant(&"tile_inset"))
	var tile_size := float(get_theme_constant(&"tile_size"))
	if caption_text.is_empty() or tile_size <= 0.0:
		return
	var glyph_count := caption_text.length()
	custom_minimum_size.x = inset * 2.0 + tile_size * glyph_count + _tile_gap() * (glyph_count - 1)


func _tile_gap() -> float:
	return float(get_theme_constant(&"tile_gap"))


## Keep every glyph, its tilted square, and the English subtitle live at 4K.
## Theme owns typography/colors; the caption determines the drawn glyph count.
func _draw() -> void:
	var caption_text := tr(caption)
	if caption_text.is_empty():
		return
	var visually_disabled := disabled and _show_disabled_visual
	var font := get_theme_font(&"font")
	var font_size := get_theme_font_size(&"font_size")
	var inset := float(get_theme_constant(&"tile_inset"))
	var tile_size := float(get_theme_constant(&"tile_size"))
	var tile_gap := _tile_gap()
	var glyph_size := mini(font_size, int(tile_size - 2.0))
	var center_y := float(get_theme_constant(&"tile_center_y"))
	var highlighted := is_visually_highlighted()
	var color_name: StringName = &"tile_color"
	if visually_disabled:
		color_name = &"tile_disabled_color"
	elif highlighted:
		color_name = &"tile_hover_color"
	var tile_color := get_theme_color(color_name)
	var text_color := get_theme_color(&"font_disabled_color" if visually_disabled else &"font_color")
	var glow := get_theme_stylebox(&"tile_glow_hover" if highlighted else &"tile_glow")
	var text_glow := get_theme_color(&"text_glow_hover_color" if highlighted else &"text_glow_color")
	var glow_radius := float((glow as StyleBoxFlat).shadow_size) if glow is StyleBoxFlat else 12.0
	var glow_color := (glow as StyleBoxFlat).shadow_color if glow is StyleBoxFlat else Color(0.96, 1.0, 1.0, 0.3)
	if highlighted:
		var pulse := 0.5 + sin(_glow_phase) * 0.5
		glow_radius += pulse * float(get_theme_constant(&"glow_pulse_spread"))
		glow_color.a *= 0.92 + pulse * 0.08
		text_glow.a *= 0.94 + pulse * 0.06
	# Draw all soft square shadows first, keeping neighboring glyphs crisp.
	if not visually_disabled:
		for index in caption_text.length():
			var center := Vector2(inset + tile_size * (index + 0.5) + tile_gap * index, center_y)
			var angle := deg_to_rad(tile_angles[index % tile_angles.size()]) if not tile_angles.is_empty() else 0.0
			draw_set_transform(center, angle)
			_draw_tile_glow(tile_size, glow_radius, glow_color)
	for index in caption_text.length():
		var center := Vector2(inset + tile_size * (index + 0.5) + tile_gap * index, center_y)
		var angle := deg_to_rad(tile_angles[index % tile_angles.size()]) if not tile_angles.is_empty() else 0.0
		draw_set_transform(center, angle)
		_draw_tile(tile_size, tile_color)
		var glyph := caption_text.substr(index, 1)
		var width := font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, glyph_size).x
		var baseline := font.get_ascent(glyph_size) - font.get_height(glyph_size) * 0.5
		if not visually_disabled:
			_draw_text_glow(font, Vector2(-width * 0.5, baseline), glyph, glyph_size, text_glow)
		draw_string(font, Vector2(-width * 0.5, baseline), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, glyph_size, text_color)
	draw_set_transform(Vector2.ZERO)
	var subtitle_size := get_theme_font_size(&"subtitle_font_size")
	var subtitle_font := get_theme_font(&"subtitle_font")
	var subtitle_position := Vector2(inset, float(get_theme_constant(&"subtitle_baseline")))
	var subtitle_color := get_theme_color(&"subtitle_disabled_color" if visually_disabled else &"subtitle_color")
	if not visually_disabled:
		_draw_text_glow(subtitle_font, subtitle_position, english_caption, subtitle_size, text_glow)
	draw_string_outline(subtitle_font, subtitle_position, english_caption, HORIZONTAL_ALIGNMENT_LEFT, size.x - inset * 2.0, subtitle_size, get_theme_constant(&"subtitle_outline_size"), get_theme_color(&"subtitle_outline_color"))
	draw_string(subtitle_font, subtitle_position, english_caption, HORIZONTAL_ALIGNMENT_LEFT, size.x - inset * 2.0, subtitle_size, subtitle_color)


## Locks input independently from the drawn state so route transitions can
## remain fully opaque while they are protected from accidental activation.
func set_interaction_disabled(value: bool, show_disabled_visual := true) -> void:
	if value and not disabled:
		_locked_highlighted = _has_live_highlight()
	disabled = value
	_show_disabled_visual = value and show_disabled_visual
	if not value:
		_locked_highlighted = false
	_sync_glow_animation()


func is_visually_disabled() -> bool:
	return disabled and _show_disabled_visual


func is_visually_highlighted() -> bool:
	if disabled:
		return not _show_disabled_visual and _locked_highlighted
	return _has_live_highlight()


func _draw_text_glow(font: Font, baseline: Vector2, value: String, font_size: int, color: Color) -> void:
	var radius := get_theme_constant(&"text_glow_radius")
	# Overlapping low-opacity outlines approximate a smooth white bloom while
	# retaining vector text and the subtitle's original fine blue keyline.
	for spread in range(radius, 0, -1):
		var layer := color
		layer.a *= exp(-float(spread * spread) / (float(radius * radius) * 0.4))
		draw_string_outline(font, baseline, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, spread, layer)


func _draw_tile(edge: float, color: Color) -> void:
	var half := edge * 0.5
	var corners := PackedVector2Array([Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	draw_colored_polygon(corners, color)
	draw_polyline(PackedVector2Array([corners[0], corners[1], corners[2], corners[3], corners[0]]), color, 0.6, true)


func _draw_tile_glow(edge: float, radius: float, color: Color) -> void:
	var layers := maxi(get_theme_constant(&"tile_glow_layers"), 4)
	for layer_index in range(layers, 0, -1):
		var distance := float(layer_index) / float(layers)
		var layer_color := color
		layer_color.a *= pow(1.0 - distance, 1.5) * 0.11
		var half := edge * 0.5 + radius * distance
		var corners := PackedVector2Array([
			Vector2(-half, -half),
			Vector2(half, -half),
			Vector2(half, half),
			Vector2(-half, half),
		])
		draw_colored_polygon(corners, layer_color)


func _has_live_highlight() -> bool:
	return not disabled and (is_hovered() or has_focus() or is_pressed())


func _sync_glow_animation() -> void:
	var highlighted := is_visually_highlighted()
	set_process(highlighted)
	if not highlighted:
		_glow_phase = 0.0
	queue_redraw()


func play_press_feedback() -> void:
	_animate_scale(Vector2.ONE * pressed_scale, press_seconds, Tween.TRANS_QUAD, Tween.EASE_OUT)


func play_release_feedback() -> void:
	_animate_scale(Vector2.ONE, release_seconds, Tween.TRANS_BACK, Tween.EASE_OUT)


func play_click_feedback() -> void:
	_kill_scale_tween()
	_scale_tween = create_tween()
	_scale_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_scale_tween.tween_property(self, "scale", Vector2.ONE * release_overshoot_scale, release_seconds * 0.45)
	_scale_tween.tween_property(self, "scale", Vector2.ONE, release_seconds * 0.55)


func _on_button_down() -> void:
	_sync_glow_animation()
	play_press_feedback()


func _on_button_up() -> void:
	_sync_glow_animation()
	play_release_feedback()


func _on_pressed() -> void:
	option_activated.emit(option_id)
	play_click_feedback()


func _animate_scale(target: Vector2, duration: float, transition: Tween.TransitionType, easing: Tween.EaseType) -> void:
	_kill_scale_tween()
	_scale_tween = create_tween()
	_scale_tween.set_trans(transition).set_ease(easing)
	_scale_tween.tween_property(self, "scale", target, duration)


func _kill_scale_tween() -> void:
	if _scale_tween != null and _scale_tween.is_valid():
		_scale_tween.kill()
	_scale_tween = null


func _refresh_pivot() -> void:
	pivot_offset = size * 0.5
	queue_redraw()


func _has_point(point: Vector2) -> bool:
	var hit_rect := Rect2(
		-touch_hit_padding,
		-touch_hit_padding,
		size.x + touch_hit_padding * 2.0,
		size.y + touch_hit_padding * 2.0
	)
	return hit_rect.has_point(point)
