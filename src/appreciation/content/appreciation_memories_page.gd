class_name AppreciationMemoriesPage
extends DesignCanvasPage


signal content_requested(request: AppreciationContentRequest)
signal scenario_requested(request: ScenarioLaunchRequest)
signal status_changed(message: String)

const CARD_SCENE := preload("res://src/appreciation/ui/appreciation_grid_card.tscn")
const PAGE_SIZE := 12

const ADV_PENDING_MESSAGE := "正在进入剧情回想。"

var _manifest: AppreciationContentManifest
var _profile: ProfileData
var _group_keys: Array[String] = ["穹", "奈绪", "瑛", "一叶", "初佳", "其他"]
var _group_index := 0
var _page_index := 0

@onready var _gallery: AppreciationGallery = $VisualCanvas/GalleryContent
@onready var _navigation: AppreciationNavigation = $VisualCanvas/AppreciationNavigation
@onready var _entry_list: GridContainer = _gallery.get_node("%CardList")
@onready var _group_buttons: Array[BaseButton] = [
	_gallery.get_node("%Group01"),
	_gallery.get_node("%Group02"),
	_gallery.get_node("%Group03"),
	_gallery.get_node("%Group04"),
	_gallery.get_node("%Group05"),
	_gallery.get_node("%Group06"),
]
@onready var _page_label: Label = _navigation.get_node("%PageNumber")
@onready var _previous_page: AppreciationPageButton = _gallery.get_node("%PreviousPage")
@onready var _next_page: AppreciationPageButton = _gallery.get_node("%NextPage")
@onready var _status: Label = _navigation.get_node("%CollectionStatus")
@onready var _video_player: VideoStreamPlayer = %MemoryVideoPlayer
@onready var _video_stop: Button = %StopVideo


func configure(manifest: AppreciationContentManifest, profile: ProfileData) -> void:
	_manifest = manifest
	_profile = profile
	if is_inside_tree():
		_refresh()


func _ready() -> void:
	super._ready()
	for index in _group_buttons.size():
		var tab := _group_buttons[index] as Button
		tab.tooltip_text = _group_keys[index]
		tab.pressed.connect(_select_group.bind(index))
	_previous_page.pressed.connect(_change_page.bind(-1))
	_next_page.pressed.connect(_change_page.bind(1))
	_navigation.page_requested.connect(_change_page)
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


func _process(_delta: float) -> void:
	_gallery.interaction_blocked = _video_player.visible


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
	_update_group_buttons()
	_refresh_entries(false)


func _update_group_buttons() -> void:
	for index in _group_buttons.size():
		var button := _group_buttons[index]
		var selected := index == _group_index
		(button as Button).button_pressed = selected


func _entries_for_group(index: int) -> Array[AppreciationMemoryEntry]:
	var selected: Array[AppreciationMemoryEntry] = []
	for memory in _manifest.memory_entries:
		if memory.group == _group_keys[index]:
			selected.append(memory)
	return selected


func _refresh_entries(animate := false, direction := 0) -> void:
	_gallery.reset_page_transition(_entry_list)
	for child in _entry_list.get_children():
		_entry_list.remove_child(child)
		child.queue_free()
	var selected := _entries_for_group(_group_index)
	var page_count := maxi(1, ceili(float(selected.size()) / float(PAGE_SIZE)))
	_page_index = clampi(_page_index, 0, page_count - 1)
	for memory_index in range(_page_index * PAGE_SIZE, mini(selected.size(), _page_index * PAGE_SIZE + PAGE_SIZE)):
		_add_memory_card(selected[memory_index], memory_index + 1)
	_page_label.text = "%d / %d" % [_page_index + 1, page_count]
	_navigation.set_pagination(_page_index, page_count)
	_previous_page.visible = true
	_next_page.visible = true
	_previous_page.disabled = _page_index <= 0
	_next_page.disabled = _page_index >= page_count - 1
	var collected := 0
	for memory in selected:
		if memory.unlocked(_profile):
			collected += 1
	_status.text = tr("已收集：%d / %d") % [collected, selected.size()]
	if animate:
		_gallery.play_page_transition(_entry_list, direction)


func _change_page(delta: int) -> void:
	if _manifest == null:
		return
	var selected := _entries_for_group(_group_index)
	var page_count := maxi(1, ceili(float(selected.size()) / float(PAGE_SIZE)))
	var target_page := clampi(_page_index + delta, 0, page_count - 1)
	if target_page == _page_index:
		return
	_page_index = target_page
	_refresh_entries(true, delta)


func _add_memory_card(memory: AppreciationMemoryEntry, number: int) -> void:
	var unlocked := memory.unlocked(_profile)
	var card := CARD_SCENE.instantiate() as AppreciationVisualCard
	card.name = "Memory_%s" % str(memory.entry_id).validate_node_name()
	card.configure(memory.entry_id, "%03d" % number, "res://assets/content/appreciation/cg_preview.png", unlocked)
	if unlocked and ResourceLoader.exists(memory.thumbnail_path):
		card.set_thumbnail(load(memory.thumbnail_path) as Texture2D)
	card.tooltip_text = memory.title if unlocked else "未解锁"
	card.pressed.connect(_select_memory.bind(memory))
	_entry_list.add_child(card)


func _select_memory(memory: AppreciationMemoryEntry) -> void:
	if not memory.unlocked(_profile):
		_status.text = tr("“%s”尚未解锁。") % memory.title
		return
	var request := AppreciationContentRequest.for_memory(memory)
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


func _play_video(memory: AppreciationMemoryEntry) -> void:
	if not ResourceLoader.exists(memory.video_path):
		_status.text = tr("缺少视频资源：%s") % memory.video_path
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
