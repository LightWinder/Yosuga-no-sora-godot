class_name AppreciationVoicePage
extends DesignCanvasPage


signal content_requested(request: AppreciationContentRequest)
signal scenario_requested(request: ScenarioLaunchRequest)
signal status_changed(message: String)

var _service: VoiceCollectionService
var _playing_id := ""
var _page_index := 0

@onready var _entry_list: GridContainer = %FavoriteList
@onready var _status: Label = %Status
@onready var _page_label: Label = %PageNumber
@onready var _previous_page: AppreciationPageButton = %PreviousPage
@onready var _next_page: AppreciationPageButton = %NextPage


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
	_previous_page.pressed.connect(_change_page.bind(-1))
	_next_page.pressed.connect(_change_page.bind(1))
	_connect_service()
	_refresh()


func favorite_count() -> int:
	return _service.count() if _service != null else 0


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
	var page_count := maxi(1, ceili(float(favorites.size()) / 12.0))
	_page_index = clampi(_page_index, 0, page_count - 1)
	for slot in 12:
		var favorite_index := _page_index * 12 + slot
		if favorite_index < favorites.size():
			_add_favorite_card(favorites[favorite_index])
		else:
			_add_empty_slot(slot)
	_page_label.text = ""
	_previous_page.visible = page_count > 1
	_next_page.visible = page_count > 1
	_previous_page.disabled = _page_index <= 0
	_next_page.disabled = _page_index >= page_count - 1
	_status.text = ""


func _change_page(delta: int) -> void:
	_page_index += delta
	_refresh()


func _add_favorite_card(favorite: VoiceFavorite) -> void:
	var card := Control.new()
	card.name = "Favorite_%s" % favorite.favorite_id.validate_node_name()
	card.custom_minimum_size = Vector2(267.0, 157.0)
	card.size = Vector2(267.0, 157.0)
	var plate := TextureRect.new()
	plate.name = "Background"
	plate.texture = _box_frame(0)
	plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(plate)
	var label := Label.new()
	label.name = "Caption"
	label.text = favorite.display_name if not favorite.display_name.is_empty() else favorite.transcript
	label.position = Vector2(12, 8)
	label.size = Vector2(243, 36)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.12, 0.30, 0.40, 1.0))
	card.add_child(label)
	if not favorite.thumbnail_path.is_empty() and ResourceLoader.exists(favorite.thumbnail_path):
		var thumb := TextureRect.new()
		thumb.name = "Thumbnail"
		thumb.position = Vector2(0, 7)
		thumb.size = Vector2(200.0, 150.0)
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		thumb.texture = load(favorite.thumbnail_path) as Texture2D
		thumb.modulate.a = 160.0 / 255.0
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(thumb)
		card.move_child(thumb, 1)
	var row := HBoxContainer.new()
	row.name = "Actions"
	row.add_theme_constant_override("separation", 4)
	row.position = Vector2(12, 109)
	row.size = Vector2(243, 38)
	card.add_child(row)
	var play := Button.new()
	play.name = "Play"
	play.text = "播放"
	play.custom_minimum_size = Vector2(58.0, 38.0)
	play.pressed.connect(_play.bind(favorite))
	row.add_child(play)
	if not favorite.save_path.is_empty():
		var jump := Button.new()
		jump.name = "JumpToSave"
		jump.text = "跳转存档"
		jump.custom_minimum_size = Vector2(82.0, 38.0)
		jump.pressed.connect(_jump.bind(favorite))
		row.add_child(jump)
	var delete_button := Button.new()
	delete_button.name = "Delete"
	delete_button.text = "删除"
	delete_button.custom_minimum_size = Vector2(58.0, 38.0)
	delete_button.pressed.connect(_delete.bind(favorite.favorite_id))
	row.add_child(delete_button)
	_entry_list.add_child(card)


func _add_empty_slot(slot: int) -> void:
	var empty := TextureRect.new()
	empty.name = "EmptySlot%02d" % (slot + 1)
	empty.custom_minimum_size = Vector2(267.0, 157.0)
	empty.size = Vector2(267.0, 157.0)
	empty.texture = _box_frame(0)
	empty.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	empty.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_entry_list.add_child(empty)


func _box_frame(index: int) -> AtlasTexture:
	var texture := load("res://assets/content/appreciation/box.png") as Texture2D
	var frame := AtlasTexture.new()
	if texture != null:
		frame.atlas = texture
		frame.region = Rect2(Vector2(267.0 * index, 0.0), Vector2(267.0, 157.0))
		frame.filter_clip = true
	return frame


func _play(favorite: VoiceFavorite) -> void:
	if _service.play_favorite(favorite.favorite_id):
		content_requested.emit(AppreciationContentRequest.for_voice(favorite))
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
	_status.text = "正在返回该语音对应的剧情位置。"
	status_changed.emit(_status.text)


func _on_favorites_changed(_favorites: Array[VoiceFavorite]) -> void:
	_refresh()


func _on_playback_changed(favorite_id: String, playing: bool) -> void:
	_playing_id = favorite_id if playing else ""
