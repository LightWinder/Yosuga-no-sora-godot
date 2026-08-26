class_name SettingsKnobSlider
extends HSlider


## Native settings slider. Godot owns interaction, focus, keyboard input and
## accessibility; the reusable scene and Theme own presentation.
func _init() -> void:
	if theme_type_variation.is_empty():
		theme_type_variation = &"SettingsKnobSlider"
	min_value = 0.0
	max_value = 100.0
	step = 1.0
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func set_value_silent(next: float) -> void:
	set_value_no_signal(clampf(next, min_value, max_value))


func set_value_range(minimum: float, maximum: float) -> void:
	min_value = minimum
	max_value = maximum
	set_value_silent(value)


func step_by(delta: float) -> void:
	value += delta
