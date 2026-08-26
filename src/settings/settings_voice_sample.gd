class_name SettingsVoiceSample
extends Node


## Plays 個別音声 sample lines through the Voice bus.  Bus volumes (master,
## voice) already apply, so the player only needs the per-character detail
## volume, mirroring source sample volume = master * voice * detail.
const SAMPLE_FILES: Array[String] = [
	"res://assets/audio/voice_samples/SR000029.ogg",
	"res://assets/audio/voice_samples/AK000006.ogg",
	"res://assets/audio/voice_samples/NO000009.ogg",
	"res://assets/audio/voice_samples/KA000054.ogg",
	"res://assets/audio/voice_samples/MT000006.ogg",
	"res://assets/audio/voice_samples/RH000003.ogg",
	"res://assets/audio/voice_samples/YH000005.ogg",
	"res://assets/audio/voice_samples/KO000004.ogg",
	"res://assets/audio/voice_samples/YM000002.ogg",
	"res://assets/audio/voice_samples/SH040002.ogg",
	"res://assets/audio/voice_samples/NP210001.ogg",
]

var _player: AudioStreamPlayer
var _streams: Dictionary = {}


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "VoiceSamplePlayer"
	_player.bus = &"Voice"
	add_child(_player)


func play_detail(detail_index: int, detail_volume: float) -> void:
	if detail_index < 0 or detail_index >= SAMPLE_FILES.size():
		return
	var stream: AudioStream = _streams.get(detail_index)
	if stream == null:
		stream = load(SAMPLE_FILES[detail_index]) as AudioStream
		if stream == null:
			return
		_streams[detail_index] = stream
	_player.volume_db = linear_to_db(clampf(detail_volume, 0.0, 1.0))
	_player.stream = stream
	_player.play()


func stop() -> void:
	if _player != null:
		_player.stop()
