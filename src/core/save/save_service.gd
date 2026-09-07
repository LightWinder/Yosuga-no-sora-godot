class_name SaveService
extends Node


signal save_changed(slot_id: int, is_autosave: bool)

const SAVE_DIRECTORY: String = "user://saves"
const AUTOSAVE_PATH: String = SAVE_DIRECTORY + "/autosave.json"
const PROFILE_PATH: String = "user://profile.json"
const MAX_SLOT_COUNT: int = 900
const QUICK_SAVE_COUNT: int = 9
const PREVIEW_SIZE := Vector2i(960, 540)

var last_error: String = ""
var _ready_for_io := false
var _storage_root: String = SAVE_DIRECTORY
var _profile_path: String = PROFILE_PATH
var _store := AtomicJsonStore.new()


## Tests/tools may point the service at an isolated temporary directory. The
## production default remains user:// and is never redirected implicitly.
func configure_storage(root_path: String, profile_path: String = "") -> void:
	if not root_path.begins_with("user://") and not root_path.is_absolute_path():
		_fail("Save storage must be user:// or an absolute test directory.")
		return
	_storage_root = root_path.trim_suffix("/")
	_profile_path = profile_path if not profile_path.is_empty() else "%s/profile.json" % _storage_root
	_ready_for_io = false


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
	data = _prepare_snapshot(data)
	data.saved_at_unix = Time.get_unix_time_from_system()
	data.autosave_meta["valid"] = true
	data.autosave_meta["saved_at_unix"] = data.saved_at_unix
	return _save_data(_autosave_path(), data) and _emit_save_changed(-1, true)


func load_slot(slot_id: int) -> SaveData:
	if not _is_valid_slot(slot_id):
		return null
	return _load_data(_slot_path(slot_id))


## Resolves the neutral save-path contract used by voice favorites and other
## route adapters without exposing SaveService internals to feature pages.
func load_path(path: String) -> SaveData:
	if path == _autosave_path():
		return load_autosave()
	for slot_id in MAX_SLOT_COUNT:
		if path == _slot_path(slot_id):
			return load_slot(slot_id)
	for quick_index in QUICK_SAVE_COUNT:
		if path == _quick_file_path(quick_index):
			return _load_data(path)
	_fail("Save path is outside the configured storage: %s" % path)
	return null


func save_slot(slot_id: int, data: SaveData) -> bool:
	if not _is_valid_slot(slot_id):
		return _fail("Invalid save slot: %d" % slot_id)
	if data == null:
		return _fail("Cannot save a null slot.")
	data = _prepare_snapshot(data)
	data.saved_at_unix = Time.get_unix_time_from_system()
	var existing := load_slot(slot_id)
	if existing != null and existing.locked:
		return _fail("This save slot is locked.")
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
	var existing := load_slot(slot_id)
	if existing != null and existing.locked:
		return _fail("This save slot is locked.")
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


## Public read-only paths keep UI/controller code independent from the
## service's production/test storage configuration.
func slot_path(slot_id: int) -> String:
	return _slot_path(slot_id) if _is_valid_slot(slot_id) else ""


func autosave_path() -> String:
	return _autosave_path()


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
	var result := _store.read_dictionary(path)
	if not _store.last_error.is_empty():
		_fail(_store.last_error)
	return result


func _write_dictionary_atomic(path: String, payload: Dictionary) -> bool:
	last_error = ""
	if not _ensure_directory():
		return false
	if _store.write_dictionary_atomic(path, payload):
		return true
	return _fail(_store.last_error)


func _restore_backup(path: String) -> bool:
	if not _ensure_directory():
		return false
	if _store.restore_backup(path):
		return true
	return _fail(_store.last_error)


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


## Nine independent atomic records. Sequence numbers order the ring without a
## separate index file that could disagree after an interrupted write.
func save_quick(data: SaveData) -> bool:
	if data == null:
		return _fail("Cannot quick-save a null snapshot.")
	var records := _quick_records()
	var destination := records.size()
	var sequence := 1
	if not records.is_empty():
		sequence = int(records[0]["sequence"]) + 1
	if records.size() == QUICK_SAVE_COUNT:
		destination = int(records.back()["index"])
	else:
		for candidate in QUICK_SAVE_COUNT:
			if not FileAccess.file_exists(_quick_file_path(candidate)) or _load_data(_quick_file_path(candidate)) == null:
				destination = candidate
				break
	var snapshot := _prepare_snapshot(data)
	snapshot.saved_at_unix = int(Time.get_unix_time_from_system())
	snapshot.autosave_meta["quick_sequence"] = sequence
	return _save_data(_quick_file_path(destination), snapshot) and _emit_save_changed(-3, false)


func load_quick(history_index: int = 0) -> SaveData:
	var path := quick_save_path(history_index)
	return _load_data(path) if not path.is_empty() else null


func quick_save_path(history_index: int = 0) -> String:
	var records := _quick_records()
	if history_index < 0 or history_index >= records.size():
		return ""
	return _quick_file_path(int(records[history_index]["index"]))


func _quick_records() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for index in QUICK_SAVE_COUNT:
		var data := _load_data(_quick_file_path(index))
		if data != null:
			records.append({"index": index, "sequence": int(data.autosave_meta.get("quick_sequence", 0))})
	records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["sequence"]) > int(b["sequence"]))
	return records


func _quick_file_path(index: int) -> String:
	return "%s/quick_%02d.json" % [_storage_root, index]


## Copy preserves timestamp, replay state and thumbnail, and never aliases the
## source Resource. The destination is unlocked, as in the source game.
func copy_to_slot(source: SaveData, destination: int) -> bool:
	if source == null or not _is_valid_slot(destination):
		return _fail("Invalid copy source or destination.")
	var existing := load_slot(destination)
	if existing != null and existing.locked:
		return _fail("The destination is locked.")
	var snapshot := _prepare_snapshot(source)
	snapshot.locked = false
	return _save_data(_slot_path(destination), snapshot) and _emit_save_changed(destination, false)


func copy_slot(source: int, destination: int) -> bool:
	if source == destination:
		return _fail("Choose a different destination.")
	return copy_to_slot(load_slot(source), destination)


func move_slot(source: int, destination: int) -> bool:
	var data := load_slot(source)
	if data == null or data.locked or source == destination:
		return _fail("The source cannot be moved.")
	# Commit the destination first: interruption may leave a duplicate, never
	# destroy the only copy of the player's progress.
	return copy_to_slot(data, destination) and clear_slot(source)


func set_slot_locked(slot_id: int, locked: bool) -> bool:
	var data := load_slot(slot_id)
	if data == null:
		return _fail("The slot is empty.")
	data.locked = locked
	return _save_data(_slot_path(slot_id), data) and _emit_save_changed(slot_id, false)


func set_slot_comment(slot_id: int, comment: String) -> bool:
	var data := load_slot(slot_id)
	if data == null or data.locked:
		return _fail("The slot is empty or locked.")
	data.comment = comment.strip_edges().left(120)
	return _save_data(_slot_path(slot_id), data) and _emit_save_changed(slot_id, false)


func _prepare_snapshot(data: SaveData) -> SaveData:
	var snapshot := SaveData.from_dictionary(data.to_dictionary())
	if data.preview_image != null and not data.preview_image.is_empty():
		var preview := data.preview_image.duplicate() as Image
		preview.resize(PREVIEW_SIZE.x, PREVIEW_SIZE.y, Image.INTERPOLATE_LANCZOS)
		snapshot.thumbnail_webp = Marshalls.raw_to_base64(preview.save_webp_to_buffer(true, 0.85))
	return snapshot
