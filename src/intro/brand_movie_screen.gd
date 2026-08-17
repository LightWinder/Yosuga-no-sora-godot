class_name BrandMovieScreen
extends Control


signal finished
signal brand_call_requested

@export_range(0.0, 10.0, 0.1) var brand_call_delay_seconds := 1.5
@export_range(1.0, 15.0, 0.1) var playback_watchdog_seconds := 6.5

@onready var _video: VideoStreamPlayer = $Video
@onready var _brand_call_timer: Timer = $BrandCallTimer
@onready var _playback_watchdog: Timer = $PlaybackWatchdog

var _is_finished := false


func _ready() -> void:
	_video.finished.connect(_finish)
	_brand_call_timer.timeout.connect(_request_brand_call)
	_playback_watchdog.timeout.connect(_finish)

	_brand_call_timer.start(brand_call_delay_seconds)
	_playback_watchdog.start(playback_watchdog_seconds)
	call_deferred("_start_playback")


func _exit_tree() -> void:
	set_process_input(false)
	_brand_call_timer.stop()
	_playback_watchdog.stop()
	_video.stop()


func _input(event: InputEvent) -> void:
	if _is_finished or not StartupInput.is_advance_event(event):
		return

	get_viewport().set_input_as_handled()
	_finish()


func _start_playback() -> void:
	if _video.stream == null:
		push_warning("Brand movie is unavailable; continuing to the warning screen.")
		_finish()
		return

	_video.play()
	await get_tree().process_frame
	if not _video.is_playing():
		push_warning("Brand movie could not start; continuing to the warning screen.")
		_finish()


func _request_brand_call() -> void:
	if not _is_finished:
		brand_call_requested.emit()


func _finish() -> void:
	if _is_finished:
		return

	_is_finished = true
	set_process_input(false)
	_brand_call_timer.stop()
	_playback_watchdog.stop()
	_video.stop()
	finished.emit()
