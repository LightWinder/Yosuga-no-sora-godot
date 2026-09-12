@tool
class_name SaveSlotCard
extends Control


## One reusable save entry. The scene owns its complete visual hierarchy;
## this script only formats SaveData and exposes a typed slot identity.
signal slot_pressed(slot_id: int, is_autosave: bool)
signal load_requested(slot_id: int, is_autosave: bool)
signal lock_requested(slot_id: int)

const LOAD_ACTION_FADE_SECONDS := 0.1

var _load_enabled := false
var _modal_blocked := false
var _transfer_mode := false
var _selection_enabled := true
var _load_action_target_visible := false
var _load_action_tween: Tween
var _selected := false
var _disabled := false

var disabled: bool:
	get:
		return _disabled
	set(value):
		_disabled = value
		if is_node_ready():
			_sync_card_button()

var slot_id := -1
var is_autosave := false
var save_data: SaveData

@onready var _card_button: Button = %CardButton
@onready var _slot_number: Label = %SlotNumber
@onready var _selection_inner_shadow: ColorRect = %SelectionInnerShadow
@onready var _kind_badge: Label = %KindBadge
@onready var _thumbnail: TextureRect = %Thumbnail
@onready var _blurred_thumbnail: TextureRect = %BlurredThumbnail
@onready var _header_scrim: ColorRect = %HeaderScrim
@onready var _missing_preview: Control = %MissingPreview
@onready var _empty_preview: Control = %EmptyPreview
@onready var _empty_plus: Label = %Plus
@onready var _metadata_margin: MarginContainer = %MetadataMargin
@onready var _comment: Label = %Comment
@onready var _date: Label = %Date
@onready var _load_action_layer: Control = %LoadActionLayer
@onready var _lock_button: Button = %LockButton


func _ready() -> void:
	resized.connect(_sync_inner_shadow_size)
	_sync_inner_shadow_size()
	_card_button.pressed.connect(_on_card_pressed)
	_lock_button.pressed.connect(func() -> void:
		if not _modal_blocked and not _transfer_mode and _is_manual_save() and save_data != null:
			lock_requested.emit(slot_id)
	)
	_sync_card_button()
	if Engine.is_editor_hint():
		_show_editor_sample()


func bind(entry_slot_id: int, entry_is_autosave: bool, data: SaveData) -> void:
	_selected = false
	_set_load_action_visible(false, false)
	slot_id = entry_slot_id
	is_autosave = entry_is_autosave
	save_data = data
	_slot_number.text = "AUTO" if is_autosave else ("Q%02d" % (slot_id - SaveService.MAX_SLOT_COUNT + 1) if is_quick_save() else "%03d" % (slot_id + 1))
	_kind_badge.text = "快速" if is_quick_save() else ""
	_kind_badge.visible = is_quick_save()
	_sync_lock_button()
	_comment.text = _display_comment(data)
	_date.text = _display_date(data)
	var texture := SaveThumbnail.texture_for(data)
	_thumbnail.texture = texture
	_thumbnail.visible = texture != null
	_blurred_thumbnail.texture = texture
	_blurred_thumbnail.visible = texture != null
	_header_scrim.visible = texture != null
	_missing_preview.visible = data != null and texture == null
	_empty_preview.visible = data == null
	_sync_empty_state()
	_metadata_margin.visible = data != null
	_comment.theme_type_variation = &"SaveLoadSlotOverlayComment" if texture != null else &"SaveLoadSlotMissingComment"
	_date.theme_type_variation = &"SaveLoadSlotOverlayDate" if texture != null else &"SaveLoadSlotMissingDate"
	_sync_load_button(false)
	disabled = not _selection_enabled
	_set_card_tooltip(_tooltip(data))


func clear_binding() -> void:
	_set_load_action_visible(false, false)
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
	_set_card_tooltip("")


func set_selected(selected: bool) -> void:
	_selected = selected
	_selection_inner_shadow.visible = selected
	_card_button.theme_type_variation = &"SaveLoadSlotButtonSelected" if selected else &"SaveLoadSlotButton"
	_slot_number.theme_type_variation = &"SaveLoadSlotNumberSelected" if selected else &"SaveLoadSlotNumber"
	_sync_load_button()


func _sync_inner_shadow_size() -> void:
	var shadow_material := _selection_inner_shadow.material as ShaderMaterial
	if shadow_material != null:
		shadow_material.set_shader_parameter(&"rect_size", size)


func has_save() -> bool:
	return save_data != null


func set_modal_blocked(blocked: bool) -> void:
	_modal_blocked = blocked
	_sync_card_button()
	_sync_lock_button()
	_sync_load_button()
	if blocked:
		_set_card_tooltip("")
		_card_button.release_focus()
	elif slot_id >= 0 or is_autosave:
		_set_card_tooltip(_tooltip(save_data))


func _on_card_pressed() -> void:
	if not _selection_enabled or (slot_id < 0 and not is_autosave):
		return
	if _selected and _can_request_load():
		load_requested.emit(slot_id, is_autosave)
		return
	slot_pressed.emit(slot_id, is_autosave)


func _can_request_load() -> bool:
	return _load_enabled and save_data != null and not _modal_blocked and not _transfer_mode


func _sync_card_button() -> void:
	if not is_node_ready():
		return
	var blocked := _disabled or _modal_blocked
	_card_button.disabled = blocked
	_card_button.mouse_filter = Control.MOUSE_FILTER_IGNORE if blocked else Control.MOUSE_FILTER_STOP


func _set_card_tooltip(value: String) -> void:
	tooltip_text = value
	_card_button.tooltip_text = value


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
	_blurred_thumbnail.texture = null
	_blurred_thumbnail.visible = false
	_header_scrim.visible = false
	_missing_preview.visible = false
	_empty_preview.visible = true
	_metadata_margin.visible = false


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


func set_selection_enabled(enabled: bool) -> void:
	_selection_enabled = enabled
	disabled = not enabled
	_card_button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	if not enabled:
		set_selected(false)
		_card_button.release_focus()


func focus_card() -> void:
	if not _card_button.disabled and _card_button.focus_mode != Control.FOCUS_NONE:
		_card_button.grab_focus()


func card_button() -> Button:
	return _card_button


func set_transfer_mode(enabled: bool) -> void:
	_transfer_mode = enabled
	_sync_empty_state()
	_sync_lock_button()
	_sync_load_button()


func _sync_empty_state() -> void:
	if not is_node_ready():
		return
	_empty_plus.visible = _transfer_mode and save_data == null and _is_manual_save()


func _sync_load_button(animate: bool = true) -> void:
	if not is_node_ready():
		return
	var should_show := _selected and _can_request_load()
	_set_load_action_visible(should_show, animate)


func _set_load_action_visible(show: bool, animate: bool) -> void:
	var target_unchanged := _load_action_target_visible == show
	_load_action_target_visible = show
	if (
		animate
		and target_unchanged
		and _load_action_tween != null
		and _load_action_tween.is_valid()
		and _load_action_tween.is_running()
	):
		return
	if _load_action_tween != null and _load_action_tween.is_valid():
		_load_action_tween.kill()
	_load_action_tween = null
	if show:
		_load_action_layer.visible = true
	elif not _load_action_layer.visible:
		_load_action_layer.modulate.a = 0.0
		return
	var target_alpha := 1.0 if show else 0.0
	if not animate or Engine.is_editor_hint() or not is_inside_tree():
		_load_action_layer.modulate.a = target_alpha
		_load_action_layer.visible = show
		return
	if is_equal_approx(_load_action_layer.modulate.a, target_alpha):
		_load_action_layer.visible = show
		return
	var tween := create_tween()
	_load_action_tween = tween
	tween.tween_property(_load_action_layer, "modulate:a", target_alpha, LOAD_ACTION_FADE_SECONDS).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(func() -> void:
		if _load_action_tween != tween:
			return
		_load_action_tween = null
		if not show:
			_load_action_layer.visible = false
	)


func _sync_lock_button() -> void:
	if not is_node_ready():
		return
	var visible_for_slot := _is_manual_save() and save_data != null
	_lock_button.visible = visible_for_slot
	_lock_button.disabled = not visible_for_slot or _modal_blocked or _transfer_mode
	if visible_for_slot:
		_lock_button.icon = get_theme_icon(&"locked" if save_data.locked else &"unlocked", &"SaveLoadCardLockButton")
		_lock_button.tooltip_text = "已锁定 · 点击解锁" if save_data.locked else "未锁定 · 点击锁定"
