@tool
class_name SaveSlotCard
extends Button


## One reusable save entry. The scene owns its complete visual hierarchy;
## this script only formats SaveData and exposes a typed slot identity.
signal slot_pressed(slot_id: int, is_autosave: bool)

var slot_id := -1
var is_autosave := false
var save_data: SaveData

@onready var _slot_number: Label = %SlotNumber
@onready var _kind_badge: Label = %KindBadge
@onready var _thumbnail: TextureRect = %Thumbnail
@onready var _empty_preview: Control = %EmptyPreview
@onready var _comment: Label = %Comment
@onready var _date: Label = %Date


func _ready() -> void:
	pressed.connect(_emit_slot_pressed)
	if Engine.is_editor_hint():
		_show_editor_sample()


func bind(entry_slot_id: int, entry_is_autosave: bool, data: SaveData) -> void:
	slot_id = entry_slot_id
	is_autosave = entry_is_autosave
	save_data = data
	_slot_number.text = "AUTO" if is_autosave else "%02d" % (slot_id + 1)
	_kind_badge.text = "自动" if is_autosave else "手动"
	_kind_badge.visible = is_autosave
	_comment.text = _display_comment(data)
	_date.text = _display_date(data)
	_set_thumbnail(_thumbnail_path(data))
	disabled = false
	tooltip_text = _tooltip(data)


func clear_binding() -> void:
	slot_id = -1
	is_autosave = false
	save_data = null
	_slot_number.text = "--"
	_kind_badge.visible = false
	_comment.text = ""
	_date.text = ""
	_set_thumbnail("")
	disabled = true
	set_selected(false)
	tooltip_text = ""


func set_selected(selected: bool) -> void:
	button_pressed = selected
	_slot_number.theme_type_variation = &"SaveLoadSlotNumberSelected" if selected else &"SaveLoadSlotNumber"
	_comment.theme_type_variation = &"SaveLoadSlotCommentSelected" if selected else &"SaveLoadSlotComment"
	var date_variation := &"SaveLoadSlotDateSelected" if selected else &"SaveLoadSlotDate"
	_date.theme_type_variation = date_variation
	_kind_badge.theme_type_variation = date_variation


func has_save() -> bool:
	return save_data != null


func set_modal_blocked(blocked: bool) -> void:
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
	var label := str(data.autosave_meta.get("label", "")).strip_edges()
	if not label.is_empty():
		return label
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


func _thumbnail_path(data: SaveData) -> String:
	if data == null:
		return ""
	for key in ["thumbnail_path", "screenshot_path", "thumbnail"]:
		var value := str(data.presentation.get(key, ""))
		if not value.is_empty():
			return value
	return ""


func _set_thumbnail(path: String) -> void:
	var texture := _load_thumbnail(path)
	_thumbnail.texture = texture
	_thumbnail.visible = texture != null
	_empty_preview.visible = texture == null


func _load_thumbnail(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if path.begins_with("res://") and ResourceLoader.exists(path):
		return load(path) as Texture2D
	if path.begins_with("user://") or path.is_absolute_path():
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)
	return null


func _tooltip(data: SaveData) -> String:
	var slot_name := "自动存档" if is_autosave else "手动存档 %02d" % (slot_id + 1)
	if data == null:
		return "%s（空）" % slot_name
	return "%s\n%s\n%s" % [slot_name, _display_comment(data), data.instruction_anchor]


func _show_editor_sample() -> void:
	if _slot_number == null:
		return
	_slot_number.text = "01"
	_kind_badge.visible = false
	_comment.text = "空存档"
	_date.text = "---- / -- / --   --:--"
	_set_thumbnail("")
