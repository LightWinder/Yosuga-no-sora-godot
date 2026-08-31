class_name AdvProgressCatalog
extends RefCounted


const CG_UNLOCK_MANIFEST := "res://assets/content/adv/cg_unlock_flags.csv"

var load_error := ""
var _cg_flags: Dictionary = {}


static func load_default() -> AdvProgressCatalog:
	var result := AdvProgressCatalog.new()
	result._load_cg_flags()
	return result


func flags_for_cg(resource_id: String) -> Array[int]:
	var normalized := _normalize_asset_id(resource_id)
	if normalized.is_empty():
		return []
	var keys: Array[String] = []
	match normalized.left(1):
		"E":
			keys.assign([normalized.left(7), normalized.left(4)])
		"S":
			keys.assign([normalized, normalized.left(4)])
		_:
			keys.append(normalized)
	return _flags_for_keys(keys)


func flags_for_character(resource_id: String) -> Array[int]:
	var normalized := _normalize_asset_id(resource_id)
	if normalized.length() < 4:
		return []
	return _flags_for_keys([normalized.left(4), normalized.left(7)])


func registered_flag_count() -> int:
	return _cg_flags.size()


func _load_cg_flags() -> void:
	_cg_flags.clear()
	if not FileAccess.file_exists(CG_UNLOCK_MANIFEST):
		load_error = "缺少 CG 解锁清单：%s" % CG_UNLOCK_MANIFEST
		return
	var file := FileAccess.open(CG_UNLOCK_MANIFEST, FileAccess.READ)
	if file == null:
		load_error = "无法读取 CG 解锁清单：%s" % CG_UNLOCK_MANIFEST
		return
	var first_row := true
	while not file.eof_reached():
		var row := file.get_csv_line()
		if first_row:
			first_row = false
			continue
		if row.size() < 2:
			continue
		var asset_id := str(row[0]).strip_edges().to_upper()
		var flag_text := str(row[1]).strip_edges()
		if asset_id.is_empty() or not flag_text.is_valid_int():
			continue
		var flag_id := flag_text.to_int()
		if flag_id > 0:
			_cg_flags[asset_id] = flag_id
	if _cg_flags.is_empty():
		load_error = "CG 解锁清单没有有效条目：%s" % CG_UNLOCK_MANIFEST


func _flags_for_keys(keys: Array[String]) -> Array[int]:
	var result: Array[int] = []
	for key in keys:
		var flag_id := int(_cg_flags.get(key, 0))
		if flag_id > 0 and not result.has(flag_id):
			result.append(flag_id)
	return result


func _normalize_asset_id(resource_id: String) -> String:
	return resource_id.strip_edges().get_file().get_basename().to_upper()
