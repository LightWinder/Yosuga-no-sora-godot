class_name AdvToneCatalog
extends RefCounted


const BACKGROUND_TONE_MANIFEST := "res://assets/content/adv/background_tones.csv"
const TONE_COLORS := {
	"normal": Color.WHITE,
	"daytime": Color.WHITE,
	"daytime_rain": Color(210.0 / 255.0, 210.0 / 255.0, 220.0 / 255.0, 1.0),
	"evening": Color(1.0, 0.82, 0.82, 1.0),
	"evening_rain": Color.WHITE,
	"night": Color(180.0 / 255.0, 180.0 / 255.0, 230.0 / 255.0, 1.0),
	"night_l": Color(220.0 / 255.0, 220.0 / 255.0, 250.0 / 255.0, 1.0),
	"midnight": Color(150.0 / 255.0, 150.0 / 255.0, 180.0 / 255.0, 1.0),
	"monochrome": Color(0.72, 0.76, 0.80, 1.0),
	"mono_negative": Color(0.38, 0.42, 0.48, 1.0),
	"negative": Color(0.55, 0.42, 0.62, 1.0),
}

var load_error := ""
var _background_tones: Dictionary = {}


static func load_default() -> AdvToneCatalog:
	var result := AdvToneCatalog.new()
	result._load_background_tones()
	return result


func tone_for_background(resource_id: String) -> String:
	var normalized := resource_id.strip_edges().get_file().get_basename().to_upper()
	if normalized.is_empty():
		return "normal"
	var candidates: Array[String] = [normalized]
	if normalized.begins_with("E"):
		candidates.assign([normalized.left(7), normalized.left(4)])
	elif normalized.begins_with("S"):
		candidates.append(normalized.left(4))
	for candidate in candidates:
		if _background_tones.has(candidate):
			return str(_background_tones[candidate])
	return "normal"


func color_for_tone(tone_name: String) -> Color:
	return TONE_COLORS.get(tone_name.strip_edges().to_lower(), Color.WHITE) as Color


func registered_background_count() -> int:
	return _background_tones.size()


func _load_background_tones() -> void:
	_background_tones.clear()
	if not FileAccess.file_exists(BACKGROUND_TONE_MANIFEST):
		load_error = "缺少背景环境色清单：%s" % BACKGROUND_TONE_MANIFEST
		return
	var file := FileAccess.open(BACKGROUND_TONE_MANIFEST, FileAccess.READ)
	if file == null:
		load_error = "无法读取背景环境色清单：%s" % BACKGROUND_TONE_MANIFEST
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
		var tone_name := str(row[1]).strip_edges().to_lower()
		if asset_id.is_empty() or not TONE_COLORS.has(tone_name):
			continue
		_background_tones[asset_id] = tone_name
	if _background_tones.is_empty():
		load_error = "背景环境色清单没有有效条目：%s" % BACKGROUND_TONE_MANIFEST
