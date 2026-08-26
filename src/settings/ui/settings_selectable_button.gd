@tool
class_name SettingsSelectableButton
extends Button


## Shared state contract for mutually exclusive settings buttons. Concrete
## controls decide how the selected state is rendered.
@export var selected: bool:
	get:
		return _selected
	set(value):
		if _selected == value:
			return
		_selected = value
		_selection_changed()

var _selected := false


func _selection_changed() -> void:
	queue_redraw()
