class_name TitleFeatureScreen
extends Control


signal back_requested
signal bonus_back_requested
signal content_requested(request: TitleContentRequest)
signal scenario_requested(request: ScenarioLaunchRequest)

const ALBUM_PAGE_SCENE: PackedScene = preload("res://src/title/content/title_album_page.tscn")
const MUSIC_PAGE_SCENE: PackedScene = preload("res://src/title/content/title_music_page.tscn")
const MEMORIES_PAGE_SCENE: PackedScene = preload("res://src/title/content/title_memories_page.tscn")
const VOICE_PAGE_SCENE: PackedScene = preload("res://src/title/content/title_voice_page.tscn")
const SAVE_LOAD_PAGE_SCENE: PackedScene = preload("res://src/save_load/save_load_page.tscn")

@onready var _title_label: Label = $Content/Title
@onready var _description_label: Label = $Content/Description
@onready var _status_label: Label = $Content/Status
@onready var _entry_list: VBoxContainer = $Content/EntryList
@onready var _back_button: Button = $Content/Back
@onready var _background: TextureRect = $Background

var feature_id: StringName = &""
var _save_service: SaveService
var _voice_service: VoiceCollectionService
var _content_page: Control


func configure(route: StringName, save_service: SaveService) -> void:
	feature_id = route
	_save_service = save_service


func _ready() -> void:
	InputActions.ensure_actions()
	if _save_service == null:
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	_back_button.pressed.connect(_on_back_pressed)
	_populate()
	_back_button.grab_focus()


func _input(event: InputEvent) -> void:
	if _content_page is TitleAlbumPage:
		var album_page := _content_page as TitleAlbumPage
		if album_page.get_viewer() != null and album_page.get_viewer().visible:
			return
	if _content_page is SaveLoadPage:
		var save_load_page := _content_page as SaveLoadPage
		if save_load_page.is_delete_confirmation_visible():
			if StartupInput.is_cancel_event(event):
				save_load_page.cancel_delete_confirmation()
				get_viewport().set_input_as_handled()
			return
	if StartupInput.is_cancel_event(event):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func is_delete_confirmation_visible() -> bool:
	var page := load_page()
	return page != null and page.is_delete_confirmation_visible()


func cancel_delete_confirmation() -> void:
	var page := load_page()
	if page != null:
		page.cancel_delete_confirmation()


func confirm_delete_confirmation() -> void:
	var page := load_page()
	if page != null:
		page.confirm_delete_confirmation()


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
	_background.visible = true
	_background.texture = load(_background_path()) as Texture2D if _background.visible else null
	match feature_id:
		&"load_game":
			_title_label.text = "读取存档"
			_description_label.text = "900 个手动槽位、9 条快速存档和自动存档；点击预览图片读取。"
			_populate_load_page()
		&"album", &"music", &"memories", &"voice":
			_title_label.text = _catalog_title(feature_id)
			_description_label.text = _catalog_description(feature_id)
			_populate_catalog_page()
		_:
			_title_label.text = "未注册的 Title 功能"
			_description_label.text = "该路由没有对应的功能模型。"
			_status_label.text = "route=%s" % feature_id


func _on_back_pressed() -> void:
	if feature_id in [&"album", &"music", &"memories", &"voice"]:
		bonus_back_requested.emit()
	else:
		back_requested.emit()


func _background_path() -> String:
	if feature_id == &"load_game":
		return "res://assets/ui/title/QD-13-BG.png"
	return "res://assets/content/appreciation/bg.png"


func _populate_load_page() -> void:
	var page := SAVE_LOAD_PAGE_SCENE.instantiate() as SaveLoadPage
	page.configure(SaveLoadPage.Mode.LOAD, _save_service)
	page.back_requested.connect(_on_back_pressed)
	page.load_requested.connect(_on_save_load_requested)
	page.status_changed.connect(_on_page_status)
	_attach_content_page(page)
	_back_button.visible = false


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
	page.custom_minimum_size = Vector2.ZERO
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_entry_list.add_child(page)


func _on_content_request(request: TitleContentRequest) -> void:
	content_requested.emit(request)


func _on_scenario_request(request: ScenarioLaunchRequest) -> void:
	scenario_requested.emit(request)


func _on_page_status(message: String) -> void:
	_status_label.text = message


func _on_save_load_requested(data: SaveData, save_path: String) -> void:
	var request := ScenarioLaunchRequest.from_save(data, save_path)
	scenario_requested.emit(request)


func load_page() -> SaveLoadPage:
	return _content_page as SaveLoadPage


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
			return "6 个角色页、4×2 网格；视频与 18 条剧情回想均可直接播放。"
		TitleCatalog.VOICE:
			return "用户收藏模型；由 ADV 运行层添加并独立持久化。"
		_:
			return "选择条目。"


func _clear_entries() -> void:
	for child in _entry_list.get_children():
		_entry_list.remove_child(child)
		child.queue_free()
	_content_page = null
