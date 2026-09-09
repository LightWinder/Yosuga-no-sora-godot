@tool
class_name AppreciationNavigation
extends Control


signal back_requested
signal catalog_requested(catalog_id: StringName)

@export_enum("album", "memories", "music", "voice") var current_catalog := "album":
	set(value):
		current_catalog = value
		_sync_selection()

@onready var _back_to_title: TitleSpriteButton = %BackToTitle
@onready var _catalog_buttons: Dictionary = {
	TitleCatalog.ALBUM: %Album,
	TitleCatalog.MEMORIES: %Memories,
	TitleCatalog.MUSIC: %Music,
	TitleCatalog.VOICE: %Voice,
}


func _ready() -> void:
	_back_to_title.configure_sprite("res://assets/content/appreciation/backtotitle.png", 2, 16.0)
	_back_to_title.pressed.connect(back_requested.emit)
	_configure_catalog_button(%Album, TitleCatalog.ALBUM, "res://assets/content/appreciation/CG.png")
	_configure_catalog_button(%Memories, TitleCatalog.MEMORIES, "res://assets/content/appreciation/scene.png")
	_configure_catalog_button(%Music, TitleCatalog.MUSIC, "res://assets/content/appreciation/ost.png")
	_configure_catalog_button(%Voice, TitleCatalog.VOICE, "res://assets/content/appreciation/fav.voices.png")
	_sync_selection()


func grab_initial_focus() -> void:
	if is_instance_valid(_back_to_title) and _back_to_title.is_visible_in_tree():
		_back_to_title.grab_focus()


func _configure_catalog_button(button: TitleSpriteButton, catalog_id: StringName, texture_path: String) -> void:
	button.configure_sprite(texture_path, 3, 16.0)
	button.pressed.connect(catalog_requested.emit.bind(catalog_id))


func _sync_selection() -> void:
	if not is_node_ready():
		return
	for catalog_id: StringName in _catalog_buttons:
		var button := _catalog_buttons[catalog_id] as TitleSpriteButton
		var selected := StringName(current_catalog) == catalog_id
		button.disabled = selected
		button.modulate.a = 1.0 if selected else 190.0 / 255.0
