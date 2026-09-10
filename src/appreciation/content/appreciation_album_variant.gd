class_name AppreciationAlbumVariant
extends Resource


@export var variant_id: String = ""
@export var texture_path: String = ""
@export var unlock_flag: int = 0


static func from_dictionary(raw: Dictionary) -> AppreciationAlbumVariant:
	var result := AppreciationAlbumVariant.new()
	result.variant_id = str(raw.get("id", ""))
	result.texture_path = str(raw.get("path", ""))
	result.unlock_flag = int(raw.get("unlock_flag", 0))
	return result
