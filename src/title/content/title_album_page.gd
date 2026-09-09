class_name TitleAlbumPage
extends DesignCanvasPage


signal content_requested(request: TitleContentRequest)
signal status_changed(message: String)

var _manifest: TitleContentManifest
var _profile: ProfileData
var _group_index := 0
var _page_index := 0
var _page_tween: Tween

@onready var _group_buttons: Array[BaseButton] = [
	%Group01,
	%Group02,
	%Group03,
	%Group04,
	%Group05,
	%Group06,
]
@onready var _card_list: GridContainer = %CardList
@onready var _page_label: Label = %PageNumber
@onready var _previous_page: AppreciationPageButton = %PreviousPage
@onready var _next_page: AppreciationPageButton = %NextPage
@onready var _status: Label = %Status
@onready var _viewer: TitleAlbumViewer = %AlbumViewer


func configure(manifest: TitleContentManifest, profile: ProfileData) -> void:
	_manifest = manifest
	_profile = profile
	if is_inside_tree():
		_refresh_groups()


func _ready() -> void:
	super._ready()
	for index in _group_buttons.size():
		var button := _group_buttons[index] as TitleSpriteButton
		button.configure_sprite(_group_texture(index), 3, 18.0)
		button.pressed.connect(_select_group.bind(index))
	_previous_page.pressed.connect(_change_page.bind(-1))
	_next_page.pressed.connect(_change_page.bind(1))
	_viewer.closed.connect(func() -> void: status_changed.emit("已返回相册列表。"))
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
		button.disabled = index == _group_index
		button.modulate.a = 1.0 if index == _group_index else 190.0 / 255.0
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
		button.disabled = selected
		button.modulate.a = 1.0 if selected else 190.0 / 255.0


func _refresh_cards(animate := false, direction := 0) -> void:
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
	_page_label.text = ""
	_previous_page.visible = page_count > 1
	_next_page.visible = page_count > 1
	_previous_page.disabled = _page_index <= 0
	_next_page.disabled = _page_index >= page_count - 1
	_status.text = ""
	if animate:
		if _page_tween != null and _page_tween.is_valid():
			_page_tween.kill()
		_card_list.position.x = 82.0 + float(direction) * 320.0
		_page_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_page_tween.tween_property(_card_list, "position:x", 82.0, 0.24)


func _change_page(delta: int) -> void:
	if _manifest == null or _group_index >= _manifest.album_groups.size():
		return
	var group := _manifest.album_groups[_group_index]
	var page_count := maxi(1, ceili(float(group.cards.size()) / 8.0))
	var target_page := clampi(_page_index + delta, 0, page_count - 1)
	if target_page == _page_index:
		return
	_page_index = target_page
	_refresh_cards(true, signi(delta))


func _add_card_card(group: TitleAlbumGroup, card: TitleAlbumCard) -> void:
	var unlocked := card.unlocked(_profile)
	var card_button := TitleVisualCard.new()
	card_button.name = "Card_%s" % card.card_id.validate_node_name()
	card_button.configure(StringName(card.card_id), card.card_id, "res://assets/content/appreciation/cg_preview.png", unlocked)
	var first := card.first_variant()
	if unlocked and first != null:
		card_button.set_thumbnail(load(first.texture_path) as Texture2D)
	var available_variants := card.unlocked_variants(_profile).size()
	card_button.tooltip_text = "%s · %d/%d" % [card.card_id, available_variants, card.variants.size()] if unlocked else "未解锁"
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
