class_name TitleAlbumViewer
extends Control


signal closed
signal variant_changed(variant: TitleAlbumVariant)

var _card: TitleAlbumCard
var _profile: ProfileData
var _variants: Array[TitleAlbumVariant] = []
var _index := 0
@onready var _image: TextureRect = $ViewerPanel/Margin/Content/AlbumImage
@onready var _status: Label = $ViewerPanel/Margin/Content/Status
@onready var _counter: Label = $ViewerPanel/Margin/Content/Counter
@onready var _previous: Button = $ViewerPanel/Margin/Content/Actions/Previous
@onready var _next: Button = $ViewerPanel/Margin/Content/Actions/Next
@onready var _close_button: Button = $ViewerPanel/Margin/Content/Actions/Close


func _ready() -> void:
	_previous.pressed.connect(previous_variant)
	_next.pressed.connect(next_variant)
	_close_button.pressed.connect(close)
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
