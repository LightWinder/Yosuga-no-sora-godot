class_name TitleVoicePage
extends TitleVisualPage


signal content_requested(request: TitleContentRequest)
signal scenario_requested(request: ScenarioLaunchRequest)
signal status_changed(message: String)

var _service: VoiceCollectionService
var _entry_list: GridContainer
var _status: Label
var _playing_id := ""
var _page_index := 0
var _page_label: Label
var _previous_page: BaseButton
var _next_page: BaseButton


func configure(service: VoiceCollectionService) -> void:
	_service = service
	if is_inside_tree():
		_connect_service()
		_refresh()


func _ready() -> void:
	super._ready()
	if _service == null:
		_service = VoiceCollectionService.new()
		_service.name = "VoiceCollectionService"
		add_child(_service)
	_build_shell()
	_connect_service()
	_refresh()


func favorite_count() -> int:
	return _service.count() if _service != null else 0


func _build_shell() -> void:
	var root := Control.new()
	root.name = "VoiceContent"
	root.position = Vector2(80.0, 120.0)
	root.size = Vector2(1760.0, 900.0)
	visual_canvas().add_child(root)
	add_design_texture(root, "res://assets/content/appreciation/fav.voices.png", Rect2(95, 18, 300, 52))
	add_design_texture(root, "res://assets/content/appreciation/cover.png", Rect2(130, 105, 1660, 600))
	add_design_label(root, "语音收藏 · 4×3 / 页", Rect2(930, 20, 600, 44), 24, Color(0.12, 0.30, 0.40, 1.0))
	_entry_list = GridContainer.new()
	_entry_list.name = "FavoriteList"
	_entry_list.columns = 4
	_entry_list.position = Vector2(170.0, 180.0)
	_entry_list.size = Vector2(1460.0, 530.0)
	_entry_list.add_theme_constant_override("h_separation", 12)
	_entry_list.add_theme_constant_override("v_separation", 12)
	root.add_child(_entry_list)
	_previous_page = TitleSpriteButton.new()
	_previous_page.name = "PreviousPage"
	(_previous_page as TitleSpriteButton).configure_sprite("res://assets/content/save_load_hd/page_previous.png", 1, 18.0)
	(_previous_page as TitleSpriteButton).set_design_size(Vector2(72.0, 42.0))
	_previous_page.position = Vector2(680.0, 765.0)
	_previous_page.pressed.connect(_change_page.bind(-1))
	root.add_child(_previous_page)
	_page_label = Label.new()
	_page_label.name = "PageNumber"
	_page_label.position = Vector2(760.0, 765.0)
	_page_label.size = Vector2(160.0, 42.0)
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_page_label.add_theme_color_override("font_color", Color(0.12, 0.30, 0.40, 1.0))
	_page_label.add_theme_font_size_override("font_size", 22)
	root.add_child(_page_label)
	_next_page = TitleSpriteButton.new()
	_next_page.name = "NextPage"
	(_next_page as TitleSpriteButton).configure_sprite("res://assets/content/save_load_hd/page_next.png", 1, 18.0)
	(_next_page as TitleSpriteButton).set_design_size(Vector2(72.0, 42.0))
	_next_page.position = Vector2(925.0, 765.0)
	_next_page.pressed.connect(_change_page.bind(1))
	root.add_child(_next_page)
	_status = Label.new()
	_status.name = "Status"
	_status.position = Vector2(250.0, 825.0)
	_status.size = Vector2(1280.0, 44.0)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status)


func _connect_service() -> void:
	if _service == null:
		return
	if not _service.favorites_changed.is_connected(_on_favorites_changed):
		_service.favorites_changed.connect(_on_favorites_changed)
	if not _service.playback_changed.is_connected(_on_playback_changed):
		_service.playback_changed.connect(_on_playback_changed)


func _refresh() -> void:
	if _entry_list == null or _service == null:
		return
	for child in _entry_list.get_children():
		_entry_list.remove_child(child)
		child.queue_free()
	var favorites := _service.list_favorites()
	if favorites.is_empty():
		add_design_texture(_entry_list, "res://assets/content/appreciation/preview.png", Rect2(0, 0, 1460, 420))
		var empty := Label.new()
		empty.name = "EmptyState"
		empty.text = "暂无语音收藏\n收藏由 ADV 运行层添加，默认数据保持为空。"
		empty.position = Vector2(0, 155)
		empty.size = Vector2(1460, 100)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", 26)
		_entry_list.add_child(empty)
		_page_label.text = "1 / 1"
		_previous_page.disabled = true
		_next_page.disabled = true
	else:
		var page_count := maxi(1, ceili(float(favorites.size()) / 12.0))
		_page_index = clampi(_page_index, 0, page_count - 1)
		for favorite_index in range(_page_index * 12, mini(favorites.size(), _page_index * 12 + 12)):
			_add_favorite_card(favorites[favorite_index])
		_page_label.text = "%d / %d" % [_page_index + 1, page_count]
		_previous_page.disabled = _page_index <= 0
		_next_page.disabled = _page_index >= page_count - 1
	_status.text = "收藏数：%d；数据独立保存，不依赖 autosave。" % favorites.size()


func _change_page(delta: int) -> void:
	_page_index += delta
	_refresh()


func _add_favorite_card(favorite: VoiceFavorite) -> void:
	var card := Control.new()
	card.name = "Favorite_%s" % favorite.favorite_id.validate_node_name()
	card.custom_minimum_size = Vector2(350.0, 170.0)
	card.size = Vector2(350.0, 170.0)
	var plate := TextureRect.new()
	plate.name = "Background"
	plate.texture = load("res://assets/content/appreciation/box.png") as Texture2D
	plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(plate)
	var label := Label.new()
	label.name = "Caption"
	label.text = favorite.display_name if not favorite.transcript.is_empty() else "未命名语音"
	label.position = Vector2(18, 14)
	label.size = Vector2(314, 38)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.12, 0.30, 0.40, 1.0))
	card.add_child(label)
	if not favorite.thumbnail_path.is_empty() and ResourceLoader.exists(favorite.thumbnail_path):
		var thumb := TextureRect.new()
		thumb.name = "Thumbnail"
		thumb.position = Vector2(18, 54)
		thumb.size = Vector2(314.0, 70.0)
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		thumb.texture = load(favorite.thumbnail_path) as Texture2D
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(thumb)
	var row := HBoxContainer.new()
	row.name = "Actions"
	row.add_theme_constant_override("separation", 4)
	row.position = Vector2(18, 125)
	row.size = Vector2(314, 40)
	card.add_child(row)
	var play := Button.new()
	play.name = "Play"
	play.text = "播放"
	play.custom_minimum_size = Vector2(72.0, 48.0)
	play.pressed.connect(_play.bind(favorite))
	row.add_child(play)
	if not favorite.save_path.is_empty():
		var jump := Button.new()
		jump.name = "JumpToSave"
		jump.text = "跳转存档"
		jump.custom_minimum_size = Vector2(90.0, 48.0)
		jump.pressed.connect(_jump.bind(favorite))
		row.add_child(jump)
	var delete_button := Button.new()
	delete_button.name = "Delete"
	delete_button.text = "删除"
	delete_button.custom_minimum_size = Vector2(72.0, 48.0)
	delete_button.pressed.connect(_delete.bind(favorite.favorite_id))
	row.add_child(delete_button)
	_entry_list.add_child(card)


func _play(favorite: VoiceFavorite) -> void:
	if _service.play_favorite(favorite.favorite_id):
		content_requested.emit(TitleContentRequest.for_voice(favorite))
		_status.text = "正在播放：%s" % favorite.display_name
	else:
		_status.text = "播放失败：%s" % _service.last_error
	status_changed.emit(_status.text)


func _delete(favorite_id: String) -> void:
	if _service.remove_favorite(favorite_id):
		_status.text = "已删除语音收藏。"
	else:
		_status.text = "删除失败：%s" % _service.last_error
	status_changed.emit(_status.text)


func _jump(favorite: VoiceFavorite) -> void:
	var request := _service.build_save_jump_request(favorite.favorite_id)
	if request == null:
		_status.text = "该收藏没有可跳转的存档。"
		return
	scenario_requested.emit(request)
	_status.text = "语音存档跳转等待正文运行层。"
	status_changed.emit(_status.text)


func _on_favorites_changed(_favorites: Array[VoiceFavorite]) -> void:
	_refresh()


func _on_playback_changed(favorite_id: String, playing: bool) -> void:
	_playing_id = favorite_id if playing else ""
