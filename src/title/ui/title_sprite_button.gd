class_name TitleSpriteButton
extends TextureButton


## A source-style button whose PNG contains normal/hover/disabled (or pressed)
## states side by side.  The control remains a real TextureButton, so
## keyboard, gamepad focus and Godot's touch-to-mouse GUI path all work.
var _hit_padding := 14.0


func configure_sprite(texture_path: String, frame_count := 3, hit_padding := 14.0) -> void:
	var texture := load(texture_path) as Texture2D
	if texture == null or frame_count <= 0:
		return
	_hit_padding = hit_padding
	var frame_size := Vector2(texture.get_width() / float(frame_count), texture.get_height())
	custom_minimum_size = frame_size
	size = frame_size
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	texture_normal = _frame(texture, frame_size, 0)
	texture_hover = _frame(texture, frame_size, mini(1, frame_count - 1))
	texture_pressed = _frame(texture, frame_size, mini(1, frame_count - 1))
	texture_focused = _frame(texture, frame_size, mini(1, frame_count - 1))
	texture_disabled = _frame(texture, frame_size, frame_count - 1)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = ""


func set_design_size(design_size: Vector2) -> void:
	size = design_size
	custom_minimum_size = design_size


func _frame(texture: Texture2D, frame_size: Vector2, index: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = texture
	frame.region = Rect2(Vector2(frame_size.x * index, 0.0), frame_size)
	frame.filter_clip = true
	return frame


func _has_point(point: Vector2) -> bool:
	return Rect2(-_hit_padding, -_hit_padding, size.x + _hit_padding * 2.0, size.y + _hit_padding * 2.0).has_point(point)
