@tool
class_name AdvDialogueIconButton
extends TextureButton
## A one-texture dialogue shortcut. The source PNG stored white and gray
## frames side by side; this component keeps one SVG and tints it per state.


const NORMAL_TINT := Color(1.0, 1.0, 1.0, 0.78)
const ACTIVE_TINT := Color(0.60, 0.60, 0.60, 0.78)
const DISABLED_TINT := Color(0.60, 0.60, 0.60, 0.50)

var _pointer_down := false


func _ready() -> void:
	mouse_entered.connect(_refresh_tint)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_refresh_tint)
	focus_exited.connect(_refresh_tint)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	_refresh_tint()


func set_action_enabled(enabled: bool) -> void:
	disabled = not enabled
	if disabled:
		_pointer_down = false
	_refresh_tint()


func refresh_tint() -> void:
	_refresh_tint()


func _on_button_down() -> void:
	_pointer_down = true
	_refresh_tint()


func _on_button_up() -> void:
	_pointer_down = false
	_refresh_tint()


func _on_mouse_exited() -> void:
	_pointer_down = false
	_refresh_tint()


func _refresh_tint() -> void:
	if disabled:
		self_modulate = DISABLED_TINT
	elif _pointer_down or is_hovered() or has_focus():
		self_modulate = ACTIVE_TINT
	else:
		self_modulate = NORMAL_TINT
	var icon := get_node_or_null("Icon") as CanvasItem
	if icon != null:
		icon.self_modulate = self_modulate
