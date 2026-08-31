class_name TitleMemoriesPage
extends DesignCanvasPage


signal content_requested(request: TitleContentRequest)
signal scenario_requested(request: ScenarioLaunchRequest)
signal status_changed(message: String)

const ADV_PENDING_MESSAGE := "正在进入剧情回想。"

var _manifest: TitleContentManifest
var _profile: ProfileData
var _group_keys: Array[String] = ["穹", "奈绪", "瑛", "一叶", "初佳", "其他"]
var _group_index := 0
var _page_index := 0

@onready var _entry_list: GridContainer = %MemoryList
@onready var _group_buttons: Array[BaseButton] = [
	%Group01,
	%Group02,
	%Group03,
	%Group04,
	%Group05,
	%Group06,
]
@onready var _page_label: Label = %PageNumber
@onready var _previous_page: TitleSpriteButton = %PreviousPage
@onready var _next_page: TitleSpriteButton = %NextPage
@onready var _status: Label = %Status
@onready var _video_player: VideoStreamPlayer = %MemoryVideoPlayer
@onready var _video_stop: Button = %StopVideo


func configure(manifest: TitleContentManifest, profile: ProfileData) -> void:
	_manifest = manifest
	_profile = profile
	if is_inside_tree():
		_refresh()


func _ready() -> void:
	super._ready()
	for index in _group_buttons.size():
		var tab := _group_buttons[index] as TitleSpriteButton
		tab.configure_sprite(_group_texture(index), 3, 18.0)
		tab.set_design_size(Vector2(245.0, 58.0))
		tab.tooltip_text = _group_keys[index]
		tab.pressed.connect(_select_group.bind(index))
	_previous_page.configure_sprite("res://assets/content/save_load_hd/page_previous.png", 1, 18.0)
	_previous_page.set_design_size(Vector2(72.0, 42.0))
	_previous_page.pressed.connect(_change_page.bind(-1))
	_next_page.configure_sprite("res://assets/content/save_load_hd/page_next.png", 1, 18.0)
	_next_page.set_design_size(Vector2(72.0, 42.0))
	_next_page.pressed.connect(_change_page.bind(1))
	_video_stop.pressed.connect(_stop_video)
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
	var scenario_request := ScenarioLaunchRequest.for_recollection(
		memory.scenario_id,
		memory.label,
		memory.unlock_flag
	)
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
