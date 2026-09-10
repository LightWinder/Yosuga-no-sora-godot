extends AppreciationVisualCard


func configure(item: StringName, caption: String, _texture_path: String, unlocked: bool, card_size := Vector2(448.0, 224.0)) -> void:
	item_id = item
	custom_minimum_size = card_size
	_locked = not unlocked
	_thumbnail = get_node("Panel/Thumbnail") as TextureRect
	(get_node("Number") as Label).text = caption
	(get_node("Caption") as Label).text = "" if unlocked else "未解锁"
	get_node("Panel/Empty").visible = not unlocked
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_update_state)
	mouse_exited.connect(_update_state)
	focus_entered.connect(_update_state)
	focus_exited.connect(_update_state)
	button_down.connect(_update_state)
	button_up.connect(_update_state)
	_update_state()


func _update_state() -> void:
	disabled = _locked
	focus_mode = Control.FOCUS_NONE if _locked else Control.FOCUS_ALL
	if _thumbnail != null:
		_thumbnail.visible = not _locked
		if _locked:
			_thumbnail.texture = null
	var pressed := not _locked and is_pressed()
	var highlighted := not _locked and (is_hovered() or has_focus())
	get_node("Highlight").visible = not _locked and has_focus()
	get_node("Panel/StateTint").visible = highlighted and not pressed
	modulate = Color(0.92, 0.92, 0.92, 1.0) if pressed else Color.WHITE
