class_name TitleMenuButton
extends TextureButton


signal option_activated(option_id: StringName)

@export_range(0.8, 1.0, 0.01) var pressed_scale := 0.94
@export_range(1.0, 1.2, 0.01) var release_overshoot_scale := 1.04
@export_range(0.01, 0.5, 0.01) var press_seconds := 0.06
@export_range(0.01, 0.5, 0.01) var release_seconds := 0.16
@export_range(0.0, 96.0, 1.0) var touch_hit_padding := 24.0

var option_id: StringName = &""
var _scale_tween: Tween


func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)
	resized.connect(_refresh_pivot)
	_refresh_pivot()


func _exit_tree() -> void:
	_kill_scale_tween()


func configure(id: StringName, display_name: String, sprite_sheet: Texture2D) -> void:
	assert(sprite_sheet != null, "A title menu button requires a sprite sheet.")
	option_id = id
	name = String(id).to_pascal_case()
	tooltip_text = display_name

	var frame_size := Vector2(sprite_sheet.get_width() / 2.0, sprite_sheet.get_height())
	custom_minimum_size = frame_size
	size = frame_size
	texture_normal = _create_frame(sprite_sheet, 0, frame_size)
	texture_hover = _create_frame(sprite_sheet, 1, frame_size)
	texture_pressed = texture_hover
	texture_focused = texture_hover
	texture_disabled = texture_normal
	_refresh_pivot()


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


func _create_frame(sprite_sheet: Texture2D, frame_index: int, frame_size: Vector2) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = sprite_sheet
	frame.region = Rect2(Vector2(frame_size.x * frame_index, 0.0), frame_size)
	frame.filter_clip = true
	return frame


func _on_button_down() -> void:
	play_press_feedback()


func _on_button_up() -> void:
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


func _has_point(point: Vector2) -> bool:
	var hit_rect := Rect2(
		-touch_hit_padding,
		-touch_hit_padding,
		size.x + touch_hit_padding * 2.0,
		size.y + touch_hit_padding * 2.0
	)
	return hit_rect.has_point(point)
