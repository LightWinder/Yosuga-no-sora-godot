class_name TitleMusicPage
extends DesignCanvasPage


signal content_requested(request: TitleContentRequest)
signal status_changed(message: String)

var _manifest: TitleContentManifest
var _selected: TitleMusicTrack
var _playing := false

@onready var _track_list: GridContainer = %TrackList
@onready var _status: Label = %Status
@onready var _player: AudioStreamPlayer = %MusicAppreciationPlayer
@onready var _stop_button: Button = %StopPlayback


func configure(manifest: TitleContentManifest) -> void:
	_manifest = manifest
	if is_inside_tree():
		_refresh()


func _ready() -> void:
	super._ready()
	_player.finished.connect(_on_finished)
	_stop_button.pressed.connect(stop)
	_refresh()


func track_count() -> int:
	return _manifest.music_tracks.size() if _manifest != null else 0


func is_playing() -> bool:
	return _playing and _player != null and _player.playing


func selected_track() -> TitleMusicTrack:
	return _selected


func select_track(index: int) -> bool:
	if _manifest == null or index < 0 or index >= _manifest.music_tracks.size():
		return false
	_select_track(_manifest.music_tracks[index])
	return is_playing()


func stop() -> void:
	if _player != null:
		_player.stop()
		_player.stream = null
		_playing = false
		_status.text = "音乐已停止。"


func _exit_tree() -> void:
	if _player != null:
		_player.stop()
		# Do not leave a duplicated Ogg stream/playback graph referenced while
		# switching away from the Music page.  This matters in long-running
		# title sessions and keeps headless contract tests leak-free as well.
		_player.stream = null
	_playing = false
	_selected = null


func _refresh() -> void:
	if _manifest == null or _track_list == null:
		return
	for child in _track_list.get_children():
		_track_list.remove_child(child)
		child.queue_free()
	for index in _manifest.music_tracks.size():
		var track := _manifest.music_tracks[index]
		var button := TitleMusicButton.new()
		button.name = "Track_%s" % str(track.track_id).validate_node_name()
		button.configure("res://assets/content/appreciation/track_%02d.png" % (index + 1), "res://assets/content/appreciation/bgm_hitbox.png")
		button.set_design_size(Vector2(460.0, 67.0))
		button.tooltip_text = "%s · %s" % [track.track_id, track.title_id]
		button.pressed.connect(_select_track.bind(track))
		_track_list.add_child(button)
	_status.text = "清单：%d 首；BGM03–BGM21 使用源 .sli 的循环起点，BGM01/BGM02_S 整首播放。" % _manifest.music_tracks.size()


func _select_track(track: TitleMusicTrack) -> void:
	_selected = track
	if _player != null:
		# Explicitly tear down the previous playback before replacing its stream;
		# assigning a new stream alone can leave an Ogg playback object alive
		# until process shutdown on Godot 4.7.
		_player.stop()
		_player.stream = null
	if not ResourceLoader.exists(track.stream_path):
		_playing = false
		_status.text = "缺少音乐资源：%s" % track.stream_path
		return
	var stream := load(track.stream_path) as AudioStreamOggVorbis
	if stream == null:
		_status.text = "无法加载音乐资源：%s" % track.stream_path
		return
	# Imported Ogg resources are cached by Godot.  Reusing that resource avoids
	# duplicate packet-sequence graphs (which otherwise survive page teardown on
	# 4.7) while the player still guarantees only one track is active.
	stream.loop = track.loop_enabled
	stream.loop_offset = track.loop_offset_seconds()
	_player.stream = stream
	_player.play()
	_playing = true
	_status.text = "正在播放：%s（%s）" % [track.track_id, "循环" if track.loop_enabled else "整首"]
	content_requested.emit(TitleContentRequest.for_music(track))
	status_changed.emit(_status.text)


func _on_finished() -> void:
	if _selected == null or not _selected.loop_enabled:
		_playing = false
	status_changed.emit("音乐播放结束。" if not _playing else "")
