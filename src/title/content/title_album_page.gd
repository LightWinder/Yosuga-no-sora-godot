class_name TitleAlbumPage
extends TitleVisualPage


signal content_requested(request: TitleContentRequest)
signal status_changed(message: String)

const VIEWER_SCENE: PackedScene = preload("res://src/title/content/title_album_viewer.tscn")

var _manifest: TitleContentManifest
var _profile: ProfileData
var _group_index := 0
var _page_index := 0
var _group_buttons: Array[BaseButton] = []
var _card_list: GridContainer
var _page_label: Label
var _previous_page: BaseButton
var _next_page: BaseButton
var _status: Label
var _viewer: TitleAlbumViewer


func configure(manifest: TitleContentManifest, profile: ProfileData) -> void:
	_manifest = manifest
	_profile = profile
	if is_inside_tree():
		_refresh_groups()


func _ready() -> void:
	super._ready()
	_build_shell()
	_refresh_groups()


func group_count() -> int:
	return _manifest.album_groups.size() if _manifest != null else 0


func card_count() -> int:
	return _manifest.album_card_count() if _manifest != null else 0


func variant_count() -> int:
	return _manifest.album_variant_count() if _manifest != null else 0


func get_viewer() -> TitleAlbumViewer:
	return _viewer


func open_card_for_test(group_index: int = 0, card_index: int = 0) -> bool:
	if _manifest == null or group_index < 0 or group_index >= _manifest.album_groups.size():
		return false
	var group := _manifest.album_groups[group_index]
	if card_index < 0 or card_index >= group.cards.size():
		return false
	_open_card(group, group.cards[card_index])
	return _viewer.visible


func _build_shell() -> void:
	var root := Control.new()
	root.name = "AlbumContent"
	root.position = Vector2(80.0, 120.0)
	root.size = Vector2(1760.0, 900.0)
	visual_canvas().add_child(root)
	add_design_texture(root, "res://assets/content/appreciation/CG.png", Rect2(95, 18, 300, 52))
	add_design_label(root, "前六组 · 79 张卡片 / 214 个差分", Rect2(900, 20, 690, 44), 24, Color(0.12, 0.30, 0.40, 1.0))
	for _index in 6:
		var button := TitleSpriteButton.new()
		button.name = "Group%02d" % (_index + 1)
		button.configure_sprite(_group_texture(_index), 3, 18.0)
		button.set_design_size(Vector2(245.0, 58.0))
		button.position = Vector2(95.0 + float(_index % 3) * 260.0, 84.0 + float(_index / 3) * 70.0)
		button.pressed.connect(_select_group.bind(_index))
		root.add_child(button)
		_group_buttons.append(button)
	_card_list = GridContainer.new()
	_card_list.name = "CardList"
	_card_list.columns = 4
	_card_list.position = Vector2(95.0, 245.0)
	_card_list.size = Vector2(1510.0, 505.0)
	_card_list.add_theme_constant_override("h_separation", 18)
	_card_list.add_theme_constant_override("v_separation", 18)
	root.add_child(_card_list)
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
	_status.position = Vector2(320.0, 840.0)
	_status.size = Vector2(1120.0, 42.0)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status)
	_viewer = VIEWER_SCENE.instantiate() as TitleAlbumViewer
	_viewer.z_index = 100
	_viewer.closed.connect(func() -> void: status_changed.emit("已返回相册列表。"))
	visual_canvas().add_child(_viewer)


func _group_texture(index: int) -> String:
	return [
		"res://assets/content/appreciation/sora.png",
		"res://assets/content/appreciation/nao.png",
		"res://assets/content/appreciation/akira.png",
		"res://assets/content/appreciation/kazuha.png",
		"res://assets/content/appreciation/motoka.png",
		"res://assets/content/appreciation/others.png",
	][index]


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
		button.disabled = false
	if _group_index >= _manifest.album_groups.size():
		_group_index = 0
	_select_group(_group_index)


func _select_group(index: int) -> void:
	if _manifest == null or index < 0 or index >= _manifest.album_groups.size():
		return
	_group_index = index
	_page_index = 0
	_refresh_cards()


func _refresh_cards() -> void:
	if _manifest == null or _card_list == null or _group_index >= _manifest.album_groups.size():
		return
	for child in _card_list.get_children():
		_card_list.remove_child(child)
		child.queue_free()
	var group := _manifest.album_groups[_group_index]
	var page_count := maxi(1, ceili(float(group.cards.size()) / 8.0))
	_page_index = clampi(_page_index, 0, page_count - 1)
	var first_card := _page_index * 8
	var end_card := mini(group.cards.size(), first_card + 8)
	for card_index in range(first_card, end_card):
		_add_card_card(group, group.cards[card_index])
	_page_label.text = "%d / %d" % [_page_index + 1, page_count]
	_previous_page.disabled = _page_index <= 0
	_next_page.disabled = _page_index >= page_count - 1
	_status.text = "%s：%d 张卡片，%d 个差分；锁定状态依据源 CgFlag。" % [group.title, group.cards.size(), group.variant_count()]
	status_changed.emit(_status.text)


func _change_page(delta: int) -> void:
	_page_index += delta
	_refresh_cards()


func _add_card_card(group: TitleAlbumGroup, card: TitleAlbumCard) -> void:
	var unlocked := card.unlocked(_profile)
	var card_button := TitleVisualCard.new()
	card_button.name = "Card_%s" % card.card_id.validate_node_name()
	card_button.configure(StringName(card.card_id), card.card_id, "res://assets/content/appreciation/cg_preview.png", unlocked, Vector2(350.0, 205.0))
	var first := card.first_variant()
	if first != null:
		card_button.set_thumbnail(load(first.texture_path) as Texture2D)
	var available_variants := card.unlocked_variants(_profile).size()
	card_button.tooltip_text = ("已解锁" if unlocked else "锁定") + " · %d/%d 差分" % [available_variants, card.variants.size()]
	card_button.disabled = not unlocked
	card_button.pressed.connect(_open_card.bind(group, card))
	_card_list.add_child(card_button)


func _open_card(group: TitleAlbumGroup, card: TitleAlbumCard) -> void:
	var variants := card.unlocked_variants(_profile)
	if variants.is_empty():
		_status.text = "“%s”尚未解锁。" % card.card_id
		return
	_viewer.configure(card, _profile)
	_viewer.open_variant(variants[0])
	content_requested.emit(TitleContentRequest.for_album(group.group_id, variants[0]))
