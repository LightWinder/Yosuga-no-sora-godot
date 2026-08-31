@tool
class_name SaveLoadPage
extends DesignCanvasPage


signal back_requested
signal load_requested(data: SaveData, save_path: String)
signal save_completed(slot_id: int)
signal status_changed(message: String)
signal mode_changed(mode: Mode)

enum Mode {
	LOAD,
	SAVE,
}

enum PendingAction {
	NONE,
	DELETE,
	OVERWRITE,
}

const ENTRIES_PER_PAGE := 12
const TOTAL_ENTRY_COUNT := SaveService.MAX_SLOT_COUNT + 1
const PAGE_COUNT := ceili(float(TOTAL_ENTRY_COUNT) / ENTRIES_PER_PAGE)

@export var mode := Mode.LOAD:
	set(value):
		mode = value
		if is_node_ready():
			_refresh_all()

var _save_service: SaveService
var _save_payload: SaveData
var _page_index := 0
var _selected_slot_id := -1
var _selected_is_autosave := false
var _selected_data: SaveData
var _pending_delete_slot_id := -1
var _pending_delete_is_autosave := false
var _pending_action := PendingAction.NONE

@onready var _page_title: PageTitle = %PageTitle
@onready var _save_mode_button: Button = %SaveMode
@onready var _load_mode_button: Button = %LoadMode
@onready var _preview_texture: TextureRect = %PreviewTexture
@onready var _preview_empty: Control = %PreviewEmpty
@onready var _preview_date: Label = %PreviewDate
@onready var _preview_location: Label = %PreviewLocation
@onready var _preview_comment: Label = %PreviewComment
@onready var _page_number: Label = %PageNumber
@onready var _previous_page: Button = %PreviousPage
@onready var _next_page: Button = %NextPage
@onready var _status: Label = %Status
@onready var _primary: Button = %Primary
@onready var _delete: Button = %Delete
@onready var _back: Button = %Back
@onready var _confirmation: ConfirmationOverlay = %ConfirmationOverlay
@onready var _slot_cards: Array[SaveSlotCard] = [
	%Slot01, %Slot02, %Slot03, %Slot04,
	%Slot05, %Slot06, %Slot07, %Slot08,
	%Slot09, %Slot10, %Slot11, %Slot12,
]


func configure(
		page_mode: Mode,
		save_service: SaveService,
		current_save: SaveData = null
) -> void:
	mode = page_mode
	_save_service = save_service
	_save_payload = current_save
	if is_inside_tree():
		_refresh_all()


func _ready() -> void:
	super._ready()
	for card in _slot_cards:
		card.slot_pressed.connect(_on_slot_pressed)
	_previous_page.pressed.connect(_change_page.bind(-1))
	_next_page.pressed.connect(_change_page.bind(1))
	_save_mode_button.pressed.connect(_switch_mode.bind(Mode.SAVE))
	_load_mode_button.pressed.connect(_switch_mode.bind(Mode.LOAD))
	_primary.pressed.connect(_on_primary_pressed)
	_delete.pressed.connect(_request_delete)
	_back.pressed.connect(func() -> void: back_requested.emit())
	_confirmation.confirmed.connect(_confirm_pending_action)
	_confirmation.canceled.connect(_cancel_pending_action)
	if _save_service == null and not Engine.is_editor_hint():
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	if _save_service != null and not _save_service.save_changed.is_connected(_on_save_changed):
		_save_service.save_changed.connect(_on_save_changed)
	_refresh_all()
	if not Engine.is_editor_hint():
		call_deferred("_focus_initial_slot")


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if is_delete_confirmation_visible() and StartupInput.is_cancel_event(event):
		_cancel_pending_action()
		get_viewport().set_input_as_handled()


func is_delete_confirmation_visible() -> bool:
	return is_confirmation_visible()


func is_confirmation_visible() -> bool:
	return _confirmation != null and _confirmation.visible


func cancel_delete_confirmation() -> void:
	_cancel_pending_action()


func confirm_delete_confirmation() -> void:
	_confirm_pending_action()


func slot_cards() -> Array[SaveSlotCard]:
	return _slot_cards.duplicate()


func selected_slot_id() -> int:
	return _selected_slot_id


func selected_is_autosave() -> bool:
	return _selected_is_autosave


func _refresh_all() -> void:
	if _slot_cards.is_empty():
		return
	_sync_mode_chrome()
	_select_initial_save()
	_refresh_page()
	_refresh_preview()
	_refresh_actions()


func _select_initial_save() -> void:
	if mode != Mode.LOAD or _selected_slot_id >= 0 or _selected_is_autosave or _save_service == null:
		return
	var newest_data := _save_service.load_autosave()
	var newest_entry_index := 0 if newest_data != null else -1
	for slot_id in SaveService.MAX_SLOT_COUNT:
		var data := _save_service.load_slot(slot_id)
		if data != null and (newest_data == null or data.saved_at_unix > newest_data.saved_at_unix):
			newest_data = data
			newest_entry_index = slot_id + 1
	if newest_entry_index < 0:
		return
	_page_index = newest_entry_index / ENTRIES_PER_PAGE
	_selected_is_autosave = newest_entry_index == 0
	_selected_slot_id = -1 if _selected_is_autosave else newest_entry_index - 1
	_selected_data = newest_data


func _sync_mode_chrome() -> void:
	var is_load := mode == Mode.LOAD
	_page_title.title = "读取" if is_load else "存档"
	_page_title.subtitle = "DATA LOAD." if is_load else "DATA SAVE."
	_load_mode_button.button_pressed = is_load
	_save_mode_button.button_pressed = not is_load
	# Title load has no live ADV state to save. The same scene remains ready
	# for an in-game owner to configure in SAVE mode with a SaveData payload.
	_load_mode_button.disabled = is_load
	_save_mode_button.disabled = not is_load or _save_payload == null
	_primary.text = "读取所选存档" if is_load else "保存到所选槽位"
	_back.text = "返回游戏" if _save_payload != null else "返回标题"


func _switch_mode(next_mode: Mode) -> void:
	if next_mode == mode or (next_mode == Mode.SAVE and _save_payload == null):
		return
	_page_index = 0
	_selected_slot_id = -1
	_selected_is_autosave = false
	_selected_data = null
	_clear_pending_delete()
	_pending_action = PendingAction.NONE
	mode = next_mode
	mode_changed.emit(mode)
	call_deferred("_focus_initial_slot")


func _refresh_page() -> void:
	_page_index = clampi(_page_index, 0, PAGE_COUNT - 1)
	for card_index in _slot_cards.size():
		var entry_index := _page_index * ENTRIES_PER_PAGE + card_index
		var card := _slot_cards[card_index]
		if entry_index >= TOTAL_ENTRY_COUNT:
			card.clear_binding()
			continue
		var is_autosave := entry_index == 0
		var slot_id := -1 if is_autosave else entry_index - 1
		var data := _load_entry(slot_id, is_autosave)
		card.bind(slot_id, is_autosave, data)
		card.disabled = mode == Mode.SAVE and is_autosave
		card.set_selected(
			_selected_is_autosave == is_autosave
			and _selected_slot_id == slot_id
		)
	_page_number.text = "%02d / %02d" % [_page_index + 1, PAGE_COUNT]
	_previous_page.disabled = _page_index <= 0
	_next_page.disabled = _page_index >= PAGE_COUNT - 1
	if _selected_slot_id >= 0 or _selected_is_autosave:
		_set_status("已选择：%s" % _selected_name())
	else:
		_set_status("请选择一个存档。" if mode == Mode.LOAD else "请选择保存位置。")


func _load_entry(slot_id: int, is_autosave: bool) -> SaveData:
	if _save_service == null:
		return null
	return _save_service.load_autosave() if is_autosave else _save_service.load_slot(slot_id)


func _change_page(delta: int) -> void:
	var next_page := clampi(_page_index + delta, 0, PAGE_COUNT - 1)
	if next_page == _page_index:
		return
	_page_index = next_page
	_selected_slot_id = -1
	_selected_is_autosave = false
	_selected_data = null
	_refresh_page()
	_refresh_preview()
	_refresh_actions()


func _on_slot_pressed(slot_id: int, is_autosave: bool) -> void:
	if mode == Mode.SAVE and is_autosave:
		_set_status("自动存档由游戏流程维护，不能手动覆盖。")
		return
	_selected_slot_id = slot_id
	_selected_is_autosave = is_autosave
	_selected_data = _load_entry(slot_id, is_autosave)
	for card in _slot_cards:
		card.set_selected(card.slot_id == slot_id and card.is_autosave == is_autosave)
	_refresh_preview()
	_refresh_actions()
	if mode == Mode.LOAD and _selected_data == null:
		_set_status("%s为空。" % _selected_name())
	else:
		_set_status("已选择：%s" % _selected_name())


func _selected_name() -> String:
	return "自动存档" if _selected_is_autosave else "手动存档 %02d" % (_selected_slot_id + 1)


func _refresh_preview() -> void:
	var data := _selected_data
	var texture := _thumbnail(data)
	_preview_texture.texture = texture
	_preview_texture.visible = texture != null
	_preview_empty.visible = texture == null
	if _selected_slot_id < 0 and not _selected_is_autosave:
		_preview_date.text = "尚未选择存档"
		_preview_location.text = "—"
		_preview_comment.text = "从右侧选择一个槽位以查看详细信息。"
		return
	_preview_date.text = _format_date(data)
	if data == null:
		_preview_location.text = "空槽位"
		_preview_comment.text = "这里还没有存档。"
		return
	var location := data.scenario_id
	if not data.instruction_anchor.is_empty():
		location += "  ·  " + data.instruction_anchor
	_preview_location.text = location if not location.is_empty() else "未记录剧情位置"
	var comment := str(data.autosave_meta.get("label", "")).strip_edges()
	_preview_comment.text = comment if not comment.is_empty() else "未添加文本注释。"


func _refresh_actions() -> void:
	var has_selection := _selected_slot_id >= 0 or _selected_is_autosave
	_primary.disabled = not has_selection
	if mode == Mode.LOAD:
		_primary.disabled = not has_selection or _selected_data == null
	else:
		_primary.disabled = not has_selection or _selected_is_autosave or _save_payload == null
	_delete.disabled = not has_selection or _selected_data == null


func _on_primary_pressed() -> void:
	if mode == Mode.LOAD:
		if _selected_data == null:
			return
		var path := _save_service.autosave_path() if _selected_is_autosave else _save_service.slot_path(_selected_slot_id)
		load_requested.emit(_selected_data, path)
		return
	if _save_payload == null or _selected_slot_id < 0:
		return
	if _selected_data != null:
		_pending_action = PendingAction.OVERWRITE
		_confirmation.open(
			"手动存档 %02d 已有内容。\n确定要覆盖吗？" % (_selected_slot_id + 1),
			"覆盖",
			"取消"
		)
		_set_slots_modal_blocked(true)
		return
	_save_selected_slot()


func _save_selected_slot() -> void:
	if _save_service.save_slot(_selected_slot_id, _save_payload):
		save_completed.emit(_selected_slot_id)
		_set_status("已保存到手动存档 %02d。" % (_selected_slot_id + 1))
	else:
		_set_status("保存失败：%s" % _save_service.last_error)


func _request_delete() -> void:
	if _selected_data == null:
		return
	_pending_delete_slot_id = _selected_slot_id
	_pending_delete_is_autosave = _selected_is_autosave
	_pending_action = PendingAction.DELETE
	var name := "自动存档" if _selected_is_autosave else "手动存档 %02d" % (_selected_slot_id + 1)
	_confirmation.open("确定要删除%s吗？\n此操作无法撤销。" % name, "删除", "取消")
	_set_slots_modal_blocked(true)


func _confirm_pending_action() -> void:
	if _confirmation == null or not _confirmation.visible:
		return
	_confirmation.close()
	_set_slots_modal_blocked(false)
	var action := _pending_action
	_pending_action = PendingAction.NONE
	if action == PendingAction.OVERWRITE:
		_save_selected_slot()
		return
	if action != PendingAction.DELETE:
		return
	var slot_id := _pending_delete_slot_id
	var is_autosave := _pending_delete_is_autosave
	_clear_pending_delete()
	var ok := _save_service.clear_autosave() if is_autosave else _save_service.clear_slot(slot_id)
	if not ok:
		_set_status("删除失败：%s" % _save_service.last_error)
		return
	_selected_slot_id = -1
	_selected_is_autosave = false
	_selected_data = null
	_refresh_all()
	_set_status("存档已删除。")


func _cancel_pending_action() -> void:
	if _confirmation != null:
		_confirmation.close()
	_set_slots_modal_blocked(false)
	_clear_pending_delete()
	_pending_action = PendingAction.NONE
	_set_status("已取消操作。")


func _clear_pending_delete() -> void:
	_pending_delete_slot_id = -1
	_pending_delete_is_autosave = false


func _set_slots_modal_blocked(blocked: bool) -> void:
	for card in _slot_cards:
		card.set_modal_blocked(blocked)


func _focus_initial_slot() -> void:
	if Engine.is_editor_hint() or not is_inside_tree() or not is_visible_in_tree():
		return
	for card in _slot_cards:
		if card.is_visible_in_tree() and not card.disabled:
			card.grab_focus()
			return
	if _back != null and _back.is_visible_in_tree() and not _back.disabled:
		_back.grab_focus()


func _on_save_changed(_slot_id: int, _is_autosave: bool) -> void:
	if _selected_slot_id >= 0 or _selected_is_autosave:
		_selected_data = _load_entry(_selected_slot_id, _selected_is_autosave)
	_refresh_all()


func _set_status(message: String) -> void:
	_status.text = message
	status_changed.emit(message)


func _format_date(data: SaveData) -> String:
	if data == null or data.saved_at_unix <= 0:
		return "---- / -- / --   --:--"
	var value := Time.get_datetime_dict_from_unix_time(data.saved_at_unix)
	return "%04d / %02d / %02d   %02d:%02d" % [
		int(value.get("year", 0)), int(value.get("month", 0)), int(value.get("day", 0)),
		int(value.get("hour", 0)), int(value.get("minute", 0)),
	]


func _thumbnail(data: SaveData) -> Texture2D:
	if data == null:
		return null
	for key in ["thumbnail_path", "screenshot_path", "thumbnail"]:
		var path := str(data.presentation.get(key, ""))
		if path.begins_with("res://") and ResourceLoader.exists(path):
			return load(path) as Texture2D
		if path.begins_with("user://") or path.is_absolute_path():
			var image := Image.load_from_file(ProjectSettings.globalize_path(path))
			if image != null and not image.is_empty():
				return ImageTexture.create_from_image(image)
	return null
