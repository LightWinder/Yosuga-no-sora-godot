class_name SettingsRepository
extends RefCounted


signal settings_changed(settings: Dictionary)
## Preview updates never write disk. Runtime adapters can apply them immediately
## while the settings screen owns debounce and commit timing.
signal settings_preview_changed(settings: Dictionary)

const DEFAULT_PATH := "user://settings.json"

var last_error: String = ""
var _storage_path := DEFAULT_PATH
var _cache: Dictionary = {}
var _cache_valid := false
var _store := AtomicJsonStore.new()


func configure_storage(path: String) -> void:
	if path.is_empty() or (not path.begins_with("user://") and not path.is_absolute_path()):
		last_error = "Settings storage must be user:// or an absolute test path."
		return
	_storage_path = path
	_cache.clear()
	_cache_valid = false
	last_error = ""


func read_settings() -> Dictionary:
	if _cache_valid:
		return _cache.duplicate(true)
	var result := _read_dictionary(_storage_path)
	if result.is_empty():
		_cache = SettingsModel.defaults()
	else:
		# Preserve prototype aliases while normalizing to the current schema.
		if not result.has("voice_volume") and result.has("system_voice_volume"):
			result["voice_volume"] = result["system_voice_volume"]
		if not result.has("mute_voice") and result.has("mute_system_voice"):
			result["mute_voice"] = result["mute_system_voice"]
		_cache = SettingsModel.normalize(result)
	_cache_valid = true
	return _cache.duplicate(true)


func write_settings(settings: Dictionary) -> bool:
	var normalized := read_settings()
	for key in settings:
		normalized[key] = settings[key]
	if settings.has("system_voice_volume") and not settings.has("voice_volume"):
		normalized["voice_volume"] = settings["system_voice_volume"]
	if settings.has("mute_system_voice") and not settings.has("mute_voice"):
		normalized["mute_voice"] = settings["mute_system_voice"]
	normalized = SettingsModel.normalize(normalized)
	if not _write_dictionary_atomic(_storage_path, normalized):
		return false
	_cache = normalized.duplicate(true)
	_cache_valid = true
	settings_changed.emit(normalized.duplicate(true))
	return true


func preview_settings(settings: Dictionary) -> void:
	var preview: Dictionary = _cache.duplicate(true) if _cache_valid else read_settings()
	for key in settings:
		preview[key] = settings[key]
	preview = SettingsModel.normalize(preview)
	settings_preview_changed.emit(preview.duplicate(true))


func restore_backup() -> bool:
	if not _store.restore_backup(_storage_path):
		last_error = _store.last_error
		return false
	_cache.clear()
	_cache_valid = false
	settings_changed.emit(read_settings())
	return true


func _read_dictionary(path: String) -> Dictionary:
	var result := _store.read_dictionary(path)
	last_error = _store.last_error
	return result


func _write_dictionary_atomic(path: String, payload: Dictionary) -> bool:
	var ok := _store.write_dictionary_atomic(path, payload)
	last_error = _store.last_error
	return ok
