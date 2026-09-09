@tool
class_name AppreciationNavigation
extends Control


signal back_requested
signal catalog_requested(catalog_id: StringName)

@export_enum("album", "memories", "music", "voice") var current_catalog := "album":
	set(value):
		current_catalog = value
		_sync_selection()

@onready var _back_to_title: Button = %BackToTitle
@onready var _catalog_buttons: Dictionary = {
	TitleCatalog.ALBUM: %Album,
	TitleCatalog.MEMORIES: %Memories,
	TitleCatalog.MUSIC: %Music,
	TitleCatalog.VOICE: %Voice,
}


func _ready() -> void:
	_back_to_title.pressed.connect(back_requested.emit)
	_configure_catalog_button(%Album, TitleCatalog.ALBUM)
	_configure_catalog_button(%Memories, TitleCatalog.MEMORIES)
	_configure_catalog_button(%Music, TitleCatalog.MUSIC)
	_configure_catalog_button(%Voice, TitleCatalog.VOICE)
	_sync_selection()


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
