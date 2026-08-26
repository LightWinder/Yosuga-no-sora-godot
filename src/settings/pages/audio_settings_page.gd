class_name AudioSettingsPage
extends SettingsPageBase


## Audio-settings controller. All controls and layout are scene-owned; the
## only retained artwork is the selected character portrait.
const VOICE_DETAIL_INDICES: Array[int] = [0, 2, 1, 3, 4, 5, 6, 7, 10]
const VOICE_PORTRAITS: Array[Texture2D] = [
	preload("res://assets/content/settings/voices/portraits/sora.png"),
	preload("res://assets/content/settings/voices/portraits/nao.png"),
	preload("res://assets/content/settings/voices/portraits/akira.png"),
	preload("res://assets/content/settings/voices/portraits/kazuha.png"),
	preload("res://assets/content/settings/voices/portraits/motoka.png"),
	preload("res://assets/content/settings/voices/portraits/ryohei.png"),
	preload("res://assets/content/settings/voices/portraits/yahiro.png"),
	preload("res://assets/content/settings/voices/portraits/kozue.png"),
	preload("res://assets/content/settings/voices/portraits/npc.png"),
]

var _voice_choices := SettingsChoiceGroup.new()
var _detail_volumes: Array[float] = []
var _selected_voice := 0

@onready var _voice_buttons: Array[SettingsVoiceChoiceButton] = [
	%SoraVoice,
	%NaoVoice,
	%AkiraVoice,
	%KazuhaVoice,
	%MotokaVoice,
	%RyoheiVoice,
	%YahiroVoice,
	%KozueVoice,
	%NpcVoice,
]
@onready var _voice_portrait: TextureRect = %VoicePortrait
@onready var _voice_sample: SettingsVoiceSample = $VoiceSample
@onready var _voice_slider: SettingsKnobSlider = %voice_detail
@onready var _channel_sliders: Dictionary[StringName, SettingsKnobSlider] = {
	&"master_volume": %master_volume,
	&"voice_volume": %voice_volume,
	&"bgm_volume": %bgm_volume,
	&"env_se_volume": %env_se_volume,
	&"se_volume": %se_volume,
	&"movie_volume": %movie_volume,
}


func _ready() -> void:
	super._ready()
	_configure_voice_choices()
	register_setting_slider(_voice_slider)
	_voice_slider.value_changed.connect(_on_voice_volume_changed)
	_voice_slider.drag_ended.connect(_on_voice_drag_ended)
	for key in _channel_sliders:
		var slider := _channel_sliders[key]
		register_setting_slider(slider)
		slider.value_changed.connect(_on_channel_changed.bind(key))


func sync_from(settings: Dictionary) -> void:
	_detail_volumes.clear()
	var source_details: Array = settings.get("voice_detail_volumes", [])
	for index in SettingsModel.VOICE_DETAIL_NAMES.size():
		_detail_volumes.append(float(source_details[index]) if index < source_details.size() else 1.0)
	_refresh_voice_selection()
	for key in _channel_sliders:
		_channel_sliders[key].set_value_silent(float(settings.get(key, 1.0)) * 100.0)


func select_voice(index: int) -> void:
	if index < 0 or index >= _voice_buttons.size():
		return
	_selected_voice = index
	_refresh_voice_selection()


func selected_voice_detail_index() -> int:
	return VOICE_DETAIL_INDICES[_selected_voice]


func voice_button_count() -> int:
	return _voice_buttons.size()


func _configure_voice_choices() -> void:
	assert(_voice_buttons.size() == VOICE_DETAIL_INDICES.size())
	assert(VOICE_PORTRAITS.size() == VOICE_DETAIL_INDICES.size())
	for index in _voice_buttons.size():
		_voice_choices.add_choice(_voice_buttons[index], index)
	_voice_choices.value_selected.connect(_on_voice_selected)


func _refresh_voice_selection() -> void:
	_voice_choices.select_value(_selected_voice)
	_voice_portrait.texture = VOICE_PORTRAITS[_selected_voice]
	var detail := selected_voice_detail_index()
	_voice_slider.set_value_silent(_detail_volumes[detail] * 100.0 if detail < _detail_volumes.size() else 100.0)


func _on_voice_selected(value: Variant) -> void:
	select_voice(int(value))


func _on_voice_volume_changed(value: float) -> void:
	var detail := selected_voice_detail_index()
	if detail >= _detail_volumes.size():
		return
	var details := _detail_volumes.duplicate()
	details[detail] = value / 100.0
	_detail_volumes = details
	emit_patch({"voice_detail_volumes": details})


func _on_voice_drag_ended(_value_changed: bool) -> void:
	var detail := selected_voice_detail_index()
	var volume := _detail_volumes[detail] if detail < _detail_volumes.size() else 1.0
	_voice_sample.play_detail(detail, volume)


func _on_channel_changed(value: float, key: StringName) -> void:
	emit_patch({key: value / 100.0})
