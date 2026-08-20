class_name TitleMemoriesPage
extends TitleVisualPage


signal content_requested(request: TitleContentRequest)
signal scenario_requested(request: ScenarioLaunchRequest)
signal status_changed(message: String)

const ADV_PENDING_MESSAGE := "ADV剧情运行层待迁移：已生成 typed ScenarioLaunchRequest，未伪造播放结果。"

var _manifest: TitleContentManifest
var _profile: ProfileData
var _entry_list: GridContainer
var _group_buttons: Array[BaseButton] = []
var _group_keys: Array[String] = ["穹", "奈绪", "瑛", "一叶", "初佳", "其他"]
var _group_index := 0
var _page_index := 0
var _page_label: Label
var _previous_page: BaseButton
var _next_page: BaseButton
var _status: Label
var _video_player: VideoStreamPlayer
var _video_stop: Button


func configure(manifest: TitleContentManifest, profile: ProfileData) -> void:
	_manifest = manifest
	_profile = profile
	if is_inside_tree():
		_refresh()


func _ready() -> void:
	super._ready()
	_build_shell()
	_refresh()


func entry_count() -> int:
	return _manifest.memory_entries.size() if _manifest != null else 0


func adv_count() -> int:
	if _manifest == null:
		return 0
	var count := 0
	for memory in _manifest.memory_entries:
		if not memory.is_video():
			count += 1
	return count


func video_count() -> int:
	return entry_count() - adv_count()


func _build_shell() -> void:
	var root := Control.new()
	root.name = "MemoriesContent"
	root.position = Vector2(80.0, 120.0)
	root.size = Vector2(1760.0, 900.0)
	visual_canvas().add_child(root)
	add_design_texture(root, "res://assets/content/appreciation/scene.png", Rect2(95, 18, 300, 52))
	add_design_label(root, "回忆 · 24 条（18 条剧情回想 + 开场 / 5 条 Staff Roll）", Rect2(720, 20, 900, 44), 24, Color(0.12, 0.30, 0.40, 1.0))
	for index in _group_keys.size():
		var tab := TitleSpriteButton.new()
		tab.name = "Group%02d" % (index + 1)
		tab.configure_sprite(_group_texture(index), 3, 18.0)
		tab.set_design_size(Vector2(245.0, 58.0))
		tab.position = Vector2(95.0 + float(index % 3) * 260.0, 84.0 + float(index / 3) * 70.0)
		tab.tooltip_text = _group_keys[index]
		tab.pressed.connect(_select_group.bind(index))
		root.add_child(tab)
		_group_buttons.append(tab)
	_video_player = VideoStreamPlayer.new()
	_video_player.name = "MemoryVideoPlayer"
	_video_player.position = Vector2(450.0, 275.0)
	_video_player.size = Vector2(1000.0, 430.0)
	_video_player.expand = true
	_video_player.visible = false
	root.add_child(_video_player)
	_video_stop = add_design_button(root, Rect2(800, 720, 300, 56), "停止视频", 22)
	_video_stop.name = "StopVideo"
	_video_stop.visible = false
	_video_stop.pressed.connect(_stop_video)
	_entry_list = GridContainer.new()
	_entry_list.name = "MemoryList"
	_entry_list.columns = 4
	_entry_list.position = Vector2(95.0, 245.0)
	_entry_list.size = Vector2(1510.0, 505.0)
	_entry_list.add_theme_constant_override("h_separation", 14)
	_entry_list.add_theme_constant_override("v_separation", 12)
	root.add_child(_entry_list)
	_previous_page = TitleSpriteButton.new()
	_previous_page.name = "PreviousPage"
	(_previous_page as TitleSpriteButton).configure_sprite("res://assets/content/save_load_hd/page_previous.png", 1, 18.0)
	(_previous_page as TitleSpriteButton).set_design_size(Vector2(72.0, 42.0))
	_previous_page.position = Vector2(680.0, 785.0)
	_previous_page.pressed.connect(_change_page.bind(-1))
	root.add_child(_previous_page)
	_page_label = Label.new()
	_page_label.name = "PageNumber"
	_page_label.position = Vector2(760.0, 785.0)
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
	_next_page.position = Vector2(925.0, 785.0)
	_next_page.pressed.connect(_change_page.bind(1))
	root.add_child(_next_page)
	_status = Label.new()
	_status.name = "Status"
	_status.position = Vector2(300.0, 840.0)
	_status.size = Vector2(1180.0, 42.0)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status)


func _group_texture(index: int) -> String:
	return [
		"res://assets/content/appreciation/sora.png",
		"res://assets/content/appreciation/nao.png",
		"res://assets/content/appreciation/akira.png",
		"res://assets/content/appreciation/kazuha.png",
		"res://assets/content/appreciation/motoka.png",
		"res://assets/content/appreciation/others.png",
	][index]


func _refresh() -> void:
	if _manifest == null or _entry_list == null:
		return
	for index in _group_buttons.size():
		var group_key := _group_keys[index]
		var count := 0
		for memory in _manifest.memory_entries:
			if memory.group == group_key:
				count += 1
		_group_buttons[index].tooltip_text = "%s (%d)" % [group_key, count]
	_select_group(_group_index)


func _select_group(index: int) -> void:
	if _manifest == null or index < 0 or index >= _group_keys.size():
		return
	_group_index = index
	_page_index = 0
	for child in _entry_list.get_children():
		_entry_list.remove_child(child)
		child.queue_free()
	var selected: Array[TitleMemoryEntry] = []
	for memory in _manifest.memory_entries:
		if memory.group == _group_keys[index]:
			selected.append(memory)
	var page_count := maxi(1, ceili(float(selected.size()) / 8.0))
	_page_index = clampi(_page_index, 0, page_count - 1)
	for memory_index in range(_page_index * 8, mini(selected.size(), _page_index * 8 + 8)):
		_add_memory_card(selected[memory_index])
	_page_label.text = "%d / %d" % [_page_index + 1, page_count]
	_previous_page.disabled = _page_index <= 0
	_next_page.disabled = _page_index >= page_count - 1
	_status.text = "%s：%d 条；剧情回想仅生成请求，视频为真实 OGV。" % [_group_keys[index], selected.size()]


func _change_page(delta: int) -> void:
	_page_index += delta
	_select_group(_group_index)


func _add_memory_card(memory: TitleMemoryEntry) -> void:
	var unlocked := memory.unlocked(_profile)
	var kind_label := "视频" if memory.is_video() else "剧情 seam"
	var card := TitleVisualCard.new()
	card.name = "Memory_%s" % str(memory.entry_id).validate_node_name()
	card.configure(memory.entry_id, memory.title + " · " + kind_label, "res://assets/content/appreciation/cg_preview.png", unlocked, Vector2(350.0, 205.0))
	if ResourceLoader.exists(memory.thumbnail_path):
		card.set_thumbnail(load(memory.thumbnail_path) as Texture2D)
	card.disabled = not unlocked
	card.pressed.connect(_select_memory.bind(memory))
	_entry_list.add_child(card)


func _select_memory(memory: TitleMemoryEntry) -> void:
	if not memory.unlocked(_profile):
		_status.text = "“%s”尚未解锁。" % memory.title
		return
	var request := TitleContentRequest.for_memory(memory)
	content_requested.emit(request)
	if memory.is_video():
		_play_video(memory)
		return
	var scenario_request := ScenarioLaunchRequest.from_memory(memory)
	scenario_requested.emit(scenario_request)
	_status.text = ADV_PENDING_MESSAGE + "（%s）" % scenario_request.summary()
	status_changed.emit(_status.text)


func _play_video(memory: TitleMemoryEntry) -> void:
	if not ResourceLoader.exists(memory.video_path):
		_status.text = "缺少视频资源：%s" % memory.video_path
		return
	var stream := load(memory.video_path) as VideoStream
	if stream == null:
		_status.text = "无法加载视频资源：%s" % memory.video_path
		return
	_video_player.stream = stream
	_video_player.visible = true
	_video_stop.visible = true
	_video_player.play()
	_status.text = "正在播放：%s" % memory.title
	status_changed.emit(_status.text)


func _stop_video() -> void:
	if _video_player != null:
		_video_player.stop()
		_video_player.stream = null
	_video_player.visible = false
	_video_stop.visible = false
	_status.text = "视频已停止。"
