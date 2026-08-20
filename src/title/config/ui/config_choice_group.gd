class_name ConfigChoiceGroup
extends RefCounted


## Mutually exclusive setting choices. Pages own setting keys and values;
## ConfigChoiceButton remains a presentation-only control.
signal value_selected(value: Variant)

var _buttons: Array[ConfigChoiceButton] = []
var _values: Array[Variant] = []


func add_choice(button: ConfigChoiceButton, value: Variant) -> void:
	_buttons.append(button)
	_values.append(value)
	button.pressed.connect(_on_button_pressed.bind(value))


func select_value(value: Variant) -> void:
	for index in _buttons.size():
		_buttons[index].selected = _values[index] == value


func set_visible(visible_value: bool) -> void:
	for button in _buttons:
		button.visible = visible_value


func _on_button_pressed(value: Variant) -> void:
	value_selected.emit(value)
