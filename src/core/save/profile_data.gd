class_name ProfileData
extends Resource


## Profile state is deliberately separate from a scenario save.  A cleared
## route, unlocked gallery entry, or other cross-save progress must survive
## replacing/clearing an autosave.
const CURRENT_SCHEMA_VERSION: int = 1

@export var schema_version: int = CURRENT_SCHEMA_VERSION
@export var content_version: String = ""
@export var global_flags: Dictionary = {}
@export var unlocked_catalog: Dictionary = {}
@export var saved_at_unix: int = 0


static func create_empty(content: String = "") -> ProfileData:
	var profile := ProfileData.new()
	profile.content_version = content
	profile.saved_at_unix = Time.get_unix_time_from_system()
	return profile


func set_global_flag(flag_id: int, enabled: bool = true) -> void:
	global_flags[str(flag_id)] = enabled


func is_global_flag_set(flag_id: int) -> bool:
	return bool(global_flags.get(str(flag_id), false))


func set_catalog_unlocked(catalog_id: StringName, entry_id: String, enabled: bool = true) -> void:
	var entries := _string_dictionary(unlocked_catalog.get(String(catalog_id), {}))
	entries[entry_id] = enabled
	unlocked_catalog[String(catalog_id)] = entries


func is_catalog_unlocked(catalog_id: StringName, entry_id: String) -> bool:
	var entries := _string_dictionary(unlocked_catalog.get(String(catalog_id), {}))
	return bool(entries.get(entry_id, false))


func to_dictionary() -> Dictionary:
	return {
		"schema_version": schema_version,
		"content_version": content_version,
		"global_flags": global_flags.duplicate(true),
		"unlocked_catalog": unlocked_catalog.duplicate(true),
		"saved_at_unix": saved_at_unix,
	}


static func from_dictionary(raw: Dictionary) -> ProfileData:
	if raw.is_empty():
		return null
	var migrated := _migrate(raw)
	if migrated.is_empty() or int(migrated.get("schema_version", 0)) > CURRENT_SCHEMA_VERSION:
		return null

	var profile := ProfileData.new()
	profile.schema_version = CURRENT_SCHEMA_VERSION
	profile.content_version = str(migrated.get("content_version", ""))
	profile.global_flags = _dictionary_or_empty(migrated.get("global_flags", {}))
	profile.unlocked_catalog = _dictionary_or_empty(migrated.get("unlocked_catalog", {}))
	profile.saved_at_unix = int(migrated.get("saved_at_unix", 0))
	return profile


static func _migrate(raw: Dictionary) -> Dictionary:
	var result := raw.duplicate(true)
	var source_schema := int(result.get("schema_version", result.get("version", 0)))
	if source_schema > CURRENT_SCHEMA_VERSION:
		return {}
	if not result.has("global_flags") and result.has("flags"):
		result["global_flags"] = result["flags"]
	if not result.has("content_version") and result.has("game_version"):
		result["content_version"] = result["game_version"]
	result["schema_version"] = CURRENT_SCHEMA_VERSION
	return result


static func _dictionary_or_empty(value: Variant) -> Dictionary:
	return value.duplicate(true) if value is Dictionary else {}


static func _string_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if value is Dictionary:
		for key in value:
			result[str(key)] = bool(value[key])
	return result
