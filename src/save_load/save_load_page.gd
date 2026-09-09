@tool
class_name SaveLoadPage
extends DesignCanvasPage


signal back_requested
signal load_requested(data: SaveData, save_path: String)
signal save_completed(slot_id: int)
signal status_changed(message: String)
signal mode_changed(mode: Mode)

enum Mode { LOAD, SAVE }
enum PendingAction { NONE, DELETE, OVERWRITE, COPY, MOVE }

@export var mode := Mode.LOAD:
	set(value):
		mode = value
		if is_node_ready():
			_refresh_all()

var _closing := false
var _close_tween: Tween
var _open_tween: Tween
var _canvas_rest_position := Vector2.ZERO

var _save_service: SaveService
var _save_payload: SaveData
var _selected_slot_id := 0
var _selected_is_autosave := false
var _selected_data: SaveData
var _pending_action := PendingAction.NONE
var _pending_slot_id := -1
var _pending_is_autosave := false
var _transfer_source: SaveData
var _transfer_source_id := -1
var _transfer_is_move := false

@onready var _page_title: PageTitle = %PageTitle
@onready var _save_mode_button: Button = %SaveMode
@onready var _load_mode_button: Button = %LoadMode
@onready var _preview_texture: TextureRect = %PreviewTexture
@onready var _preview_empty: Control = %PreviewEmpty
@onready var _preview_date: Label = %PreviewDate
@onready var _preview_location: Label = %PreviewLocation
@onready var _slot_list: SaveSlotList = %SlotList
@onready var _status: Label = %Status
@onready var _primary: Button = %Primary
@onready var _delete: Button = %Delete
@onready var _copy: Button = %Copy
@onready var _move: Button = %Move
@onready var _comment_edit: LineEdit = %CommentEdit
@onready var _back: Button = %Back
@onready var _confirmation: ConfirmationOverlay = %ConfirmationOverlay


func configure(page_mode: Mode, service: SaveService, current_save: SaveData = null) -> void:
	_save_service = service
	_save_payload = current_save
	mode = page_mode


func _ready() -> void:
	super._ready()
	_slot_list.slot_selected.connect(_on_slot_pressed)
	_slot_list.load_requested.connect(_on_slot_load_requested)
	_slot_list.lock_requested.connect(_toggle_slot_lock)
	_save_mode_button.pressed.connect(_switch_mode.bind(Mode.SAVE))
	_load_mode_button.pressed.connect(_switch_mode.bind(Mode.LOAD))
	_primary.pressed.connect(_on_primary_pressed)
	_delete.pressed.connect(_request_delete)
	_copy.pressed.connect(_begin_transfer.bind(false))
	_move.pressed.connect(_begin_transfer.bind(true))
	_comment_edit.text_submitted.connect(_save_comment)
	_back.pressed.connect(func() -> void: back_requested.emit())
	_confirmation.confirmed.connect(_confirm_pending_action)
	_confirmation.canceled.connect(_cancel_pending_action)
	(%ManualShortcut as Button).pressed.connect(scroll_to_entry.bind(0))
	(%QuickShortcut as Button).pressed.connect(scroll_to_entry.bind(SaveService.MAX_SLOT_COUNT))
	(%AutoShortcut as Button).pressed.connect(scroll_to_entry.bind(SaveService.MAX_SLOT_COUNT + SaveService.QUICK_SAVE_COUNT))
	if _save_service == null and not Engine.is_editor_hint():
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	if _save_service != null:
		_save_service.save_changed.connect(_on_save_changed)
	_refresh_all()
	if not Engine.is_editor_hint():
		_canvas_rest_position = visual_canvas().position
		_play_open_transition()
		_focus_initial_slot.call_deferred()


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if _closing:
		get_viewport().set_input_as_handled()
		return
	if StartupInput.is_cancel_event(event):
		if is_confirmation_visible():
			_cancel_pending_action()
			get_viewport().set_input_as_handled()
		elif _transfer_source != null:
			_end_transfer()
			_set_status("已取消复制或移动。")
			get_viewport().set_input_as_handled()
		else:
			back_requested.emit()
			get_viewport().set_input_as_handled()


func slot_cards() -> Array[SaveSlotCard]:
	return _slot_list.cards()


func scroll_to_entry(entry: int) -> void:
	_slot_list.scroll_to_entry(entry, true)


func selected_slot_id() -> int:
	return _selected_slot_id


func selected_is_autosave() -> bool:
	return _selected_is_autosave


func is_confirmation_visible() -> bool:
	return _confirmation != null and _confirmation.visible


func is_delete_confirmation_visible() -> bool:
	return is_confirmation_visible()


func cancel_delete_confirmation() -> void:
	_cancel_pending_action()


func confirm_delete_confirmation() -> void:
	_confirm_pending_action()


func _refresh_all() -> void:
	if not is_node_ready():
		return
	_page_title.title = "读取" if mode == Mode.LOAD else "存档"
	_page_title.subtitle = "DATA LOAD." if mode == Mode.LOAD else "DATA SAVE."
	_load_mode_button.button_pressed = mode == Mode.LOAD
	_save_mode_button.button_pressed = mode == Mode.SAVE
	_save_mode_button.disabled = _save_payload == null
	_primary.visible = mode == Mode.SAVE
	_back.text = "返回游戏" if _save_payload != null else "返回标题"
	(%QuickShortcut as Button).visible = mode == Mode.LOAD
	(%AutoShortcut as Button).visible = mode == Mode.LOAD
	_selected_data = _load_entry(_selected_slot_id, _selected_is_autosave)
	_slot_list.configure(_save_service, mode == Mode.LOAD)
	_slot_list.set_selection(_selected_slot_id, _selected_is_autosave)
	_refresh_preview()
	_refresh_actions()
	if _transfer_source == null:
		_set_status("已选择：%s" % _selected_name())


func _switch_mode(next_mode: Mode) -> void:
	if next_mode == mode or (next_mode == Mode.SAVE and _save_payload == null) or is_confirmation_visible():
		return
	_end_transfer()
	_selected_slot_id = 0
	_selected_is_autosave = false
	mode = next_mode
	_slot_list.scroll_vertical = 0
	mode_changed.emit(mode)
	_focus_initial_slot.call_deferred()


func _load_entry(id: int, auto: bool) -> SaveData:
	if _save_service == null:
		return null
	if auto:
		return _save_service.load_autosave()
	if id >= SaveService.MAX_SLOT_COUNT:
		return _save_service.load_quick(id - SaveService.MAX_SLOT_COUNT)
	return _save_service.load_slot(id)


func _on_slot_pressed(id: int, auto: bool) -> void:
	if is_confirmation_visible():
		return
	if _transfer_source != null:
		_choose_transfer_destination(id, auto)
		return
	_selected_slot_id = id
	_selected_is_autosave = auto
	_selected_data = _load_entry(id, auto)
	_slot_list.set_selection(id, auto)
	_refresh_preview()
	_refresh_actions()
	_set_status("已选择：%s%s" % [_selected_name(), "（空）" if _selected_data == null else ""])


func _on_slot_load_requested(id: int, auto: bool) -> void:
	if mode != Mode.LOAD or is_confirmation_visible() or _transfer_source != null:
		return
	if id != _selected_slot_id or auto != _selected_is_autosave:
		return
	if _selected_data == null:
		return
	var path := _save_service.slot_path(id)
	if auto:
		path = _save_service.autosave_path()
	elif id >= SaveService.MAX_SLOT_COUNT:
		path = _save_service.quick_save_path(id - SaveService.MAX_SLOT_COUNT)
	load_requested.emit(_selected_data, path)


func _selected_name() -> String:
	if _selected_is_autosave:
		return "自动存档"
	if _selected_slot_id >= SaveService.MAX_SLOT_COUNT:
		return "快速存档 %02d" % (_selected_slot_id - SaveService.MAX_SLOT_COUNT + 1)
	return "手动存档 %03d" % (_selected_slot_id + 1)


func _is_manual_selection() -> bool:
	return not _selected_is_autosave and _selected_slot_id >= 0 and _selected_slot_id < SaveService.MAX_SLOT_COUNT


func _refresh_preview() -> void:
	var data := _selected_data
	var texture := SaveThumbnail.texture_for(data)
	_preview_texture.texture = texture
	_preview_texture.visible = texture != null
	_preview_empty.visible = texture == null
	_preview_date.text = _format_date(data)
	_comment_edit.text = data.comment if data != null else ""
	if data == null:
		_preview_location.text = "空槽位"
		return
	var location := data.scenario_id
	if not data.instruction_anchor.is_empty():
		location += "  ·  " + data.instruction_anchor
	_preview_location.text = location if not location.is_empty() else "未记录剧情位置"


func _refresh_actions() -> void:
	var occupied := _selected_data != null
	var locked := occupied and _selected_data.locked
	var manual := _is_manual_selection()
	var transferring := _transfer_source != null
	_primary.disabled = _save_payload == null or not manual or locked or transferring
	_delete.disabled = not occupied or locked or transferring or (not manual and not _selected_is_autosave)
	_copy.disabled = _transfer_is_move if transferring else not occupied
	_copy.text = "取消复制" if transferring and not _transfer_is_move else "复制"
	_move.disabled = not _transfer_is_move if transferring else (not manual or not occupied or locked)
	_move.text = "取消移动" if transferring and _transfer_is_move else "移动"
	_comment_edit.editable = manual and occupied and not locked and not transferring


func _on_primary_pressed() -> void:
	if mode != Mode.SAVE or _primary.disabled or is_confirmation_visible():
		return
	_pending_slot_id = _selected_slot_id
	if _selected_data != null:
		_open_confirmation(PendingAction.OVERWRITE, "%s已有内容，确定覆盖吗？" % _selected_name(), "覆盖")
	else:
		_save_selected_slot()


func _save_selected_slot() -> void:
	if _save_service.save_slot(_pending_slot_id, _save_payload):
		save_completed.emit(_pending_slot_id)
		_set_status("存档已保存。")
	else:
		_set_status("保存失败：%s" % _save_service.last_error)


func _request_delete() -> void:
	if _delete.disabled or is_confirmation_visible():
		return
	_pending_slot_id = _selected_slot_id
	_pending_is_autosave = _selected_is_autosave
	_open_confirmation(PendingAction.DELETE, "确定删除%s吗？" % _selected_name(), "删除")


func _begin_transfer(move: bool) -> void:
	if is_confirmation_visible():
		return
	if _transfer_source != null:
		_end_transfer()
		_set_status("已取消操作。")
		return
	if _selected_data == null or (move and (not _is_manual_selection() or _selected_data.locked)):
		return
	_transfer_source = SaveData.from_dictionary(_selected_data.to_dictionary())
	_transfer_source_id = _selected_slot_id if _is_manual_selection() else -1
	_transfer_is_move = move
	_slot_list.set_transfer_mode(true)
	_refresh_actions()
	_set_status("%s %s → 请选择目标手动槽位" % ["移动" if move else "复制", _selected_name()])
	if not _is_manual_selection():
		_slot_list.scroll_to_entry(0)


func _choose_transfer_destination(id: int, auto: bool) -> void:
	if auto or id < 0 or id >= SaveService.MAX_SLOT_COUNT or id == _transfer_source_id:
		_set_status("请选择另一个手动槽位作为目标。")
		return
	var destination := _save_service.load_slot(id)
	if destination != null and destination.locked:
		_set_status("目标槽位已锁定，请先解锁。")
		return
	_pending_slot_id = id
	var verb := "移动" if _transfer_is_move else "复制"
	_open_confirmation(PendingAction.MOVE if _transfer_is_move else PendingAction.COPY,
		"%s到手动存档 %03d？%s" % [verb, id + 1, "\n目标已有存档，将被覆盖。" if destination != null else ""], verb)


func _end_transfer() -> void:
	_transfer_source = null
	_transfer_source_id = -1
	_transfer_is_move = false
	_slot_list.set_transfer_mode(false)
	_refresh_actions()


func _toggle_slot_lock(slot_id: int) -> void:
	if is_confirmation_visible() or _transfer_source != null:
		return
	var data := _save_service.load_slot(slot_id)
	if data == null:
		return
	if not _save_service.set_slot_locked(slot_id, not data.locked):
		_set_status("修改锁定状态失败：%s" % _save_service.last_error)


func _save_comment(comment: String) -> void:
	if not _comment_edit.editable:
		return
	if _save_service.set_slot_comment(_selected_slot_id, comment):
		_set_status("存档文本已保存。")
	else:
		_set_status("存档文本保存失败：%s" % _save_service.last_error)


func _open_confirmation(action: PendingAction, message: String, confirm_text: String) -> void:
	_pending_action = action
	_confirmation.open(message, confirm_text, "取消")
	_slot_list.set_modal_blocked(true)


func _confirm_pending_action() -> void:
	if not is_confirmation_visible():
		return
	var action := _pending_action
	_pending_action = PendingAction.NONE
	_confirmation.close()
	_slot_list.set_modal_blocked(false)
	if action == PendingAction.OVERWRITE:
		_save_selected_slot()
		return
	var ok := false
	if action == PendingAction.DELETE:
		ok = _save_service.clear_autosave() if _pending_is_autosave else _save_service.clear_slot(_pending_slot_id)
	elif action == PendingAction.COPY:
		ok = _save_service.copy_to_slot(_transfer_source, _pending_slot_id)
	elif action == PendingAction.MOVE:
		ok = _save_service.move_slot(_transfer_source_id, _pending_slot_id)
	if action == PendingAction.COPY or action == PendingAction.MOVE:
		_end_transfer()
		if ok:
			_on_slot_pressed(_pending_slot_id, false)
	if ok:
		_set_status("存档已删除。" if action == PendingAction.DELETE else "存档已%s。" % ("移动" if action == PendingAction.MOVE else "复制"))
	else:
		_set_status("操作失败：%s" % _save_service.last_error)


func _cancel_pending_action() -> void:
	_confirmation.close()
	_slot_list.set_modal_blocked(false)
	_pending_action = PendingAction.NONE
	_set_status("请选择目标槽位，或点击取消。" if _transfer_source != null else "已取消操作。")


func _focus_initial_slot() -> void:
	if not Engine.is_editor_hint() and is_visible_in_tree():
		_slot_list.scroll_to_entry(0, true)


func _on_save_changed(_id: int, _auto: bool) -> void:
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


func is_closing() -> bool:
	return _closing


## Match SettingsScreen's close motion, leaving the live backdrop in place.
func play_close_transition() -> void:
	if _closing:
		return
	_closing = true
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	_open_tween = null
	_slot_list.set_modal_blocked(true)
	var canvas := visual_canvas()
	_close_tween = create_tween().set_parallel(true)
	_close_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_close_tween.tween_property(self, "modulate:a", 0.0, 0.30)
	_close_tween.tween_property(canvas, "position", _canvas_rest_position + Vector2(0.0, 18.0), 0.30)
	await _close_tween.finished
	_close_tween = null


func _exit_tree() -> void:
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	if _close_tween != null and _close_tween.is_valid():
		_close_tween.kill()


## Same 300 ms cubic ease-out and 18 px rise as SettingsScreen.
func _play_open_transition() -> void:
	modulate.a = 0.0
	var canvas := visual_canvas()
	canvas.position = _canvas_rest_position + Vector2(0.0, 18.0)
	var tween := create_tween().set_parallel(true)
	_open_tween = tween
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.30)
	tween.tween_property(canvas, "position", _canvas_rest_position, 0.30)
	await tween.finished
	if _open_tween == tween:
		_open_tween = null
