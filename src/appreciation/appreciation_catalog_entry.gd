class_name AppreciationCatalogEntry
extends Resource


@export var entry_id: StringName = &""
@export var title: String = ""
@export var description: String = ""
@export var unlocked: bool = false
@export var media_path: String = ""
@export var unlock_flag: int = 0
@export var metadata: Dictionary = {}


static func create(
	entry: StringName,
	entry_title: String,
	entry_description: String,
	can_open: bool,
	entry_media_path: String = "",
	entry_unlock_flag: int = 0,
	entry_metadata: Dictionary = {}
) -> AppreciationCatalogEntry:
	var result := AppreciationCatalogEntry.new()
	result.entry_id = entry
	result.title = entry_title
	result.description = entry_description
	result.unlocked = can_open
	result.media_path = entry_media_path
	result.unlock_flag = entry_unlock_flag
	result.metadata = entry_metadata.duplicate(true)
	return result
