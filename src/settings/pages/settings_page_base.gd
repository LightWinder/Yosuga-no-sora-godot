class_name SettingsPageBase
extends Control


## Shared content-area page for the settings tabs. The outer PanelContainer
## owns each page's final size; pages emit typed setting patches while the shell
## owns values, preview and persistence.
signal patch_requested(patch: Dictionary, immediate: bool)
signal commit_requested

var _setting_sliders: Array[SettingsKnobSlider] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func sync_from(_settings: Dictionary) -> void:
	pass


func find_setting_slider(key: String) -> SettingsKnobSlider:
	for slider in _setting_sliders:
		if slider.name == key:
			return slider
	return null


func register_setting_slider(slider: SettingsKnobSlider) -> void:
	if slider != null and not _setting_sliders.has(slider):
		_setting_sliders.append(slider)
		slider.drag_ended.connect(func(_changed: bool) -> void: commit_requested.emit())


func emit_patch(patch: Dictionary, immediate := false) -> void:
	patch_requested.emit(patch, immediate)
