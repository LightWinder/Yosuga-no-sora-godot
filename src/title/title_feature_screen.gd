class_name TitleFeatureScreen
extends Control


signal back_requested
signal bonus_back_requested
signal content_requested(request: TitleContentRequest)
signal scenario_requested(request: ScenarioLaunchRequest)

const SCENARIO_NOTICE_SCENE: PackedScene = preload("res://src/title/scenario/scenario_unavailable_notice.tscn")
const ALBUM_PAGE_SCENE: PackedScene = preload("res://src/title/content/title_album_page.tscn")
const MUSIC_PAGE_SCENE: PackedScene = preload("res://src/title/content/title_music_page.tscn")
const MEMORIES_PAGE_SCENE: PackedScene = preload("res://src/title/content/title_memories_page.tscn")
const VOICE_PAGE_SCENE: PackedScene = preload("res://src/title/content/title_voice_page.tscn")

@onready var _title_label: Label = $Content/Title
@onready var _description_label: Label = $Content/Description
@onready var _status_label: Label = $Content/Status
@onready var _entry_list: VBoxContainer = $Content/EntryList
@onready var _primary_button: Button = $Content/Primary
@onready var _back_button: Button = $Content/Back
@onready var _background: TextureRect = $Background

var feature_id: StringName = &""
var _save_service: SaveService
var _voice_service: VoiceCollectionService
var _content_page: Control
var _selected_save: SaveData
var _selected_save_path := ""
var _delete_confirmation: ConfirmationDialog
var _pending_delete_slot_id := -1
var _pending_delete_is_autosave := false
var _scenario_notice: ScenarioUnavailableNotice


func configure(route: StringName, save_service: SaveService) -> void:
	feature_id = route
	_save_service = save_service


func _ready() -> void:
	InputActions.ensure_actions()
	if _save_service == null:
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	_primary_button.pressed.connect(_on_primary_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	_populate()
	_back_button.grab_focus()


func _input(event: InputEvent) -> void:
	if _scenario_notice != null and _scenario_notice.visible:
		if StartupInput.is_cancel_event(event):
			_scenario_notice.hide_notice()
			get_viewport().set_input_as_handled()
		return
	if _content_page is TitleAlbumPage:
		var album_page := _content_page as TitleAlbumPage
		if album_page.get_viewer() != null and album_page.get_viewer().visible:
			return
	if StartupInput.is_cancel_event(event):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func is_delete_confirmation_visible() -> bool:
	return is_instance_valid(_delete_confirmation) and _delete_confirmation.visible


func cancel_delete_confirmation() -> void:
	_cancel_pending_delete()


func confirm_delete_confirmation() -> void:
	_confirm_pending_delete()


func is_scenario_notice_visible() -> bool:
	return is_instance_valid(_scenario_notice) and _scenario_notice.visible


func _ensure_delete_confirmation() -> void:
	if is_instance_valid(_delete_confirmation):
		return
	_delete_confirmation = ConfirmationDialog.new()
	_delete_confirmation.name = "DeleteSaveConfirmation"
	_delete_confirmation.title = "删除存档"
	_delete_confirmation.confirmed.connect(_confirm_pending_delete)
	_delete_confirmation.canceled.connect(_cancel_pending_delete)
	add_child(_delete_confirmation)


func _ensure_scenario_notice() -> void:
	if is_instance_valid(_scenario_notice):
		return
	_scenario_notice = SCENARIO_NOTICE_SCENE.instantiate() as ScenarioUnavailableNotice
	add_child(_scenario_notice)


func _ensure_voice_service() -> void:
	if is_instance_valid(_voice_service):
		return
	_voice_service = VoiceCollectionService.new()
	_voice_service.name = "VoiceCollectionService"
	add_child(_voice_service)


func _populate() -> void:
	_clear_entries()
	_selected_save = null
	_selected_save_path = ""
	_primary_button.visible = false
	_primary_button.disabled = false
	_status_label.text = ""
	_background.texture = load(_background_path(feature_id)) as Texture2D
	match feature_id:
		&"load_game":
			_title_label.text = "读取存档"
			_description_label.text = "选择自动存档或 20 个手动存档槽；确认后才会删除。"
			_populate_load_page()
		&"album", &"music", &"memories", &"voice":
			_title_label.text = _catalog_title(feature_id)
			_description_label.text = _catalog_description(feature_id)
			_populate_catalog_page()
		_:
			_title_label.text = "未注册的 Title 功能"
			_description_label.text = "该路由没有对应的功能模型。"
			_status_label.text = "route=%s" % feature_id
	_style_navigation()


func _on_back_pressed() -> void:
	if feature_id in [&"album", &"music", &"memories", &"voice"]:
		bonus_back_requested.emit()
	else:
		back_requested.emit()


func _background_path(route: StringName) -> String:
	if route == &"load_game":
		return "res://assets/content/save_load_hd/background_load.png"
	return "res://assets/content/appreciation/bg.png"


func _style_navigation() -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.80, 0.92, 0.96, 0.88)
	normal.border_color = Color(0.28, 0.57, 0.70, 0.85)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.96, 0.99, 1.0, 0.96)
	hover.border_color = Color(0.08, 0.40, 0.58, 1.0)
	hover.set_border_width_all(3)
	for button in [_back_button, _primary_button]:
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("focus", hover)
		button.add_theme_color_override("font_color", Color(0.06, 0.24, 0.34, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.02, 0.16, 0.25, 1.0))


func _populate_load_page() -> void:
	_clear_entries()
	_add_load_row(-1, true, _save_service.load_autosave())
	for slot_id in SaveService.MAX_SLOT_COUNT:
		_add_load_row(slot_id, false, _save_service.load_slot(slot_id))
	_status_label.text = "请选择一个存档。"


func _add_load_row(slot_id: int, is_autosave: bool, data: SaveData) -> void:
	var row := HBoxContainer.new()
	row.name = "AutosaveRow" if is_autosave else "SaveSlot%02dRow" % (slot_id + 1)
	row.custom_minimum_size.y = 54.0
	row.add_theme_constant_override("separation", 12)
	var select_button := Button.new()
	select_button.name = "Select"
	select_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select_button.focus_mode = Control.FOCUS_ALL
	select_button.text = _save_label(slot_id, is_autosave, data)
	select_button.pressed.connect(_on_load_selected.bind(slot_id, is_autosave))
	row.add_child(select_button)
	var delete_button := Button.new()
	delete_button.name = "Delete"
	delete_button.text = "删除"
	delete_button.custom_minimum_size.x = 100.0
	delete_button.disabled = data == null
	delete_button.pressed.connect(_on_load_deleted.bind(slot_id, is_autosave))
	row.add_child(delete_button)
	_entry_list.add_child(row)


func _save_label(slot_id: int, is_autosave: bool, data: SaveData) -> String:
	var prefix := "自动存档" if is_autosave else "槽位 %02d" % (slot_id + 1)
	if data == null:
		return "%s    · 空" % prefix
	var label := str(data.autosave_meta.get("label", ""))
	if label.is_empty():
		label = data.scenario_id if not data.scenario_id.is_empty() else "未命名"
	return "%s    · %s    · %s" % [prefix, label, data.instruction_anchor]


func _on_load_selected(slot_id: int, is_autosave: bool) -> void:
	_selected_save = _save_service.load_autosave() if is_autosave else _save_service.load_slot(slot_id)
	_selected_save_path = SaveService.AUTOSAVE_PATH if is_autosave else "%s/slot_%02d.json" % [SaveService.SAVE_DIRECTORY, slot_id]
	if _selected_save == null:
		_status_label.text = "该存档不可读取，可能已损坏。"
		_primary_button.disabled = true
		return
	_status_label.text = "已选择：%s" % _save_label(slot_id, is_autosave, _selected_save)
	_primary_button.visible = true
	_primary_button.disabled = false
	_primary_button.text = "继续所选存档"


func _on_load_deleted(slot_id: int, is_autosave: bool) -> void:
	var data := _save_service.load_autosave() if is_autosave else _save_service.load_slot(slot_id)
	if data == null:
		return
	_pending_delete_slot_id = slot_id
	_pending_delete_is_autosave = is_autosave
	_ensure_delete_confirmation()
	var target_name := "自动存档" if is_autosave else "槽位 %02d" % (slot_id + 1)
	_delete_confirmation.dialog_text = "确定删除%s吗？取消不会删除文件。" % target_name
	_delete_confirmation.popup_centered(Vector2i(640, 220))


func _confirm_pending_delete() -> void:
	if not is_instance_valid(_delete_confirmation):
		return
	_delete_confirmation.hide()
	var slot_id := _pending_delete_slot_id
	var is_autosave := _pending_delete_is_autosave
	_pending_delete_slot_id = -1
	_pending_delete_is_autosave = false
	if slot_id == -1 and not is_autosave:
		return
	var ok := _save_service.clear_autosave() if is_autosave else _save_service.clear_slot(slot_id)
	if not ok:
		_status_label.text = "删除失败：%s" % _save_service.last_error
		return
	_populate_load_page()


func _cancel_pending_delete() -> void:
	if is_instance_valid(_delete_confirmation):
		_delete_confirmation.hide()
	_pending_delete_slot_id = -1
	_pending_delete_is_autosave = false
	_status_label.text = "已取消删除。"


func _populate_catalog_page() -> void:
	var manifest := TitleCatalog.load_manifest()
	var profile := _save_service.load_profile()
	match feature_id:
		TitleCatalog.ALBUM:
			var album := ALBUM_PAGE_SCENE.instantiate() as TitleAlbumPage
			album.configure(manifest, profile)
			album.content_requested.connect(_on_content_request)
			album.status_changed.connect(_on_page_status)
			_attach_content_page(album)
		TitleCatalog.MUSIC:
			var music := MUSIC_PAGE_SCENE.instantiate() as TitleMusicPage
			music.configure(manifest)
			music.content_requested.connect(_on_content_request)
			music.status_changed.connect(_on_page_status)
			_attach_content_page(music)
		TitleCatalog.MEMORIES:
			var memories := MEMORIES_PAGE_SCENE.instantiate() as TitleMemoriesPage
			memories.configure(manifest, profile)
			memories.content_requested.connect(_on_content_request)
			memories.scenario_requested.connect(_on_scenario_request)
			memories.status_changed.connect(_on_page_status)
			_attach_content_page(memories)
		TitleCatalog.VOICE:
			_ensure_voice_service()
			var voice := VOICE_PAGE_SCENE.instantiate() as TitleVoicePage
			voice.configure(_voice_service)
			voice.content_requested.connect(_on_content_request)
			voice.scenario_requested.connect(_on_scenario_request)
			voice.status_changed.connect(_on_page_status)
			_attach_content_page(voice)
	_status_label.text = "manifest：相册 %d 卡/%d 差分，音乐 %d 首，回忆 %d 条。" % [manifest.album_card_count(), manifest.album_variant_count(), manifest.music_tracks.size(), manifest.memory_entries.size()]


func _attach_content_page(page: Control) -> void:
	_content_page = page
	page.custom_minimum_size = Vector2(0.0, 680.0)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_entry_list.add_child(page)


func _on_content_request(request: TitleContentRequest) -> void:
	content_requested.emit(request)


func _on_scenario_request(request: ScenarioLaunchRequest) -> void:
	scenario_requested.emit(request)
	_show_scenario_notice(request)


func _show_scenario_notice(request: ScenarioLaunchRequest) -> void:
	_ensure_scenario_notice()
	_scenario_notice.show_request(request)
	_status_label.text = "正文运行层待迁移：请求已发出。"


func _on_page_status(message: String) -> void:
	_status_label.text = message


func _on_primary_pressed() -> void:
	if feature_id != &"load_game" or _selected_save == null:
		return
	var request := ScenarioLaunchRequest.from_save(_selected_save, _selected_save_path)
	scenario_requested.emit(request)
	_show_scenario_notice(request)


func _catalog_title(catalog_id: StringName) -> String:
	match catalog_id:
		TitleCatalog.ALBUM:
			return "相册鉴赏"
		TitleCatalog.MUSIC:
			return "音乐鉴赏"
		TitleCatalog.MEMORIES:
			return "回忆鉴赏"
		TitleCatalog.VOICE:
			return "语音收藏"
		_:
			return "鉴赏"


func _catalog_description(catalog_id: StringName) -> String:
	match catalog_id:
		TitleCatalog.ALBUM:
			return "源 HD 前六组角色页，4×2 卡片网格；差分可在全屏 viewer 中切换。"
		TitleCatalog.MUSIC:
			return "21 首真实 BGM，3×7 曲目布局；按源 .sli 设置循环点。"
		TitleCatalog.MEMORIES:
			return "6 个角色页、4×2 网格；视频真实播放，18 条剧情回想仅发 typed seam。"
		TitleCatalog.VOICE:
			return "用户收藏模型；默认为空，由未来 ADV 运行层添加并持久化。"
		_:
			return "选择条目。"


func _clear_entries() -> void:
	for child in _entry_list.get_children():
		_entry_list.remove_child(child)
		child.queue_free()
	_content_page = null
