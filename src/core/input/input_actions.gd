class_name InputActions
extends RefCounted


const ADVANCE: StringName = &"vn_advance"
const CANCEL: StringName = &"vn_cancel"
const CONFIRM: StringName = &"vn_confirm"


## Keeps input names in one place so screens depend on intent, not devices.
## The project settings contain the same actions for editor discoverability;
## this method is intentionally idempotent for tests and embedded scenes.
static func ensure_actions() -> void:
	_ensure_action(ADVANCE)
	_ensure_action(CANCEL)
	_ensure_action(CONFIRM)


static func _ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)


static func is_pressed(event: InputEvent, action: StringName) -> bool:
	return event.is_action_pressed(action, false)
