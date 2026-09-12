class_name SaveThumbnail
extends RefCounted

const TEXTURE_META := &"_save_thumbnail_texture"
const PROBED_META := &"_save_thumbnail_probed"


## Decoded only for the visible card pool and selected preview, never all 900 slots.
static func texture_for(data: SaveData) -> Texture2D:
	if data == null:
		return null
	if data.has_meta(PROBED_META):
		if data.has_meta(TEXTURE_META):
			return data.get_meta(TEXTURE_META) as Texture2D
		return null
	var texture := _load_texture(data)
	data.set_meta(PROBED_META, true)
	if texture != null:
		data.set_meta(TEXTURE_META, texture)
	return texture


static func _load_texture(data: SaveData) -> Texture2D:
	if not data.thumbnail_webp.is_empty():
		var image := Image.new()
		if image.load_webp_from_buffer(Marshalls.base64_to_raw(data.thumbnail_webp)) == OK:
			return ImageTexture.create_from_image(image)
	# Keep early port saves and imported preview fixtures readable.
	for key in ["thumbnail_path", "screenshot_path", "thumbnail"]:
		var path := str(data.presentation.get(key, ""))
		if path.begins_with("res://") and ResourceLoader.exists(path):
			return load(path) as Texture2D
		if (path.begins_with("user://") or path.is_absolute_path()) and FileAccess.file_exists(path):
			var image := Image.load_from_file(ProjectSettings.globalize_path(path))
			if image != null and not image.is_empty():
				return ImageTexture.create_from_image(image)
	return null
