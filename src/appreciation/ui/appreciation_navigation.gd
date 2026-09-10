@tool
class_name AppreciationNavigation
extends Control


signal back_requested
signal catalog_requested(catalog_id: StringName)
signal page_requested(delta: int)

@export_enum("album", "memories", "music", "voice") var current_catalog := "album":
	set(value):
		current_catalog = value
		_sync_selection()

@onready var _back_to_title: Button = %BackToTitle
@onready var _catalog_buttons: Dictionary = {
	AppreciationCatalog.ALBUM: %Album,
	AppreciationCatalog.MEMORIES: %Memories,
	AppreciationCatalog.MUSIC: %Music,
	AppreciationCatalog.VOICE: %Voice,
}


func _ready() -> void:
	_back_to_title.pressed.connect(back_requested.emit)
	(%PagePrevious as Button).pressed.connect(page_requested.emit.bind(-1))
	(%PageNext as Button).pressed.connect(page_requested.emit.bind(1))
	_configure_catalog_button(%Album, AppreciationCatalog.ALBUM)
	_configure_catalog_button(%Memories, AppreciationCatalog.MEMORIES)
	_configure_catalog_button(%Music, AppreciationCatalog.MUSIC)
	_configure_catalog_button(%Voice, AppreciationCatalog.VOICE)
	_sync_selection()


func set_pagination(page_index: int, page_count: int) -> void:
	(%Pagination as Control).show()
	(%PageNumber as Label).text = "%d / %d" % [page_index + 1, page_count]
	var previous := %PagePrevious as Button
	var next := %PageNext as Button
	previous.disabled = page_index <= 0
	next.disabled = page_index >= page_count - 1
	previous.modulate.a = 0.35 if previous.disabled else 1.0
	next.modulate.a = 0.35 if next.disabled else 1.0
	# Keep keyboard/controller focus on an available action at the page boundary.
	if previous.disabled and previous.has_focus():
		(next if not next.disabled else _back_to_title).grab_focus()
	elif next.disabled and next.has_focus():
		(previous if not previous.disabled else _back_to_title).grab_focus()


func grab_initial_focus() -> void:
	if is_instance_valid(_back_to_title) and _back_to_title.is_visible_in_tree():
		_back_to_title.grab_focus()


func _configure_catalog_button(button: Button, catalog_id: StringName) -> void:
	button.pressed.connect(catalog_requested.emit.bind(catalog_id))


func _sync_selection() -> void:
	if not is_node_ready():
		return
	for catalog_id: StringName in _catalog_buttons:
		var button := _catalog_buttons[catalog_id] as Button
		var selected := StringName(current_catalog) == catalog_id
		button.button_pressed = selected
