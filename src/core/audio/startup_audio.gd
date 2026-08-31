class_name StartupAudio
extends Node


const TITLE_LOOP_OFFSET_SECONDS := 161922.0 / 44100.0
const TITLE_BGM: AudioStreamOggVorbis = preload("res://assets/audio/bgm/BGM07_title.ogg")

const BRAND_CALLS: Array[AudioStream] = [
	preload("res://assets/audio/system_voice/SR080001.ogg"),
	preload("res://assets/audio/system_voice/AK080001.ogg"),
	preload("res://assets/audio/system_voice/NO080001.ogg"),
	preload("res://assets/audio/system_voice/KA080001.ogg"),
	preload("res://assets/audio/system_voice/MT080001.ogg"),
	preload("res://assets/audio/system_voice/RH080001.ogg"),
	preload("res://assets/audio/system_voice/YH080001.ogg"),
	preload("res://assets/audio/system_voice/KO080001.ogg"),
]

const TITLE_CALLS: Array[AudioStream] = [
	preload("res://assets/audio/system_voice/SR080002.ogg"),
	preload("res://assets/audio/system_voice/AK080002.ogg"),
	preload("res://assets/audio/system_voice/NO080002.ogg"),
	preload("res://assets/audio/system_voice/KA080002.ogg"),
	preload("res://assets/audio/system_voice/MT080002.ogg"),
	preload("res://assets/audio/system_voice/RH080002.ogg"),
	preload("res://assets/audio/system_voice/YH080002.ogg"),
	preload("res://assets/audio/system_voice/KO080002.ogg"),
]

@onready var _bgm_player: AudioStreamPlayer = $BgmPlayer
@onready var _voice_player: AudioStreamPlayer = $VoicePlayer

var _random := RandomNumberGenerator.new()
var _system_voice_muted := false
var _settings_applier := AudioSettingsApplier.new()
var _bgm_fade_tween: Tween


func _ready() -> void:
	_random.randomize()


func play_random_brand_call() -> void:
	_play_random_voice(BRAND_CALLS)


func play_random_title_call() -> void:
	_play_random_voice(TITLE_CALLS)


func play_title_bgm() -> void:
	if _bgm_player.playing and (_bgm_fade_tween == null or not _bgm_fade_tween.is_valid()):
		return
	_kill_bgm_fade()
	_bgm_player.stop()
	_bgm_player.volume_db = 0.0

	var stream := TITLE_BGM.duplicate() as AudioStreamOggVorbis
	stream.loop = true
	stream.loop_offset = TITLE_LOOP_OFFSET_SECONDS
	_bgm_player.stream = stream
	_bgm_player.play()


## The source Title lets BGM07 outlive its three-second visual departure and
## completes this fade after five seconds while ADV is already active.
func fade_out_title_bgm(fade_milliseconds: int = 5000) -> void:
	if not _bgm_player.playing:
		return
	_kill_bgm_fade()
	if fade_milliseconds <= 0:
		_stop_title_bgm_now()
		return
	var tween := create_tween()
	_bgm_fade_tween = tween
	tween.tween_property(
		_bgm_player,
		"volume_db",
		-80.0,
		float(fade_milliseconds) / 1000.0
	)
	tween.finished.connect(
		func() -> void:
			if _bgm_fade_tween != tween:
				return
			_bgm_fade_tween = null
			_stop_title_bgm_now()
	)


func stop_all() -> void:
	_kill_bgm_fade()
	_stop_title_bgm_now()
	_voice_player.stop()
	_voice_player.stream = null


func apply_settings(settings: Dictionary) -> void:
	# StartupFlow is the single runtime owner for persisted and previewed audio
	# settings. Apply every declared bus here; configuration pages only emit
	# values and never mutate AudioServer directly.
	_settings_applier.apply(settings)
	_system_voice_muted = bool(settings.get("mute_system_voice", false))


func _play_random_voice(streams: Array[AudioStream]) -> void:
	if streams.is_empty() or _system_voice_muted:
		return

	_voice_player.stop()
	_voice_player.stream = streams[_random.randi_range(0, streams.size() - 1)]
	_voice_player.play()


func _kill_bgm_fade() -> void:
	if _bgm_fade_tween != null and _bgm_fade_tween.is_valid():
		_bgm_fade_tween.kill()
	_bgm_fade_tween = null


func _stop_title_bgm_now() -> void:
	_bgm_player.stop()
	_bgm_player.stream = null
	_bgm_player.volume_db = 0.0
