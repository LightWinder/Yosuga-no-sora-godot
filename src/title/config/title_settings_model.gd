class_name TitleSettingsModel
extends RefCounted


const CURRENT_SCHEMA_VERSION: int = 2
const CONFIRMATION_KEYS: Array[String] = [
	"load", "overwrite", "delete", "copy", "move", "title", "end", "select_jump", "log_jump", "default", "clear_read",
]
const VOICE_DETAIL_NAMES: Array[String] = ["穹", "奈绪", "瑛", "一叶", "初佳", "亮平", "八寻", "梢", "NPC"]


static func defaults() -> Dictionary:
	var confirmations: Dictionary = {}
	for key in CONFIRMATION_KEYS:
		confirmations[key] = true
	var voice_details: Array[float] = []
	for _index in VOICE_DETAIL_NAMES.size():
		voice_details.append(1.0)
	return {
		"schema_version": CURRENT_SCHEMA_VERSION,
		"master_volume": 1.0,
		"voice_volume": 1.0,
		"bgm_volume": 1.0,
		"env_se_volume": 1.0,
		"se_volume": 1.0,
		"movie_volume": 1.0,
		"system_voice_volume": 1.0,
		"mute_master": false,
		"mute_voice": false,
		"mute_bgm": false,
		"mute_env_se": false,
		"mute_se": false,
		"mute_movie": false,
		"mute_system_voice": false,
		"voice_detail_volumes": voice_details,
		"window_mode": "windowed",
		"window_width": 1280,
		"window_opacity": 1.0,
		"font_type": 0,
		"portrait_visible": true,
		"read_color": true,
		"screen_effect": true,
		"read_skip": true,
		"voice_stop_on_click": false,
		"lock_skip": false,
		"lock_auto": false,
		"route_guide": true,
		"message_speed": 5,
		"auto_speed": 5000,
		"confirmations": confirmations,
	}


static func normalize(raw: Dictionary) -> Dictionary:
	var result := defaults()
	for key in raw:
		result[key] = raw[key]
	result["schema_version"] = CURRENT_SCHEMA_VERSION
	result["voice_detail_volumes"] = _float_array(result.get("voice_detail_volumes", []), VOICE_DETAIL_NAMES.size())
	var normalized_confirmations: Dictionary = {}
	var source_confirmations: Variant = result.get("confirmations", {})
	for key in CONFIRMATION_KEYS:
		normalized_confirmations[key] = bool(source_confirmations.get(key, true)) if source_confirmations is Dictionary else true
	result["confirmations"] = normalized_confirmations
	return result


static func _float_array(value: Variant, count: int) -> Array[float]:
	var result: Array[float] = []
	if value is Array:
		for item in value:
			result.append(clampf(float(item), 0.0, 1.0))
	while result.size() < count:
		result.append(1.0)
	if result.size() > count:
		result.resize(count)
	return result
