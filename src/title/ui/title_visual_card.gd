class_name TitleVisualCard
extends TextureButton


signal activated

var item_id: StringName = &""
var _thumbnail: TextureRect
var _caption: Label
var _badge: Label
var _locked := true
var _card_size := Vector2(300.0, 190.0)


func configure(item: StringName, title: String, texture_path: String, unlocked: bool, card_size := Vector2(300.0, 190.0)) -> void:
	item_id = item
	_card_size = card_size
	custom_minimum_size = card_size
	size = card_size
	texture_normal = _frame(texture_path, 0)
	texture_hover = _frame(texture_path, 1)
	texture_pressed = _frame(texture_path, 1)
	texture_focused = _frame(texture_path, 1)
	texture_disabled = _frame(texture_path, 0)
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	focus_mode = Control.FOCUS_ALL
	_locked = not unlocked
	disabled = false
	_mouse_layer()
	_thumbnail = TextureRect.new()
	_thumbnail.position = Vector2(12.0, 12.0)
	_thumbnail.size = Vector2(card_size.x - 24.0, card_size.y - 70.0)
	_thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_thumbnail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_thumbnail.texture = load(texture_path) as Texture2D if texture_path.begins_with("res://") else null
	add_child(_thumbnail)
	_caption = Label.new()
	_caption.position = Vector2(14.0, card_size.y - 53.0)
	_caption.size = Vector2(card_size.x - 28.0, 30.0)
	_caption.text = title
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption.add_theme_font_size_override("font_size", 20)
	_caption.add_theme_color_override("font_color", Color.WHITE)
	_caption.add_theme_color_override("font_outline_color", Color(0.02, 0.12, 0.18, 1.0))
	_caption.add_theme_constant_override("outline_size", 4)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caption)
	_badge = Label.new()
	_badge.position = Vector2(14.0, 14.0)
	_badge.size = Vector2(card_size.x - 28.0, 30.0)
	_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_badge.add_theme_font_size_override("font_size", 18)
	_badge.add_theme_color_override("font_color", Color.WHITE)
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_badge)
	_update_state()
	pressed.connect(func() -> void: activated.emit())


func set_thumbnail(texture: Texture2D) -> void:
	if _thumbnail != null:
		_thumbnail.texture = texture


func set_unlocked(value: bool) -> void:
	_locked = not value
	_update_state()


func _update_state() -> void:
	if _badge == null:
		return
	_badge.text = "LOCKED" if _locked else "UNLOCKED"
	_badge.modulate = Color(0.75, 0.85, 0.9, 0.88) if _locked else Color(0.8, 1.0, 0.92, 1.0)
	_thumbnail.modulate = Color(0.38, 0.48, 0.52, 0.65) if _locked else Color.WHITE


func _frame(path: String, index: int) -> AtlasTexture:
	var texture := load(path) as Texture2D
	var frame := AtlasTexture.new()
	if texture == null:
		return frame
	var width := texture.get_width() / 3.0
	frame.atlas = texture
	frame.region = Rect2(Vector2(width * index, 0.0), Vector2(width, texture.get_height()))
	return frame


func _mouse_layer() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
