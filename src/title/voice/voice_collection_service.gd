class_name VoiceCollectionService
extends Node


signal favorites_changed(favorites: Array[VoiceFavorite])
signal playback_changed(favorite_id: String, playing: bool)
signal save_jump_requested(request: ScenarioLaunchRequest)

const DEFAULT_PATH := "user://voice_favorites.json"
const SCHEMA_VERSION := 1

var last_error: String = ""
var _storage_path := DEFAULT_PATH
var _favorites: Array[VoiceFavorite] = []
var _player: AudioStreamPlayer


func configure_storage(path: String) -> void:
	if path.is_empty():
		last_error = "语音收藏路径不能为空。"
		return
	_storage_path = path
	_favorites.clear()
	_load()


func _ready() -> void:
	_load()
	_player = AudioStreamPlayer.new()
	_player.name = "VoiceFavoritePlayer"
	_player.bus = &"Voice"
	add_child(_player)
	_player.finished.connect(_on_playback_finished)


func list_favorites() -> Array[VoiceFavorite]:
	return _favorites.duplicate()


func count() -> int:
	return _favorites.size()


func add_favorite(favorite: VoiceFavorite) -> bool:
	if favorite == null or favorite.favorite_id.is_empty() or favorite.voice_path.is_empty():
		last_error = "语音收藏缺少唯一 ID 或音频路径。"
		return false
	for existing in _favorites:
		if existing.favorite_id == favorite.favorite_id or existing.voice_path == favorite.voice_path:
			return false
	_favorites.append(favorite)
	if not _save():
		_favorites.pop_back()
		return false
	favorites_changed.emit(list_favorites())
	return true


func remove_favorite(favorite_id: String) -> bool:
	for index in _favorites.size():
		if _favorites[index].favorite_id != favorite_id:
			continue
		_favorites.remove_at(index)
		if not _save():
			_load()
			return false
		if _player != null and _player.playing:
			_player.stop()
		favorites_changed.emit(list_favorites())
		return true
	return false


func clear() -> bool:
	var previous := _favorites.duplicate()
	_favorites.clear()
	if not _save():
		_favorites = previous
		return false
	favorites_changed.emit(list_favorites())
	return true


func restore_backup() -> bool:
	var global_path := ProjectSettings.globalize_path(_storage_path)
	var backup_path := "%s.bak" % global_path
	if not FileAccess.file_exists(backup_path):
		last_error = "没有可恢复的语音收藏备份。"
		return false
	var temporary_path := "%s.restore.tmp" % global_path
	if FileAccess.file_exists(temporary_path):
		DirAccess.remove_absolute(temporary_path)
	if FileAccess.file_exists(global_path):
		var stage_error := DirAccess.rename_absolute(global_path, temporary_path)
		if stage_error != OK:
			last_error = "无法暂存当前语音收藏：%s" % error_string(stage_error)
			return false
	var restore_error := DirAccess.rename_absolute(backup_path, global_path)
	if restore_error != OK:
		if FileAccess.file_exists(temporary_path) and not FileAccess.file_exists(global_path):
			DirAccess.rename_absolute(temporary_path, global_path)
		last_error = "无法恢复语音收藏备份：%s" % error_string(restore_error)
		return false
	if FileAccess.file_exists(temporary_path):
		DirAccess.rename_absolute(temporary_path, backup_path)
	_load()
	favorites_changed.emit(list_favorites())
	return true


func play_favorite(favorite_id: String) -> bool:
	if _player == null:
		return false
	var favorite := _find(favorite_id)
	if favorite == null or not ResourceLoader.exists(favorite.voice_path):
		last_error = "语音资源不存在：%s" % (favorite.voice_path if favorite != null else favorite_id)
		return false
	var stream := load(favorite.voice_path) as AudioStream
	if stream == null:
		last_error = "无法加载语音资源：%s" % favorite.voice_path
		return false
	_player.stream = stream
	_player.play()
	playback_changed.emit(favorite_id, true)
	return true


func stop() -> void:
	if _player != null and _player.playing:
		_player.stop()
		playback_changed.emit("", false)


func build_save_jump_request(favorite_id: String) -> ScenarioLaunchRequest:
	var favorite := _find(favorite_id)
	if favorite == null or favorite.save_path.is_empty():
		return null
	var request := ScenarioLaunchRequest.new()
	request.kind = ScenarioLaunchRequest.RequestKind.CONTINUE
	request.save_path = favorite.save_path
	request.availability_message = "语音收藏的存档跳转等待正文运行层。"
	save_jump_requested.emit(request)
	return request


func _find(favorite_id: String) -> VoiceFavorite:
	for favorite in _favorites:
		if favorite.favorite_id == favorite_id:
			return favorite
	return null


func _load() -> void:
	last_error = ""
	_favorites.clear()
	if not FileAccess.file_exists(_storage_path):
		return
	var file := FileAccess.open(_storage_path, FileAccess.READ)
	if file == null:
		last_error = "无法读取语音收藏。"
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or int((parsed as Dictionary).get("schema_version", 0)) > SCHEMA_VERSION:
		last_error = "语音收藏 schema 无法迁移。"
		return
	var raw_items: Variant = (parsed as Dictionary).get("favorites", [])
	if raw_items is Array:
		for raw in raw_items:
			if raw is Dictionary:
				var favorite := VoiceFavorite.from_dictionary(raw as Dictionary)
				if favorite.favorite_id.is_empty() or favorite.voice_path.is_empty():
					continue
				if _find(favorite.favorite_id) == null:
					_favorites.append(favorite)


func _save() -> bool:
	last_error = ""
	var global_path := ProjectSettings.globalize_path(_storage_path)
	var directory := global_path.get_base_dir()
	var make_error := DirAccess.make_dir_recursive_absolute(directory)
	if make_error != OK and make_error != ERR_ALREADY_EXISTS:
		last_error = "无法创建语音收藏目录：%s" % error_string(make_error)
		return false
	var temporary_path := "%s.tmp" % global_path
	var backup_path := "%s.bak" % global_path
	var previous_backup_path := "%s.previous" % backup_path
	var payload: Array[Dictionary] = []
	for favorite in _favorites:
		payload.append(favorite.to_dictionary())
	var payload_text := JSON.stringify({"schema_version": SCHEMA_VERSION, "favorites": payload}, "\t", false)
	var verify_payload: Variant = JSON.parse_string(payload_text)
	if not verify_payload is Dictionary:
		last_error = "语音收藏序列化校验失败。"
		return false
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		last_error = "无法写入语音收藏临时文件。"
		return false
	file.store_string(payload_text)
	file.flush()
	file.close()
	if FileAccess.file_exists(previous_backup_path):
		var clear_previous_error := DirAccess.remove_absolute(previous_backup_path)
		if clear_previous_error != OK:
			last_error = "无法清理语音收藏备份暂存文件：%s" % error_string(clear_previous_error)
			return false
	var staged_old_backup := false
	if FileAccess.file_exists(backup_path) and FileAccess.file_exists(global_path):
		var stage_backup_error := DirAccess.rename_absolute(backup_path, previous_backup_path)
		if stage_backup_error != OK:
			last_error = "无法暂存既有语音收藏备份：%s" % error_string(stage_backup_error)
			return false
		staged_old_backup = true
	if FileAccess.file_exists(global_path):
		var backup_error := DirAccess.rename_absolute(global_path, backup_path)
		if backup_error != OK:
			if staged_old_backup:
				DirAccess.rename_absolute(previous_backup_path, backup_path)
			last_error = "无法保护既有语音收藏：%s" % error_string(backup_error)
			return false
	var rename_error := DirAccess.rename_absolute(temporary_path, global_path)
	if rename_error != OK:
		if FileAccess.file_exists(backup_path) and not FileAccess.file_exists(global_path):
			DirAccess.rename_absolute(backup_path, global_path)
		if staged_old_backup and not FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(previous_backup_path, backup_path)
		last_error = "无法替换语音收藏文件：%s" % error_string(rename_error)
		return false
	if staged_old_backup and FileAccess.file_exists(previous_backup_path):
		DirAccess.remove_absolute(previous_backup_path)
	return true


func _on_playback_finished() -> void:
	playback_changed.emit("", false)
