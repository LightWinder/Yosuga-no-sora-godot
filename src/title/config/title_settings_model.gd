class_name TitleSettingsModel
extends RefCounted


const CURRENT_SCHEMA_VERSION: int = 3
const WINDOW_WIDTH_1080P_MIN: int = 1760
const WINDOW_WIDTH_900P_MIN: int = 1440
const CONFIRMATION_KEYS: Array[String] = [
	"load", "overwrite", "delete", "copy", "move", "title", "end", "select_jump", "log_jump", "default", "clear_read",
]
## Source VCID_TO_INDEX order (SR, AK, NO, KA, MT, RH, YH, KO, YM, SH, NP).
const VOICE_DETAIL_NAMES: Array[String] = ["穹", "瑛", "奈绪", "一叶", "初佳", "亮平", "やひろ", "梢", "隆之", "繁治", "NPC"]
const VOICE_DETAIL_IDS: Array[String] = ["SR", "AK", "NO", "KA", "MT", "RH", "YH", "KO", "YM", "SH", "NP"]
## 個別音声 sample files by detail index; played after the per-character volume slider drag ends.
const VOICE_SAMPLE_FILES: Array[String] = [
	"SR000029", "AK000006", "NO000009", "KA000054", "MT000006", "RH000003", "YH000005", "KO000004", "YM000002", "SH040002", "NP210001",
]
## Schema 2 stored nine entries in UI order (穹/奈绪/瑛/.../NPC); map old index to the source VCID index.
const LEGACY_VOICE_DETAIL_REMAP: Array[int] = [0, 2, 1, 3, 4, 5, 6, 7, 10]


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
		# Match System.tjs defaults; these are linear bus gains, not decibels.
		"bgm_volume": 0.5,
		"env_se_volume": 0.7,
		"se_volume": 0.7,
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
		"window_depth": 50,
		"font_type": 0,
		"portrait_visible": true,
		"read_color": true,
		"screen_effect": true,
		# Keep the source CONFIG.readSkip polarity: 1 means the HD "允许跳过未读文本"
		# switch is off; ConfigSystemPage translates this to its YES/NO artwork.
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
	result["voice_detail_volumes"] = _voice_detail_array(raw.get("voice_detail_volumes", []))
	if raw.has("window_opacity") and not raw.has("window_depth"):
		result["window_depth"] = clampi(roundi(float(raw["window_opacity"]) * 100.0), 0, 100)
	result.erase("window_opacity")
	if int(raw.get("schema_version", 0)) < 3:
		if raw.has("message_speed"):
			var legacy_speed: Variant = raw["message_speed"]
			if legacy_speed is float and legacy_speed <= 10.0:
				result["message_speed"] = clampi(int(legacy_speed * 10.0), 0, 100)
			elif legacy_speed is int and legacy_speed <= 10:
				result["message_speed"] = clampi(legacy_speed * 10, 0, 100)
	result["window_depth"] = clampi(int(result.get("window_depth", 50)), 0, 100)
	var requested_width := clampi(int(result.get("window_width", 1280)), 1280, 1920)
	result["window_width"] = 1920 if requested_width >= WINDOW_WIDTH_1080P_MIN else (1600 if requested_width >= WINDOW_WIDTH_900P_MIN else 1280)
	result["font_type"] = clampi(int(result.get("font_type", 0)), 0, 5)
	# The HD source exposes only Window and Fullscreen. Keep old prototype
	# values readable, but do not persist an unsupported third mode as if it
	# were a user-facing setting.
	result["window_mode"] = "fullscreen" if str(result.get("window_mode", "windowed")) == "fullscreen" else "windowed"
	result["message_speed"] = clampi(int(result.get("message_speed", 5)), 0, 100)
	result["auto_speed"] = clampi(int(result.get("auto_speed", 5000)), 0, 10000)
	for key in [
		"mute_master", "mute_voice", "mute_bgm", "mute_env_se", "mute_se", "mute_movie", "mute_system_voice",
		"portrait_visible", "read_color", "screen_effect", "read_skip", "voice_stop_on_click", "lock_skip", "lock_auto", "route_guide",
	]:
		result[key] = bool(result.get(key, false))
	for key in ["master_volume", "voice_volume", "bgm_volume", "env_se_volume", "se_volume", "movie_volume", "system_voice_volume"]:
		result[key] = clampf(float(result.get(key, 1.0)), 0.0, 1.0)
	var normalized_confirmations: Dictionary = {}
	var source_confirmations: Variant = result.get("confirmations", {})
	for key in CONFIRMATION_KEYS:
		normalized_confirmations[key] = bool(source_confirmations.get(key, true)) if source_confirmations is Dictionary else true
	result["confirmations"] = normalized_confirmations
	return result


static func _voice_detail_array(value: Variant) -> Array[float]:
	var source: Array[float] = []
	if value is Array:
		for item in value:
			source.append(clampf(float(item), 0.0, 1.0))
	var result: Array[float] = []
	if source.size() == 9:
		for _index in VOICE_DETAIL_NAMES.size():
			result.append(1.0)
		for old_index in source.size():
			var new_index := LEGACY_VOICE_DETAIL_REMAP[old_index]
			if new_index < result.size():
				result[new_index] = source[old_index]
		return result
	for index in VOICE_DETAIL_NAMES.size():
		result.append(source[index] if index < source.size() else 1.0)
	return result
