class_name StartupInput
extends RefCounted


## Returns true exactly once for a user-level advance gesture.
##
## Touches use Godot's native touch-to-mouse path so every Control gets the
## same GUI behavior on desktop and mobile. The emulated mouse event is
## filtered here because the original ScreenTouch is already the startup
## gesture; otherwise one tap could advance twice.
static func is_advance_event(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return event.pressed
	if event is InputEventMouseButton:
		return not _is_emulated_mouse(event) and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	return InputActions.is_pressed(event, InputActions.ADVANCE)


static func is_cancel_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return not _is_emulated_mouse(event) and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT
	return InputActions.is_pressed(event, InputActions.CANCEL)


static func is_confirm_event(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return event.pressed
	if event is InputEventMouseButton:
		return not _is_emulated_mouse(event) and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	return InputActions.is_pressed(event, InputActions.CONFIRM)


static func _is_emulated_mouse(event: InputEventMouseButton) -> bool:
	return event.device == InputEvent.DEVICE_ID_EMULATION
