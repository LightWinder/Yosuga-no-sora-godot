class_name AppreciationAlbumPage
extends DesignCanvasPage


signal content_requested(request: AppreciationContentRequest)
signal status_changed(message: String)

const PAGE_SIZE := 12
const CARD_SCENE := preload("res://src/appreciation/ui/appreciation_grid_card.tscn")

var _manifest: AppreciationContentManifest
var _profile: ProfileData
var _group_index := 0
var _page_index := 0

@onready var _gallery: AppreciationGallery = $VisualCanvas/GalleryContent
@onready var _navigation: AppreciationNavigation = $VisualCanvas/AppreciationNavigation
@onready var _group_buttons: Array[BaseButton] = [
	_gallery.get_node("%Group01"),
	_gallery.get_node("%Group02"),
	_gallery.get_node("%Group03"),
	_gallery.get_node("%Group04"),
	_gallery.get_node("%Group05"),
	_gallery.get_node("%Group06"),
]
@onready var _card_list: GridContainer = _gallery.get_node("%CardList")
@onready var _page_label: Label = _navigation.get_node("%PageNumber")
@onready var _previous_page: AppreciationPageButton = _gallery.get_node("%PreviousPage")
@onready var _next_page: AppreciationPageButton = _gallery.get_node("%NextPage")
@onready var _status: Label = _navigation.get_node("%CollectionStatus")
@onready var _viewer: AppreciationAlbumViewer = %AlbumViewer


func configure(manifest: AppreciationContentManifest, profile: ProfileData) -> void:
	_manifest = manifest
	_profile = profile
	if is_inside_tree():
		_refresh_groups()


func _ready() -> void:
	super._ready()
	for index in _group_buttons.size():
		var button := _group_buttons[index] as Button
		button.pressed.connect(_select_group.bind(index))
	_previous_page.pressed.connect(_change_page.bind(-1))
	_next_page.pressed.connect(_change_page.bind(1))
	_navigation.page_requested.connect(_change_page)
	_viewer.closed.connect(func() -> void: status_changed.emit("已返回相册列表。"))
	_refresh_groups()


func _process(_delta: float) -> void:
	_gallery.interaction_blocked = _viewer.visible


func group_count() -> int:
	return _manifest.album_groups.size() if _manifest != null else 0


func card_count() -> int:
	return _manifest.album_card_count() if _manifest != null else 0


func variant_count() -> int:
	return _manifest.album_variant_count() if _manifest != null else 0


func get_viewer() -> AppreciationAlbumViewer:
	return _viewer


func open_card_for_test(group_index: int = 0, card_index: int = 0) -> bool:
	if _manifest == null or group_index < 0 or group_index >= _manifest.album_groups.size():
		return false
	var group := _manifest.album_groups[group_index]
	if card_index < 0 or card_index >= group.cards.size():
		return false
	_open_card(group, group.cards[card_index])
	return _viewer.visible


func _refresh_groups() -> void:
	if _manifest == null or _card_list == null:
		return
	for index in _group_buttons.size():
		var button := _group_buttons[index]
		if index >= _manifest.album_groups.size():
			button.visible = false
			continue
		var group := _manifest.album_groups[index]
		button.visible = true
		button.tooltip_text = "%s (%d/%d)" % [group.title, group.unlocked_card_count(_profile), group.cards.size()]
		(button as Button).button_pressed = index == _group_index
	if _group_index >= _manifest.album_groups.size():
		_group_index = 0
	_select_group(_group_index)


func _select_group(index: int) -> void:
	if _manifest == null or index < 0 or index >= _manifest.album_groups.size():
		return
	_group_index = index
	_page_index = 0
	_update_group_buttons()
	_refresh_cards(false)


func _update_group_buttons() -> void:
	for index in _group_buttons.size():
		var button := _group_buttons[index]
		var selected := index == _group_index
		(button as Button).button_pressed = selected


func _refresh_cards(animate := false, direction := 0) -> void:
	if _manifest == null or _card_list == null or _group_index >= _manifest.album_groups.size():
		return
	_gallery.reset_page_transition(_card_list)
	for child in _card_list.get_children():
		_card_list.remove_child(child)
		child.queue_free()
	var group := _manifest.album_groups[_group_index]
	var page_count := maxi(1, ceili(float(group.cards.size()) / float(PAGE_SIZE)))
	_page_index = clampi(_page_index, 0, page_count - 1)
	var first_card := _page_index * PAGE_SIZE
	var end_card := mini(group.cards.size(), first_card + PAGE_SIZE)
	for card_index in range(first_card, end_card):
		_add_card_card(group, group.cards[card_index], card_index + 1)
	_page_label.text = "%d / %d" % [_page_index + 1, page_count]
	_navigation.set_pagination(_page_index, page_count)
	_previous_page.visible = true
	_next_page.visible = true
	_previous_page.disabled = _page_index <= 0
	_next_page.disabled = _page_index >= page_count - 1
	_status.text = tr("已收集：%d / %d") % [group.unlocked_card_count(_profile), group.cards.size()]
	if animate:
		_gallery.play_page_transition(_card_list, direction)


func _change_page(delta: int) -> void:
	if _manifest == null or _group_index >= _manifest.album_groups.size():
		return
	var group := _manifest.album_groups[_group_index]
	var page_count := maxi(1, ceili(float(group.cards.size()) / float(PAGE_SIZE)))
	var target_page := clampi(_page_index + delta, 0, page_count - 1)
	if target_page == _page_index:
		return
	_page_index = target_page
	_refresh_cards(true, delta)


func _add_card_card(group: AppreciationAlbumGroup, card: AppreciationAlbumCard, number: int) -> void:
	var unlocked := card.unlocked(_profile)
	var card_button := CARD_SCENE.instantiate() as AppreciationVisualCard
	card_button.name = "Card_%s" % card.card_id.validate_node_name()
	card_button.configure(StringName(card.card_id), "%03d" % number, "res://assets/content/appreciation/cg_preview.png", unlocked)
	var unlocked_variants := card.unlocked_variants(_profile)
	var first: AppreciationAlbumVariant = unlocked_variants[0] if not unlocked_variants.is_empty() else null
	if unlocked and first != null:
		card_button.set_thumbnail(load(first.texture_path) as Texture2D)
	var available_variants := card.unlocked_variants(_profile).size()
	card_button.tooltip_text = "%s · %d/%d" % [card.card_id, available_variants, card.variants.size()] if unlocked else "未解锁"
	card_button.pressed.connect(_open_card.bind(group, card))
	_card_list.add_child(card_button)


func _open_card(group: AppreciationAlbumGroup, card: AppreciationAlbumCard) -> void:
	var variants := card.unlocked_variants(_profile)
	if variants.is_empty():
		_status.text = tr("“%s”尚未解锁。") % card.card_id
		return
	_viewer.configure(card, _profile)
	_viewer.open_variant(variants[0])
	content_requested.emit(AppreciationContentRequest.for_album(group.group_id, variants[0]))
