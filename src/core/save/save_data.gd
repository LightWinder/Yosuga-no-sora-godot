class_name SaveData
extends Resource


const CURRENT_SCHEMA_VERSION: int = 4

@export var schema_version: int = CURRENT_SCHEMA_VERSION
@export var content_version: String = ""
@export var scenario_id: String = ""
@export var instruction_anchor: String = ""
## Kept for schema compatibility with early migration saves. New cross-save
## progress is canonical in ProfileData, never inferred from autosave.
@export var global_flags: Dictionary = {}
@export var local_flags: Dictionary = {}
@export var scenario_parameters: Dictionary = {}
## Mirrors the source ADV save contract's `select` log. Replaying these
## one-based selections reconstructs KRKR condition state before a saved Hitret.
@export var choice_history: Array[int] = []
## Mirrors the source `_stackSelect`/`_logSaveInfo` pair so loading a save does
## not discard the already-visited choice boundaries used by "previous choice".
@export var choice_navigation_stack: Array[Dictionary] = []
@export var choice_navigation_position: int = 0
@export var read_text_ids: Array[String] = []
@export var presentation: Dictionary = {}
@export var settings: Dictionary = {}
@export var autosave_meta: Dictionary = {}
@export var saved_at_unix: int = 0


static func create_empty(content: String = "") -> SaveData:
	var data := SaveData.new()
	data.content_version = content
	data.saved_at_unix = Time.get_unix_time_from_system()
	return data


func set_global_flag(flag_id: int, enabled: bool = true) -> void:
	global_flags[str(flag_id)] = enabled


func is_global_flag_set(flag_id: int) -> bool:
	return bool(global_flags.get(str(flag_id), false))


func set_local_flag(flag_id: String, enabled: bool = true) -> void:
	local_flags[flag_id] = enabled


func to_dictionary() -> Dictionary:
	return {
		"schema_version": schema_version,
		"content_version": content_version,
		"scenario_id": scenario_id,
		"instruction_anchor": instruction_anchor,
		"global_flags": global_flags.duplicate(true),
		"local_flags": local_flags.duplicate(true),
		"scenario_parameters": scenario_parameters.duplicate(true),
		"choice_history": choice_history.duplicate(),
		"choice_navigation_stack": choice_navigation_stack.duplicate(true),
		"choice_navigation_position": choice_navigation_position,
		"read_text_ids": read_text_ids.duplicate(),
		"presentation": presentation.duplicate(true),
		"settings": settings.duplicate(true),
		"autosave_meta": autosave_meta.duplicate(true),
		"saved_at_unix": saved_at_unix,
	}


## Decodes the on-disk contract and upgrades the previous prototype shape.
## Returning null for a future/invalid schema lets the service keep the old
## file intact and present a recoverable error to the caller.
static func from_dictionary(raw: Dictionary) -> SaveData:
	var migrated := _migrate(raw)
	if migrated.is_empty():
		return null
	if int(migrated.get("schema_version", 0)) > CURRENT_SCHEMA_VERSION:
		return null

	var data := SaveData.new()
	data.schema_version = CURRENT_SCHEMA_VERSION
	data.content_version = str(migrated.get("content_version", ""))
	data.scenario_id = str(migrated.get("scenario_id", ""))
	data.instruction_anchor = str(migrated.get("instruction_anchor", ""))
	data.global_flags = _dictionary_or_empty(migrated.get("global_flags", {}))
	data.local_flags = _dictionary_or_empty(migrated.get("local_flags", {}))
	data.scenario_parameters = _dictionary_or_empty(migrated.get("scenario_parameters", {}))
	data.choice_history = _int_array(migrated.get("choice_history", []))
	data.choice_navigation_stack = _dictionary_array(
		migrated.get("choice_navigation_stack", [])
	)
	data.choice_navigation_position = clampi(
		int(migrated.get("choice_navigation_position", 0)),
		0,
		data.choice_navigation_stack.size()
	)
	data.read_text_ids = _string_array(migrated.get("read_text_ids", []))
	data.presentation = _dictionary_or_empty(migrated.get("presentation", {}))
	data.settings = _dictionary_or_empty(migrated.get("settings", {}))
	data.autosave_meta = _dictionary_or_empty(migrated.get("autosave_meta", {}))
	data.saved_at_unix = int(migrated.get("saved_at_unix", 0))
	return data


static func _migrate(raw: Dictionary) -> Dictionary:
	if raw.is_empty():
		return {}

	var result := raw.duplicate(true)
	var source_schema := int(result.get("schema_version", result.get("version", 0)))
	if source_schema > CURRENT_SCHEMA_VERSION:
		return {}

	# Schema 0 was used by early migration experiments.  Keep these aliases
	# here so a user can safely update the port without losing route flags.
	if not result.has("global_flags") and result.has("flags"):
		result["global_flags"] = result["flags"]
	if not result.has("scenario_id") and result.has("scenario"):
		result["scenario_id"] = result["scenario"]
	if not result.has("instruction_anchor") and result.has("anchor"):
		result["instruction_anchor"] = result["anchor"]
	if not result.has("content_version") and result.has("game_version"):
		result["content_version"] = result["game_version"]
	if source_schema < 4:
		result["choice_navigation_stack"] = []
		result["choice_navigation_position"] = 0

	result["schema_version"] = CURRENT_SCHEMA_VERSION
	return result


static func _dictionary_or_empty(value: Variant) -> Dictionary:
	return value.duplicate(true) if value is Dictionary else {}


static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(str(item))
	return result


static func _int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if value is Array:
		for item in value:
			result.append(int(item))
	return result


static func _dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item.duplicate(true))
	return result
