class_name ContentWarningScreen
extends Control


signal finished

enum Phase {
	FADING_IN,
	HOLDING,
	FAST_HOLDING,
	FADING_TO_WHITE,
	DONE,
}

@export_range(0.0, 5.0, 0.1) var fade_in_seconds := 1.0
@export_range(0.0, 20.0, 0.1) var hold_seconds := 8.0
@export_range(0.0, 10.0, 0.1) var fast_hold_seconds := 4.0
@export_range(0.0, 5.0, 0.1) var fade_to_white_seconds := 1.0

@onready var _content: Control = $Content
@onready var _white_cover: ColorRect = $WhiteCover
@onready var _hold_timer: Timer = $HoldTimer

var _phase := Phase.FADING_IN
var _active_tween: Tween


func _ready() -> void:
	_hold_timer.timeout.connect(_begin_white_fade)
	_set_content_alpha(0.0)
	_set_cover_alpha(0.0)
	_begin_fade_in()


func _exit_tree() -> void:
	_cancel_pending_transition()


func _input(event: InputEvent) -> void:
	if not StartupInput.is_advance_event(event):
		return

	get_viewport().set_input_as_handled()
	match _phase:
		Phase.FADING_IN, Phase.HOLDING:
			_cancel_pending_transition()
			_set_content_alpha(1.0)
			_phase = Phase.FAST_HOLDING
			_hold_timer.start(fast_hold_seconds)
		Phase.FAST_HOLDING:
			_begin_white_fade()
		Phase.FADING_TO_WHITE:
			_complete()


func _begin_fade_in() -> void:
	_phase = Phase.FADING_IN
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(_content, "modulate:a", 1.0, fade_in_seconds)
	_active_tween.finished.connect(_begin_standard_hold, CONNECT_ONE_SHOT)


func _begin_standard_hold() -> void:
	_active_tween = null
	if _phase != Phase.FADING_IN:
		return

	_phase = Phase.HOLDING
	_hold_timer.start(hold_seconds)


func _begin_white_fade() -> void:
	if _phase == Phase.DONE:
		return

	_cancel_pending_transition()
	_phase = Phase.FADING_TO_WHITE
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(_white_cover, "color:a", 1.0, fade_to_white_seconds)
	_active_tween.finished.connect(_complete, CONNECT_ONE_SHOT)


func _complete() -> void:
	if _phase == Phase.DONE:
		return

	_cancel_pending_transition()
	_phase = Phase.DONE
	set_process_input(false)
	_set_cover_alpha(1.0)
	finished.emit()


func _cancel_pending_transition() -> void:
	_hold_timer.stop()
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null


func _set_content_alpha(alpha: float) -> void:
	var color := _content.modulate
	color.a = alpha
	_content.modulate = color


func _set_cover_alpha(alpha: float) -> void:
	var color := _white_cover.color
	color.a = alpha
	_white_cover.color = color
