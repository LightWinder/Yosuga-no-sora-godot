class_name TitleMusicButton
extends TextureButton


## Source HD music row: `track_XX.png` is the title artwork, while the
## three-state `bgm_hitbox.png` is the actual normal/hover/pressed surface.
## Keeping them separate avoids cropping the title atlas and preserves the
## source 3×7 information architecture.
var _title_layer: TextureRect


func configure(track_texture_path: String, hitbox_texture_path: String) -> void:
	var hitbox := load(hitbox_texture_path) as Texture2D
	var title := load(track_texture_path) as Texture2D
	if hitbox == null or title == null:
		return
	var frame_size := Vector2(hitbox.get_width() / 3.0, hitbox.get_height())
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	custom_minimum_size = frame_size
	size = frame_size
	texture_normal = _frame(hitbox, frame_size, 0)
	texture_hover = _frame(hitbox, frame_size, 1)
	texture_pressed = _frame(hitbox, frame_size, 2)
	texture_focused = _frame(hitbox, frame_size, 1)
	texture_disabled = _frame(hitbox, frame_size, 0)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_title_layer = TextureRect.new()
	_title_layer.name = "TitleArtwork"
	_title_layer.texture = title
	_title_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_title_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_title_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_title_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title_layer)


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
	return Rect2(-16.0, -16.0, size.x + 32.0, size.y + 32.0).has_point(point)
