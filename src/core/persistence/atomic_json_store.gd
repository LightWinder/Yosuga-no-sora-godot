class_name AtomicJsonStore
extends RefCounted


var last_error: String = ""


func read_dictionary(path: String) -> Dictionary:
	last_error = ""
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _read_failure("Unable to open %s: %s" % [path, error_string(FileAccess.get_open_error())])
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return _read_failure("Invalid JSON object in %s" % path)
	return parsed


func write_dictionary_atomic(path: String, payload: Dictionary) -> bool:
	last_error = ""
	if not _ensure_parent_directory(path):
		return false
	var temporary_path := "%s.tmp" % path
	var backup_path := "%s.bak" % path
	var previous_backup_path := "%s.previous" % backup_path
	var payload_text := JSON.stringify(payload, "\t", false)
	if not JSON.parse_string(payload_text) is Dictionary:
		return _fail("Unable to serialize JSON object for %s" % path)
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _fail("Unable to create temporary JSON file: %s" % error_string(FileAccess.get_open_error()))
	file.store_string(payload_text)
	file.flush()
	file.close()

	if FileAccess.file_exists(previous_backup_path):
		var clear_previous_error := DirAccess.remove_absolute(_absolute(previous_backup_path))
		if clear_previous_error != OK:
			return _fail("Unable to clear stale backup staging file: %s" % error_string(clear_previous_error))
	var staged_old_backup := false
	if FileAccess.file_exists(backup_path) and FileAccess.file_exists(path):
		var stage_backup_error := DirAccess.rename_absolute(
			_absolute(backup_path),
			_absolute(previous_backup_path)
		)
		if stage_backup_error != OK:
			return _fail("Unable to stage JSON backup: %s" % error_string(stage_backup_error))
		staged_old_backup = true
	if FileAccess.file_exists(path):
		var backup_error := DirAccess.rename_absolute(_absolute(path), _absolute(backup_path))
		if backup_error != OK:
			if staged_old_backup:
				DirAccess.rename_absolute(_absolute(previous_backup_path), _absolute(backup_path))
			return _fail("Unable to protect existing JSON file: %s" % error_string(backup_error))

	var replace_error := DirAccess.rename_absolute(_absolute(temporary_path), _absolute(path))
	if replace_error != OK:
		if FileAccess.file_exists(backup_path) and not FileAccess.file_exists(path):
			DirAccess.rename_absolute(_absolute(backup_path), _absolute(path))
		if staged_old_backup and not FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(_absolute(previous_backup_path), _absolute(backup_path))
		return _fail("Unable to atomically replace %s: %s" % [path, error_string(replace_error)])
	if staged_old_backup and FileAccess.file_exists(previous_backup_path):
		DirAccess.remove_absolute(_absolute(previous_backup_path))
	return true


func restore_backup(path: String) -> bool:
	last_error = ""
	var backup_path := "%s.bak" % path
	if not FileAccess.file_exists(backup_path):
		return _fail("No JSON backup exists for %s" % path)
	if not _ensure_parent_directory(path):
		return false

	var temporary_path := "%s.restore.tmp" % path
	if FileAccess.file_exists(temporary_path):
		DirAccess.remove_absolute(_absolute(temporary_path))
	if FileAccess.file_exists(path):
		var move_current_error := DirAccess.rename_absolute(_absolute(path), _absolute(temporary_path))
		if move_current_error != OK:
			return _fail("Unable to stage current JSON file for restore: %s" % error_string(move_current_error))

	var restore_error := DirAccess.rename_absolute(_absolute(backup_path), _absolute(path))
	if restore_error != OK:
		if FileAccess.file_exists(temporary_path) and not FileAccess.file_exists(path):
			DirAccess.rename_absolute(_absolute(temporary_path), _absolute(path))
		return _fail("Unable to restore JSON backup: %s" % error_string(restore_error))
	if FileAccess.file_exists(temporary_path):
		DirAccess.rename_absolute(_absolute(temporary_path), _absolute(backup_path))
	return true


func _ensure_parent_directory(path: String) -> bool:
	var directory := _absolute(path).get_base_dir()
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK and error != ERR_ALREADY_EXISTS:
		return _fail("Unable to create JSON directory: %s" % error_string(error))
	return true


func _absolute(path: String) -> String:
	return ProjectSettings.globalize_path(path)


func _read_failure(message: String) -> Dictionary:
	last_error = message
	return {}


func _fail(message: String) -> bool:
	last_error = message
	return false
