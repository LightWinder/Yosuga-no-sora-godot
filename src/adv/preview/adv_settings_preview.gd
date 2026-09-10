class_name AdvSettingsPreview
extends Control
## Fixed, silent settings demonstration. No scenario or gameplay state is used.

const SAMPLE_SPEAKER := "穹"
const SAMPLE_MESSAGE := "……这么长的文字，应该足够确认显示速度了吧？太快会来不及阅读，太慢又会让人有些着急。"
const SAMPLE_PORTRAIT: Texture2D = preload("res://assets/content/adv/characters/CA02_01T.PNG")

@onready var _dialogue_view: AdvDialogueView = %DialogueView
@onready var _replay_timer: Timer = %ReplayTimer

var _settings: Dictionary = SettingsModel.defaults()
var _demo_active := false


func configure(settings: Dictionary) -> void:
	assert(not is_inside_tree())
	_settings = SettingsModel.normalize(settings)


func _ready() -> void:
	_dialogue_view.set_interactive(false)
	_dialogue_view.set_speaker(SAMPLE_SPEAKER, true)
	_dialogue_view.set_message(SAMPLE_MESSAGE)
	_dialogue_view.reveal_finished.connect(_on_reveal_finished)
	_replay_timer.timeout.connect(_restart_sample)
	visibility_changed.connect(_sync_demo_visibility)
	apply_settings(_settings)
	_sync_demo_visibility()


func _exit_tree() -> void:
	_stop_demo()


func apply_settings(settings: Dictionary) -> void:
	_settings = SettingsModel.normalize(settings)
	if not is_node_ready():
		return
	_dialogue_view.set_frame_opacity(float(_settings["window_depth"]) / 100.0)
	_dialogue_view.set_portrait(SAMPLE_PORTRAIT if bool(_settings["portrait_visible"]) else null)
	_dialogue_view.set_message_font(AdvDialogueAppearance.message_font(int(_settings["font_type"])))
	_dialogue_view.set_message_color(AdvDialogueAppearance.message_color(true, bool(_settings["read_color"])))
	# Preserve visible characters. An already running replay wait is untouched;
	# auto_speed is read only when the next reveal completes.
	_dialogue_view.set_reveal_speed(int(_settings["message_speed"]))


func _sync_demo_visibility() -> void:
	if not is_node_ready():
		return
	var active := is_visible_in_tree()
	if active == _demo_active:
		return
	_demo_active = active
	if active:
		_restart_sample()
	else:
		_stop_demo()


func _stop_demo() -> void:
	_demo_active = false
	_replay_timer.stop()
	_dialogue_view.cancel_reveal()


func _restart_sample() -> void:
	if not _demo_active:
		return
	_replay_timer.stop()
	_dialogue_view.reveal_message(SAMPLE_MESSAGE, int(_settings["message_speed"]))


func _on_reveal_finished() -> void:
	if _demo_active:
		# Timer.start(0) reuses its previous duration, so zero means next frame.
		_replay_timer.start(maxf(float(_settings["auto_speed"]) / 1000.0, 0.001))
