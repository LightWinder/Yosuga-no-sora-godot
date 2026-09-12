@tool
class_name SaveSlotList
extends ScrollContainer


signal slot_selected(slot_id: int, is_autosave: bool)
signal load_requested(slot_id: int, is_autosave: bool)
signal lock_requested(slot_id: int)
signal range_changed(first: int, last: int)

const CARD_SCENE: PackedScene = preload("res://src/save_load/save_slot_card.tscn")
const COLUMNS := 4
const GAP := 14.0
const SCROLL_GUTTER := 14.0
const VISIBLE_ROWS := 3

var _service: SaveService
var _load_mode := true
var _selected_id := 0
var _selected_auto := false
var _blocked := false
var _transfer_mode := false
var _cards: Array[SaveSlotCard] = []
var _bindings: Dictionary = {}
var _quick_history: Array[SaveData] = []
var _autosave_data: SaveData
var _cell := Vector2(252, 242)
var _row_pitch := _cell.y + GAP
var _total := SaveService.MAX_SLOT_COUNT
@onready var _items: Control = %Items


func _ready() -> void:
	get_v_scroll_bar().value_changed.connect(func(_value: float) -> void: _layout_cards())
	resized.connect(_layout_cards)
	_layout_cards.call_deferred()


func configure(service: SaveService, load_mode: bool) -> void:
	_service = service
	_load_mode = load_mode
	_total = SaveService.MAX_SLOT_COUNT + (SaveService.QUICK_SAVE_COUNT + 1 if load_mode else 0)
	if is_node_ready():
		reload()


func reload() -> void:
	_bindings.clear()
	_quick_history.clear()
	_autosave_data = null
	if _service != null and _load_mode:
		_quick_history = _service.load_quick_history()
		_autosave_data = _service.load_autosave()
	_layout_cards()


func cards() -> Array[SaveSlotCard]:
	var visible_cards: Array[SaveSlotCard] = []
	for card in _cards:
		if card.visible and card.position.y < scroll_vertical + size.y and card.position.y + card.size.y > scroll_vertical:
			visible_cards.append(card)
	visible_cards.sort_custom(func(a: SaveSlotCard, b: SaveSlotCard) -> bool: return int(a.get_meta("entry")) < int(b.get_meta("entry")))
	return visible_cards


func data_for(slot_id: int, is_autosave: bool) -> SaveData:
	for card in _cards:
		if card.visible and card.slot_id == slot_id and card.is_autosave == is_autosave:
			return card.save_data
	if _service == null:
		return null
	if is_autosave:
		return _autosave_data
	if slot_id >= SaveService.MAX_SLOT_COUNT:
		var quick_index := slot_id - SaveService.MAX_SLOT_COUNT
		return _quick_history[quick_index] if quick_index >= 0 and quick_index < _quick_history.size() else null
	return _service.load_slot(slot_id)


func set_selection(slot_id: int, is_autosave: bool) -> void:
	_selected_id = slot_id
	_selected_auto = is_autosave
	for card in _cards:
		card.set_selected(not card.disabled and card.slot_id == slot_id and card.is_autosave == is_autosave)


func set_transfer_mode(enabled: bool) -> void:
	_transfer_mode = enabled
	for card in _cards:
		card.set_load_enabled(_load_mode and not enabled)
		card.set_transfer_mode(enabled)
		card.set_selection_enabled(_can_select_card(card))
	set_selection(_selected_id, _selected_auto)


func set_modal_blocked(blocked: bool) -> void:
	_blocked = blocked
	mouse_filter = Control.MOUSE_FILTER_IGNORE if blocked else Control.MOUSE_FILTER_STOP
	for card in _cards:
		card.set_modal_blocked(blocked)


func scroll_to_entry(entry: int, focus: bool = false) -> void:
	entry = clampi(entry, 0, _total - 1)
	var top := (entry / COLUMNS) * _row_pitch
	if top < scroll_vertical:
		scroll_vertical = int(top)
	elif top + _cell.y > scroll_vertical + size.y:
		scroll_vertical = ceili(top + _cell.y - size.y)
	_layout_cards()
	if focus:
		for card in _cards:
			if card.visible and int(card.get_meta("entry", -1)) == entry:
				_emit_selection(card.slot_id, card.is_autosave)
				card.focus_card()
				break


func _layout_cards() -> void:
	if not is_node_ready() or size.x <= 0 or size.y <= 0:
		return
	var width := size.x - get_v_scroll_bar().size.x - SCROLL_GUTTER
	var card_width := (width - GAP * (COLUMNS - 1)) / COLUMNS
	_cell = Vector2(card_width, maxf(242.0, (size.y - GAP * (VISIBLE_ROWS - 1)) / VISIBLE_ROWS))
	_row_pitch = _cell.y + GAP
	var rows := ceili(float(_total) / COLUMNS)
	_items.custom_minimum_size.y = (rows - 1) * _row_pitch + _cell.y
	var pool_size := mini(_total, (VISIBLE_ROWS + 2) * COLUMNS)
	while _cards.size() < pool_size:
		var card := CARD_SCENE.instantiate() as SaveSlotCard
		card.name = "VisibleSaveCell%02d" % _cards.size()
		_items.add_child(card)
		card.slot_pressed.connect(_on_selected)
		card.load_requested.connect(func(id: int, auto: bool) -> void: load_requested.emit(id, auto))
		card.lock_requested.connect(func(id: int) -> void: lock_requested.emit(id))
		card.card_button().gui_input.connect(_on_card_input.bind(card))
		_cards.append(card)
	var first_row := maxi(0, floori(float(scroll_vertical) / _row_pitch) - 1)
	for pool_index in _cards.size():
		var entry := first_row * COLUMNS + pool_index
		# Stable modulo assignment preserves the focus owner during one-row scrolls.
		var card := _cards[entry % _cards.size()]
		card.visible = entry < _total
		if not card.visible:
			continue
		card.position = Vector2((entry % COLUMNS) * (_cell.x + GAP), (entry / COLUMNS) * _row_pitch)
		card.size = _cell
		if int(_bindings.get(card, -1)) != entry:
			_bindings[card] = entry
			card.set_meta("entry", entry)
			var auto := entry == SaveService.MAX_SLOT_COUNT + SaveService.QUICK_SAVE_COUNT
			var id := -1 if auto else entry
			var data: SaveData
			if _service != null:
				if auto:
					data = _autosave_data
				elif entry >= SaveService.MAX_SLOT_COUNT:
					var quick_index := entry - SaveService.MAX_SLOT_COUNT
					if quick_index < _quick_history.size():
						data = _quick_history[quick_index]
				else:
					data = _service.load_slot(entry)
			card.bind(id, auto, data)
			card.set_load_enabled(_load_mode and not _transfer_mode)
			card.set_transfer_mode(_transfer_mode)
			card.set_selection_enabled(_can_select_card(card))
			card.set_selected(not card.disabled and id == _selected_id and auto == _selected_auto)
			card.set_modal_blocked(_blocked)
	var first := floori(float(scroll_vertical) / _row_pitch) * COLUMNS
	range_changed.emit(first + 1, mini(first + VISIBLE_ROWS * COLUMNS, _total))


func _on_selected(id: int, auto: bool) -> void:
	if not _blocked:
		_emit_selection(id, auto)


func _emit_selection(id: int, auto: bool) -> void:
	slot_selected.emit(id, auto)


func _on_card_input(event: InputEvent, card: SaveSlotCard) -> void:
	if _blocked or card.disabled or event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	var delta := 0
	if event.is_action_pressed("ui_down"):
		delta = COLUMNS
	elif event.is_action_pressed("ui_up"):
		delta = -COLUMNS
	elif event.is_action_pressed("ui_left"):
		delta = -1
	elif event.is_action_pressed("ui_right"):
		delta = 1
	if delta != 0:
		accept_event()
		scroll_to_entry(int(card.get_meta("entry")) + delta, true)


func _can_select_card(card: SaveSlotCard) -> bool:
	if _transfer_mode:
		return not card.is_autosave and card.slot_id >= 0 and card.slot_id < SaveService.MAX_SLOT_COUNT
	return not _load_mode or card.has_save()
