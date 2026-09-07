class_name SaveThumbnail
extends RefCounted


## Decoded only for the visible card pool and selected preview, never all 900 slots.
static func texture_for(data: SaveData) -> Texture2D:
	if data == null:
		return null
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
