class_name TitleAlbumViewer
extends Control


signal closed
signal variant_changed(variant: TitleAlbumVariant)

var _card: TitleAlbumCard
var _profile: ProfileData
var _variants: Array[TitleAlbumVariant] = []
var _index := 0
var _image: TextureRect
var _status: Label
var _counter: Label
var _previous: Button
var _next: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	visible = false
	InputActions.ensure_actions()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if StartupInput.is_cancel_event(event):
		close()
		get_viewport().set_input_as_handled()
		return
	if _is_previous_event(event):
		previous_variant()
		get_viewport().set_input_as_handled()
		return
	if _is_next_event(event):
		next_variant()
		get_viewport().set_input_as_handled()
		return
	if InputActions.is_pressed(event, InputActions.ADVANCE) or InputActions.is_pressed(event, InputActions.CONFIRM):
		next_variant()
		get_viewport().set_input_as_handled()


func _is_previous_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key := event as InputEventKey
		return key.pressed and not key.echo and (key.keycode == KEY_LEFT or key.physical_keycode == KEY_LEFT)
	if event is InputEventJoypadButton:
		var button := event as InputEventJoypadButton
		return button.pressed and button.button_index == JOY_BUTTON_DPAD_LEFT
	return false


func _is_next_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key := event as InputEventKey
		return key.pressed and not key.echo and (key.keycode == KEY_RIGHT or key.physical_keycode == KEY_RIGHT)
	if event is InputEventJoypadButton:
		var button := event as InputEventJoypadButton
		return button.pressed and button.button_index == JOY_BUTTON_DPAD_RIGHT
	return false


func configure(card: TitleAlbumCard, profile: ProfileData) -> void:
	_card = card
	_profile = profile
	_variants = card.unlocked_variants(profile) if card != null else []
	_index = 0
	if is_inside_tree():
		_refresh()


func open_variant(variant: TitleAlbumVariant = null) -> bool:
	if _variants.is_empty():
		return false
	if variant != null:
		for candidate_index in _variants.size():
			if _variants[candidate_index].variant_id == variant.variant_id:
				_index = candidate_index
				break
	visible = true
	_refresh()
	return true


func close() -> void:
	visible = false
	closed.emit()


func next_variant() -> TitleAlbumVariant:
	if _variants.is_empty():
		return null
	_index = posmod(_index + 1, _variants.size())
	_refresh()
	return _variants[_index]


func previous_variant() -> TitleAlbumVariant:
	if _variants.is_empty():
		return null
	_index = posmod(_index - 1, _variants.size())
	_refresh()
	return _variants[_index]


func current_variant() -> TitleAlbumVariant:
	return _variants[_index] if not _variants.is_empty() else null


func variant_count() -> int:
	return _variants.size()


func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.92)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var panel := PanelContainer.new()
	panel.name = "ViewerPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -720.0
	panel.offset_top = -460.0
	panel.offset_right = 720.0
	panel.offset_bottom = 460.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 20)
	panel.add_child(box)
	_image = TextureRect.new()
	_image.name = "AlbumImage"
	_image.custom_minimum_size = Vector2(0.0, 700.0)
	_image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_image)
	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_status)
	_counter = Label.new()
	_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_counter)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	box.add_child(actions)
	_previous = Button.new()
	_previous.text = "上一差分"
	_previous.pressed.connect(previous_variant)
	actions.add_child(_previous)
	_next = Button.new()
	_next.text = "下一差分"
	_next.pressed.connect(next_variant)
	actions.add_child(_next)
	var close_button := Button.new()
	close_button.text = "返回相册"
	close_button.pressed.connect(close)
	actions.add_child(close_button)


func _refresh() -> void:
	if _image == null:
		return
	var current := current_variant()
	if current == null:
		_image.texture = null
		_status.text = "该相册尚未解锁。"
		_counter.text = ""
		return
	_image.texture = load(current.texture_path) as Texture2D
	_status.text = current.variant_id if _image.texture != null else "缺少资源：%s" % current.texture_path
	_counter.text = "%d / %d" % [_index + 1, _variants.size()]
	_previous.disabled = _variants.size() <= 1
	_next.disabled = _variants.size() <= 1
	variant_changed.emit(current)
