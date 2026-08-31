class_name AdvDialogueView
extends Control
## Dialogue presentation only. Callers supply resolved assets and decide when
## to advance, hide chrome, or restore a saved frame.


signal hide_requested
signal frame_gui_input(event: InputEvent)
signal reveal_finished

const HIDE_OFFSET := Vector2(0.0, 120.0)

@onready var _message_panel: PanelContainer = %MessagePanel
@onready var _speaker_label: Label = %SpeakerLabel
@onready var _speaker_name_image: TextureRect = %SpeakerNameImage
@onready var _message_label: RichTextLabel = %MessageLabel
@onready var _portrait: TextureRect = %Portrait
@onready var _hide_button: TextureButton = %MessageHideButton
@onready var _message_focus_mode := _message_label.focus_mode
@onready var _message_scrollbar: VScrollBar = _message_label.get_v_scroll_bar()
@onready var _scrollbar_focus_mode := _message_scrollbar.focus_mode
@onready var _scrollbar_mouse_filter := _message_scrollbar.mouse_filter

var _frame_style: StyleBoxTexture
var _interactive := true
var _reveal_tween: Tween
var _revealing := false
var _milliseconds_per_character := 5
var _reveal_progress := 0.0
var _frame_tween: Tween
var _frame_finish: Callable
var _rest_position := Vector2.ZERO
var _rest_modulate := Color.WHITE


func _ready() -> void:
	# Only the frame texture fades with window_depth, not its text/portrait.
	# Never modify the shared Theme used by another game or preview instance.
	_frame_style = _message_panel.get_theme_stylebox("panel").duplicate() as StyleBoxTexture
	_message_panel.add_theme_stylebox_override("panel", _frame_style)
	_rest_position = _message_panel.position
	_rest_modulate = _message_panel.modulate
	_hide_button.pressed.connect(_on_hide_pressed)
	_message_panel.gui_input.connect(_on_frame_gui_input)


func _exit_tree() -> void:
	cancel_reveal()
	_cancel_frame_transition()


func set_interactive(enabled: bool) -> void:
	_interactive = enabled
	_hide_button.disabled = not enabled
	_hide_button.focus_mode = Control.FOCUS_CLICK if enabled else Control.FOCUS_NONE
	_hide_button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	_message_panel.mouse_filter = Control.MOUSE_FILTER_PASS if enabled else Control.MOUSE_FILTER_IGNORE
	(%MessageColumn as Control).mouse_filter = _message_panel.mouse_filter
	_speaker_label.mouse_filter = _message_panel.mouse_filter
	# RichTextLabel owns an internal scrollbar even when scrolling is disabled.
	_message_label.focus_mode = _message_focus_mode if enabled else Control.FOCUS_NONE
	_message_scrollbar.focus_mode = _scrollbar_focus_mode if enabled else Control.FOCUS_NONE
	_message_scrollbar.mouse_filter = _scrollbar_mouse_filter if enabled else Control.MOUSE_FILTER_IGNORE


func _on_hide_pressed() -> void:
	if _interactive:
		hide_requested.emit()


func _on_frame_gui_input(event: InputEvent) -> void:
	if _interactive:
		# Forward without interpreting advance/cancel or accepting unrelated input.
		frame_gui_input.emit(event)


func set_speaker(text: String, texture: Texture2D, show_name: bool) -> void:
	_speaker_label.text = text
	_speaker_label.visible = show_name and texture == null
	_speaker_name_image.texture = texture
	_speaker_name_image.visible = show_name and texture != null


func set_portrait(texture: Texture2D) -> void:
	_portrait.texture = texture
	_portrait.visible = texture != null


func set_message_font_size(font_size: int) -> void:
	_message_label.add_theme_font_size_override("normal_font_size", font_size)


func set_message_font(font: Font) -> void:
	_message_label.add_theme_font_override("normal_font", font)


func set_message_color(color: Color) -> void:
	_message_label.add_theme_color_override("default_color", color)


func set_frame_opacity(alpha: float) -> void:
	_frame_style.modulate_color.a = clampf(alpha, 0.0, 1.0)


## Replace the line fully revealed without completing the previous animation.
func set_message(text: String) -> void:
	cancel_reveal()
	_message_label.text = text
	_message_label.visible_characters = -1


func reveal_message(text: String, milliseconds_per_character: int) -> void:
	set_message(text)
	_milliseconds_per_character = maxi(milliseconds_per_character, 0)
	_reveal_progress = 0.0
	_message_label.visible_characters = 0
	_revealing = true
	_continue_reveal()


func set_reveal_speed(milliseconds_per_character: int) -> void:
	var speed := maxi(milliseconds_per_character, 0)
	if speed == _milliseconds_per_character:
		return
	_milliseconds_per_character = speed
	if _revealing:
		_kill_reveal_tween()
		_continue_reveal()


func _continue_reveal() -> void:
	var count := _message_label.get_total_character_count()
	if count <= _reveal_progress:
		finish_reveal()
		return
	var duration := 0.001 if _milliseconds_per_character == 0 else maxf(
		(float(count) - _reveal_progress) * float(_milliseconds_per_character) / 1000.0, 0.01
	)
	_reveal_tween = create_tween()
	_reveal_tween.tween_method(_set_reveal_progress, _reveal_progress, float(count), duration)
	_reveal_tween.finished.connect(finish_reveal)


func _set_reveal_progress(value: float) -> void:
	_reveal_progress = value
	_message_label.visible_characters = roundi(value)


func is_revealing() -> bool:
	return _revealing


func finish_reveal() -> void:
	var was_revealing := _revealing
	cancel_reveal()
	_message_label.visible_characters = -1
	if was_revealing:
		reveal_finished.emit()


## Freeze presentation without emitting completion or advancing caller flow.
func cancel_reveal() -> void:
	_kill_reveal_tween()
	_revealing = false


func _kill_reveal_tween() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_reveal_tween = null


func frame_position() -> Vector2:
	return _message_panel.position


func frame_alpha() -> float:
	return _message_panel.modulate.a


func is_frame_visible() -> bool:
	return _message_panel.visible


func set_frame_position(value: Vector2) -> void:
	# A permanent move replaces the resting position, never an animation offset.
	_cancel_frame_transition()
	_rest_position = value
	_message_panel.position = value
	_message_panel.modulate = _rest_modulate


## Change only the display flag, preserving a scenario fade's current alpha.
func set_frame_displayed(value: bool) -> void:
	_message_panel.visible = value


func restore_frame_state(frame_position_value: Vector2, alpha: float, visible_value: bool) -> void:
	_cancel_frame_transition()
	_message_panel.position = frame_position_value
	_message_panel.modulate.a = alpha
	_message_panel.visible = visible_value
	_rest_position = _message_panel.position
	_rest_modulate = _message_panel.modulate


func apply_frame_type(frame_type: String) -> void:
	if frame_type == "10" or frame_type == "ノベル":
		set_frame_position(Vector2.ZERO)
		_message_panel.size = Vector2(1920.0, 1080.0)
	else:
		set_frame_position(Vector2(0.0, 760.0))
		_message_panel.size = Vector2(1920.0, 320.0)


## Script show/hide and initial dialogue use a fade, without manual sliding.
func set_frame_visible(value: bool, duration: float = 0.3) -> void:
	_cancel_frame_transition()
	_message_panel.position = _rest_position
	_message_panel.visible = true
	var alpha := 1.0 if value else 0.0
	_frame_finish = func() -> void:
		_rest_modulate.a = alpha
		_message_panel.modulate.a = alpha
		_message_panel.visible = value
	if duration <= 0.0:
		finish_frame_transition()
		return
	_frame_tween = create_tween()
	_frame_tween.tween_property(_message_panel, "modulate:a", alpha, duration)
	_frame_tween.finished.connect(finish_frame_transition)


## Player chrome slides and fades, retaining the resting frame even when hidden.
## Overlay callers use duration 0 to hide/restore synchronously.
func set_chrome_visible(value: bool, duration: float = 0.3) -> void:
	# Temporary slide offsets never become the resting frame state.
	finish_frame_transition()
	if value:
		_message_panel.visible = true
		_message_panel.position = _rest_position
		_message_panel.modulate = _rest_modulate
		if duration > 0.0:
			_message_panel.position += HIDE_OFFSET
			_message_panel.modulate.a = 0.0
	_frame_finish = func() -> void:
		_message_panel.position = _rest_position
		_message_panel.modulate = _rest_modulate
		_message_panel.visible = value
	if duration <= 0.0:
		finish_frame_transition()
		return
	_frame_tween = create_tween().set_parallel()
	_frame_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if value else Tween.EASE_IN)
	_frame_tween.tween_property(
		_message_panel, "position", _rest_position if value else _rest_position + HIDE_OFFSET, duration
	)
	_frame_tween.tween_property(_message_panel, "modulate:a", _rest_modulate.a if value else 0.0, duration)
	_frame_tween.finished.connect(finish_frame_transition)


func finish_frame_transition() -> void:
	var finish := _frame_finish
	_cancel_frame_transition()
	if finish.is_valid():
		finish.call()


func _cancel_frame_transition() -> void:
	if _frame_tween != null and _frame_tween.is_valid():
		_frame_tween.kill()
	_frame_tween = null
	_frame_finish = Callable()
