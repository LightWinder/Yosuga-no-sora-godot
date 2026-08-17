class_name SaveService
extends Node


signal save_changed(slot_id: int, is_autosave: bool)
signal settings_changed(settings: Dictionary)
## Emitted while a settings control is being adjusted. It never writes disk;
## the owner can apply the values to live systems and commit them later.
signal settings_preview_changed(settings: Dictionary)

const SAVE_DIRECTORY: String = "user://saves"
const AUTOSAVE_PATH: String = SAVE_DIRECTORY + "/autosave.json"
const PROFILE_PATH: String = "user://profile.json"
const SETTINGS_PATH: String = "user://settings.json"
const MAX_SLOT_COUNT: int = 20
const SETTINGS_MODEL: Script = preload("res://src/title/config/title_settings_model.gd")

var last_error: String = ""
var _ready_for_io := false
var _storage_root: String = SAVE_DIRECTORY
var _profile_path: String = PROFILE_PATH
var _settings_path: String = SETTINGS_PATH
var _settings_cache: Dictionary = {}
var _settings_cache_valid := false


## Tests/tools may point the service at an isolated temporary directory. The
## production default remains user:// and is never redirected implicitly.
func configure_storage(root_path: String, settings_path: String = "", profile_path: String = "") -> void:
	if not root_path.begins_with("user://") and not root_path.is_absolute_path():
		_fail("Save storage must be user:// or an absolute test directory.")
		return
	_storage_root = root_path.trim_suffix("/")
	_settings_path = settings_path if not settings_path.is_empty() else "%s/settings.json" % _storage_root
	_profile_path = profile_path if not profile_path.is_empty() else "%s/profile.json" % _storage_root
	_ready_for_io = false
	_settings_cache.clear()
	_settings_cache_valid = false


func _ready() -> void:
	_ready_for_io = _ensure_directory()


func has_autosave() -> bool:
	var data := load_autosave()
	return data != null and bool(data.autosave_meta.get("valid", true))


func load_autosave() -> SaveData:
	return _load_data(_autosave_path())


func save_autosave(data: SaveData) -> bool:
	if data == null:
		return _fail("Cannot save a null autosave.")
	data.saved_at_unix = Time.get_unix_time_from_system()
	data.autosave_meta["valid"] = true
	data.autosave_meta["saved_at_unix"] = data.saved_at_unix
	return _save_data(_autosave_path(), data) and _emit_save_changed(-1, true)


func load_slot(slot_id: int) -> SaveData:
	if not _is_valid_slot(slot_id):
		return null
	return _load_data(_slot_path(slot_id))


func save_slot(slot_id: int, data: SaveData) -> bool:
	if not _is_valid_slot(slot_id):
		return _fail("Invalid save slot: %d" % slot_id)
	if data == null:
		return _fail("Cannot save a null slot.")
	data.saved_at_unix = Time.get_unix_time_from_system()
	return _save_data(_slot_path(slot_id), data) and _emit_save_changed(slot_id, false)


func has_slot(slot_id: int) -> bool:
	return _is_valid_slot(slot_id) and FileAccess.file_exists(_slot_path(slot_id)) and load_slot(slot_id) != null


func list_slot_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	for slot_id in MAX_SLOT_COUNT:
		var data := load_slot(slot_id)
		if data == null:
			continue
		summaries.append({
			"slot_id": slot_id,
			"scenario_id": data.scenario_id,
			"instruction_anchor": data.instruction_anchor,
			"saved_at_unix": data.saved_at_unix,
			"label": str(data.autosave_meta.get("label", "")),
		})
	return summaries


func get_autosave_summary() -> Dictionary:
	var data := load_autosave()
	if data == null:
		return {"valid": false}
	return {
		"valid": bool(data.autosave_meta.get("valid", true)),
		"scenario_id": data.scenario_id,
		"instruction_anchor": data.instruction_anchor,
		"label": str(data.autosave_meta.get("label", "")),
		"saved_at_unix": data.saved_at_unix,
	}


func load_profile() -> ProfileData:
	if not FileAccess.file_exists(_profile_path):
		return ProfileData.create_empty()
	var raw := _read_dictionary(_profile_path)
	if raw.is_empty():
		return null
	var profile := ProfileData.from_dictionary(raw)
	if profile == null:
		_fail("Unsupported or invalid profile schema in %s" % _profile_path)
	return profile


func has_profile() -> bool:
	return FileAccess.file_exists(_profile_path) and load_profile() != null


func save_profile(profile: ProfileData) -> bool:
	if profile == null:
		return _fail("Cannot save a null profile.")
	profile.saved_at_unix = Time.get_unix_time_from_system()
	return _write_dictionary_atomic(_profile_path, profile.to_dictionary()) and _emit_save_changed(-2, false)


func set_global_flag(flag_id: int, enabled: bool = true) -> bool:
	var profile := load_profile()
	if profile == null:
		return false
	profile.set_global_flag(flag_id, enabled)
	return save_profile(profile)


func clear_profile() -> bool:
	if not FileAccess.file_exists(_profile_path):
		return true
	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(_profile_path))
	if error != OK:
		return _fail("Unable to remove profile: %s" % error_string(error))
	save_changed.emit(-2, false)
	return true


func restore_autosave_backup() -> bool:
	return _restore_backup(_autosave_path())


func restore_profile_backup() -> bool:
	return _restore_backup(_profile_path)


func restore_slot_backup(slot_id: int) -> bool:
	if not _is_valid_slot(slot_id):
		return _fail("Invalid save slot: %d" % slot_id)
	return _restore_backup(_slot_path(slot_id))


func clear_autosave() -> bool:
	var path := _autosave_path()
	if not FileAccess.file_exists(path):
		return true
	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if error != OK:
		return _fail("Unable to remove autosave: %s" % error_string(error))
	save_changed.emit(-1, true)
	return true


func clear_slot(slot_id: int) -> bool:
	if not _is_valid_slot(slot_id):
		return _fail("Invalid save slot: %d" % slot_id)
	var path := _slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return true
	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if error != OK:
		return _fail("Unable to remove save slot: %s" % error_string(error))
	save_changed.emit(slot_id, false)
	return true


func read_settings() -> Dictionary:
	if _settings_cache_valid:
		return _settings_cache.duplicate(true)
	var defaults: Dictionary = SETTINGS_MODEL.defaults()
	var result := _read_dictionary(_settings_path)
	if result.is_empty():
		_settings_cache = defaults.duplicate(true)
	else:
		# Preserve the prototype's flat aliases while upgrading to the complete
		# HD contract.  Unknown keys remain intact for future settings pages.
		if not result.has("voice_volume") and result.has("system_voice_volume"):
			result["voice_volume"] = result["system_voice_volume"]
		if not result.has("mute_voice") and result.has("mute_system_voice"):
			result["mute_voice"] = result["mute_system_voice"]
		_settings_cache = SETTINGS_MODEL.normalize(result)
	_settings_cache_valid = true
	return _settings_cache.duplicate(true)


func write_settings(settings: Dictionary) -> bool:
	var normalized := read_settings()
	for key in settings:
		normalized[key] = settings[key]
	if settings.has("system_voice_volume") and not settings.has("voice_volume"):
		normalized["voice_volume"] = settings["system_voice_volume"]
	if settings.has("mute_system_voice") and not settings.has("mute_voice"):
		normalized["mute_voice"] = settings["mute_system_voice"]
	normalized = SETTINGS_MODEL.normalize(normalized)
	var ok := _write_dictionary_atomic(_settings_path, normalized)
	if ok:
		_settings_cache = normalized.duplicate(true)
		_settings_cache_valid = true
		settings_changed.emit(normalized.duplicate(true))
	return ok


func preview_settings(settings: Dictionary) -> void:
	# Once the page has taken its initial snapshot, dragging a slider must not
	# re-open settings.json.  Cache invalidation is handled by configure_storage
	# and every successful write_settings call.
	var preview: Dictionary = _settings_cache.duplicate(true) if _settings_cache_valid else read_settings()
	for key in settings:
		preview[key] = settings[key]
	preview = SETTINGS_MODEL.normalize(preview)
	settings_preview_changed.emit(preview.duplicate(true))


func is_global_flag_set(flag_id: int) -> bool:
	var profile := load_profile()
	return profile != null and profile.is_global_flag_set(flag_id)


func _save_data(path: String, data: SaveData) -> bool:
	if not _ensure_directory():
		return false
	return _write_dictionary_atomic(path, data.to_dictionary())


func _load_data(path: String) -> SaveData:
	var raw := _read_dictionary(path)
	if raw.is_empty():
		return null
	var result := SaveData.from_dictionary(raw)
	if result == null:
		_fail("Unsupported or invalid save schema in %s" % path)
	return result


func _read_dictionary(path: String) -> Dictionary:
	last_error = ""
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("Unable to open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		_fail("Invalid JSON object in %s" % path)
		return {}
	return parsed


func _write_dictionary_atomic(path: String, payload: Dictionary) -> bool:
	last_error = ""
	if not _ensure_directory():
		return false
	var temporary_path := "%s.tmp" % path
	var backup_path := "%s.bak" % path
	var previous_backup_path := "%s.previous" % backup_path
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _fail("Unable to create temporary save: %s" % error_string(FileAccess.get_open_error()))
	file.store_string(JSON.stringify(payload, "\t", false))
	file.flush()
	file.close()

	# Stage the old backup instead of deleting it before the new file is known to
	# be replaceable.  This keeps both the current file and its last recovery
	# point intact if a platform rename fails halfway through the transaction.
	if FileAccess.file_exists(previous_backup_path):
		var clear_previous_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(previous_backup_path))
		if clear_previous_error != OK:
			return _fail("Unable to clear stale save backup staging file: %s" % error_string(clear_previous_error))
	var staged_old_backup := false
	if FileAccess.file_exists(backup_path) and FileAccess.file_exists(path):
		var stage_backup_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(backup_path),
			ProjectSettings.globalize_path(previous_backup_path)
		)
		if stage_backup_error != OK:
			return _fail("Unable to stage save backup: %s" % error_string(stage_backup_error))
		staged_old_backup = true
	if FileAccess.file_exists(path):
		var backup_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(path),
			ProjectSettings.globalize_path(backup_path)
		)
		if backup_error != OK:
			if staged_old_backup:
				DirAccess.rename_absolute(
					ProjectSettings.globalize_path(previous_backup_path),
					ProjectSettings.globalize_path(backup_path)
				)
			return _fail("Unable to protect existing save: %s" % error_string(backup_error))

	var error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary_path),
		ProjectSettings.globalize_path(path)
	)
	if error != OK:
		# Restore the prior file when replacement failed.  Keep the temporary
		# payload available for diagnostics/recovery instead of deleting data.
		if FileAccess.file_exists(backup_path) and not FileAccess.file_exists(path):
			DirAccess.rename_absolute(
				ProjectSettings.globalize_path(backup_path),
				ProjectSettings.globalize_path(path)
			)
		if staged_old_backup and not FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(
				ProjectSettings.globalize_path(previous_backup_path),
				ProjectSettings.globalize_path(backup_path)
			)
		return _fail("Unable to atomically replace %s: %s" % [path, error_string(error)])
	if staged_old_backup and FileAccess.file_exists(previous_backup_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(previous_backup_path))
	return true


func _restore_backup(path: String) -> bool:
	var backup_path := "%s.bak" % path
	if not FileAccess.file_exists(backup_path):
		return _fail("No save backup exists for %s" % path)
	if not _ensure_directory():
		return false

	var temporary_path := "%s.restore.tmp" % path
	if FileAccess.file_exists(temporary_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
	if FileAccess.file_exists(path):
		var move_current_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(path),
			ProjectSettings.globalize_path(temporary_path)
		)
		if move_current_error != OK:
			return _fail("Unable to stage current save for restore: %s" % error_string(move_current_error))

	var restore_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(backup_path),
		ProjectSettings.globalize_path(path)
	)
	if restore_error != OK:
		if FileAccess.file_exists(temporary_path) and not FileAccess.file_exists(path):
			DirAccess.rename_absolute(
				ProjectSettings.globalize_path(temporary_path),
				ProjectSettings.globalize_path(path)
			)
		return _fail("Unable to restore save backup: %s" % error_string(restore_error))

	# Preserve the replaced current file as the next backup, making restore a
	# reversible operation instead of a destructive rollback.
	if FileAccess.file_exists(temporary_path):
		DirAccess.rename_absolute(
			ProjectSettings.globalize_path(temporary_path),
			ProjectSettings.globalize_path(backup_path)
		)
	return true


func _ensure_directory() -> bool:
	if _ready_for_io:
		return true
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_storage_root))
	if error != OK and error != ERR_ALREADY_EXISTS:
		return _fail("Unable to create save directory: %s" % error_string(error))
	_ready_for_io = true
	return true


func _slot_path(slot_id: int) -> String:
	return "%s/slot_%02d.json" % [_storage_root, slot_id]


func _autosave_path() -> String:
	return "%s/autosave.json" % _storage_root


func _is_valid_slot(slot_id: int) -> bool:
	return slot_id >= 0 and slot_id < MAX_SLOT_COUNT


func _emit_save_changed(slot_id: int, is_autosave: bool) -> bool:
	save_changed.emit(slot_id, is_autosave)
	return true


func _fail(message: String) -> bool:
	last_error = message
	push_error(message)
	return false
