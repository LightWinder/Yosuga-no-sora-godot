extends TitleVisualCard


func configure(item: StringName, caption: String, _texture_path: String, unlocked: bool, card_size := Vector2(396.0, 222.75)) -> void:
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
	_update_state()


func _update_state() -> void:
	disabled = _locked
	focus_mode = Control.FOCUS_NONE if _locked else Control.FOCUS_ALL
	if _thumbnail != null:
		_thumbnail.visible = not _locked
		if _locked:
			_thumbnail.texture = null
	var panel := get_node("Highlight") as Panel
	var highlighted := not _locked and (is_hovered() or has_focus())
	panel.add_theme_stylebox_override("panel", preload("res://assets/themes/save_load/slot_focus.tres"))
	panel.visible = highlighted
