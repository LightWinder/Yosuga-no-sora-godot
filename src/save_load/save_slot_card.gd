@tool
class_name SaveSlotCard
extends Button


## One reusable save entry. The scene owns its complete visual hierarchy;
## this script only formats SaveData and exposes a typed slot identity.
signal slot_pressed(slot_id: int, is_autosave: bool)
signal load_requested(slot_id: int, is_autosave: bool)
signal lock_requested(slot_id: int)

var _load_enabled := false
var _modal_blocked := false
var _transfer_mode := false

var slot_id := -1
var is_autosave := false
var save_data: SaveData

@onready var _slot_number: Label = %SlotNumber
@onready var _kind_badge: Label = %KindBadge
@onready var _thumbnail: TextureRect = %Thumbnail
@onready var _empty_preview: Control = %EmptyPreview
@onready var _comment: Label = %Comment
@onready var _date: Label = %Date
@onready var _load_button: Button = %LoadButton
@onready var _lock_button: Button = %LockButton


func _ready() -> void:
	_load_button.icon = get_theme_icon(&"icon", &"SaveLoadThumbnailButton")
	pressed.connect(_emit_slot_pressed)
	_load_button.pressed.connect(func() -> void:
		if button_pressed and not _modal_blocked and _load_enabled and save_data != null:
			load_requested.emit(slot_id, is_autosave)
	)
	_lock_button.pressed.connect(func() -> void:
		if not _modal_blocked and not _transfer_mode and _is_manual_save() and save_data != null:
			lock_requested.emit(slot_id)
	)
	if Engine.is_editor_hint():
		_show_editor_sample()


func bind(entry_slot_id: int, entry_is_autosave: bool, data: SaveData) -> void:
	slot_id = entry_slot_id
	is_autosave = entry_is_autosave
	save_data = data
	_slot_number.text = "AUTO" if is_autosave else ("Q%02d" % (slot_id - SaveService.MAX_SLOT_COUNT + 1) if is_quick_save() else "%03d" % (slot_id + 1))
	_kind_badge.text = "自动" if is_autosave else ("快速" if is_quick_save() else "锁定")
	_kind_badge.visible = is_autosave or is_quick_save()
	_sync_lock_button()
	_comment.text = _display_comment(data)
	_date.text = _display_date(data)
	var texture := SaveThumbnail.texture_for(data)
	_thumbnail.texture = texture
	_thumbnail.visible = texture != null
	_empty_preview.visible = texture == null
	_sync_load_button()
	disabled = false
	tooltip_text = _tooltip(data)


func clear_binding() -> void:
	slot_id = -1
	is_autosave = false
	save_data = null
	_slot_number.text = "--"
	_kind_badge.visible = false
	_lock_button.visible = false
	_comment.text = ""
	_date.text = ""
	_clear_thumbnail()
	disabled = true
	set_selected(false)
	tooltip_text = ""


func set_selected(selected: bool) -> void:
	button_pressed = selected
	theme_type_variation = &"SaveLoadSlotButtonSelected" if selected else &"SaveLoadSlotButton"
	_slot_number.theme_type_variation = &"SaveLoadSlotNumberSelected" if selected else &"SaveLoadSlotNumber"
	_comment.theme_type_variation = &"SaveLoadSlotCommentSelected" if selected else &"SaveLoadSlotComment"
	var date_variation := &"SaveLoadSlotDateSelected" if selected else &"SaveLoadSlotDate"
	_date.theme_type_variation = date_variation
	_kind_badge.theme_type_variation = date_variation
	_sync_load_button()


func has_save() -> bool:
	return save_data != null


func set_modal_blocked(blocked: bool) -> void:
	_modal_blocked = blocked
	_load_button.disabled = blocked
	_sync_lock_button()
	_sync_load_button()
	mouse_filter = Control.MOUSE_FILTER_IGNORE if blocked else Control.MOUSE_FILTER_STOP
	if blocked:
		tooltip_text = ""
		release_focus()
	elif slot_id >= 0 or is_autosave:
		tooltip_text = _tooltip(save_data)


func _emit_slot_pressed() -> void:
	if slot_id >= 0 or is_autosave:
		slot_pressed.emit(slot_id, is_autosave)


func _display_comment(data: SaveData) -> String:
	if data == null:
		return "空存档"
	if not data.comment.is_empty():
		return data.comment
	if not data.scenario_id.is_empty():
		return data.scenario_id
	return "未命名存档"


func _display_date(data: SaveData) -> String:
	if data == null or data.saved_at_unix <= 0:
		return "---- / -- / --   --:--"
	var value := Time.get_datetime_dict_from_unix_time(data.saved_at_unix)
	return "%04d / %02d / %02d   %02d:%02d" % [
		int(value.get("year", 0)),
		int(value.get("month", 0)),
		int(value.get("day", 0)),
		int(value.get("hour", 0)),
		int(value.get("minute", 0)),
	]


func _clear_thumbnail() -> void:
	_thumbnail.texture = null
	_thumbnail.visible = false
	_empty_preview.visible = true


func _tooltip(data: SaveData) -> String:
	var slot_name := "自动存档" if is_autosave else ("快速存档 %02d" % (slot_id - SaveService.MAX_SLOT_COUNT + 1) if is_quick_save() else "手动存档 %03d" % (slot_id + 1))
	if data == null:
		return tr("%s（空）") % slot_name
	return "%s\n%s\n%s" % [slot_name, _display_comment(data), data.instruction_anchor]


func _show_editor_sample() -> void:
	if _slot_number == null:
		return
	_slot_number.text = "01"
	_kind_badge.visible = false
	_comment.text = "空存档"
	_date.text = "---- / -- / --   --:--"
	_clear_thumbnail()


func is_quick_save() -> bool:
	return not is_autosave and slot_id >= SaveService.MAX_SLOT_COUNT


func _is_manual_save() -> bool:
	return not is_autosave and slot_id >= 0 and slot_id < SaveService.MAX_SLOT_COUNT


func set_load_enabled(enabled: bool) -> void:
	_load_enabled = enabled
	_sync_load_button()


func set_transfer_mode(enabled: bool) -> void:
	_transfer_mode = enabled
	_sync_lock_button()


func _sync_load_button() -> void:
	if not is_node_ready():
		return
	_load_button.visible = button_pressed and _load_enabled and save_data != null and not _modal_blocked
	_load_button.disabled = not _load_button.visible


func _sync_lock_button() -> void:
	if not is_node_ready():
		return
	var visible_for_slot := _is_manual_save() and save_data != null
	_lock_button.visible = visible_for_slot
	_lock_button.disabled = not visible_for_slot or _modal_blocked or _transfer_mode
	if visible_for_slot:
		_lock_button.icon = get_theme_icon(&"locked" if save_data.locked else &"unlocked", &"SaveLoadCardLockButton")
		_lock_button.tooltip_text = "已锁定 · 点击解锁" if save_data.locked else "未锁定 · 点击锁定"
