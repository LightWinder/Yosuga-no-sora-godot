class_name AdvQuickSettingsPopovers
extends Control


signal settings_preview_requested(settings: Dictionary)
signal settings_commit_requested(settings: Dictionary)

const ANIMATION_SECONDS := 0.15
const ANIMATION_OFFSET := Vector2(0.0, 18.0)
const AUDIO_KEYS: Array[StringName] = [
	&"master_volume",
	&"bgm_volume",
	&"voice_volume",
	&"se_volume",
	&"env_se_volume",
]

@onready var _audio_panel: Control = %AudioQuickSettingsPanel
@onready var _text_panel: Control = %TextQuickSettingsPanel
@onready var _audio_backdrop: AdvQuickSettingsBackdrop = %AudioQuickSettingsBackdrop
@onready var _text_backdrop: AdvQuickSettingsBackdrop = %TextQuickSettingsBackdrop
@onready var _audio_sliders: Dictionary[StringName, SettingsKnobSlider] = {
	&"master_volume": %master_volume,
	&"bgm_volume": %bgm_volume,
	&"voice_volume": %voice_volume,
	&"se_volume": %se_volume,
	&"env_se_volume": %env_se_volume,
}
@onready var _message_speed_slider: SettingsKnobSlider = %message_speed
@onready var _auto_speed_slider: SettingsKnobSlider = %auto_speed
@onready var _window_depth_slider: SettingsKnobSlider = %window_depth
@onready var _skip_read_choice: CheckBox = %SkipReadChoice
@onready var _skip_all_choice: CheckBox = %SkipAllChoice
@onready var _commit_timer: Timer = %QuickSettingsCommitTimer

var _settings: Dictionary = SettingsModel.defaults()
var _active_panel: Control
var _panel_tween: Tween
var _panel_rest_positions: Dictionary = {}
var _pending_commit := false


func _ready() -> void:
	_panel_rest_positions[_audio_panel] = _audio_panel.position
	_panel_rest_positions[_text_panel] = _text_panel.position
	_hide_immediately(_audio_panel)
	_hide_immediately(_text_panel)
	for key in AUDIO_KEYS:
		var slider := _audio_sliders[key]
		slider.value_changed.connect(_on_audio_value_changed.bind(key))
		slider.drag_ended.connect(_on_slider_drag_ended)
	_message_speed_slider.value_changed.connect(_on_message_speed_changed)
	_auto_speed_slider.value_changed.connect(_on_auto_speed_changed)
	_window_depth_slider.value_changed.connect(_on_window_depth_changed)
	for slider in [_message_speed_slider, _auto_speed_slider, _window_depth_slider]:
		slider.drag_ended.connect(_on_slider_drag_ended)
	_skip_read_choice.pressed.connect(_on_skip_read_pressed)
	_skip_all_choice.pressed.connect(_on_skip_all_pressed)
	_commit_timer.timeout.connect(flush_pending_commit)
	sync_from(_settings)


func _exit_tree() -> void:
	_kill_panel_tween()
	flush_pending_commit()


func sync_from(settings: Dictionary) -> void:
	_settings = SettingsModel.normalize(settings)
	for key in AUDIO_KEYS:
		_audio_sliders[key].set_value_silent(float(_settings.get(key, 1.0)) * 100.0)
	# The source frame stores both speed values in the inverse direction.
	_message_speed_slider.set_value_silent(100.0 - float(_settings.get("message_speed", 5)))
	_auto_speed_slider.set_value_silent(
		100.0 - float(_settings.get("auto_speed", 5000)) / 100.0
	)
	var depth := float(_settings.get("window_depth", 50))
	_window_depth_slider.set_value_silent(depth)
	_skip_read_choice.set_pressed_no_signal(bool(_settings.get("read_skip", true)))
	_skip_all_choice.set_pressed_no_signal(not bool(_settings.get("read_skip", true)))
	_audio_backdrop.set_depth(depth / 100.0)
	_text_backdrop.set_depth(depth / 100.0)


func set_interactive(enabled: bool) -> void:
	if not enabled:
		close()
	for panel in [_audio_panel, _text_panel]:
		panel.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	for slider in _all_sliders():
		slider.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
		slider.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	for choice in [_skip_read_choice, _skip_all_choice]:
		choice.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
		choice.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE


func toggle_audio() -> void:
	_toggle_panel(_audio_panel)


func toggle_text() -> void:
	_toggle_panel(_text_panel)


func close() -> bool:
	flush_pending_commit()
	if _active_panel == null:
		return false
	var panel := _active_panel
	_active_panel = null
	_animate_hide(panel)
	return true


func has_open() -> bool:
	return _active_panel != null


func active_panel_name() -> StringName:
	return _active_panel.name if _active_panel != null else &""


func current_settings() -> Dictionary:
	return _settings.duplicate(true)


func _all_sliders() -> Array[SettingsKnobSlider]:
	var sliders: Array[SettingsKnobSlider] = []
	for key in AUDIO_KEYS:
		sliders.append(_audio_sliders[key])
	sliders.append_array([_message_speed_slider, _auto_speed_slider, _window_depth_slider])
	return sliders


func flush_pending_commit() -> void:
	if not _pending_commit:
		return
	_pending_commit = false
	_commit_timer.stop()
	settings_commit_requested.emit(_settings.duplicate(true))


func _toggle_panel(panel: Control) -> void:
	if _active_panel == panel:
		close()
		return
	flush_pending_commit()
	if _active_panel != null:
		_hide_immediately(_active_panel)
	_active_panel = panel
	_animate_show(panel)


func _animate_show(panel: Control) -> void:
	_kill_panel_tween()
	var rest: Vector2 = _panel_rest_positions[panel]
	panel.position = rest + ANIMATION_OFFSET
	panel.modulate.a = 0.0
	panel.visible = true
	_panel_tween = create_tween().set_parallel()
	_panel_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_panel_tween.tween_property(panel, "position", rest, ANIMATION_SECONDS)
	_panel_tween.tween_property(panel, "modulate:a", 1.0, ANIMATION_SECONDS)
	_panel_tween.finished.connect(_clear_finished_tween.bind(_panel_tween))


func _animate_hide(panel: Control) -> void:
	_kill_panel_tween()
	var rest: Vector2 = _panel_rest_positions[panel]
	_panel_tween = create_tween().set_parallel()
	_panel_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_panel_tween.tween_property(panel, "position", rest + ANIMATION_OFFSET, ANIMATION_SECONDS)
	_panel_tween.tween_property(panel, "modulate:a", 0.0, ANIMATION_SECONDS)
	_panel_tween.finished.connect(_finish_hiding.bind(panel, _panel_tween))


func _finish_hiding(panel: Control, tween: Tween) -> void:
	if tween != _panel_tween:
		return
	_panel_tween = null
	if panel != _active_panel:
		_hide_immediately(panel)


func _clear_finished_tween(tween: Tween) -> void:
	if tween == _panel_tween:
		_panel_tween = null


func _hide_immediately(panel: Control) -> void:
	panel.visible = false
	panel.position = _panel_rest_positions.get(panel, panel.position)
	panel.modulate.a = 1.0


func _kill_panel_tween() -> void:
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel_tween = null


func _on_audio_value_changed(value: float, key: StringName) -> void:
	_apply_value(key, value / 100.0)


func _on_message_speed_changed(value: float) -> void:
	_apply_value(&"message_speed", int(100.0 - value))


func _on_auto_speed_changed(value: float) -> void:
	_apply_value(&"auto_speed", int((100.0 - value) * 100.0))


func _on_window_depth_changed(value: float) -> void:
	_apply_value(&"window_depth", int(value))


func _on_skip_read_pressed() -> void:
	_apply_value(&"read_skip", true, true)


func _on_skip_all_pressed() -> void:
	_apply_value(&"read_skip", false, true)


func _on_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		flush_pending_commit()


func _apply_value(key: StringName, value: Variant, commit_now := false) -> void:
	_settings[key] = value
	_settings = SettingsModel.normalize(_settings)
	if key == &"window_depth":
		var depth := float(_settings.get("window_depth", 50)) / 100.0
		_audio_backdrop.set_depth(depth)
		_text_backdrop.set_depth(depth)
	settings_preview_requested.emit(_settings.duplicate(true))
	_pending_commit = true
	if commit_now:
		flush_pending_commit()
	else:
		_commit_timer.start()
