class_name ConfigAudioPage
extends ConfigPageBase


## Audio tab: nine voice character buttons with portraits, per-character volume
## and six global channel sliders; sample voice plays after the voice slider
## drag ends (source playVoiceVolumeSample).
signal sample_requested(detail_index: int)

const VOICE_ROOT := "res://assets/content/settings/voices/"
const VOICE_PORTRAIT_ROOT := VOICE_ROOT + "portraits/"
const VOICE_BUTTONS: Array[Dictionary] = [
	{"file": "sora", "detail": 0, "pos": Vector2(389, 393)},
	{"file": "nao", "detail": 2, "pos": Vector2(632, 393)},
	{"file": "akira", "detail": 1, "pos": Vector2(883, 393)},
	{"file": "kazuha", "detail": 3, "pos": Vector2(389, 473)},
	{"file": "motoka", "detail": 4, "pos": Vector2(632, 473)},
	{"file": "ryohei", "detail": 5, "pos": Vector2(883, 473)},
	{"file": "yahiro", "detail": 6, "pos": Vector2(389, 561)},
	{"file": "kozue", "detail": 7, "pos": Vector2(632, 561)},
	{"file": "npc", "detail": 10, "pos": Vector2(883, 561)},
]
const CHANNEL_SLIDERS: Array[Dictionary] = [
	{"key": "master_volume", "x": 1374.0, "y": 406.0, "w": 422.0},
	{"key": "voice_volume", "x": 1429.0, "y": 490.0, "w": 367.0},
	{"key": "bgm_volume", "x": 1429.0, "y": 545.0, "w": 367.0},
	{"key": "env_se_volume", "x": 1429.0, "y": 602.0, "w": 367.0},
	{"key": "se_volume", "x": 1429.0, "y": 661.0, "w": 367.0},
	{"key": "movie_volume", "x": 1429.0, "y": 716.0, "w": 367.0},
]

var _voice_buttons: Array[ConfigToggleButton] = []
var _voice_portrait: TextureRect
var _voice_slider: ConfigKnobSlider
var _channel_sliders: Dictionary = {}
var _detail_volumes: Array[float] = []
var _selected_voice := 0


func _ready() -> void:
	super._ready()
	add_page_background(VOICE_ROOT + "bg.png")
	for index in VOICE_BUTTONS.size():
		var entry: Dictionary = VOICE_BUTTONS[index]
		var button := add_strip_toggle(VOICE_ROOT + str(entry.file) + ".png", entry.pos)
		button.name = "%sVoice" % str(entry.file).to_pascal_case()
		button.pressed.connect(_on_voice_pressed.bind(index))
		_voice_buttons.append(button)
	_voice_portrait = TextureRect.new()
	_voice_portrait.name = "VoicePortrait"
	_voice_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_voice_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_voice_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_voice_portrait)
	# The source trapezoid grows from 115% to 155% (not the 100%→130%
	# horizontal slider scale used by the six fixed channel tracks).
	_voice_slider = add_slider("voice_detail", Vector2(437, 715), Vector2(1051, 710), 1.15, 1.55)
	_voice_slider.value_changed.connect(_on_voice_volume_changed)
	_voice_slider.drag_ended.connect(_on_voice_drag_ended)
	for entry in CHANNEL_SLIDERS:
		var key := String(entry.key)
		var center_y := float(entry.y) + 4.0
		var slider := add_slider(key, Vector2(entry.x, center_y), Vector2(float(entry.x) + float(entry.w), center_y), 1.0, 1.0)
		slider.value_changed.connect(_on_channel_changed.bind(key))
		_channel_sliders[key] = slider


func sync_from(settings: Dictionary) -> void:
	_detail_volumes.clear()
	var source_details: Array = settings.get("voice_detail_volumes", [])
	for index in TitleSettingsModel.VOICE_DETAIL_NAMES.size():
		_detail_volumes.append(float(source_details[index]) if index < source_details.size() else 1.0)
	_refresh_voice_selection()
	for key in _channel_sliders:
		(_channel_sliders[key] as ConfigKnobSlider).set_value_silent(float(settings.get(key, 1.0)) * 100.0)


func select_voice(index: int) -> void:
	if index < 0 or index >= VOICE_BUTTONS.size():
		return
	_selected_voice = index
	_refresh_voice_selection()


func selected_voice_detail_index() -> int:
	return int(VOICE_BUTTONS[_selected_voice].detail)


func voice_button_count() -> int:
	return _voice_buttons.size()


func find_voice_slider() -> ConfigKnobSlider:
	return _voice_slider


func _refresh_voice_selection() -> void:
	for index in _voice_buttons.size():
		_voice_buttons[index].selected = index == _selected_voice
	var entry: Dictionary = VOICE_BUTTONS[_selected_voice]
	var portrait := load(VOICE_PORTRAIT_ROOT + str(entry.file) + ".png") as Texture2D
	_voice_portrait.texture = portrait
	if portrait != null:
		# EXPAND_IGNORE_SIZE keeps source pixels crisp, but it does not infer a
		# Control size. Set the image-sized rect explicitly before positioning;
		# otherwise the selected portrait remains a zero-sized blank node.
		_voice_portrait.size = Vector2(portrait.get_width(), portrait.get_height())
		var x := 81.0 + (288.0 - portrait.get_width()) / 2.0
		var y: float
		if str(entry.file) == "npc":
			y = 378.0 + (452.0 - portrait.get_height()) / 2.0
		else:
			y = 826.0 - portrait.get_height()
		_voice_portrait.position = Vector2(x, y)
	else:
		_voice_portrait.size = Vector2.ZERO
	var detail := int(entry.detail)
	_voice_slider.set_value_silent(_detail_volumes[detail] * 100.0 if detail < _detail_volumes.size() else 100.0)


func _on_voice_pressed(index: int) -> void:
	select_voice(index)


func _on_voice_volume_changed(value: float) -> void:
	var detail := selected_voice_detail_index()
	if detail >= _detail_volumes.size():
		return
	var details := _detail_volumes.duplicate()
	details[detail] = value / 100.0
	_detail_volumes = details
	emit_patch({"voice_detail_volumes": details})


func _on_voice_drag_ended(_value_changed: bool) -> void:
	sample_requested.emit(selected_voice_detail_index())


func _on_channel_changed(value: float, key: String) -> void:
	emit_patch({key: value / 100.0})
