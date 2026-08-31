class_name AdvAssetResolver
extends RefCounted


const EVENT_DIRECTORIES: Array[String] = [
	"res://assets/content/event_1920",
	"res://assets/content/adv/backgrounds",
]
const CHARACTER_DIRECTORIES: Array[String] = [
	"res://assets/content/adv/characters",
]
const BGM_DIRECTORIES: Array[String] = [
	"res://assets/audio/bgm",
]
const VOICE_DIRECTORIES: Array[String] = [
	"res://assets/audio/adv/voice",
]
const EFFECT_DIRECTORIES: Array[String] = [
	"res://assets/audio/adv/effects",
]
const RULE_DIRECTORIES: Array[String] = [
	"res://assets/content/adv/rules",
]
const VIDEO_DIRECTORIES: Array[String] = [
	"res://assets/video",
]

var _event_paths: Dictionary = {}
var _character_paths: Dictionary = {}
var _bgm_paths: Dictionary = {}
var _voice_paths: Dictionary = {}
var _effect_paths: Dictionary = {}
var _rule_paths: Dictionary = {}
var _video_paths: Dictionary = {}


func rebuild() -> void:
	_event_paths = _index_directories(EVENT_DIRECTORIES, ["png", "jpg", "jpeg", "webp"])
	_character_paths = _index_directories(CHARACTER_DIRECTORIES, ["png", "jpg", "jpeg", "webp"])
	_bgm_paths = _index_directories(BGM_DIRECTORIES, ["ogg", "wav", "mp3"])
	_voice_paths = _index_directories(VOICE_DIRECTORIES, ["ogg", "wav", "mp3"])
	_effect_paths = _index_directories(EFFECT_DIRECTORIES, ["ogg", "wav", "mp3"])
	_rule_paths = _index_directories(RULE_DIRECTORIES, ["png", "jpg", "jpeg", "webp"])
	_video_paths = _index_directories(VIDEO_DIRECTORIES, ["ogv"])


func texture_for_cg(resource_id: String) -> Texture2D:
	_ensure_catalog()
	return _load_texture(_event_paths, resource_id)


func path_for_cg(resource_id: String) -> String:
	_ensure_catalog()
	return _path_for(_event_paths, resource_id)


func texture_for_character(resource_id: String) -> Texture2D:
	_ensure_catalog()
	return _load_texture(_character_paths, resource_id)


func path_for_character(resource_id: String) -> String:
	_ensure_catalog()
	return _path_for(_character_paths, resource_id)


func stream_for_bgm(resource_id: String) -> AudioStream:
	_ensure_catalog()
	return _load_audio(_bgm_paths, resource_id)


func path_for_bgm(resource_id: String) -> String:
	_ensure_catalog()
	return _path_for(_bgm_paths, resource_id)


func stream_for_voice(resource_id: String) -> AudioStream:
	_ensure_catalog()
	return _load_audio(_voice_paths, resource_id)


func path_for_voice(resource_id: String) -> String:
	_ensure_catalog()
	return _path_for(_voice_paths, resource_id)


func stream_for_effect(resource_id: String) -> AudioStream:
	_ensure_catalog()
	return _load_audio(_effect_paths, resource_id)


func path_for_effect(resource_id: String) -> String:
	_ensure_catalog()
	return _path_for(_effect_paths, resource_id)


func texture_for_rule(resource_id: String) -> Texture2D:
	_ensure_catalog()
	return _load_texture(_rule_paths, resource_id)


func path_for_rule(resource_id: String) -> String:
	_ensure_catalog()
	return _path_for(_rule_paths, resource_id)


func path_for_video(resource_id: String) -> String:
	_ensure_catalog()
	return _path_for(_video_paths, resource_id)


func _ensure_catalog() -> void:
	if _event_paths.is_empty() and _character_paths.is_empty():
		rebuild()


func _index_directories(directories: Array[String], extensions: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	for directory_path in directories:
		var directory := DirAccess.open(directory_path)
		if directory == null:
			continue
		for file_name in directory.get_files():
			if not extensions.has(file_name.get_extension().to_lower()):
				continue
			var path := "%s/%s" % [directory_path, file_name]
			var file_key := file_name.to_lower()
			var basename_key := file_name.get_basename().to_lower()
			if not result.has(file_key):
				result[file_key] = path
			if not result.has(basename_key):
				result[basename_key] = path
	return result


func _normalized_key(resource_id: String) -> String:
	return resource_id.strip_edges().get_file().to_lower()


func _path_for(catalog: Dictionary, resource_id: String) -> String:
	var key := _normalized_key(resource_id)
	if catalog.has(key):
		return str(catalog[key])
	return str(catalog.get(key.get_basename(), ""))


func _load_texture(catalog: Dictionary, resource_id: String) -> Texture2D:
	var path := _path_for(catalog, resource_id)
	return ResourceLoader.load(path, "Texture2D") as Texture2D if not path.is_empty() else null


func _load_audio(catalog: Dictionary, resource_id: String) -> AudioStream:
	var path := _path_for(catalog, resource_id)
	return ResourceLoader.load(path, "AudioStream") as AudioStream if not path.is_empty() else null
