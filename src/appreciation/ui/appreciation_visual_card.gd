class_name AppreciationVisualCard
extends TextureButton


signal activated

var item_id: StringName = &""
var _thumbnail: TextureRect
var _frame_layer: TextureRect
var _frames: Array[AtlasTexture] = []
var _locked := true
var _card_size := Vector2(430.0, 250.0)


func configure(item: StringName, _title: String, texture_path: String, unlocked: bool, card_size := Vector2(430.0, 250.0)) -> void:
	item_id = item
	_card_size = card_size
	custom_minimum_size = card_size
	size = card_size
	_frames = [_frame(texture_path, 0), _frame(texture_path, 1), _frame(texture_path, 2)]
	texture_normal = null
	texture_hover = null
	texture_pressed = null
	texture_focused = null
	texture_disabled = null
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	focus_mode = Control.FOCUS_ALL
	_locked = not unlocked
	disabled = _locked
	_mouse_layer()
	_thumbnail = TextureRect.new()
	_thumbnail.name = "Thumbnail"
	_thumbnail.position = Vector2(2.0, 2.0)
	_thumbnail.size = Vector2(card_size.x - 14.0, card_size.y - 16.0)
	_thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_thumbnail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_thumbnail.visible = unlocked
	add_child(_thumbnail)
	_frame_layer = TextureRect.new()
	_frame_layer.name = "Frame"
	_frame_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_frame_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_frame_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_frame_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame_layer)
	mouse_entered.connect(_update_state)
	mouse_exited.connect(_update_state)
	focus_entered.connect(_update_state)
	focus_exited.connect(_update_state)
	button_down.connect(_update_state)
	button_up.connect(_update_state)
	_update_state()
	pressed.connect(func() -> void: activated.emit())


func set_thumbnail(texture: Texture2D) -> void:
	# Source behavior never loads the real art into a locked slot.  Besides
	# matching the third-frame lock card, this prevents locked CGs/memories
	# from being exposed through the scene tree or GPU texture cache.
	if not _locked and _thumbnail != null:
		_thumbnail.texture = texture


func set_unlocked(value: bool) -> void:
	_locked = not value
	_update_state()


func is_locked() -> bool:
	return _locked


func has_visible_thumbnail() -> bool:
	return _thumbnail != null and _thumbnail.visible and _thumbnail.texture != null


func _update_state() -> void:
	disabled = _locked
	focus_mode = Control.FOCUS_NONE if _locked else Control.FOCUS_ALL
	if _thumbnail != null:
		_thumbnail.visible = not _locked
		if _locked:
			_thumbnail.texture = null
	if _frame_layer != null and _frames.size() == 3:
		var highlighted := not _locked and (is_hovered() or has_focus() or is_pressed())
		_frame_layer.texture = _frames[2 if _locked else (1 if highlighted else 0)]


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
