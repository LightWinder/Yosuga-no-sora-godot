class_name AppreciationScreen
extends Control


signal back_requested
signal bonus_back_requested
signal content_requested(request: AppreciationContentRequest)
signal scenario_requested(request: ScenarioLaunchRequest)

const ALBUM_PAGE_SCENE: PackedScene = preload("res://src/appreciation/content/appreciation_album_page.tscn")
const MUSIC_PAGE_SCENE: PackedScene = preload("res://src/appreciation/content/appreciation_music_page.tscn")
const MEMORIES_PAGE_SCENE: PackedScene = preload("res://src/appreciation/content/appreciation_memories_page.tscn")
const VOICE_PAGE_SCENE: PackedScene = preload("res://src/appreciation/content/appreciation_voice_page.tscn")

@onready var _title_label: Label = $Content/Title
@onready var _description_label: Label = $Content/Description
@onready var _status_label: Label = $Content/Status
@onready var _entry_list: VBoxContainer = $Content/EntryList
@onready var _back_button: Button = $Content/Back

var catalog_id: StringName = &""
var _save_service: SaveService
var _voice_service: VoiceCollectionService
var _content_page: Control
var _closing := false
var _transition_tween: Tween
var _content_rest_position := Vector2.ZERO


func configure(
		catalog: StringName,
		save_service: SaveService,
		voice_service: VoiceCollectionService = null
) -> void:
	catalog_id = catalog
	_save_service = save_service
	_voice_service = voice_service


func is_closing() -> bool:
	return _closing


func _ready() -> void:
	InputActions.ensure_actions()
	if _save_service == null:
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	_back_button.pressed.connect(_on_back_pressed)
	_populate()
	_back_button.grab_focus()
	_content_rest_position = $Content.position
	_play_open_transition()


func _input(event: InputEvent) -> void:
	if _content_page is AppreciationAlbumPage:
		var album_page := _content_page as AppreciationAlbumPage
		if album_page.get_viewer() != null and album_page.get_viewer().visible:
			return
	if StartupInput.is_cancel_event(event):
		_on_appreciation_back_requested()
		get_viewport().set_input_as_handled()


func _ensure_voice_service() -> void:
	if is_instance_valid(_voice_service):
		return
	_voice_service = VoiceCollectionService.new()
	_voice_service.name = "VoiceCollectionService"
	add_child(_voice_service)


func _populate() -> void:
	_clear_entries()
	_back_button.visible = true
	_status_label.text = ""
	match catalog_id:
		&"album", &"music", &"memories", &"voice":
			_title_label.text = _catalog_title(catalog_id)
			_description_label.text = _catalog_description(catalog_id)
			_populate_catalog_page()
		_:
			_title_label.text = "未注册的鉴赏类别"
			_description_label.text = "该类别没有对应的鉴赏页面。"
			_status_label.text = "catalog=%s" % catalog_id


func _on_back_pressed() -> void:
	if _closing:
		return
	bonus_back_requested.emit()


func _on_appreciation_back_requested() -> void:
	if _closing:
		return
	back_requested.emit()


func play_close_transition() -> void:
	if _closing:
		return
	_closing = true
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	get_viewport().gui_release_focus()
	set_process_input(false)
	_transition_tween = create_tween().set_parallel(true)
	_transition_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_transition_tween.tween_property(self, "modulate:a", 0.0, 0.24)
	_transition_tween.tween_property($Content, "position", _content_rest_position + Vector2(0.0, 18.0), 0.24)
	await _transition_tween.finished
	_transition_tween = null


func _play_open_transition() -> void:
	modulate.a = 0.0
	$Content.position = _content_rest_position + Vector2(0.0, 18.0)
	_transition_tween = create_tween().set_parallel(true)
	_transition_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_transition_tween.tween_property(self, "modulate:a", 1.0, 0.30)
	_transition_tween.tween_property($Content, "position", _content_rest_position, 0.30)


func _populate_catalog_page() -> void:
	_back_button.visible = false
	var manifest := AppreciationCatalog.load_manifest()
	var profile := _save_service.load_profile()
	match catalog_id:
		AppreciationCatalog.ALBUM:
			var album := ALBUM_PAGE_SCENE.instantiate() as AppreciationAlbumPage
			album.configure(manifest, profile)
			album.content_requested.connect(_on_content_request)
			album.status_changed.connect(_on_page_status)
			_attach_content_page(album)
		AppreciationCatalog.MUSIC:
			var music := MUSIC_PAGE_SCENE.instantiate() as AppreciationMusicPage
			music.configure(manifest)
			music.content_requested.connect(_on_content_request)
			music.status_changed.connect(_on_page_status)
			_attach_content_page(music)
		AppreciationCatalog.MEMORIES:
			var memories := MEMORIES_PAGE_SCENE.instantiate() as AppreciationMemoriesPage
			memories.configure(manifest, profile)
			memories.content_requested.connect(_on_content_request)
			memories.scenario_requested.connect(_on_scenario_request)
			memories.status_changed.connect(_on_page_status)
			_attach_content_page(memories)
		AppreciationCatalog.VOICE:
			_ensure_voice_service()
			var voice := VOICE_PAGE_SCENE.instantiate() as AppreciationVoicePage
			voice.configure(_voice_service)
			voice.content_requested.connect(_on_content_request)
			voice.scenario_requested.connect(_on_scenario_request)
			voice.status_changed.connect(_on_page_status)
			_attach_content_page(voice)
	_status_label.text = ""


func _attach_content_page(page: Control) -> void:
	_content_page = page
	page.custom_minimum_size = Vector2.ZERO
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_entry_list.add_child(page)
	var navigation := page.get_node_or_null("VisualCanvas/AppreciationNavigation") as AppreciationNavigation
	if navigation != null:
		navigation.back_requested.connect(_on_appreciation_back_requested)
		navigation.catalog_requested.connect(_switch_catalog)
		navigation.call_deferred("grab_initial_focus")


func _switch_catalog(catalog_id: StringName) -> void:
	if catalog_id == self.catalog_id or catalog_id not in [AppreciationCatalog.ALBUM, AppreciationCatalog.MEMORIES, AppreciationCatalog.MUSIC, AppreciationCatalog.VOICE]:
		return
	self.catalog_id = catalog_id
	_populate()


func _on_content_request(request: AppreciationContentRequest) -> void:
	content_requested.emit(request)


func _on_scenario_request(request: ScenarioLaunchRequest) -> void:
	scenario_requested.emit(request)


func _on_page_status(message: String) -> void:
	_status_label.text = message


func _catalog_title(catalog_id: StringName) -> String:
	match catalog_id:
		AppreciationCatalog.ALBUM:
			return "相册鉴赏"
		AppreciationCatalog.MUSIC:
			return "音乐鉴赏"
		AppreciationCatalog.MEMORIES:
			return "回忆鉴赏"
		AppreciationCatalog.VOICE:
			return "语音收藏"
		_:
			return "鉴赏"


func _catalog_description(catalog_id: StringName) -> String:
	match catalog_id:
		AppreciationCatalog.ALBUM:
			return "源 HD 前六组角色页，4×3 卡片网格；差分可在全屏 viewer 中切换。"
		AppreciationCatalog.MUSIC:
			return "21 首真实 BGM，3×7 曲目布局；按源 .sli 设置循环点。"
		AppreciationCatalog.MEMORIES:
			return "6 个角色页、4×3 网格；视频与 18 条剧情回想均可直接播放。"
		AppreciationCatalog.VOICE:
			return "用户收藏模型；由 ADV 运行层添加并独立持久化。"
		_:
			return "选择条目。"


func _clear_entries() -> void:
	for child in _entry_list.get_children():
		_entry_list.remove_child(child)
		child.queue_free()
	_content_page = null
