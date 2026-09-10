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
var _store := AtomicJsonStore.new()


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
	last_error = ""
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
	if not _store.restore_backup(_storage_path):
		last_error = "无法恢复语音收藏备份：%s" % _store.last_error
		return false
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
	var parsed := _store.read_dictionary(_storage_path)
	if not _store.last_error.is_empty():
		last_error = "无法读取语音收藏：%s" % _store.last_error
		return
	if parsed.is_empty():
		return
	if int(parsed.get("schema_version", 0)) > SCHEMA_VERSION:
		last_error = "语音收藏 schema 无法迁移。"
		return
	var raw_items: Variant = parsed.get("favorites", [])
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
	var payload: Array[Dictionary] = []
	for favorite in _favorites:
		payload.append(favorite.to_dictionary())
	if _store.write_dictionary_atomic(
		_storage_path,
		{"schema_version": SCHEMA_VERSION, "favorites": payload}
	):
		return true
	last_error = "无法保存语音收藏：%s" % _store.last_error
	return false


func _on_playback_finished() -> void:
	playback_changed.emit("", false)
